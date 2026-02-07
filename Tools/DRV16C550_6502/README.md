# DRV16C550_6502
This is a driver for uart 16C550 to be used with 6502.

        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ; BIOS
        ;
        ;; vERSION 0.0.1

This version has the following characteristics:
1 - B_READ_BYTE:

        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ; B_READ_BYTE: Read byte from UART waiting for it (BLOCANT)
        ; Registers changed: A
        ; Flag CARRY not changed.
        ;
The flag CARRY is not changed because though it is blocant it will always return a valid character.
It has an option to echo the character you just uncomment the line JSR WRITE_BYTE.

2 - READ_BYTE

        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ; READ_BYTE: Read byte from UART waiting for it (NO BLOCANT)
        ; Registers changed: A, Y
        ; Flag CARRY: Set when character ready
        ;             Clear when no character ready

This routine is not blocant so the flag carry should be use to know if it returned a
valid character or not.
It also has an option to echo the character you just uncomment the line JSR WRITE_BYTE.

3 - WRITE_BYTE

        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ; WRITE_BYTE: Write byte to UART
        ; Registers changed: NONE
        ; Flag CARRY not changed.
        ;

This routine write one byte to uart it does not change carry flag and does not send a line feed automatically.

4 - WRITE_BYTE_WITH_ECHO

        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ; WRITE_BYTE_WITH_ECHO: Write byte to UART, IF BYTE IS 0D WRITE 0A(LF) TOO
        ; Registers changed: NONE
        ; Flag CARRY not changed.
        ;

This routine write one byte to uart it does not change carry flag,but it does send a line feed automatically.

# bios.cfg
This file reflects my hardware as described bellow.

1 - RAM - From 0000 to 77FF - 30k bytes.

2 - IO  - From 7800 to 7FFF - 2k bytes.

3 - ROM - From 8000 to FFFF - 32k bytes.




