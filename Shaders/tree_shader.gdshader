shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_disabled, diffuse_burley, specular_schlick_ggx, vertex_lighting;

uniform vec4 albedo : source_color;
uniform sampler2D texture_albedo : source_color, filter_linear_mipmap, repeat_enable;
uniform float alpha_scissor_threshold : hint_range(0.0, 1.0, 0.001);
uniform ivec2 albedo_texture_size;
uniform float point_size : hint_range(0.1, 128.0, 0.1);

uniform float roughness : hint_range(0.0, 1.0);
uniform sampler2D texture_metallic : hint_default_white, filter_linear_mipmap, repeat_enable;
uniform vec4 metallic_texture_channel;
uniform sampler2D texture_roughness : hint_roughness_r, filter_linear_mipmap, repeat_enable;

uniform float specular : hint_range(0.0, 1.0, 0.01);
uniform float metallic : hint_range(0.0, 1.0, 0.01);

uniform vec3 uv1_scale;
uniform vec3 uv1_offset;
uniform vec3 uv2_scale;
uniform vec3 uv2_offset;

uniform bool debug_mode = false;

uniform vec3 color : source_color;
uniform vec3 color2 : source_color;
uniform sampler2D noise;
uniform float noiseScale = 20.0;

varying vec3 worldPos;

uniform float wind_direction = 90.0f;
uniform float wind_strenth = 3.0f;
uniform float sway_speed = 3.0f;
uniform float bendieness_multiplier = 0.0f;

uniform sampler2D albedo_texture : source_color;

varying float wind_multiplier;

vec2 rotation_to_direction()
{
	float rotation_radians = wind_direction * (3.14f / 180.0f);
	vec2 direction = vec2(cos(rotation_radians), sin(rotation_radians));
	
	return normalize(direction);
}

void vertex() {
	// Shading Mode: Per Vertex
	ROUGHNESS = roughness;

	UV = UV * uv1_scale.xy + uv1_offset.xy;
		worldPos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
    float dist = worldPos.y;
	
	// DEBUG: applies visual gradients.
    if (debug_mode)
	{
		float gradient = clamp(dist * 0.2, 0.0, 1.0);
    	COLOR = vec4(gradient, gradient, gradient, 1.0);
	}
	
	// magic 100.0f just to make it easier to adjust in property panel
	float sway = sin(TIME * sway_speed + VERTEX.y) * wind_strenth / 100.0f;
    VERTEX.x += (sway * dist);
	
	// magic 100.0f just to make it easier to adjust in property panel
	vec2 wind_bending = vec2((wind_strenth / 100.0f) * dist) * rotation_to_direction();
	VERTEX.xz += wind_bending * bendieness_multiplier;
}

void fragment() {
	vec2 base_uv = UV;

	vec4 albedo_tex = texture(texture_albedo, base_uv);

	// Vertex Color Use as Albedo: Enabled
	albedo_tex *= COLOR;

	ALBEDO = albedo.rgb * albedo_tex.rgb;

	float metallic_tex = dot(texture(texture_metallic, base_uv), metallic_texture_channel);
	METALLIC = metallic_tex * metallic;
	SPECULAR = specular;

	vec4 roughness_texture_channel = vec4(1.0, 0.0, 0.0, 0.0);
	float roughness_tex = dot(texture(texture_roughness, base_uv), roughness_texture_channel);
	ROUGHNESS = roughness_tex * roughness;
	ALPHA *= albedo.a * albedo_tex.a;
	ALPHA_SCISSOR_THRESHOLD = alpha_scissor_threshold;
	vec3 noiseLevel = texture(noise, worldPos.xz / noiseScale).rgb;
	ALBEDO = mix(color, color2, UV.y) * mix(color, color2, noiseLevel.r);
	if(!FRONT_FACING){
		NORMAL = -NORMAL;
	}
}
