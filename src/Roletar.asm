.ORG 0x030

Roleta:
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
	RET
	
	
	
	Decod:
	RCALL Decodifica_dezena
	RCALL Decodifica_unidade
	RET

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
	CBI PORTC,flagD
	SBI PORTC,flagC
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
	SBI PORTC,flagD
	CBI PORTC,flagC
	LPM R0, Z 
	OUT DISPLAY, R0
	RCALL Atraso
	RET
	

Tabela: 
.db 0x7F, 0x0E, 0xB7, 0x9F, 0xCE, 0xDB, 0xFB, 0x0F, 0xFF, 0xDF 
