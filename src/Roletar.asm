.ORG 0x030

Roleta:
	
	CPI resultado, 0X26
	BRNE incrementa_resultado
	LDI resultado, 0x00
	RJMP Decod
	incrementa_resultado:
	INC resultado
	Decod:
	RCALL Display
	RCALL Atraso
	RJMP Roleta
	

Atraso:
	LDI R17, 255

loop:
	DEC R17
	BRNE loop

	RET

