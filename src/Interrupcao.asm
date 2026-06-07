Interrup:
    CPI flagLoop, 0x01
    BREQ PararLoop          ; se loop girando: seta flagSorteio = 2 (parar)

    ; Loop NÃO está rodando: seta flagSorteio = 1 (iniciar sorteio)
    LDI flagSorteio, 0x01
    RJMP FimInterrup

PararLoop:
    LDI flagLoop, 0x00
    LDI flagSorteio, 0x02   ; sinaliza parada do loop

FimInterrup:
    RETI 
