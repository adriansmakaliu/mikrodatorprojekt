;
; AssemblerApplication2.asm
;
; Created: 27/01/2023 10:54:47
; Author : Adrián Smaka
;


; Replace with your application code

HWINIT:
	sbi DDRB, 0 //DDRB0 as output
	cbi DDRD, 7 //DDRD7 as input

mainLoop:
	sbic PORTD, 7
	call ledON
	sbis PORTD, 7
	call ledOFF
	out PORTB, r16
	jmp mainLoop

ledON:
	ldi r16, 1
	ret

ledOFF:
	ldi r16, 0
	ret

