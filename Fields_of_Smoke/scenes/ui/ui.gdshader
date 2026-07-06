shader_type canvas_item;

uniform sampler2D blood_texture : source_color;
uniform sampler2D noise_texture : repeat_enable;
uniform float blood_intensity : hint_range(0.0, 1.0) = 0.0;
uniform vec2 random_offset;

void fragment() {
    vec2 blood_uv = UV;
    
    vec4 blood = texture(blood_texture, blood_uv);
    float noise = texture(noise_texture, UV + random_offset).r;
    
    float mask = smoothstep(1.0 - blood_intensity, 1.2 - blood_intensity, blood.a * noise);
    
    COLOR = vec4(blood.rgb, mask * blood_intensity);
}