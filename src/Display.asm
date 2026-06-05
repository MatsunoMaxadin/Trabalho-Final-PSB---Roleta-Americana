.ORG 0x090

Display:

testa_inicial: 
CPI flagModo, 0x00; 
BRNE testa_par
LDI AUX, 0xE7 ; "P"
RCALL decod_A
LDI AUX, 0x74 ; "L"
RCALL decod_B
LDI AUX, 0xEF ; "A"
RCALL decod_C
LDI AUX, 0xCE ; "Y"
RCALL decod_D
RET


testa_par:
CPI flagModo, 0x01
BRNE testa_impar
LDI AUX, 0xE7 ; "P"
RCALL decod_B
LDI AUX, 0xEF ; "A"
RCALL decod_C
LDI AUX, 0xA4 ; "R"
RCALL decod_D
RET

testa_impar:
CPI flagModo, 0x02
BRNE testa_vermelho
LDI AUX, 0x0E ; "I"
RCALL decod_B
LDI AUX, 0xE7 ; "P"
RCALL decod_C
LDI AUX, 0xA4 ; "R"
RCALL decod_D
RET

testa_vermelho:
CPI flagModo, 0x03
BRNE testa_preto
LDI AUX, 0x3C ; "V"
RCALL decod_B
LDI AUX, 0xF5 ; "E"
RCALL decod_C
LDI AUX, 0xA4 ; "R"
RCALL decod_D
RET

testa_preto:
CPI flagModo, 0x04
BRNE testa_numEsp
LDI AUX, 0xE7 ; "P"
RCALL decod_B
LDI AUX, 0xA4 ; "R"
RCALL decod_C
LDI AUX, 0xF5 ; "E"
RCALL decod_D
RET

testa_numEsp:
LDI AUX, 0xAC ; "N"
RCALL decod_A
LDI AUX, 0x84 ; "-"
RCALL decod_B
LDI AUX, 0xA
RCALL encontrar_dezena_e_unidade
RCALL decod_D
MOV AUX, AUXB ; envia o valor da dezena para AUX
RCALL decod_C
RET

decod_A:
CBI PORTC, flagA ; habilitando apenas o display A
SBI PORTC, flagB
SBI PORTC, flagC
SBI PORTC, flagD

OUT DISPLAY, AUX
RET

decod_B:
CBI PORTC, flagB ; habilitando apenas o display B
SBI PORTC, flagA
SBI PORTC, flagC
SBI PORTC, flagD

OUT DISPLAY, AUX
RET

decod_C:
CBI PORTC, flagC ; habilitando apenas o display C
SBI PORTC, flagA
SBI PORTC, flagB
SBI PORTC, flagD

OUT DISPLAY, AUX
RET

decod_D:
CBI PORTC, flagD ; habilitando apenas o display D
SBI PORTC, flagA
SBI PORTC, flagB
SBI PORTC, flagC

OUT DISPLAY, AUX
RET

encontrar_dezena_e_unidade:
MOV AUX, numEscolhido
LDI AUXB, 0x00
div_10:

CPI AUX, 10
BRLO FimDiv ; se for menor que 10, encerra, e AUX nos dá a unidade
SUBI AUX, 10 ; "AUX - 10"

INC AUXB ; incrementando toda vez que subtraimos 10, para encontrar a dezena
RJMP div_10

FimDiv:
RET





