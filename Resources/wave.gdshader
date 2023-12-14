shader_type canvas_item;

uniform int iterations = 3;
uniform float zoom = 5.0;
uniform float power = 0.5;
uniform float speed = 0.1;
// Export color picker
uniform vec4 background : source_color = vec4(1.0, 1.0, 1.0, 1.0);

void fragment() {
	float intensity = power * 0.01;
	float bright = 1.0;
	float time = TIME * speed; //TIME since shader calc
	vec2 coords = 250.0 + UV / zoom;
	vec2 iter = vec2(coords);
	for (int n = 0; n < iterations; n++) {
		iter = coords + vec2(cos(time - iter.x) + sin(time + iter.y), sin(time - iter.x) + cos(time + iter.y));
		vec2 tmp = vec2(sin(time + iter.x) + cos(time + iter.y));
		vec2 vector = vec2(coords.x / tmp.x, coords.y / tmp.y) * 0.005;
		bright += 1.0 / length(vector);
	}
	bright /= float(iterations);
	bright = 1.2 - pow(bright, 1.5);
	vec4 color = vec4(pow(abs(bright), 8.0)); //bright to power of 8
	color = clamp(color + background, 0.0, 1.0);
	COLOR = color;
}
