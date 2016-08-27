.org 0x0
.global _start

_start:
    # ori test
    ori $2, $0, 0xffff
    ori $3, $0, 0x0020 
    ori $4, $0, 0xff00

    # forwarding test
    ori $5, $0, 0x1100 # = 0x1100
    ori $5, $5, 0x0020 # = 0x1120
    ori $5, $5, 0x4400 # = 0x5520
    ori $5, $5, 0x0044 # = 0x5564
