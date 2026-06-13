; ----------------------------------------------------------
; Rotina de Interrupção INT0
;
; Esta rotina é chamada quando o botão de parada é pressionado.
; Se a roleta estiver ativa (flagLoop = 1), ela para a roleta
; e solicita a exibição do resultado final.
; Caso contrário, ignora a interrupção para evitar bounce.
; ----------------------------------------------------------
Interrup:
    CPI flagLoop, 0x01
    BREQ PararLoop          ; se loop girando: seta flagSorteio = 2 (parar)

    ; Loop NÃO está rodando - proteção contra bounce
    RJMP FimInterrup

PararLoop:
    LDI flagLoop, 0x00		; faz o loop parar
    LDI flagSorteio, 0x02   ; indica ao display para exibir resultado

FimInterrup:
    RETI 
