.nolist
.include "m328Pdef.inc"
.list

; colocando etiquetas para os pinos e definindo registradores
.equ DISPLAY = PORTD
.equ flagA = PC5
.equ flagB = PC4
.equ flagC = PC3
.equ flagD = PC2
.equ LEDVITORIA = PC1
.equ LEDVERM = PC0
.equ LEDPRET = PB5
.equ LEDVERDE = PB4
.equ BOTAOSORTEIO = PD2
.equ BOTAOMODO = PB0
.equ BOTAOINC = PB1
.equ BOTAODEC = PB2
.equ BOTAOROLETAR = PB3
.def dezena = R20
.def unidade = R21
.def flagModo = R22
.def flagSorteio = R23
.def flagLoop = R17
.def AUX = R16
.def AUXB = R24
.def resultado = R25
.def contador = R18
.def numEscolhido = R19


; incluindo outras funçoes
.include "Roletar.asm" 
.include "Display.asm"
.include "Interrupcao.asm"
.include "Escolher_numero.asm"
.include "Resultado_roleta.asm"

.ORG 0x000
RJMP inicializacoes	; pula para o começo do programa

.ORG 0X0002		; endereço reservado para interrupção INT0 - PD2
JMP	Interrup	; pula para rotina de interrupção

inicializacoes:
LDI AUX, 0b11111011 
OUT DDRD, AUX ; inicializando o DISPLAY, com todos os pinos sendo de saída, menos PD2, que é a entrada para a interrupção
LDI AUX, 0xff 
OUT DDRC, AUX ; inicializando todos os pinos da portaC como saída
LDI AUX, 0b11110000
OUT DDRB, AUX ; inicializando os 4 primeiros pinos da PORTB como entrada (botoes) e os 4 últimos como saída (LEDS)
LDI AUX, 0b00001111
OUT PORTB, AUX ; ativando o pull-up para os botoes e desligando os LEDS
LDI AUX, 0x00
OUT PORTC, AUX ; ligando os displays
LDI dezena, 0x00 ; zerando os valores da roleta
LDI unidade, 0x00

; configuração da interrupção - borda de descida

LDI AUX, 0b00000010		 
STS EICRA, AUX		;	faz ISC00=0 e ISC01=1, assim configurando borda de descida através do registrador EICRA (que exige STS e não OUT)
LDI AUX, 0b00000001	;	habilita a interrpção INT0 através do registrador EIMSK
OUT EIMSK, AUX		

; fim da configuração de interrupção

LDI AUX, 0b00000100
OUT DISPLAY, AUX ; desligando o display
LDI flagModo, 0x00 ; iniciando flagModo com 0
LDI flagSorteio, 0x00 
LDI flagLoop, 0



Principal:
    LDI flagModo, 0x00          ; registrador de modo começa em 0
    LDI flagSorteio, 0x00       ; flag de sorteio limpa
    LDI flagLoop, 0x00          ; flag de loop limpa
    CLI                         ; desativa interrupção

    ; Apaga todos os LEDs (pull-up nos botões, LEDs desligados)
    LDI AUX, 0b00001111
    OUT PORTB, AUX
    LDI AUX, 0x00
    OUT PORTC, AUX

    ; chama Display para mostrar tela inicial (modo 0 = tela PLAY)
    RCALL Mostrar_Display


; Loop principal: aguarda BOTAOMODO ou disparo do SORTEIO
LoopPrincipal:
    RCALL Mostrar_Display           ; atualiza display continuamente
    ; --- Verifica BOTAOMODO (PB0) — ativo em LOW (pull-up) ---
    SBIS PINB, BOTAOMODO            ; pula próxima se botão NÃO pressionado
    return_modo: ; label para retornar da rotina de escolher número e atualizar flagModo
    RCALL TrataBotaoModo            ; botão pressionado: trata
    SBIS PINB, BOTAOROLETAR ; verifica se botão para começar a roleta foi pressionado
    RJMP VerificaModo
    	
    RJMP LoopPrincipal            ; senão continua no loop


; verifica se (1 <= flagModo <= 5)
VerificaModo:
    CPI flagModo, 0
    BREQ ModoInvalido               ; modo 0 (tela PLAY) não sorteia

    CPI flagModo, 6
    BRSH ModoInvalido               ; modo >= 6 não existe (segurança)

    ; Modo válido (1–5): aciona o sorteio
    LDI flagSorteio, 0x01 ; avisa ao display que está no modo animação de roleta
	LDI flagLoop, 1       ; faz rodar o loop infinito
	SEI					; ativa o serviço de interrupção      
    RCALL Roleta           
    RCALL Avaliar_resultado
    RJMP inicializacoes ; volta ao inicio após o sorteio

ModoInvalido:
    RJMP LoopPrincipal


; ============================================================
; TrataBotaoModo: debounce + cicla flagModo 0 -> 5 -> 0
;                 e acende o LED correspondente ao modo
; ============================================================
TrataBotaoModo:
    RCALL ATRASO                     ; debounce
    ; Aguarda soltar o botão antes de registrar
AguardaSoltarModo:
    SBIS PINB, BOTAOMODO
    RJMP AguardaSoltarModo          ; ainda pressionado: espera

    INC flagModo
    CPI flagModo, 6
    BRNE AtualizaLEDsModo
    LDI flagModo, 0x00              ; após modo 5, volta ao modo 0

AtualizaLEDsModo:
    ; Apaga todos os LEDs antes de acender o do modo atual
    LDI AUX, 0b00001111
    OUT PORTB, AUX                  ; desliga LEDPRET (PB5) e mantém pull-ups
    LDI AUX, 0x00
    OUT PORTC, AUX                  ; desliga todos LEDs da PORTC

    ; Seleciona LED pelo modo
    CPI flagModo, 0
    BREQ LedModo0                   ; tela PLAY: nenhum LED especial

    CPI flagModo, 1
    BREQ LedModo1                   ; PAR: LED branco

    CPI flagModo, 2
    BREQ LedModo2                   ; ÍMPAR: LED branco (diferente do par se quiser)

    CPI flagModo, 3
    BREQ LedModo3                   ; VERMELHO: LED vermelho

    CPI flagModo, 4
    BREQ LedModo4                   ; PRETO: LED preto

    CPI flagModo, 5
    BREQ LedModo5                   ; Nº ESPECÍFICO: nenhum LED (INC/DEC disponíveis)

    RET

LedModo0:
    ; Modo 0: tela PLAY — sem LED aceso
    LDI dezena, 0x00
    LDI unidade, 0x00
    RET

LedModo1:
    ; PAR — acende LED branco
    SBI PORTB, LEDVERDE
    RET

LedModo2:
    ; ÍMPAR — acende LED verde
    SBI PORTB, LEDVERDE
    RET

LedModo3:
    ; VERMELHO — acende LED vermelho
    SBI PORTC, LEDVERM
    RET

LedModo4:
    SBI PORTB, LEDPRET
    RET

LedModo5:
    RJMP Escolher_numero
  
