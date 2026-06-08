;
; Função que verifica os botões de incremento e decremento, além de coletar o número em que o usuário deseja apostar.
;

;.include "m328Pdef.inc"

Escolher_numero:

LDI numEscolhido, 0 ; número comeca em 0

; Loop principal da função

Verifica_botoes:
	RCALL Mostrar_Display ; chama a função de display para mantê-los acesos
	
	SBIS PINB, BOTAOINC ; verifica acionamento do botão
	RJMP Incrementar

	SBIS PINB, BOTAODEC
	RJMP Decrementar

	SBIS PINB, BOTAOMODO
	RJMP return_modo ; vai para a parte do código do programa que chama o tratamento da alteração do modo

	SBIS PINB, BOTAOROLETAR
	RJMP VerificaModo ; vai para a parte do código do programa que irá chamar a rotina de roletar
	
	RJMP Verifica_botoes

Incrementar:
	RCALL Mostrar_Display
	SBIS PINB, BOTAOINC
	RJMP Incrementar  ; espera soltar o botão

	CPI numEscolhido, 37 ; compara com 37
	BRNE Faz_incremento

	LDI numEscolhido, 0 ; volta para o zero
	RJMP Fim_inc

	Faz_incremento:
	INC numEscolhido

	Fim_inc:
	RCALL Mostrar_Display
	RJMP Verifica_botoes

Decrementar:
	RCALL Mostrar_Display
	SBIS PINB, BOTAODEC
	RJMP Decrementar  ; espera soltar o botão

	CPI numEscolhido, 0 ; compara com 0
	BRNE Faz_decremento

	LDI numEscolhido, 37 ; volta para 37 (00)
	RJMP Fim_dec

	Faz_decremento:
	DEC numEscolhido

	Fim_dec:
	RCALL Mostrar_Display
	RJMP Verifica_botoes
