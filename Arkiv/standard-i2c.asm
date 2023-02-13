;
; AssemblerApplication4.asm
;
; Created: 03/02/2023 21:34:57
; Author : Adrián Smaka



HWINIT:
	sbi DDRC, 4
	sbi DDRC, 5
	rjmp IDLE

IDLE:
	sbi PORTC, 4 //2us per sbi instruction
	sbi PORTC, 5
	call START

START:
	cbi PORTC, 4
	cbi PORTC, 5
	call ADDR

ADDR:
	ldi r16, 0x20
	call TX

TX:
	sbrs r16, 0 ; skips if bit0 = 0
	call SENDL
	sbrc r16, 0
	call SENDH
	lsr r16
	call TX

SENDH:
	sbi PORTC, 4
	ret

SENDL:
	cbi PORTC, 4
	ret

kaka:
	nop