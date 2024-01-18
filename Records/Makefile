# This program is for 32-bit systems!
all:
	as -g --32 records.s -o records.o
	ld -g -m elf_i386 records.o -o records

clean:
	rm records *.o

run:
	./records
