shader_type canvas_item;

// Base water colours (kept for the subtle water tint beneath the foam)
uniform vec4 WATER_COL  : source_color = vec4(0.04, 0.38, 0.88, 1.0);
uniform vec4 WATER2_COL : source_color = vec4(0.04, 0.35, 0.78, 1.0);
uniform vec4 FOAM_COL   : source_color = vec4(0.92, 0.97, 0.99, 1.0);

uniform float distortion_speed = 2.0;
uniform float flow_speed       = 0.35;
uniform vec2  tile             = vec2(4.0, 14.0);

// Foam controls
uniform float foam_intensity   = 1.8;   // overall foam coverage multiplier
uniform float edge_foam_width  = 0.18;  // fraction of width that gets extra bank foam
uniform float streak_scale     = 3.0;   // elongation of downstream foam streaks

const float M_2PI = 6.283185307;
const float M_6PI = 18.84955592;

// ── Noise helpers (identical to water.gdshader) ──────────────────────────────

float random(vec2 uv) {
	return fract(sin(dot(uv.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

float noise(vec2 uv) {
	vec2 uv_index = floor(uv);
	vec2 uv_fract = fract(uv);

	float a = random(uv_index);
	float b = random(uv_index + vec2(1.0, 0.0));
	float c = random(uv_index + vec2(0.0, 1.0));
	float d = random(uv_index + vec2(1.0, 1.0));

	vec2 blur = smoothstep(0.0, 1.0, uv_fract);

	return mix(a, b, blur.x) +
	       (c - a) * blur.y * (1.0 - blur.x) +
	       (d - b) * blur.x * blur.y;
}

float fbm(vec2 uv) {
	int   octaves   = 6;
	float amplitude = 0.5;
	float frequency = 3.0;
	float value     = 0.0;
	for (int i = 0; i < octaves; i++) {
		value     += amplitude * noise(frequency * uv);
		amplitude *= 0.5;
		frequency *= 2.0;
	}
	return value;
}

// ── Bubble circles (from water.gdshader) ─────────────────────────────────────

float circ(vec2 pos, vec2 c, float s) {
	c = abs(pos - c);
	c = min(c, 1.0 - c);
	return smoothstep(0.0, 0.002, sqrt(s) - sqrt(dot(c, c))) * -1.0;
}

float waterlayer(vec2 uv) {
	uv = mod(uv, 1.0);
	float ret = 1.0;
	ret += circ(uv, vec2(0.37378, 0.277169), 0.0268181);
	ret += circ(uv, vec2(0.0317477, 0.540372), 0.0193742);
	ret += circ(uv, vec2(0.430044, 0.882218), 0.0232337);
	ret += circ(uv, vec2(0.641033, 0.695106), 0.0117864);
	ret += circ(uv, vec2(0.0146398, 0.0791346), 0.0299458);
	ret += circ(uv, vec2(0.43871, 0.394445), 0.0289087);
	ret += circ(uv, vec2(0.909446, 0.878141), 0.028466);
	ret += circ(uv, vec2(0.310149, 0.686637), 0.0128496);
	ret += circ(uv, vec2(0.928617, 0.195986), 0.0152041);
	ret += circ(uv, vec2(0.0438506, 0.868153), 0.0268601);
	ret += circ(uv, vec2(0.308619, 0.194937), 0.00806102);
	ret += circ(uv, vec2(0.349922, 0.449714), 0.00928667);
	ret += circ(uv, vec2(0.0449556, 0.953415), 0.023126);
	ret += circ(uv, vec2(0.117761, 0.503309), 0.0151272);
	ret += circ(uv, vec2(0.563517, 0.244991), 0.0292322);
	ret += circ(uv, vec2(0.566936, 0.954457), 0.00981141);
	ret += circ(uv, vec2(0.0489944, 0.200931), 0.0178746);
	ret += circ(uv, vec2(0.569297, 0.624893), 0.0132408);
	ret += circ(uv, vec2(0.298347, 0.710972), 0.0114426);
	ret += circ(uv, vec2(0.878141, 0.771279), 0.00322719);
	ret += circ(uv, vec2(0.150995, 0.376221), 0.00216157);
	ret += circ(uv, vec2(0.119673, 0.541984), 0.0124621);
	ret += circ(uv, vec2(0.629598, 0.295629), 0.0198736);
	ret += circ(uv, vec2(0.334357, 0.266278), 0.0187145);
	ret += circ(uv, vec2(0.918044, 0.968163), 0.0182928);
	ret += circ(uv, vec2(0.965445, 0.505026), 0.006348);
	ret += circ(uv, vec2(0.514847, 0.865444), 0.00623523);
	ret += circ(uv, vec2(0.710575, 0.0415131), 0.00322689);
	ret += circ(uv, vec2(0.71403, 0.576945), 0.0215641);
	ret += circ(uv, vec2(0.748873, 0.413325), 0.0110795);
	ret += circ(uv, vec2(0.0623365, 0.896713), 0.0236203);
	ret += circ(uv, vec2(0.980482, 0.473849), 0.00573439);
	ret += circ(uv, vec2(0.647463, 0.654349), 0.0188713);
	ret += circ(uv, vec2(0.651406, 0.981297), 0.00710875);
	ret += circ(uv, vec2(0.428928, 0.382426), 0.0298806);
	ret += circ(uv, vec2(0.811545, 0.62568), 0.00265539);
	ret += circ(uv, vec2(0.400787, 0.74162), 0.00486609);
	ret += circ(uv, vec2(0.331283, 0.418536), 0.00598028);
	ret += circ(uv, vec2(0.894762, 0.0657997), 0.00760375);
	ret += circ(uv, vec2(0.525104, 0.572233), 0.0141796);
	ret += circ(uv, vec2(0.431526, 0.911372), 0.0213234);
	ret += circ(uv, vec2(0.658212, 0.910553), 0.000741023);
	ret += circ(uv, vec2(0.514523, 0.243263), 0.0270685);
	ret += circ(uv, vec2(0.0249494, 0.252872), 0.00876653);
	ret += circ(uv, vec2(0.502214, 0.47269), 0.0234534);
	ret += circ(uv, vec2(0.693271, 0.431469), 0.0246533);
	ret += circ(uv, vec2(0.415, 0.884418), 0.0271696);
	ret += circ(uv, vec2(0.149073, 0.41204), 0.00497198);
	ret += circ(uv, vec2(0.533816, 0.897634), 0.00650833);
	ret += circ(uv, vec2(0.0409132, 0.83406), 0.0191398);
	ret += circ(uv, vec2(0.638585, 0.646019), 0.0206129);
	ret += circ(uv, vec2(0.660342, 0.966541), 0.0053511);
	ret += circ(uv, vec2(0.513783, 0.142233), 0.00471653);
	ret += circ(uv, vec2(0.124305, 0.644263), 0.00116724);
	ret += circ(uv, vec2(0.99871, 0.583864), 0.0107329);
	ret += circ(uv, vec2(0.894879, 0.233289), 0.00667092);
	ret += circ(uv, vec2(0.246286, 0.682766), 0.00411623);
	ret += circ(uv, vec2(0.0761895, 0.16327), 0.0145935);
	ret += circ(uv, vec2(0.949386, 0.802936), 0.0100873);
	ret += circ(uv, vec2(0.480122, 0.196554), 0.0110185);
	ret += circ(uv, vec2(0.896854, 0.803707), 0.013969);
	ret += circ(uv, vec2(0.292865, 0.762973), 0.00566413);
	ret += circ(uv, vec2(0.0995585, 0.117457), 0.00869407);
	ret += circ(uv, vec2(0.377713, 0.00335442), 0.0063147);
	ret += circ(uv, vec2(0.506365, 0.531118), 0.0144016);
	ret += circ(uv, vec2(0.408806, 0.894771), 0.0243923);
	ret += circ(uv, vec2(0.143579, 0.85138), 0.00418529);
	ret += circ(uv, vec2(0.0902811, 0.181775), 0.0108896);
	ret += circ(uv, vec2(0.780695, 0.394644), 0.00475475);
	ret += circ(uv, vec2(0.298036, 0.625531), 0.00325285);
	ret += circ(uv, vec2(0.218423, 0.714537), 0.00157212);
	ret += circ(uv, vec2(0.658836, 0.159556), 0.00225897);
	ret += circ(uv, vec2(0.987324, 0.146545), 0.0288391);
	ret += circ(uv, vec2(0.222646, 0.251694), 0.00092276);
	ret += circ(uv, vec2(0.159826, 0.528063), 0.00605293);
	return max(ret, 0.0);
}

// ── Downstream foam streaks ───────────────────────────────────────────────────
// Generates elongated wispy streaks that flow along the river.
float foam_streaks(vec2 uv, float i_time) {
	// Stretch Y so streaks are tall and thin, matching river flow direction.
	vec2 suv = vec2(uv.x * 2.5, uv.y * streak_scale * 0.4);
	suv.y -= i_time * flow_speed * 1.4;

	// Two fbm layers at different offsets create complex streak shapes.
	float f1 = fbm(suv + vec2(0.3, 0.0));
	float f2 = fbm(suv * 1.7 + vec2(0.9, 0.5));

	// Threshold the combined noise to get discrete streak patches.
	float streaks = smoothstep(0.62, 0.78, (f1 + f2) * 0.5);
	return streaks;
}

// ── Bank / edge foam ─────────────────────────────────────────────────────────
// Foam that accumulates at the left and right banks of the river.
float edge_foam(vec2 raw_uv, float i_time) {
	float dist_to_edge = min(raw_uv.x, 1.0 - raw_uv.x);
	float edge_mask    = 1.0 - smoothstep(0.0, edge_foam_width, dist_to_edge);

	// Animate the edge foam gently so it isn't static.
	vec2 euv = vec2(raw_uv.x * 6.0, raw_uv.y * 2.5 - i_time * flow_speed * 0.8);
	float edge_noise = noise(euv) * 0.6 + noise(euv * 2.1 + 0.4) * 0.4;
	float threshold  = smoothstep(0.38, 0.6, edge_noise);

	return edge_mask * threshold;
}

// ── Main water + foam composite ───────────────────────────────────────────────

vec4 river_foam(vec2 uv, vec2 raw_uv, float i_time) {
	uv *= vec2(0.25, 0.18);

	uv.y -= i_time * flow_speed;
	uv   += fbm(vec2(uv.x * 1.4, uv.y * 0.35)) * vec2(0.08, 0.2);

	// Same ripple distortion as water.gdshader.
	float h = sin(uv.y * 1.6 + i_time * 1.1);
	uv += vec2(sin(uv.y * 0.7 + i_time) * 0.012, h * 0.03);
	h = sin(uv.y * 2.2 - i_time * 0.85);
	uv += vec2(h * 0.008, h * 0.025);

	float d1   = mod(uv.y + uv.x * 0.15, M_2PI);
	float d2   = mod((uv.y - uv.x * 0.1 + 0.25) * 1.3, M_6PI);
	d1 = i_time * 0.12 + d1;
	d2 = i_time * 0.55 + d2;
	vec2 dist = vec2(
		sin(d1) * 0.04 + sin(d2) * 0.02,
		cos(d1) * 0.18 + cos(d2) * 0.07
	);

	// Base water with boosted bubble foam from water.gdshader.
	float bubble1 = waterlayer(uv + dist);
	float bubble2 = waterlayer(vec2(1.0) - uv - dist.yx);
	float bubbles  = clamp((bubble1 + bubble2) * foam_intensity, 0.0, 1.0);

	// Streak foam flowing downstream.
	float streaks = foam_streaks(uv, i_time) * foam_intensity * 0.65;

	// Bank foam at river edges.
	float banks = edge_foam(raw_uv, i_time) * foam_intensity * 0.9;

	// Composite: water base → streaks → bubble foam → edge banks.
	vec3 col = mix(WATER_COL.rgb, WATER2_COL.rgb, bubble1);
	col = mix(col,  FOAM_COL.rgb, clamp(streaks,  0.0, 1.0));
	col = mix(col,  FOAM_COL.rgb, clamp(bubbles,  0.0, 1.0));
	col = mix(col,  FOAM_COL.rgb, clamp(banks,    0.0, 1.0));

	// Alpha: foam patches are opaque; base water is semi-transparent so the
	// underlying water.gdshader layer shows through where foam is absent.
	float foam_total = clamp(streaks + bubbles * 0.7 + banks, 0.0, 1.0);
	float alpha      = mix(0.0, 1.0, foam_total);

	return vec4(col, alpha);
}

void fragment() {
	vec4 foam = river_foam(UV * tile, UV, TIME * distortion_speed);
	// Overlay foam on top of the original tile texture.
	// foam.a is the total foam coverage (0 = tile shows through, 1 = full foam).
	COLOR.rgb = mix(COLOR.rgb, FOAM_COL.rgb, foam.a);
	// Leave COLOR.a untouched so the tile's own transparency is preserved.
}
