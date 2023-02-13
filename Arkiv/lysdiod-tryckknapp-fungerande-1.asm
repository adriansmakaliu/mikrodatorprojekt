;
; AssemblerApplication2.asm
;
; Created: 27/01/2023 10:54:47
; Author : Adrián Smaka
;


; Replace with your application code

HWINIT:
	cbi DDRB, 0 //DDRB0 as input
	sbi DDRB, 1 //DDRB1 as output

mainLoop:
 	sbic PINB, 0
	call ledON
	sbis PINB, 0
	call ledOFF
	jmp mainLoop

ledON:
	sbi PORTB, 1
	ret

ledOFF:
	cbi PORTB, 1
	ret

