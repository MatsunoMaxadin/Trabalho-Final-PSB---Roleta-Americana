; ----------------------------------------------------------
; Rotina de Controle da Roleta
; Responsável por simular o giro da roleta durante o sorteio.
; Incrementa o valor do resultado até atingir o limite (37),
; reiniciando em 0 quando necessário. Enquanto a flag de loop
; estiver ativa, mantém a animação nos displays.
; ----------------------------------------------------------

Roleta:
	CPI flagLoop, 1 ; Verifica se a flag para o loop está ativa.
	BRNE final_loop ; Se não, encerra o loop.
	
	CPI resultado, 0X25 ; Confere se o resultado chegou no valor máximo (37).
	BRLO incrementa_resultado ; Se não, incrementa
	LDI resultado, 0x00 ; Se sim, Zera o valor
	RJMP Decod ; Pula para a rotina de decodificação
	incrementa_resultado:
	INC resultado ; incrementando o resultado
	Decod:
	RCALL Mostrar_Display ; Imprime a animação da roleta girando nos displays
	RCALL Atraso ; Chama um atraso para a multiplexação ocorrer
	RJMP Roleta ; Retorna ao início do loop
	

; ----------------------------------------------------------
; Finalização do Loop da Roleta
; Caso a flag de loop esteja desativada, encerra a rotina
; e desabilita interrupções.
; ----------------------------------------------------------

final_loop:
    CLI ; desabilita interrupção
	RET ; Retorna para a rotina chamadora
