;
; Input_numero.asm
; Author : Guilherme Meira
; Funcao que habilita os botoes de incremento e decremento, alem de coletar o numero em que o usuario deseja apostar.
;

;.include "m328Pdef.inc"

; Definicoes 





Escolher_numero:

espera_soltar_modo:
    SBIS PINB, BOTAOMODO
    RJMP espera_soltar_modo

LDI numEscolhido, 0 ; Numero comeca em 0

; Loop Principal da funcao

Verifica_botoes:
	RCALL Mostrar_Display ; chama a funcao de display para mante-los acesos
	
	SBIS PINB, BOTAOINC ; verifica acionamento do botao
	RJMP Incrementar

	SBIS PINB, BOTAODEC
	RJMP Decrementar

	SBIS PINB, BOTAOMODO
	RJMP Trocar_modo

	SBIS PINB, ROLETAR
	RJMP Chama_roleta
	
	RJMP Verifica_botoes

Incrementar:
	RCALL Mostrar_Display
	SBIS PINB, BOTAOINC
	RJMP Incrementar  ;Espera soltar o botao

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
	RJMP Decrementar  ;Espera soltar o botao

	CPI numEscolhido, 0 ; compara com 0
	BRNE Faz_decremento

	LDI numEscolhido, 37 ; volta para 37 (00)
	RJMP Fim_dec

	Faz_decremento:
	DEC numEscolhido

	Fim_dec:
	RCALL Mostrar_Display
	RJMP Verifica_botoes

; Rotinas para sair do modo

Trocar_modo:
	RCALL Mostrar_Display
	SBIS PINB, BOTAOMODO
	RJMP Trocar_modo

	LDI flagModo, 1 ; volta para o modo 1 (par)

	RJMP Encerrar

Chama_roleta:

	RCALL Mostrar_Display
	SBIS PINB, ROLETAR
	RJMP Chama_roleta

	RCALL Roleta ; chama a funcao de girar a roleta

Encerrar:
	RET
