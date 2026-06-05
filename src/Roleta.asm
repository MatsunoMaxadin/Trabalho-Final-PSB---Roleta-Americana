.nolist
.include "m328Pdef.inc"
.list

; colocando etiquetas para os pinos e definindo registradores
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
.def flagModo = R22
.def flagSorteio = R23
.def AUX = R16
.def AUXB = R24
.def resultado = R25
.def contador = R26


; incluindo outras funçoes
.include "Roletar.asm" 

.ORG 0x010

inicializacoes:
LDI AUX, 0b11111011 
OUT DDRD, AUX ; inicializando o DISPLAY, com todos os pinos sendo de saída, menos PD2, que é a entrada para a interrupção
LDI AUX, 0xff 
OUT DDRC, AUX ; inicializando todos os pinos da portaC como saída
LDI AUX, 0b11110000
OUT DDRB, AUX ; inicializando os 4 primeiros pinos da PORTB como entrada (botoes) e os 4 últimos como saída (LEDS)
LDI AUX, 0b00001111
OUT PORTB, AUX ; ativando o pull-up para os botoes e desligando os LEDS
LDI AUX, 0x00
OUT PORTC, AUX ; ligando os displays
LDI dezena, 0x00 ; zerando os valores da roleta
LDI unidade, 0x00
LDI AUX, 0b00000100
OUT DISPLAY, AUX ; desligando o display
LDI flagModo, 0x00 ; iniciando flagModo com 0
LDI flagSorteio, 0x00 

Principal:
	RCALL Decodifica_dezena
        RCALL Decodifica_unidade
	SBIS PINB, ROLETAR
	RCALL Roleta
	RCALL Decodifica_dezena
	RCALL Decodifica_unidade
	RJMP Principal
