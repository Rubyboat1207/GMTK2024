shader_type canvas_item;

uniform vec2 camera_position = vec2(0.1,0.1);

void vertex() {

}

void fragment() {
	COLOR = texture(TEXTURE, (UV - camera_position) * 2.0); // Read from texture again.
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
