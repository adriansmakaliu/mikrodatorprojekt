		          //d4 d5 d6 d7 bkl e rw rs -> d0 d1 d2 d3 bkl e rw rs
.equ displayOn1 = 0b01000100 //set display
.equ displayOn2 = 0b11111100 //set display

;.equ data = 0x00
;.equ data2 = 0x00
.equ lcdaddr= $4E

HWINIT:
	rjmp ADDRINIT ; rjmp d� det �r inte t�nkt att mman ska �terkomma ofta till hwinit

ADDRINIT:
	ldi r16, lcdaddr ; adress till LCD-sk�rmen �r $20 << 0 som write = $40
	ldi r17, 8 ; 7bitars adress + RW biten = 8 bitar
	call START

START:
	sbi DDRC, 4
	call DELAYSMALL ; SDA l�g innan SCL, m�ste s�ttas i DDR!!! pga. pull up motst�ndet
	sbi DDRC, 5
	call SEND

SEND:
	sbrs r16, 7 ; skips if bit7 = 1
	call SEND0
	sbrc r16, 7 ; skips if bit7 = 0
	call SEND1
	call BITSHIFT
	call SEND

SEND1:
	sbi PORTC, 4
	call DELAYBIG
	call CLKSHIFT
	call DELAYBIG
	ret

SEND0:
	cbi PORTC, 4
	call DELAYBIG
	call CLKSHIFT
	call DELAYBIG
	ret

CLKSHIFT:
	sbi PORTC, 5
	call DELAYBIG
	cbi PORTC, 5
	ret

DELAYSMALL:
	ldi r22, 2
delayYttreLiten:
	ser r21
delayInreLiten:
	dec r21
	brne delayInreLiten
	dec r22
	brne delayYttreLiten
	ret

DELAY:
	ldi r22, 8
delayYttre:
	ser r21
delayInre:
	dec r21
	brne delayInre
	dec r22
	brne delayYttre
	ret

DELAYBIG:
	ldi r22, 16
delayYttreStor:
	ser r21
delayInreStor:
	dec r21
	brne delayInreStor
	dec r22
	brne delayYttreStor
	ret

DELAYDEBUG:
	ser r22
delayYttreDebug:
	ser r21
delayInreDebug:
	dec r21
	brne delayInreDebug
	dec r22
	brne delayYttreDebug
	ret


BITSHIFT: ; kollar hur m�nga bitar kvar
	lsl r16 ; storst signifikant bit skickas f�rst ut
	dec r17
	cpi r17, 0
	breq ACKNACK
	ret

ACKNACK: ; 1 motsvarar fel med att skicka info
	cbi PORTC, 4
	cbi DDRC, 4
	call CLKSHIFT
	sbic PORTC, 4
	call STOP; stoppar hela processen om en 1 l�ses
	sbi DDRC, 4
	inc r20 ; 1 betyder att adressen �r skickat och att r16 kan skrivas �ver
	call REGCHECK

REGCHECK: ; kollar r20 f�r att se om adressen eller datan �r skickat
	cpi r20, 1 ; adress�verf�ring klar
	breq DATAINIT ; data�verf�ringen p�b�rjas om adressen �r skickat
	cpi r20, 2 ; data�verf�ring klar
	breq DATAINIT2 ; andra dataramen skickas
	cpi r20, 3
	breq STOP
	call STOP

DATAINIT:
	ldi r16, displayOn1
	ldi r17, 8 ; s�tter att datan best�r av 8 bitar
	call SEND

DATAINIT2:
	ldi r16, displayOn2
	ldi r17, 8
	call SEND

STOP: ; SDA h�g efter SCL
	cbi PORTC, 5
	call DELAYBIG
	sbi PORTC, 5
	call DELAYBIG
	cbi DDRC, 5
	call DELAYBIG
	cbi DDRC, 4
	call IDLE

IDLE:
	call IDLE
	

/*
ACKNACK: ; 1 motsvarar fel med att skicka info
	cbi PORTC, 4
	call DELAYBIG
	call CLKSHIFT
	sbic PINC, 4 // HUR KAN PINC4 L�SAS OM DDRC4 �R H�G??
	call HWINIT; startar om hela processen om en 1 l�ses
	inc r20 ; 1 betyder att adressen �r skickat och att r16 kan skrivas �ver
	call REGCHECK
*/