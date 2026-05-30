.nolist
.include "m328Pdef.inc"
.list

.equ DISPLAY = PORTD
.equ flagA = PC5
.equ flagB = PC4
.equ flagC = PC3
.equ flagD = PC2
.equ LEDVITORIA = PC1
.equ LEDVERM = PC0
.equ LEDPRET = PB5
.equ LEDBRANCO = PB4
.equ BOTAOSORTEIO = PD2
.equ BOTAOMODO = PB0
.equ BOTAOINC = PB1
.equ BOTAODEC = PB2
.equ ROLETAR = PB3
.def AUX = R16
.def dezena = R20
.def unidade = R21

.include "Display_Roleta.asm"

.ORG 0x010

inicializacoes:
LDI AUX, 0b11111011
OUT DDRD, AUX
LDI AUX, 0xff
OUT DDRC, AUX
LDI AUX, 0b11110000
OUT DDRB, AUX
LDI AUX, 0b00001111
OUT PORTB, AUX
LDI AUX, 0x00
OUT PORTC, AUX
LDI dezena, 0x00
LDI unidade, 0x00
LDI AUX, 0b00000100
OUT DISPLAY, AUX

Principal:
	RCALL Decodifica_dezena
        RCALL Decodifica_unidade
	SBIS PINB, ROLETAR
	RJMP inicio
	RCALL Decodifica_dezena
	RCALL Decodifica_unidade
	RJMP Principal
