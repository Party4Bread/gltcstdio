bool inThirds(float d) {    
    return d>=THIRD && d<=TWO_THIRDS;
}

bool inThirdCircle(float cx, float cy, vec2 u) {
 	return length(vec2(cx, cy)-u)<=0.16666666 ;
}

bool in2ThirdCircle(float cx, float cy, vec2 u) {
 	return length(vec2(cx, cy)-u)<=0.33333333 ;
}

bool truchetTile(vec2 u, int type) {
    if (type==1) return inThirds(length(vec2(0.0, 1.0) - u)) || inThirds(length(vec2(1.0, 0.0) - u));
   	//else if (type==2) return inThirds(u.x) || inThirds(u.y);
   	else if (type==2) return !in2ThirdCircle(0.0, 0.0, u) && !in2ThirdCircle(1.0, 0.0, u) && !in2ThirdCircle(0.0, 1.0, u) && !in2ThirdCircle(1.0, 1.0, u);
    else if (type==3) return inThirdCircle(0.0, 0.5, u) || inThirdCircle(1.0, 0.5, u) || inThirdCircle(0.5, 0.0, u) || inThirdCircle(0.5, 1.0, u);
    else return inThirds(length(u)) || inThirds(length(vec2(1.0, 1.0) - u));
}

int hash(int a, int b) {
    return (a + b) * (a + b + 1) / 2 + a;
}

int hashmore(int i, int j, float regularity) {
    float x = float(i);
    float y = float(j);
    int h = int(fract(sin(x*12.9898+y*78.233) * (x/(mod(y, 1000.0)+1.0)+458.5453))*1000.0);
    if (regularity==0.0) return h;
    return (mod(float(hash(i,j)), 100.0)>=regularity*100.0) ? h : (i+j)*50;
}

int getType(int i, int j, int[16] types, int types_size, float regularity) {
    return int(types[int(mod(float(hashmore(i, j, regularity)), float(types_size)))]);
}

int getLevel(int i, int j, float distribution, float regularity, int levels) {
    float d = distribution;
    float k = pow(100.0/d, 1.0/float(levels));
    float div = pow(2.0, float(levels));
    while (levels>=1) {
        vec2 F = vec2(float(i-(i<0?int(div)-1:0)), float(j-(j<0?int(div)-1:0)))/div;
        int I = int(F.x);
        int J = int(F.y);
	    if (mod(float(hashmore(I+11, J+14, regularity)), 100.0) > d) return levels;
        d /= k;
        div /= 2.0;
        --levels;
    }
    return 0;
}

bool inWing(vec2 pos, vec2 center, float ox, float oy, float r2) {
    vec2 delta = pos - vec2(center.x+ox, center.y+oy);
    return dot(delta, delta) < r2;
}

int minWing(int wing, vec2 pos, int i, int j, float distribution, float regularity, int levels) {
    int mLevel = getLevel(i, j, distribution, regularity, levels);
    int W = wing;
    //for(int level = wing-1; level>=mLevel; --level) {
    for(int level = mLevel; level<W; ++level) {
        float len = 1.0;
        float halflen = len/2.0;
        float exp = pow(2.0, float(level));
        vec2 center = vec2(floor(float(i)/exp) + halflen, floor(float(j)/exp) + halflen);
        float radius = len/3.0;
		vec2 ppos = pos / exp; //float(1<<level);

        if (max(abs(ppos.x-center.x), abs(ppos.y-center.y)) <= halflen+radius) {

            //float radius2 = radius*radius;
            vec2 rel = ppos-center;
            vec2 wingc = sign(rel)*halflen;
            if (wingc.x!=0.0 && wingc.y!=0.0) {
                vec2 delta = rel-wingc;
                //wing = dot(delta, delta) < radius2 ? level :wing;
                if (length(delta) < radius) return level;
            }
            /*wing = (inWing(ppos, center, -halflen, -halflen, radius2)
                || inWing(ppos, center, -halflen, halflen, radius2)
                || inWing(ppos, center, halflen, -halflen, radius2)
                || inWing(ppos, center, halflen, halflen, radius2) ) ? level : wing;*/

            /*wing = ((length(ppos - (center+vec2(-halflen, -halflen))) < radius)
    || (length(ppos - (center+vec2(-halflen, halflen))) < radius)
    || (length(ppos - (center+vec2(halflen, -halflen))) < radius)
    || (length(ppos - (center+vec2(halflen, halflen))) < radius) ) ? level : wing;*/
            /*
            if (length(ppos - (center+vec2(-halflen, -halflen))) < radius) return level;
            else if (length(ppos - (center+vec2(-halflen, halflen))) < radius) return level;
            else if (length(ppos - (center+vec2(halflen, -halflen))) < radius) return level;
            else if (length(ppos - (center+vec2(halflen, halflen))) < radius) return level;*/
       	}
    }

    return wing;
}

vec4 multiLevelTruchet(vec2 pos, vec2 outPos, int source_specified, vec4 color1, vec4 color2, float distribution, float regularity, int[16] types, int types_size, int levels) {
//if (0==0) return vec4(1., 0., 0., 1.); // causes crash on android!
    vec2 ipos = floor(pos);
    int i = int(ipos.x);
    int j = int(ipos.y);

    int level = getLevel(i, j, distribution, regularity, levels);
    int exp = int(pow(2.0, float(level)));
    int I = (i-(i<0?exp-1:0))/exp;
    int J = (j-(j<0?exp-1:0))/exp;
    int type = getType(I, J, types, types_size, regularity);
    float scaling = pow(2.0, float(level)); //float(1 << level);
    bool negative = (level - (level/2)*2 == 1); //level%2==1;

    vec2 scPos = pos/scaling;
    vec2 relPos = fract(scPos);

    float k = truchetTile(relPos, type) ? 1.0 : 0.0;
    if (negative) k = 1.0-k;

    // test wing
    int wing = level;
    if (level>=1 && max(abs(relPos.x-0.5), abs(relPos.y-0.5)) > 0.333333) {
        int N = int(pow(2.0, float(level-1))); //(1 << (level-1));
        for(int jj=j-N; jj<=j+N; ++jj) {
            for(int ii=i-N; ii<=i+N; ++ii) {
                wing = minWing(wing, pos, ii, jj, distribution, regularity, levels);
            }
        }
        if (wing<level) {
            k = (wing - (wing/2)*2)==0 ? 0.0 : 1.0; //k = wing%2==0 ? 0.0 : 1.0;
        }

    }

    vec4 outColor = mix(color1, color2, k);
    if (source_specified==1) return mergeColor(__source__(outPos), outColor);
    else return outColor;    
}
