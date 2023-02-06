.equ SDA = PORTC, 4
.equ SDA = PORTC, 5

HWINIT:
	sbi DDRC, 4 //SDA
	sbi DDRC, 5 //SCL
	jmp PRESTART

PRESTART:
	sbi SDA //Är hög innan I2C:s start-sats
	sbi SCL

START:
	cbi PORTC, 4
	cbi PORTC, 4
