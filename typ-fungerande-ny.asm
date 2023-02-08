
; Hur kan man l�sa data fr�n SDA eller SCL d� om man avaktiverar  DDRCx s� blir den automatiskt h�g?

.equ functionSet = 0b00001000 ; LCD datablad s.23-24
.equ data = 0xAB
.equ data2 = 0xCD
.equ lcdaddr= $40

HWINIT:
	sbi DDRC, 4
	call DELAY ; SDA l�g innan SCL, m�ste s�ttas i DDR!!!
	sbi DDRC, 5
	rjmp ADDRINIT

ADDRINIT:
	ldi r16, lcdaddr ; adress till LCD-sk�rmen �r $20 << 0 som write = $40 //CHANGEME
	ldi r17, 8 ; 7bitars adress + RW biten = 8 bitar
	call START

START:
	cbi PORTC, 4 ; SDA l�g innan SCL
	cbi PORTC, 5
	call SEND

SEND:
	sbrs r16, 7 ; skips if bit7 = 0
	call SEND0
	sbrc r16, 7
	call SEND1
	call CLKSHIFT
	lsl r16 ; storst signifikant bit skickas f�rst ut?
	call BITCOUNT
	call SEND

SEND1:
	sbi PORTC, 4
	call BIGDELAY
	ret

SEND0:
	cbi PORTC, 4
	call BIGDELAY
	ret

CLKSHIFT:
	sbi PORTC, 5
	call DELAY
	call DELAY
	call DELAY
	cbi PORTC, 5
	call BIGDELAY
	ret

DELAY:
	ldi r22, 4
delayYttre:
	ser r21
delayInre:
	dec r21
	brne delayInre
	dec r22
	brne delayYttre
	ret

BIGDELAY:
	ldi r22, 40
delayYttreStor:
	ser r21
delayInreStor:
	dec r21
	brne delayInreStor
	dec r22
	brne delayYttreStor
	ret


BITCOUNT: ; kollar hur m�nga bitar kvar
	dec r17
	cpi r17, 0
	breq ACKNACK
	ret

ACKNACK: ; 1 motsvarar fel med att skicka info
	;cbi PORTC, 5
	;cbi PORTC, 4
	;cbi DDRC, 4 ; PC4 som ing�ng
	cbi PORTC, 4
	call CLKSHIFT
	sbic PINC, 4
	call HWINIT; startar om hela processen om en 1 l�ses
	;sbi DDRC, 4
	;call BIGDELAY
	inc r20 ; 1 betyder att adressen �r skickat och att r16 kan skrivas �ver
	call REGCHECK

REGCHECK: ; kollar r20 f�r att se om adressen eller datan �r skickat
	cpi r20, 1 ; adress�verf�ring klar
	breq DATAINIT ; data�verf�ringen p�b�rjas om adressen �r skickat
	cpi r20, 2 ; data�verf�ring klar
	;breq STOP
	breq DATAINIT2 ; andra dataramen skickas
	cpi r20, 3
	breq STOP
	;brne HWINIT

DATAINIT:
	ldi r16, data //CHANGEME
	ldi r17, 8 ; s�tter att datan best�r av 8 bitar
	call SEND

DATAINIT2:
	ldi r16, data2
	ldi r17, 8
	call SEND

STOP: ; SDA h�g efter SCL
	cbi PORTC, 4
	cbi PORTC, 5
	call DELAY
	call DELAY
	call DELAY
	call DELAY
	cbi DDRC, 5
	call DELAY
	cbi DDRC, 4
	;ldi r20, 2
	call DONE

DONE:
	call DONE
	