.ORG 0x090

Mostrar_Display:

CPI flagSorteio, 0x00
BREQ testa_inicial
CPI flagSorteio, 0x01
BREQ jump_loop

RJMP mostra_resultado

jump_loop:
RJMP loop_roleta

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
SBI PORTC, flagA ; habilitando apenas o display A
CBI PORTC, flagB
CBI PORTC, flagC
CBI PORTC, flagD

OUT DISPLAY, AUX
RCALL Atraso
RET

decod_B:
SBI PORTC, flagB ; habilitando apenas o display B
CBI PORTC, flagA
CBI PORTC, flagC
CBI PORTC, flagD

OUT DISPLAY, AUX
RCALL Atraso
RET

decod_C:
SBI PORTC, flagC ; habilitando apenas o display C
CBI PORTC, flagA
CBI PORTC, flagB
CBI PORTC, flagD

OUT DISPLAY, AUX
RCALL Atraso
RET

decod_D:
SBI PORTC, flagD ; habilitando apenas o display D
CBI PORTC, flagA
CBI PORTC, flagB
CBI PORTC, flagC

OUT DISPLAY, AUX
RCALL Atraso
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

LDI ZH, HIGH(Tabela_numero << 1) 
LDI ZL, LOW(Tabela_numero << 1) 

ADD ZL, AUX
BRCC display_unidade
	
INC ZH 

display_unidade:

LPM R0, Z 
MOV AUX, R0

RCALL decod_D
RET




decod_Dezena:
LDI ZH, HIGH(Tabela_numero << 1) 
LDI ZL, LOW(Tabela_numero << 1) 

ADD ZL, AUXB
BRCC display_dezena
	
INC ZH 

display_dezena:

LPM R0, Z 
MOV AUX, R0

RCALL decod_C
RET


mostra_resultado:
LDI AUX, 0xAC ; "N"
RCALL decod_A
LDI AUX, 0x84 ; "-"
RCALL decod_B
CPI resultado, 0x25
BREQ caso_0
MOV AUX, resultado
RCALL encontrar_dezena_e_unidade
RCALL decod_Unidade
RCALL decod_Dezena
RET
caso_0:
LDI AUX, 0x00
RCALL decod_C
RET

loop_roleta:
LDI AUX, 0xAC ; "N"
RCALL decod_A
LDI AUX, 0x84 ; "-"
RCALL decod_B
LDI ZH, HIGH(Tabela_roleta << 1) 
LDI ZL, LOW(Tabela_roleta << 1) 

ADD ZL, contador
BRCC display_roleta
	
INC ZH 

display_roleta:

LPM R0, Z
MOV AUX, R0

CPI contador, 0x04
BRLO display_direita
RCALL decod_C
RJMP incrementa_contador
display_direita:
RCALL decod_D

incrementa_contador:
INC contador
CPI contador, 0x08
BREQ zerar_contador
RET
zerar_contador:
LDI contador, 0x00
RET






Tabela_numero: 
.db 0x7F, 0x0E, 0xB7, 0x9F, 0xCE, 0xDB, 0xFB, 0x0F, 0xFF, 0xDF 

Tabela_roleta:
.db 0xEF, 0xFE, 0x75, 0xBE,  0xBE, 0xF5, 0xE5, 0xEF
