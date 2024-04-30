shader_type canvas_item;

uniform float divide = 1;
uniform float blur = 0.1;

void fragment(){
    COLOR.w = smoothstep(divide, divide+blur, UV.y);
}