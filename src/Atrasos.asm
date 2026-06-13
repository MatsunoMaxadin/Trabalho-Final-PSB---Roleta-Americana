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
; Rotina de Debounce
;
; Após apertar um botão, os contatos podem se fechar e abrir
; rapidamente por um curto instante. Isso causa pulsos elétricos
; indesejados que podem ser lidos como vários cliques.
;
; Esta rotina espera um pequeno tempo antes de aceitar o
; comando, garantindo que o botão esteja realmente pressionado.
; ----------------------------------------------------------
Atraso_Debounce:		; atraso para o debounce dos botões
    LDI R29, 150            

loop_debounce:
    RCALL Mostrar_Display   ; Atualiza os displays para não "apagarem"
    DEC R29                 
    BRNE loop_debounce
    
    RET   
