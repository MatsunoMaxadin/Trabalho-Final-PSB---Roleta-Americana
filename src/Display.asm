; --- Rotina de Exibição no Display ---
; Responsável por controlar tudo que será mostrado nos displays de 7 segmentos.
; Os displays utilizados são quatro, sendo chamados de Display A, Display B, Display C e Display D, da esquerda para a direita.
; Dependendo do estado do sistema, pode exibir:
; - O modo de aposta selecionado;
; - A animação da roleta;
; - O resultado final do sorteio.

.ORG 0x090

Mostrar_Display:

CPI flagSorteio, 0x00 ; Verifica se o sorteio ainda não começou
BREQ testa_inicial ; Se sim, exibe o modo selecionado

CPI flagSorteio, 0x01 ; Verifica se o sorteio está em andamento
BREQ jump_loop ; Se sim, executa a animação da roleta

RJMP mostra_resultado ; Caso contrário, exibe o resultado final

jump_loop: ; indo para a rotina de loop da roleta com RJMP, pois está fora do alcance do BREQ (mais de 64 linhas abaixo)
RJMP loop_roleta

; --- Exibição dos Modos de Jogo ---
; Cada bloco verifica qual modo foi selecionado e imprime sua
; representação textual nos displays.

testa_inicial:
CPI flagModo, 0x00 ; Verifica se o modo atual é PLAY
BRNE testa_par

LDI AUX, 0xE7 ; Caractere "P"
RCALL decod_A

LDI AUX, 0x74 ; Caractere "L"
RCALL decod_B

LDI AUX, 0xEF ; Caractere "A"
RCALL decod_C

LDI AUX, 0xCE ; Caractere "Y"
RCALL decod_D

RET

testa_par:
CPI flagModo, 0x01 ; Verifica se o modo atual é PAR
BRNE testa_impar

LDI AUX, 0xE7 ; "P"
RCALL decod_B

LDI AUX, 0xEF ; "A"
RCALL decod_C

LDI AUX, 0xA4 ; "R"
RCALL decod_D

RET

testa_impar:
CPI flagModo, 0x02 ; Verifica se o modo atual é ÍMPAR
BRNE testa_vermelho

LDI AUX, 0x0E ; "I"
RCALL decod_B

LDI AUX, 0xE7 ; "P"
RCALL decod_C

LDI AUX, 0xA4 ; "R"
RCALL decod_D

RET

testa_vermelho:
CPI flagModo, 0x03 ; Verifica se o modo atual é VERMELHO
BRNE testa_preto

LDI AUX, 0x3C ; "V"
RCALL decod_B

LDI AUX, 0xF5 ; "E"
RCALL decod_C

LDI AUX, 0xA4 ; "R"
RCALL decod_D

RET

testa_preto:
CPI flagModo, 0x04 ; Verifica se o modo atual é PRETO
BRNE testa_numEsp

LDI AUX, 0xE7 ; "P"
RCALL decod_B

LDI AUX, 0xA4 ; "R"
RCALL decod_C

LDI AUX, 0xF5 ; "E"
RCALL decod_D

RET

; --- Exibição do Número Escolhido ---
; Caso o modo seja "Número Específico", exibe "N-" seguido
; do valor escolhido pelo jogador.

testa_numEsp:

LDI AUX, 0xAC ; "N"
RCALL decod_A

LDI AUX, 0x84 ; "-"
RCALL decod_B

MOV AUX, numEscolhido ; Carrega o número escolhido

RCALL encontrar_dezena_e_unidade ; Separa dezenas e unidades

RCALL decod_Unidade ; Exibe unidade
RCALL decod_Dezena ; Exibe dezena

RET

; ----------------------------------------------------------
; Rotinas de Multiplexação dos Displays
; Cada rotina habilita apenas um display e envia para ele
; o padrão armazenado em AUX.
; ----------------------------------------------------------

decod_A:

SBI PORTC, flagA ; Habilita display A
CBI PORTC, flagB
CBI PORTC, flagC
CBI PORTC, flagD

OUT DISPLAY, AUX ; Envia padrão para o display

RCALL Atraso ; Mantém o display aceso por um curto período

RET

decod_B:

SBI PORTC, flagB ; Habilita display B
CBI PORTC, flagA
CBI PORTC, flagC
CBI PORTC, flagD

OUT DISPLAY, AUX

RCALL Atraso

RET

decod_C:

SBI PORTC, flagC ; Habilita display C
CBI PORTC, flagA
CBI PORTC, flagB
CBI PORTC, flagD

OUT DISPLAY, AUX

RCALL Atraso

RET

decod_D:

SBI PORTC, flagD ; Habilita display D
CBI PORTC, flagA
CBI PORTC, flagB
CBI PORTC, flagC

OUT DISPLAY, AUX

RCALL Atraso

RET

; ----------------------------------------------------------
; Rotina de Conversão Decimal
; Recebe em AUX um número decimal e separa:
; AUX  -> unidade
; AUXB -> dezena
; ----------------------------------------------------------

encontrar_dezena_e_unidade:

LDI AUXB, 0x00 ; Inicializa contador de dezenas

div_10:

CPI AUX, 10 ; Verifica se ainda é possível subtrair 10
BRLO FimDiv ; Se menor que 10, terminou

SUBI AUX, 10 ; Remove uma dezena do valor

INC AUXB ; Conta uma dezena

RJMP div_10

FimDiv:
RET

; ----------------------------------------------------------
; Rotina de Decodificação da Unidade
; Utiliza a tabela de números para converter o valor da
; unidade em um padrão de display de 7 segmentos.
; ----------------------------------------------------------

decod_Unidade:

LDI ZH, HIGH(Tabela_numero << 1) ; Carrega os bits mais significativos do endereço da tabela_numero no registrador Z
LDI ZL, LOW(Tabela_numero << 1) ; Carrega os bits menos significativos do endereço da tabela_numero no registrador Z

ADD ZL, AUX ; soma o valor da unidade ao endereço base da tabela para obter o endereço desejado

BRCC display_unidade ; caso a soma tenha carry, incrementa a parte alta do endereço
INC ZH

display_unidade:

LPM R0, Z ; Lê o padrão da memória Flash

MOV AUX, R0 ; transfere o valor de R0 para AUX, registrador utilizado para imprimir no display.

RCALL decod_D ; Exibe no display D

RET

; ----------------------------------------------------------
; Rotina de Decodificação da Dezena
; Semelhante à rotina anterior, porém utilizando AUXB.
; ----------------------------------------------------------

decod_Dezena:

LDI ZH, HIGH(Tabela_numero << 1) ; Carrega os bits mais significativos do endereço da tabela_numero no registrador Z
LDI ZL, LOW(Tabela_numero << 1)  ; Carrega os bits menos significativos do endereço da tabela_numero no registrador Z

ADD ZL, AUXB ; Soma o valor da dezena ao endereço base da tabela para obter o endereço desejado

BRCC display_dezena ; Caso a soma gere carry, incrementa a parte alta do endereço
INC ZH

display_dezena:

LPM R0, Z ; Lê da memória Flash o padrão correspondente ao valor da dezena

MOV AUX, R0 ; Transfere o padrão lido para AUX, registrador utilizado para impressão

RCALL decod_C ; Exibe o padrão encontrado no display C

RET

; ----------------------------------------------------------
; Exibição do Resultado Final do Sorteio
; Mostra "N-" seguido do número sorteado.
; O valor 37 representa a posição especial "0" da roleta.
; ----------------------------------------------------------

mostra_resultado:

LDI AUX, 0xAC ; "N"
RCALL decod_A ; imprime o valor no display A

LDI AUX, 0x84 ; "-"
RCALL decod_B ; imprime o valor no display B

CPI resultado, 0x25 ; Verifica se o resultado corresponde ao número 0
BREQ caso_0

MOV AUX, resultado ; transfere o resultado do sorteio para o registrador AUX

RCALL encontrar_dezena_e_unidade ; chama a função para separar a unidade e a dezena em dois registradores diferentes.

RCALL decod_Unidade ; imprime o valor da unidade no display D
RCALL decod_Dezena ; imprime o valor da dezena no display C

RET

caso_0:

LDI AUX, 0x00 

RCALL decod_C ; imprime o valor 0 apenas no display C, deixando o display D vazio.

RET

; ----------------------------------------------------------
; Rotina de Animação da Roleta
; Alterna os displays entre esquerda e direita para criar
; efeito visual durante o sorteio.
; ----------------------------------------------------------

loop_roleta:

LDI ZH, HIGH(Tabela_roleta << 1); Carrega os bits mais significativos do endereço da tabela_roleta no registrador Z
LDI ZL, LOW(Tabela_roleta << 1) ; Carrega os bits menos significativos do endereço da tabela_numero no registrador Z


ADD ZL, contador ; Somando o valor do contador ao endereço inicial para encontrar o próximo padrão da animação

BRCC display_roleta ; caso aconteça carry, incrementa a parte alta do endereço
INC ZH

display_roleta:

LPM R0, Z ; Lendo o padrão atual da animação

MOV AUX, R0 ; transferindo o valor para AUX, registrador utilizado para imprimir o valor nos displays

CPI contador, 0x04 ; Verifica qual lado da animação deve acender
BRLO display_direita

SBI PORTC, flagA ; Acende A e C simultaneamente
SBI PORTC, flagC
CBI PORTC, flagB
CBI PORTC, flagD

OUT DISPLAY, AUX ; Imprime o padrão em display A e display C

RCALL Atraso_maior ; Chama um atraso maior para uma animação mais suave

RJMP incrementa_contador 

display_direita:

SBI PORTC, flagB ; Acende B e D simultaneamente
SBI PORTC, flagD
CBI PORTC, flagA
CBI PORTC, flagC

OUT DISPLAY, AUX ; Imprime o padrão em display B e display D

RCALL Atraso_maior ; Chama um atraso maior para uma animação mais suave

incrementa_contador:

INC contador ; Avança para o próximo quadro da animação

CPI contador, 0x08 ; Verifica se chegou ao final da tabela
BREQ zerar_contador ; Se chegou, volta ao início

RET

zerar_contador:

LDI contador, 0x00 ; Reinicia a animação

RET

; ----------------------------------------------------------
; Rotinas de Atraso
; Utilizadas para multiplexação dos displays e controle da
; velocidade da animação da roleta.
; ----------------------------------------------------------


; ----------------------------------------------------------
; Rotina de Atraso Simples
;
; Produz um pequeno atraso utilizado principalmente na
; multiplexação dos displays.
;
; O atraso é obtido através da execução repetitiva de um
; laço que decrementa um registrador até que seu valor
; atinja zero.
; ----------------------------------------------------------

Atraso:

LDI AUX, 255 ; Carrega o valor máximo de um byte em AUX
MOV R9, AUX ; Utiliza R9 como contador do atraso

loop:

DEC R9 ; Decrementa o contador em uma unidade
BRNE loop ; Enquanto R9 for diferente de zero, continua no laço

RET ; Retorna para a rotina chamadora


; ----------------------------------------------------------
; Rotina de Atraso Maior
;
; Produz um atraso significativamente maior que o atraso
; simples. É utilizada durante a animação da roleta para
; tornar a transição entre os quadros perceptível ao
; usuário.
;
; O atraso é implementado através de três contadores
; encadeados (R9, R8 e R7), aumentando consideravelmente
; o número total de iterações executadas.
; ----------------------------------------------------------

Atraso_maior:

LDI AUX, 255 ; Valor inicial dos contadores internos
MOV R9, AUX ; Primeiro contador
MOV R8, AUX ; Segundo contador

LDI AUX, 6 ; Valor do contador externo
MOV R7, AUX ; Terceiro contador

loop_maior:

DEC R9 ; Decrementa o contador mais interno
BRNE loop_maior ; Enquanto R9 não for zero, continua executando

DEC R8 ; Quando R9 chega a zero, decrementa R8
BRNE loop_maior ; Se R8 não for zero, reinicia o ciclo de R9

DEC R7 ; Quando R8 chega a zero, decrementa R7
BRNE loop_maior ; Se R7 não for zero, reinicia todo o processo

RET ; Retorna para a rotina chamadora

; ----------------------------------------------------------
; Tabela de Conversão para Display de 7 Segmentos
; Índice da tabela = valor numérico.
; ----------------------------------------------------------

Tabela_numero:
.db 0x7F, 0x0E, 0xB7, 0x9F, 0xCE, 0xDD, 0xFD, 0x0F, 0xFF, 0xDF

; ----------------------------------------------------------
; Tabela de Animação da Roleta
; Cada posição representa um quadro da animação exibida
; durante o sorteio.
; ----------------------------------------------------------

Tabela_roleta:
.db 0x05, 0x06, 0x0C, 0x14, 0x14, 0x24, 0x44, 0x05
