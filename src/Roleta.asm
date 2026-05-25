.nolist
.include "m328Pdef.inc"
.list

.equ DISPLAY = PORTC
.equ flagDezena = PB3
.equ flagUnidade = PB4
.equ BOTAO = PB2
.def AUX = R16
.def dezena = R20
.def unidade = R21

.include "Display_Roleta.asm"

.ORG 0x000

inicializacoes:

LDI AUX, 0xff
OUT DDRC, AUX
LDI AUX, 0b00011000
OUT DDRB, AUX
LDI AUX, 0b00000100
OUT PORTB, AUX
LDI dezena, 0x00
LDI unidade, 0x00
LDI AUX, 0x00
OUT DISPLAY, AUX

Principal:
	SBIS PINB, BOTAO
	RJMP inicio
	RCALL Decodifica_dezena
	RCALL Decodifica_unidade
	RJMP Principal
