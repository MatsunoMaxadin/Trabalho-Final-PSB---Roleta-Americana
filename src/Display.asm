.ORG 0x090

Display:

CPI flagSorteio, 0x00
BRNE mostra_resultado

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
MOV AUX, numEscolhido
RCALL encontrar_dezena_e_unidade
RCALL decod_Unidade
RCALL decod_Dezena
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
LDI AUXB, 0x00
div_10:

CPI AUX, 10
BRLO FimDiv ; se for menor que 10, encerra, e AUX nos dá a unidade
SUBI AUX, 10 ; "AUX - 10"

INC AUXB ; incrementando toda vez que subtraimos 10, para encontrar a dezena
RJMP div_10

FimDiv:
RET

decod_Unidade:

LDI ZH, HIGH(Tabela << 1) 
LDI ZL, LOW(Tabela << 1) 

ADD ZL, AUX
BRCC display_unidade
	
INC ZH 

display_unidade:

LPM R0, Z 
MOV AUX, R0

RCALL decod_D
RET




decod_Dezena:
LDI ZH, HIGH(Tabela << 1) 
LDI ZL, LOW(Tabela << 1) 

ADD ZL, AUXB
BRCC display_dezena
	
INC ZH 

display_dezena:

LPM R0, Z 
MOV AUX, R0

RCALL decod_D
RET



mostra_resultado:
MOV AUX, resultado
RCALL encontrar_dezena_e_unidade
RCALL decod_Unidade
RCALL decod_Dezena
RET





Tabela: 
.db 0x7F, 0x0E, 0xB7, 0x9F, 0xCE, 0xDB, 0xFB, 0x0F, 0xFF, 0xDF 
