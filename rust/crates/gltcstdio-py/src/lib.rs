//! Python bindings for `gltcstdio`.
//!
//! Images cross the boundary as `bytes` of RGBA8 with an explicit width and
//! height, which needs no array protocol on either side; the Python wrapper
//! in `gltcstdio_rs/__init__.py` turns those into numpy arrays or PIL
//! images for callers who want them.

use std::collections::HashMap;

use gltcstdio::{bank, cpu, Backend, Fidelity, Image, Params, Renderer, Value};
use pyo3::exceptions::{PyRuntimeError, PyValueError};
use pyo3::prelude::*;
use pyo3::types::{PyBytes, PyDict, PyList, PyString};

fn to_err(e: gltcstdio::Error) -> PyErr {
    PyRuntimeError::new_err(e.to_string())
}

/// Turn a Python object into a parameter value.
fn value_from(obj: &Bound<'_, PyAny>) -> PyResult<Value> {
    if let Ok(s) = obj.cast::<PyString>() {
        return Ok(Value::Str(s.extract()?));
    }
    if let Ok(b) = obj.extract::<bool>() {
        return Ok(Value::Bool(b));
    }
    if let Ok(i) = obj.extract::<i64>() {
        return Ok(Value::Int(i as i32));
    }
    if let Ok(f) = obj.extract::<f64>() {
        return Ok(Value::Float(f as f32));
    }
    if let Ok(seq) = obj.extract::<Vec<f64>>() {
        return Ok(Value::Seq(seq.into_iter().map(|v| v as f32).collect()));
    }
    if let Ok(rows) = obj.extract::<Vec<Vec<f64>>>() {
        // A matrix arrives row by row and is stored the same way.
        return Ok(Value::Seq(
            rows.into_iter().flatten().map(|v| v as f32).collect(),
        ));
    }
    Err(PyValueError::new_err(format!(
        "cannot use {} as a parameter value",
        obj.get_type().name()?
    )))
}

fn params_from(dict: Option<&Bound<'_, PyDict>>) -> PyResult<Params> {
    let mut out = Params::new();
    if let Some(d) = dict {
        for (k, v) in d.iter() {
            out.insert(k.extract::<String>()?, value_from(&v)?);
        }
    }
    Ok(out)
}

fn backend_name(b: Backend) -> &'static str {
    match b {
        Backend::Gl => "gpu",
        Backend::Cpu => "cpu",
        Backend::Graph => "graph",
    }
}

fn fidelity_name(f: Fidelity) -> &'static str {
    match f {
        Fidelity::Extracted => "extracted",
        Fidelity::Recovered => "recovered",
        Fidelity::Reimplemented => "reimplemented",
    }
}

/// An RGBA8 image.
#[pyclass(name = "Image", module = "gltcstdio_rs", from_py_object)]
#[derive(Clone)]
struct PyImage {
    inner: Image,
}

#[pymethods]
impl PyImage {
    /// `Image(width, height, rgba_bytes)`.
    #[new]
    fn new(width: u32, height: u32, data: &[u8]) -> PyResult<Self> {
        let want = width as usize * height as usize * 4;
        if data.len() != want {
            return Err(PyValueError::new_err(format!(
                "expected {want} bytes of RGBA8, got {}",
                data.len()
            )));
        }
        Ok(Self {
            inner: Image::new(width, height, data.to_vec()),
        })
    }

    #[getter]
    fn width(&self) -> u32 {
        self.inner.width
    }

    #[getter]
    fn height(&self) -> u32 {
        self.inner.height
    }

    /// The pixels, as RGBA8 bytes row by row.
    #[getter]
    fn data<'py>(&self, py: Python<'py>) -> Bound<'py, PyBytes> {
        PyBytes::new(py, &self.inner.data)
    }

    fn __repr__(&self) -> String {
        format!("Image({}x{})", self.inner.width, self.inner.height)
    }
}

/// Renders filters; holds the GPU device, so keep one around.
#[pyclass(name = "Renderer", module = "gltcstdio_rs", unsendable)]
struct PyRenderer {
    inner: Renderer,
}

#[pymethods]
impl PyRenderer {
    /// Open a GPU device, falling back to CPU-only if there is none.
    #[new]
    #[pyo3(signature = (gpu = true))]
    fn new(gpu: bool) -> PyResult<Self> {
        let inner = if gpu {
            Renderer::new_blocking().map_err(to_err)?
        } else {
            Renderer::cpu_only()
        };
        Ok(Self { inner })
    }

    /// Whether a GPU device is open.
    #[getter]
    fn has_gpu(&self) -> bool {
        self.inner.has_gpu()
    }

    /// Apply a filter, optionally through a preset and with extra inputs.
    #[pyo3(signature = (filter_id, image, params = None, preset = None, inputs = None))]
    fn apply(
        &mut self,
        filter_id: &str,
        image: &PyImage,
        params: Option<&Bound<'_, PyDict>>,
        preset: Option<&str>,
        inputs: Option<&Bound<'_, PyDict>>,
    ) -> PyResult<PyImage> {
        let values = params_from(params)?;
        let out = match (preset, inputs) {
            (Some(name), None) => self
                .inner
                .apply_preset(filter_id, &image.inner, name, &values),
            (_, Some(extra)) => {
                let mut bound: HashMap<String, Image> = HashMap::new();
                for (k, v) in extra.iter() {
                    let img: PyImage = v.extract()?;
                    bound.insert(k.extract::<String>()?, img.inner);
                }
                self.inner
                    .apply_with_inputs(filter_id, &image.inner, &values, &bound)
            }
            _ => self.inner.apply(filter_id, &image.inner, &values),
        };
        Ok(PyImage {
            inner: out.map_err(to_err)?,
        })
    }
}

/// Every filter id in the bank.
#[pyfunction]
fn list_filters(py: Python<'_>) -> Bound<'_, PyList> {
    let ids: Vec<&str> = bank().ids().collect();
    PyList::new(py, ids).expect("filter ids are strings")
}

/// A filter's metadata: name, category, backend, parameters and presets.
#[pyfunction]
fn describe<'py>(py: Python<'py>, filter_id: &str) -> PyResult<Bound<'py, PyDict>> {
    let spec = bank()
        .get(filter_id)
        .ok_or_else(|| PyValueError::new_err(format!("no filter named {filter_id:?}")))?;

    let out = PyDict::new(py);
    out.set_item("id", &spec.id)?;
    out.set_item("name", &spec.name)?;
    out.set_item("category", &spec.category)?;
    out.set_item("backend", backend_name(spec.backend))?;
    out.set_item("fidelity", fidelity_name(spec.fidelity))?;
    out.set_item("inputs", spec.inputs)?;
    out.set_item("extra_inputs", spec.extra_inputs.clone())?;

    let params = PyList::empty(py);
    for p in &spec.params {
        let entry = PyDict::new(py);
        entry.set_item("name", &p.name)?;
        entry.set_item("type", &p.ty)?;
        entry.set_item("label", &p.label)?;
        entry.set_item("widget", &p.widget)?;
        if let Some(min) = p.min {
            entry.set_item("min", min)?;
        }
        if let Some(max) = p.max {
            entry.set_item("max", max)?;
        }
        if let Some(raw) = &p.default {
            entry.set_item("default", json_to_py(py, raw)?)?;
        }
        params.append(entry)?;
    }
    out.set_item("params", params)?;
    out.set_item(
        "presets",
        spec.presets.iter().map(|p| p.name.clone()).collect::<Vec<_>>(),
    )?;
    Ok(out)
}

fn json_to_py<'py>(py: Python<'py>, raw: &serde_json::Value) -> PyResult<Bound<'py, PyAny>> {
    Ok(match raw {
        serde_json::Value::Null => py.None().into_bound(py),
        serde_json::Value::Bool(b) => b.into_pyobject(py)?.to_owned().into_any(),
        serde_json::Value::Number(n) => {
            if let Some(i) = n.as_i64() {
                i.into_pyobject(py)?.into_any()
            } else {
                n.as_f64().unwrap_or(0.0).into_pyobject(py)?.into_any()
            }
        }
        serde_json::Value::String(s) => s.into_pyobject(py)?.into_any(),
        serde_json::Value::Array(items) => {
            let list = PyList::empty(py);
            for item in items {
                list.append(json_to_py(py, item)?)?;
            }
            list.into_any()
        }
        serde_json::Value::Object(map) => {
            let dict = PyDict::new(py);
            for (k, v) in map {
                dict.set_item(k, json_to_py(py, v)?)?;
            }
            dict.into_any()
        }
    })
}

/// Every category in the bank.
#[pyfunction]
fn categories() -> Vec<String> {
    bank().categories().into_iter().map(String::from).collect()
}

/// Filter ids that have a CPU implementation.
#[pyfunction]
fn cpu_filters() -> Vec<String> {
    cpu::ids().into_iter().map(String::from).collect()
}

#[pymodule]
fn _native(m: &Bound<'_, PyModule>) -> PyResult<()> {
    m.add_class::<PyImage>()?;
    m.add_class::<PyRenderer>()?;
    m.add_function(wrap_pyfunction!(list_filters, m)?)?;
    m.add_function(wrap_pyfunction!(describe, m)?)?;
    m.add_function(wrap_pyfunction!(categories, m)?)?;
    m.add_function(wrap_pyfunction!(cpu_filters, m)?)?;
    m.add("__version__", env!("CARGO_PKG_VERSION"))?;
    Ok(())
}
