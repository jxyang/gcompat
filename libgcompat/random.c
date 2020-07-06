#include <inttypes.h>
#include <stdlib.h>

int initstate_r(unsigned int seed, char *statebuf, size_t statelen, void *buf) {
	return 0;
}

int random_r(struct random_data *buf, int32_t *result) {
	*result = random();
	return 0;
}
