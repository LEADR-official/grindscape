shader_type canvas_item;

// Tweakable parameters
uniform float gamma : hint_range(0.5, 1.5) = 0.9;
uniform float contrast : hint_range(0.5, 1.2) = 0.85;
uniform float brightness : hint_range(-0.2, 0.2) = 0.05;
uniform float saturation : hint_range(0.5, 2.0) = 1.2;
uniform float color_levels : hint_range(8.0, 64.0) = 32.0;
uniform float pixel_size : hint_range(1.0, 8.0) = 2.0;

// Warm color bias (OSRS yellow-green tint)
uniform vec3 color_bias = vec3(1.05, 1.08, 0.94);

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_nearest;

void fragment() {
	// Pixelation - sample at reduced resolution for chunky pixel look
	vec2 screen_size = vec2(textureSize(SCREEN_TEXTURE, 0));
	vec2 pixelated_uv = floor(SCREEN_UV * screen_size / pixel_size) * pixel_size / screen_size;
	vec3 color = texture(SCREEN_TEXTURE, pixelated_uv).rgb;

	// 1. Low contrast curve - lift shadows, mute highlights
	color = pow(color, vec3(gamma));
	color = (color - 0.5) * contrast + 0.5 + brightness;

	// 2. Warm color balance - OSRS yellow-green bias
	color *= color_bias;

	// 3. Boost saturation - OSRS is vibrant, not muted!
	float gray = dot(color, vec3(0.299, 0.587, 0.114));
	color = mix(vec3(gray), color, saturation);

	// 4. Posterization - 32 levels for subtle banding
	color = floor(color * color_levels + 0.5) / color_levels;

	// Clamp to valid range
	color = clamp(color, 0.0, 1.0);

	COLOR = vec4(color, 1.0);
}
