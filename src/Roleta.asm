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
.def dezena = R20
.def unidade = R21
.def flagModo = R22
.def flagSorteio = R23
.def flagLoop = R17
.def AUX = R16
.def AUXB = R24
.def resultado = R25
.def contador = R18
.def numEscolhido = R19


; incluindo outras funçoes
.include "Roletar.asm" 
.include "Display.asm"
.include "Interrupcao.asm"
.include "Escolher_numero.asm"

.ORG 0x000
RJMP inicializacoes	; pula para o começo do programa

.ORG 0X0002		; endereço reservado para interrupção INT0 - PD2
JMP	Interrup	; pula para rotina de interrupção

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

; configuração da interrupção - borda de descida

LDI AUX, 0b00000010		 
STS EICRA, AUX		;	faz ISC00=0 e ISC01=1, assim configurando borda de descida através do registrador EICRA (que exige STS e não OUT)
LDI AUX, 0b00000001	;	habilita a interrpção INT0 através do registrador EIMSK
OUT EIMSK, AUX		
SEI					;	habilita as interrupções através do bit I de SREG

; fim da configuração de interrupção

LDI AUX, 0b00000100
OUT DISPLAY, AUX ; desligando o display
LDI flagModo, 0x00 ; iniciando flagModo com 0
LDI flagSorteio, 0x00 
LDI flagLoop, 0



Principal:
	RCALL Mostrar_Display
	SBIC PINB, BOTAOMODO
	RJMP Principal
	LDI flagModo, 0x05
	RCALL Escolher_numero
	LDI flagLoop, 1
	LDI flagSorteio, 0x01	
	mostrando:
	RCALL Mostrar_Display
	
	RJMP mostrando
	
