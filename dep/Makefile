CFLAGS = -g -O0 -Wall -std=gnu99
SHARED = -fPIC --shared

utils.so: utils.c
	gcc $(CFLAGS) $(SHARED) $^ -o $@

clean:
	rm utils.so