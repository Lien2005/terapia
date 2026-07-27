shader_type spatial;
render_mode diffuse_burley, specular_schlick_ggx;

uniform sampler2D albedo_texture : source_color;
uniform sampler2D normal_map;
uniform sampler2D roughness_texture : hint_roughness_gray;
uniform vec4 albedo_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float uv_scale = 8.0;
uniform float roughness_scale : hint_range(0.0, 1.0) = 1.0;
uniform float normal_strength : hint_range(0.0, 2.0) = 1.0;
uniform float specular_value : hint_range(0.0, 1.0) = 0.5;

void fragment() {
	vec2 tiled_uv = UV * uv_scale;
	ALBEDO = texture(albedo_texture, tiled_uv).rgb * albedo_color.rgb;
	NORMAL_MAP = texture(normal_map, tiled_uv).xyz;
	NORMAL_MAP_DEPTH = normal_strength;
	ROUGHNESS = texture(roughness_texture, tiled_uv).r * roughness_scale;
	SPECULAR = specular_value;
}