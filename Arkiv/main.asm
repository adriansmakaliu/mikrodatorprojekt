;
; AssemblerApplication2.asm
;
; Created: 27/01/2023 10:54:47
; Author : Adrián Smaka
;


; Replace with your application code

HWINIT:
	sbi DDRB, 5 //DDRB5 as output
	out DDRB, r16 //DDRB5 to r16 
	cbi DDRD, 7 //DDRD7 as input

mainLoop:
	sbis DDRD, 7
	call mainLoop
	sbi DDRB, 5
	call mainLoop

;	sbr r16, 10
;	cpi r16, 10 
;	breq infloop
	

infloop:
	call infloop