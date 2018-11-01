
#define glError() { \
	GLenum err = glGetError(); \
	if (err != GL_NO_ERROR) { \
		printf("glError: %04x caught at %s:%u\n", err, __FILE__, __LINE__); \
	} \
}

