.ORG 0x070

Roleta:
	CPI flagLoop, 1
	BRNE final_loop
	
	CPI resultado, 0X26
	BRNE incrementa_resultado
	LDI resultado, 0x00
	RJMP Decod
	incrementa_resultado:
	INC resultado
	Decod:
	RCALL Mostrar_Display
	RCALL Atraso
	RJMP Roleta
	


final_loop:
	RET

