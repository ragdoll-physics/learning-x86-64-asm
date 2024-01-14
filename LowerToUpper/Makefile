all:
	as -g main.s -o main.o
	ld -g -dynamic-linker /lib64/ld-linux-x86-64.so.2 -lc main.o -o main -e main

clean:
	rm main *.o
