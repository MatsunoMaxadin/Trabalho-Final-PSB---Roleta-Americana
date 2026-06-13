; ----------------------------------------------------------
; Rotina de Controle da Roleta
; Responsável por simular o giro da roleta durante o sorteio.
; Incrementa o valor do resultado até atingir o limite (37),
; reiniciando em 0 quando necessário. Enquanto a flag de loop
; estiver ativa, mantém a animação nos displays.
; ----------------------------------------------------------

Roleta:
    CPI flagLoop, 1        ; Verifica se a flag de loop está ativa
    BRNE final_loop        ; Se não estiver, encerra a rotina

    CPI resultado, 0x25    ; Confere se o resultado chegou ao valor máximo (37 decimal)
    BRLO incrementa_resultado ; Se ainda não chegou, vai para incremento
    LDI resultado, 0x00    ; Se chegou ao limite, reinicia o valor em 0
    RJMP Decod             ; Pula para a rotina de decodificação

incrementa_resultado:
    INC resultado          ; Incrementa o valor do resultado

Decod:
    RCALL Mostrar_Display  ; Atualiza os displays com a animação da roleta
    RCALL Atraso           ; Chama atraso para permitir a multiplexação correta
    RJMP Roleta            ; Retorna ao início da rotina, mantendo o loop ativo

; ----------------------------------------------------------
; Finalização do Loop da Roleta
; Caso a flag de loop esteja desativada, encerra a rotina
; e desabilita interrupções.
; ----------------------------------------------------------

final_loop:
    CLI                    ; Desabilita interrupções
    RET                    ; Retorna para a rotina chamadora

