CFLAGS="-Wall -std=c11 -pedantic -O3 -g"

#no static link here
gcc -c -fpic lib.c $CFLAGS
#can static link here
gcc -shared -o lib.so lib.o

mojo build main.mojo
