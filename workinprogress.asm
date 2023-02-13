
;r16 = data, r17 = datalängd, r18 = längd av yttre delay, r19 = längd av inre delay, r20 = vilken data är utskickat

.equ addr = $40 ; $20 + RW biten
.equ SDA = PC4
.equ SCL = PC5
.equ dataLen = 8
.equ delayExtLen = 10
.equ delayIntLen = 0xFF
.equ data = 0b00100100

;lookup: .db 

HWINIT:
	ldi r16, addr ; sparar adressen
	ldi r17, 8 ; sparar 7 bitars adress + RW biten
	rjmp START

START:
	sbi DDRC, SDA
	call DELAY
	sbi DDRC, SCL
	call DELAY
	call SEND

SEND:
	sbrs r16, 7
	call SDL
	sbrc r16, 7
	call SDH
	call BITSHIFT
	jmp SEND

ACKNACK:
	cbi DDRC, SDA
	call CLKPULSE
	sbic PINC, SDA
	call STOP
	inc r20
	call DATACHECK

DATACHECK: ; kollar vilken data ska skickas ut
	cpi r20, 1
	breq DATAENL
	cpi r20, 2
	breq DATAENH
	cpi r20, 3
	breq DATAENL
	call STOP

STOP:
	sbi DDRC, SDA
	call DELAY
	cbi DDRC, SCL
	call DELAY
	cbi DDRC, SDA
	call IDLE

IDLE:
	jmp IDLE

DATAENH:
	ldi r16, data 
	ldi r17, dataLen
	ret

DATAENL:
	ldi r16, data
	ldi r17, dataLen
	andi r16, 0b11111011
	ret

SDH:
	cbi DDRC, SDA ; Hög då DDRC4 = 0
	call DELAY
	call CLKPULSE
	ret
	
SDL:
	sbi DDRC, SDA ; Låg då DDRC4 = 1
	call DELAY
	call CLKPULSE
	ret

CLKPULSE:
	cbi DDRC, SCL
	call DELAY
	sbi DDRC, SCL
	call DELAY
	ret

BITSHIFT:
	lsl r16 ; storst signifikant bit (DB7) skickas först ut
	dec r17
	cpi r17, 0
	breq ACKNACK
	ret

DELAY:
	ldi r18, delayExtLen	
delayExt:
	ldi r19, delayIntLen
delayInt:
	dec r19
	brne delayInt
	dec r18
	brne delayExt
	ret
	