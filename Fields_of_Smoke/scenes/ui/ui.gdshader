shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;

uniform sampler2D blood_texture : source_color;
uniform sampler2D noise_texture : repeat_enable;
uniform float blood_intensity : hint_range(0.0, 1.0) = 0.0;
uniform vec2 random_offset;
uniform float darkness_factor : hint_range(0.0, 1.0) = 0;

void fragment() {
    vec2 blood_uv = UV;
	vec4 screen_color = texture(screen_texture, SCREEN_UV);
    
    vec4 blood = texture(blood_texture, blood_uv);
    float noise = texture(noise_texture, UV + random_offset).r;
    
    float mask = smoothstep(1.0 - blood_intensity, 1.2 - blood_intensity, blood.a * noise);
    
	vec3 global_darkened_screen = mix(screen_color.rgb, screen_color.rgb * darkness_factor, blood_intensity);
    
    vec3 final_rgb = mix(global_darkened_screen, blood.rgb, mask);
    
    COLOR = vec4(final_rgb, 1.0);
}