shader_type spatial;
render_mode unshaded, blend_add, cull_disabled, depth_draw_never, depth_test_disabled;

// Drawn on a single quad that spans -1..1, so r == 1.0 is exactly the explosion's outer edge.
// splosions.gd scales the quad to the damage radius and drives progress 0 -> 1.

uniform float progress : hint_range(0.0, 1.0) = 0.0;
uniform vec3 core_color : source_color = vec3(1.0, 0.95, 0.75);
uniform vec3 mid_color : source_color = vec3(1.0, 0.55, 0.06);
uniform vec3 edge_color : source_color = vec3(0.85, 0.1, 0.0);
uniform float wobble = 0.13;    // how ragged the rings are
uniform float lobes = 9.0;

const float TAU_ = 6.2831853;

float hash(float n) {
	return fract(sin(n * 12.9898) * 43758.5453);
}

// noise around the circle - wraps at `lobes` so there's no seam where atan flips
float angular_noise(float a, float seed) {
	float x = a * lobes;
	float i = floor(x);
	float f = smoothstep(0.0, 1.0, fract(x));
	return mix(hash(mod(i, lobes) + seed), hash(mod(i + 1.0, lobes) + seed), f) - 0.5;
}

vec3 fire_ramp(float heat) {
	vec3 c = mix(vec3(0.0), edge_color, smoothstep(0.0, 0.18, heat));
	c = mix(c, mid_color, smoothstep(0.15, 0.45, heat));
	return mix(c, core_color, smoothstep(0.5, 0.9, heat));
}

float band(float r, float rad, float w) {
	return smoothstep(w, 0.0, abs(r - rad));
}

void fragment() {
	vec2 p = UV * 2.0 - 1.0;
	float r = length(p);
	float a = atan(p.y, p.x) / TAU_ + 0.5;

	// two octaves of angular turbulence, so nothing ever reads as a clean circle
	float turb = angular_noise(a, 1.0) + angular_noise(a * 2.7, 11.0) * 0.5;

	float heat = 0.0;

	// shockwave crests racing out to the rim, staggered so you see waves leaving the core
	for (int k = 0; k < 3; k++) {
		float fk = float(k);
		float delay = fk * 0.11;
		float t = clamp((progress - delay) / max(1.0 - delay, 0.001), 0.0, 1.0);
		if (t <= 0.0) {
			continue;
		}
		float ease = 1.0 - pow(1.0 - t, 2.2);
		float rr = r + turb * wobble * ease;
		// crests leave the core rather than being born on top of it
		heat += band(rr, mix(0.12, 1.0, ease), mix(0.22, 0.05, t)) * pow(1.0 - t, 0.6) * (1.0 - fk * 0.22) * 0.6;
	}

	// the fireball - fills fast, churns, then cools. Kept small so the waves stay readable.
	float ct = clamp(progress / 0.45, 0.0, 1.0);
	float core_r = (1.0 - pow(1.0 - ct, 3.0)) * 0.45;
	float rc = r + turb * wobble * 1.1;
	heat += smoothstep(core_r, core_r * 0.2, rc) * (1.0 - smoothstep(0.25, 0.75, progress)) * 0.85;

	heat *= 1.0 - smoothstep(0.8, 1.0, progress);

	if (heat < 0.02) {
		discard;
	}
	ALBEDO = fire_ramp(clamp(heat, 0.0, 1.0)) * (1.0 + heat * 0.4);
	ALPHA = clamp(heat, 0.0, 1.0);
}
