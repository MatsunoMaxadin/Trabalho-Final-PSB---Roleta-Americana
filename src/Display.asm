.ORG 0x090

Mostrar_Display:

CPI flagSorteio, 0x00 ; verificando se está sendo escolhido o modo
BREQ testa_inicial
CPI flagSorteio, 0x01 ; Verificando se está ocorrendo o sorteio
BREQ jump_loop

RJMP mostra_resultado ; mostra o resultado do sorteio

jump_loop:
RJMP loop_roleta

testa_inicial: 
CPI flagModo, 0x00 ; confere se está no modo "PLAY" (início do jogo) para imprimir no display
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
CPI flagModo, 0x01 ; confere se está no modo "PAR" para imprimir no display
BRNE testa_impar
LDI AUX, 0xE7 ; "P"
RCALL decod_B
LDI AUX, 0xEF ; "A"
RCALL decod_C
LDI AUX, 0xA4 ; "R"
RCALL decod_D
RET

testa_impar:
CPI flagModo, 0x02 ; confere se está no modo "IMPAR" para imprimir no display
BRNE testa_vermelho
LDI AUX, 0x0E ; "I"
RCALL decod_B
LDI AUX, 0xE7 ; "P"
RCALL decod_C
LDI AUX, 0xA4 ; "R"
RCALL decod_D
RET

testa_vermelho:
CPI flagModo, 0x03 ; confere se está no modo "VERMELHO" para imprimir no display
BRNE testa_preto
LDI AUX, 0x3C ; "V"
RCALL decod_B
LDI AUX, 0xF5 ; "E"
RCALL decod_C
LDI AUX, 0xA4 ; "R"
RCALL decod_D
RET

testa_preto:
CPI flagModo, 0x04 ; confere se está no modo "PRETO" para imprimir no display
BRNE testa_numEsp
LDI AUX, 0xE7 ; "P"
RCALL decod_B
LDI AUX, 0xA4 ; "R"
RCALL decod_C
LDI AUX, 0xF5 ; "E"
RCALL decod_D
RET

testa_numEsp: ; como é o último caso possível, não precisa verificar, e imprime o modo "NUMERO ESCOLHIDO" no display
LDI AUX, 0xAC ; "N"
RCALL decod_A
LDI AUX, 0x84 ; "-"
RCALL decod_B
MOV AUX, numEscolhido
RCALL encontrar_dezena_e_unidade ; separando o número escolhido em dezena e unidade para imprimir
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

LDI ZH, HIGH(Tabela_numero << 1) ; pegando o endereço da tabela de números
LDI ZL, LOW(Tabela_numero << 1) 

ADD ZL, AUX ; adiciona o valor da unidade com ZL. Se acontecer carry, incrementa ZH.
BRCC display_unidade
	
INC ZH 

display_unidade:

LPM R0, Z 
MOV AUX, R0

RCALL decod_D
RET




decod_Dezena:
LDI ZH, HIGH(Tabela_numero << 1) ; pegando o endereço da tabela de números
LDI ZL, LOW(Tabela_numero << 1) 

ADD ZL, AUXB ; adiciona o valor da dezena com ZH. Se acontecer carry, incrementa ZH.
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
LDI ZH, HIGH(Tabela_roleta << 1) ; lendo o 
LDI ZL, LOW(Tabela_roleta << 1) 

ADD ZL, contador
BRCC display_roleta
	
INC ZH 

display_roleta:

LPM R0, Z
MOV AUX, R0

CPI contador, 0x04
BRLO display_direita
SBI PORTC, flagA ; configurando a multiplexação para A e C ligarem ao mesmo tempo
SBI PORTC, flagC
CBI PORTC, flagB
CBI PORTC, flagD
OUT DISPLAY, AUX
RCALL Atraso_maior ; chamando um atraso maior para uma animação mais suave

RJMP incrementa_contador
display_direita:
SBI PORTC, flagB ; configurando a multiplexação para B e D ligarem ao mesmo tempo
SBI PORTC, flagD
CBI PORTC, flagA
CBI PORTC, flagC
OUT DISPLAY, AUX
RCALL Atraso_maior ; chamando um atraso maior para uma animação mais suave

incrementa_contador:
INC contador
CPI contador, 0x08
BREQ zerar_contador
RET
zerar_contador:
LDI contador, 0x00
RET



Atraso:
	LDI AUX, 255
	MOV R9, AUX

loop:
	DEC R9
	BRNE loop
	RET
	
Atraso_maior:

	LDI AUX, 255
	MOV R9, AUX
	MOV R8, AUX
	LDI AUX, 6
	MOV R7, AUX
	
loop_maior:

	
	
	DEC R9
	BRNE loop_maior
	DEC R8
	BRNE loop_maior
	DEC R7
	BRNE loop_maior
	
	
	RET
	


Tabela_numero: 
.db 0x7F, 0x0E, 0xB7, 0x9F, 0xCE, 0xDD, 0xFD, 0x0F, 0xFF, 0xDF 

Tabela_roleta:
.db 0x05, 0x06, 0x0C, 0x14, 0x14, 0x24, 0x44, 0x05
