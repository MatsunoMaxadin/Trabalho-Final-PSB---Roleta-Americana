.nolist
.include "m328Pdef.inc"
.list

.equ DISPLAY = PORTC
.equ flagDezena = PB0
.equ flagUnidade = PB1
.equ BOTAO = PB2
.def AUX = R16
.def dezena = R20
.def unidade = R21

.ORG 0x000

inicializacoes:

LDI AUX, 0xff
OUT DDRC, AUX
LDI AUX, 0b00000011
OUT DDRB, AUX
LDI dezena, 0x00
LDI unidade, 0x01
CBI PORTB, flagDezena
CBI PORTB, flagUnidade
LDI AUX, 0x00
OUT DISPLAY, AUX
STS UCSR0B, R1

Principal:
	SBIS PINB, BOTAO
	RJMP Principal
	CPI dezena, 0X00
	BREQ caso_00
	CPI dezena, 0x04
	BREQ verifica_unidade_do_30
	CPI unidade, 0x0A
	BRNE incrementa_unidade
	LDI unidade, 0x01
	INC dezena
	RJMP decod
	incrementa_unidade:
	INC unidade
	RJMP decod
	verifica_unidade_do_30:
	CPI unidade, 0x09
	BRNE incrementa_unidade
	RJMP inicializacoes
	caso_00:
	RCALL Decodifica_dezena
	RCALL Atraso
	INC dezena
	RJMP Principal
	
	
	
	Decod:
	RCALL Decodifica_dezena
	RCALL Atraso
	RJMP Principal

Atraso:
	LDI R19, 16
volta:
	DEC R17
	BRNE volta
	DEC R18
	BRNE volta
	DEC R19
	BRNE volta
	RET
Decodifica_dezena:
	
	LDI ZH, HIGH(Tabela << 1) 
	LDI ZL, LOW(Tabela << 1) 

	ADD ZL, dezena 
	BRCC le_tab_dezena 
	
	INC ZH 



le_tab_dezena:
	CBI PINB,flagDezena
	SBI PINB,flagUnidade
	LPM R0, Z 
	OUT DISPLAY, R0
Decodifica_unidade:

	
	LDI ZH, HIGH(Tabela << 1) 
	LDI ZL, LOW(Tabela << 1) 

	ADD ZL, unidade
	BRCC le_tab_unidade 
	
	INC ZH 



le_tab_unidade:
	SBI PINB,flagDezena
	CBI PINB,flagUnidade
	LPM R0, Z 
	OUT DISPLAY, R0
	RET
	

Tabela: 
.db 0x70, 0xBF, 0x86, 0xDB, 0xCF, 0xE6, 0xED, 0xFD, 0x87, 0xFF, 0xE7, 0xF7, 0xFC, 0xB9, 0xED, 0xF9, 0xF1
