  ;
; AssemblerApplication4.asm
;
; Created: 03/02/2023 21:34:57
; Author : Adrián Smaka

.equ pi = 0b11110111 ; LCD datablad s17

HWINIT:
	sbi DDRC, 4
	sbi DDRC, 5
	rjmp IDLE

IDLE:
	sbi PORTC, 4 //2us per sbi instruction
	sbi PORTC, 5
	call START

START:
	cbi PORTC, 4 ; SDA låg innan SCL
	cbi PORTC, 5
	call ADDRINIT

ADDRINIT:
	ldi r16, $20 ; adress till LCD-skärmen är $20
	ldi r17, 7
	call SEND

SEND:
	sbrs r16, 0 ; skips if bit0 = 0
	call SEND0
	sbrc r16, 0
	call SEND1
	lsl r16 ; storst signifikant bit skickas först ut?
	call BITCOUNT
	call SEND

SEND1:
	sbi PORTC, 4
	ret

SEND0:
	cbi PORTC, 4
	ret

BITCOUNT: ; kollar hur många bitar kvar
	dec r17
	cpi r17, 0
	breq RWBIT
	ret

RWBIT: ; skickar ut skriv- eller läs-biten då 1 motsvarar läs och 0 betyder skriv
	cpi r20, 1 ; om r20 = 1 så är det datan som skickas och så är RW biten onödig
	breq ACKNACK
	cbi PORTC, 4
	call ACKNACK

ACKNACK: ; 1 motsvarar fel med att skicka info
	cbi DDRC, 4 ; PC4 som ingång
	sbic PORTC, 4
	call HWINIT ; startar om hela processen om en 0 läses
	inc r20 ; betyder att adressen är skickat och att r16 kan skrivas över
	call REGCHECK

REGCHECK: ; kollar r20 för att se om adressen är skickat
	cpi r20, 1 ; adressöverföring klar
	breq DATAINIT ; dataöverföringen påbörjas om adressen är skickat
	cpi r20, 2 ; dataöverföring klar
	breq STOP
	brne HWINIT

DATAINIT:
	ldi r16, pi
	ldi r17, 8 ; sätter att datan består av 8 bitar
	call SEND

STOP: ; SDA hög efter SCL
	cbi PORTC, 5
	cbi PORTC, 4
	