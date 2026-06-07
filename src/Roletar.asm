.ORG 0x070

Roleta:
	CPI flagLoop, 1 ; Verifica se a flag para o loop está ativa.
	BRNE final_loop ; Se não, encerra o loop.
	
	CPI resultado, 0X26 ; Confere se o resultado chegou no valor máximo (37).
	BRNE incrementa_resultado ; Se não, incrementa
	LDI resultado, 0x00 ; Se sim, Zera o valor
	RJMP Decod ; Pula para a rotina de decodificação
	incrementa_resultado:
	INC resultado ; incrementando o resultado
	Decod:
	RCALL Mostrar_Display ; Imprime a animação da roleta girando nos displays
	RCALL Atraso ; Chama um atraso para a multiplexação ocorrer
	RJMP Roleta ; Retorna ao início do loop
	


final_loop:
	RET ; Retorna para a rotina chamadora
