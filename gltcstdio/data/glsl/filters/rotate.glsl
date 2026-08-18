vec4 rotateSmart(vec2 uv, vec2 outPos, int rotateMode, vec2 sourceDim, vec2 includedRect, vec4 colorOut, mat3 viewTransform) {
            float ratio = sourceDim.x/sourceDim.y;
            vec2 boundA = abs(tf(viewTransform, vec2(ratio, 1.)));
            vec2 boundB = abs(tf(viewTransform, vec2(ratio, -1.)));
            vec2 bounds = vec2(max(boundA.x, boundB.x), max(boundA.y, boundB.y));

            if (rotateMode<=1) {
                vec2 u = uv;
                bool inside = abs(u.x)<=ratio && abs(u.y)<=1.0; 
                return (inside||rotateMode==1) ? __source__(uv) : mergeColor(__source__(uv), colorOut);//__source__(uv);
            }
            if (rotateMode==3) {
                vec2 bounds2 = abs(tf(viewTransform, includedRect));
                vec2 v = tf(viewTransform, uv)*bounds.y;
                vec2 delta = abs(abs(v)-bounds2);
                //if (min(delta.x, delta.y)<0.01) return vec4(1., 0., 0., 1.);
                vec2 u = uv  * abs(bounds2.y);
                return __source__(u);
            }
            
            vec2 u = uv * bounds.y;
            bool inside = abs(u.x)<=ratio && abs(u.y)<=1.0; 
/*
      vec2 vert = tf(viewTransform, vec2(0., 1.));
      float vertLength = length(vert);
      vec2 v = tf(viewTransform, uv);
      //if (sdSegment(v, vec2(0.0), vert) < 0.01) return vec4(1., 1., 0., 1.);
//      vec2 iRect = vec2(-0.3, 1.); //includedRect;
      vec2 iRect = includedRect;
      if (length(u-iRect)<0.1) return vec4(0., 0.5, 1., 1.);
      vec2 uu = tf(viewTransform, u);
      vec2 tir = tf(viewTransform, iRect / bounds.y);
      
      if (abs(v.x)<abs(tir.x) && abs(v.y)<abs(tir.y)) return mergeColor(__source__(uv), vec4(.5, .5, 1., 0.2));
      
      //if (abs(uv.x)<abs(iRect.x)/ bounds.y && abs(uv.y)<abs(iRect.y)/ bounds.y) return mergeColor(__source__(uv), vec4(.5, .5, 1., 0.2));
      //if (sdSegment(uv, vec2(0.0), vec2(0., 1.)) < 0.01) return vec4(1., 0.0, 1., 1.);      
      //return vec4(fract(v), .5, 1.);
      //if (abs(v.x)<includedRect.x && abs(v.y)<includedRect.y) return vec4(1., 0., 0., 1.);
*/
            return inside ? __source__(uv) : mergeColor(__source__(uv), colorOut);
        }
