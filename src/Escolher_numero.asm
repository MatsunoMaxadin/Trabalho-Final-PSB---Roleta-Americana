;
; Função que verifica os botões de incremento e decremento, além de coletar o número em que o usuário deseja apostar.
;


Escolher_numero:

LDI numEscolhido, 0 ; número comeca em 0

; Loop principal da função

Verifica_botoes:
	RCALL Mostrar_Display ; chama a função de display para mantê-los acesos
	
	SBIS PINB, BOTAOINC ; verifica acionamento do botão
	RCALL Incrementar

	SBIS PINB, BOTAODEC
	RCALL Decrementar

	SBIS PINB, BOTAOMODO
	RET ; volta para o fluxo principal

	SBIS PINB, BOTAOROLETAR
	RET ; volta para o fluxo principal
	
	RJMP Verifica_botoes

Incrementar:
	RCALL Atraso_Debounce		; debounce precionar
	espera_soltar_soma:
	RCALL Mostrar_Display
	SBIS PINB, BOTAOINC
	RJMP espera_soltar_soma ; espera soltar o botão
	RCALL Atraso_Debounce		; debounce soltar

	CPI numEscolhido, 37 ; compara com 37
	BRNE Faz_incremento

	LDI numEscolhido, 0 ; volta para o zero
	RJMP Fim_inc

	Faz_incremento:
	INC numEscolhido

	Fim_inc:
	RCALL Mostrar_Display
	RET

Decrementar:
	RCALL Atraso_Debounce			; debounce pressionar
	espera_soltar_sub:
	RCALL Mostrar_Display
	SBIS PINB, BOTAODEC
	RJMP espera_soltar_sub  ; espera soltar o botão
	RCALL Atraso_Debounce			; debounce soltar

	CPI numEscolhido, 0 ; compara com 0
	BRNE Faz_decremento

	LDI numEscolhido, 37 ; volta para 37 (00)
	RJMP Fim_dec

	Faz_decremento:
	DEC numEscolhido

	Fim_dec:
	RCALL Mostrar_Display
	RET
