.nolist
.include "m328Pdef.inc"
.list

.equ DISPLAY = PORTC
.equ flagDezena = PB0
.equ flagUnidade = PB1
.def AUX = R16
.def dezena = R20
.def unidade = R21

.ORG 0x000

inicializacoes:

LDI AUX 0xff
OUT DDRC, AUX
LDI AUX 0b00000011
OUT DDRB, AUX
LDI dezena = 0x00
LDI unidade = 0x01
CBI PORTB, flagDezena
CBI PORTB, flagUnidade
LDI AUX 0x00
OUT DISPLAY, AUX
STS UCSR0B, R1

Principal:

