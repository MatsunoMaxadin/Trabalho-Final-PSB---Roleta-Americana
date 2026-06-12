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
