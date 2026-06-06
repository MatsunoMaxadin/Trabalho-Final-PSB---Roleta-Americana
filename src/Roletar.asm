.ORG 0x030

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
	

Atraso:
	LDI AUX, 255
	MOV R9, AUX

loop:
	DEC R9
	BRNE loop
	RET
final_loop:
	RET

