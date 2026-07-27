shader_type spatial;
render_mode cull_disabled;

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
	vec3 noiseLevel = texture(noise, worldPos.xz / noiseScale).rgb;
	ALBEDO = mix(color, color2, UV.y) * mix(color, color2, noiseLevel.r);
	if(!FRONT_FACING){
		NORMAL = -NORMAL;
	}
}
