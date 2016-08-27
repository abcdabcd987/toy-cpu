#!/usr/bin/env python
import os
import sys
import binascii

TOOLCHAIN = '/Users/abcdabcd987/Developer/tmp/mips-gcc-4.8.1/bin/'
INPUT = sys.argv[1]
OUTPUT = sys.argv[2]

os.system('{}/mips-elf-as -mips32 {} -o rom.o'.format(TOOLCHAIN, INPUT))
os.system('{}/mips-elf-ld rom.o -o rom.om'.format(TOOLCHAIN))
os.system('{}/mips-elf-objcopy -O binary rom.om rom.bin'.format(TOOLCHAIN))
s = open('rom.bin', 'rb').read()
s = binascii.b2a_hex(s)
with open(OUTPUT, 'w') as f:
    for i in range(0, len(s), 8):
        f.write(s[i:i+8])
        f.write('\n')
os.system('rm -f rom.o rom.om rom.bin')
