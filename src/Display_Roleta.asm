.ORG 0x010

inicio:
	CPI dezena, 0x03
	BREQ verifica_unidade_do_30
	CPI unidade, 0x09
	BRNE incrementa_unidade
	LDI unidade, 0x00
	INC dezena
	RJMP decod
	incrementa_unidade:
	INC unidade
	RJMP decod
	verifica_unidade_do_30:
	CPI unidade, 0x07
	BRNE incrementa_unidade
	RJMP inicializacoes
	caso_00:
	RCALL Decodifica_dezena
	RCALL Decodifica_unidade
	INC dezena
	RJMP Principal
	
	
	
	Decod:
	RCALL Decodifica_dezena
	RCALL Decodifica_unidade
	RJMP Principal

Atraso:
	LDI R17, 255

loop:
	DEC R17
	BRNE loop

	RET
Decodifica_dezena:
	
	LDI ZH, HIGH(Tabela << 1) 
	LDI ZL, LOW(Tabela << 1) 

	ADD ZL, dezena 
	BRCC le_tab_dezena 
	
	INC ZH 



le_tab_dezena:
	CBI PORTB,flagDezena
	SBI PORTB,flagUnidade
	LPM R0, Z 
	OUT DISPLAY, R0
	RCALL Atraso
	RET
Decodifica_unidade:

	
	LDI ZH, HIGH(Tabela << 1) 
	LDI ZL, LOW(Tabela << 1) 

	ADD ZL, unidade
	BRCC le_tab_unidade 
	
	INC ZH 



le_tab_unidade:
	SBI PORTB,flagDezena
	CBI PORTB,flagUnidade
	LPM R0, Z 
	OUT DISPLAY, R0
	RCALL Atraso
	RET
	

Tabela: 
.db 0xBF, 0x86, 0xDB, 0xCF, 0xE6, 0xED, 0xFD, 0x87, 0xFF, 0xE7, 0xF7, 0xFC, 0xB9, 0xED, 0xF9, 0xF1
