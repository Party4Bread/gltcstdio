//! Parameter values, and the coercion the bank's declared types imply.

use std::collections::BTreeMap;

use serde::Deserialize;

/// A value a caller can set a parameter to.
///
/// The bank declares a GLSL type for every parameter, so a caller may pass
/// whatever is convenient -- a number for a `float`, three numbers for a
/// `vec3` -- and `coerce` puts it into the declared shape.
#[derive(Debug, Clone, PartialEq)]
pub enum Value {
    Float(f32),
    Int(i32),
    Bool(bool),
    /// A vector, a matrix in row-major order, or a flat array.
    Seq(Vec<f32>),
    /// A nested list, as an array parameter's elements arrive.
    List(Vec<Value>),
    Str(String),
}

impl Value {
    pub fn as_f32(&self) -> Option<f32> {
        match self {
            Value::Float(v) => Some(*v),
            Value::Int(v) => Some(*v as f32),
            Value::Bool(v) => Some(if *v { 1.0 } else { 0.0 }),
            Value::Seq(v) => v.first().copied(),
            _ => None,
        }
    }

    /// The value flattened to floats, in declaration order.
    pub fn flatten(&self) -> Vec<f32> {
        match self {
            Value::Float(v) => vec![*v],
            Value::Int(v) => vec![*v as f32],
            Value::Bool(v) => vec![if *v { 1.0 } else { 0.0 }],
            Value::Seq(v) => v.clone(),
            Value::List(items) => items.iter().flat_map(|i| i.flatten()).collect(),
            Value::Str(_) => Vec::new(),
        }
    }
}

impl From<f32> for Value {
    fn from(v: f32) -> Self {
        Value::Float(v)
    }
}
impl From<f64> for Value {
    fn from(v: f64) -> Self {
        Value::Float(v as f32)
    }
}
impl From<i32> for Value {
    fn from(v: i32) -> Self {
        Value::Int(v)
    }
}
impl From<bool> for Value {
    fn from(v: bool) -> Self {
        Value::Bool(v)
    }
}
impl From<&str> for Value {
    fn from(v: &str) -> Self {
        Value::Str(v.to_string())
    }
}
impl<const N: usize> From<[f32; N]> for Value {
    fn from(v: [f32; N]) -> Self {
        Value::Seq(v.to_vec())
    }
}
impl From<Vec<f32>> for Value {
    fn from(v: Vec<f32>) -> Self {
        Value::Seq(v)
    }
}

/// Values by parameter name.
pub type Params = BTreeMap<String, Value>;

/// Build a [`Params`] from pairs: `params![("intensity", 0.5), ("mode", 2)]`.
#[macro_export]
macro_rules! params {
    ($(($k:expr, $v:expr)),* $(,)?) => {{
        let mut m = $crate::Params::new();
        $( m.insert($k.to_string(), $crate::Value::from($v)); )*
        m
    }};
}

impl<'de> Deserialize<'de> for Value {
    fn deserialize<D: serde::Deserializer<'de>>(d: D) -> Result<Self, D::Error> {
        let raw = serde_json::Value::deserialize(d)?;
        Ok(from_json(&raw))
    }
}

impl Value {
    /// A JSON value in the shape a caller would pass.
    pub fn from_json(raw: &serde_json::Value) -> Value {
        from_json(raw)
    }
}

/// A value back as JSON, in the shape `from_json` reads.
///
/// The round trip is exact for `f32`: a float goes out as the `f64` nearest
/// it and comes back as the same `f32`.
pub fn to_json(value: &Value) -> serde_json::Value {
    match value {
        Value::Bool(b) => serde_json::Value::Bool(*b),
        Value::Str(s) => serde_json::Value::String(s.clone()),
        Value::Int(i) => serde_json::Value::from(*i),
        Value::Float(f) => serde_json::Number::from_f64(*f as f64)
            .map(serde_json::Value::Number)
            .unwrap_or(serde_json::Value::Null),
        Value::Seq(items) => serde_json::Value::Array(
            items
                .iter()
                .map(|f| to_json(&Value::Float(*f)))
                .collect(),
        ),
        Value::List(items) => serde_json::Value::Array(items.iter().map(to_json).collect()),
    }
}

/// The bank's JSON defaults, in the same shapes a caller would pass.
pub fn from_json(raw: &serde_json::Value) -> Value {
    match raw {
        serde_json::Value::Bool(b) => Value::Bool(*b),
        serde_json::Value::String(s) => Value::Str(s.clone()),
        serde_json::Value::Number(n) => {
            if n.is_f64() && n.as_f64().map(|v| v.fract() != 0.0).unwrap_or(false) {
                Value::Float(n.as_f64().unwrap() as f32)
            } else if let Some(i) = n.as_i64() {
                Value::Int(i as i32)
            } else {
                Value::Float(n.as_f64().unwrap_or(0.0) as f32)
            }
        }
        serde_json::Value::Array(items) => {
            let converted: Vec<Value> = items.iter().map(from_json).collect();
            if converted.iter().all(|v| matches!(v, Value::Float(_) | Value::Int(_) | Value::Bool(_))) {
                Value::Seq(converted.iter().filter_map(|v| v.as_f32()).collect())
            } else {
                Value::List(converted)
            }
        }
        serde_json::Value::Null => Value::Float(0.0),
        serde_json::Value::Object(_) => Value::Float(0.0),
    }
}

/// How many floats a GLSL type holds, and how many elements if it is an array.
pub fn type_shape(ty: &str) -> (usize, Option<usize>) {
    if let Some((elem, len)) = array_spec(ty) {
        let (n, _) = type_shape(elem);
        return (n * len, Some(len));
    }
    let n = match ty {
        "float" | "int" | "bool" => 1,
        "vec2" => 2,
        "vec3" => 3,
        "vec4" => 4,
        "mat3" => 9,
        "mat4" => 16,
        _ => 1,
    };
    (n, None)
}

/// `("vec4", 32)` for `vec4[32]`.
pub fn array_spec(ty: &str) -> Option<(&str, usize)> {
    let open = ty.find('[')?;
    let close = ty.find(']')?;
    let len = ty[open + 1..close].parse().ok()?;
    Some((&ty[..open], len))
}

/// Fit `value` to the declared type, padding or truncating as needed.
pub fn coerce(ty: &str, value: &Value) -> Vec<f32> {
    let (want, _) = type_shape(ty);
    let mut flat = value.flatten();
    // A matrix given as one number is that number down the diagonal, which is
    // how the bank stores an identity transform's default.
    if matches!(ty, "mat3" | "mat4") && flat.len() == 1 {
        let n = if ty == "mat3" { 3 } else { 4 };
        let d = flat[0];
        flat = (0..n * n).map(|i| if i % (n + 1) == 0 { d } else { 0.0 }).collect();
    }
    flat.resize(want, 0.0);
    flat
}
