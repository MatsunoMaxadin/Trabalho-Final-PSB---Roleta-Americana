Avaliar_resultado:
	; Zera LEDS que serão utilizados
	CBI PORTC, LEDVITORIA ; Apaga LED de Vitória
	CBI PORTC, LEDVERM ; Apaga LED Vermelho
	CBI PORTB, LEDPRET ; Apaga LED Preto
	CBI PORTB, LEDVERDE ; Apaga LED Verde

	; Usa ponteiro Z para ler a tabela de cores da memória Flash
	LDI ZH, HIGH(Tabela_cores << 1) ; Carrega parte alta do endereço da tabeça
	LDI ZL, LOW(Tabela_cores << 1) ; Carrega parte baixa do endereço da tabela
	ADD ZL, resultado ; Soma número sorteado na roleta (0 a 37) ao ponteiro Z
	BRCC sem_carry_cor ; Se a soma não estourar o Carry, não incrementa ZH
	INC ZH ; Se a soma estourou, acrescenta o vai um para ZH (parte alta)

sem_carry_cor:
	LPM R16, Z ; coloca cor da tabela em R16 usando o ponteiro Z (0 = Verde, 1 = Vermelho, 2 = Preto)

	CPI R16, 0 ; Verifica se é verde
	BRNE checa_vermelho ; Se não é verde, checa vermelho
	SBI PORTB, LEDVERDE ; Se for Verde, acende LED VERDE

	; Abaixo segue o tratamento para 0 e 00. Representa derrota imediata em todos os modos, exceto o Modo 5 (Número específico)
	CPI flagModo, 0x05 ; Verifica se jogador escolheu Modo 5
	BREQ checa_especifico ; Se sim, vai para rotina de verificar número específico
	RJMP define_derrota ; Se não, perde automaticamente e vai para rotina de derrota

checa_vermelho:
	CPI R16, 1 ; Verifica se cor é Vermelha
	BRNE checa_preto ; Se não for, checa se é Preta
	SBI PORTC, LEDVERM ; Acende LED Vermelho
	RJMP avalia_modo ; Verifica modo de aposta

checa_preto:
	SBI PORTB, LEDPRET ; Liga LED Preto

avalia_modo:
	CPI flagModo, 0x01 ; Modo 1 = Par
	BREQ checa_par
	CPI flagModo, 0x02 ; Modo 2 = Ímpar
	BREQ checa_impar
	CPI flagModo, 0x03 ; Modo 3 = Vermelho
	BREQ checa_modo_verm 
	CPI flagModo, 0x04 ; Modo 4 = Preto
	BREQ checa_modo_preto
	CPI flagModo, 0x05 ; Modo 5 = Número específico
	BREQ checa_especifico
	RJMP define_derrota ; Trava. Se não for nenhum modo, é derrota imediata

checa_par:
	SBRC resultado, 0 ; Verifica Bit 0. Se for 0 (par) pula a próxima linha
	RJMP define_derrota ; Se o Bit 0 for 1, é ímpar, vai para Derrota
	RJMP define_vitoria ; Se pulou linha, é par, vai para Vitoria

checa_impar:
	SBRS resultado, 0 ;Verifica Bit 0. Se for 1 (ímpar) pula a próxima linha
	RJMP define_derrota ; Se o Bit 0 for 0, é par, vai para Derrota
	RJMP define_vitoria ; Se pulou linha, é par, vai para Vitoria

checa_modo_verm:
	CPI R16, 1 ; Compara cor sorteada com vermelho
	BREQ define_vitoria ; Se igual, Vitória
	RJMP define_derrota ; Se diferente, Derrota

checa_modo_preto:
	CPI R16, 2 ; Compara cor sorteada com preto
	BREQ define_vitoria ; Se igual, Vitória
	RJMP define_derrota ; Se diferente, Derrota

checa_especifico:
	CP resultado, numEscolhido ; Compara Número sorteado com Número selecionado
	BREQ define_vitoria ; Se igual, Vitória
	RJMP define_derrota ; Se diferente, Derrota

define_vitoria:
	LDI R26, 1 ; R26 será usado como "flag" para indicar vitoria
	RJMP loop_fim_jogo

define_derrota:
	LDI R26, 0 ; R26 será usado como "flag" para indicar derrota
	RJMP loop_fim_jogo

loop_fim_jogo:
	RCALL Mostrar_Display 

	CPI R26, 1 ; Verifica Vitória através do "flag"
	BRNE check_botao_sair ; Se R26 = 0, LEDS não piscam

	; Rotina de pequeno atraso para ser possível ver LEDs apagando e acendendo
	INC R27
	CPI R27,250 ; Pequeno atraso da inversão de LEDs
	BRLO check_botao_sair ; Se for menor que 200, pula
	LDI R27, 0 ; Zera contador R27

	INC R28
	CPI R28, 15
	BRLO check_botao_sair
	LDI R28, 0


	SBIC PORTC, LEDVITORIA ; Verifica se LEDVITORIA está ligado
	RJMP apaga_vitoria ; Se está ligado, pula para rotina de apagar
	SBI PORTC, LEDVITORIA ; Se está apagado, liga LEDVITORIA
	RJMP check_botao_sair

apaga_vitoria:
	CBI PORTC, LEDVITORIA ; Desliga o LED

check_botao_sair:
	SBIC PINB, BOTAOMODO ; Verifica se Botão Modo foi pressionado
	RJMP loop_fim_jogo ; Enquanto não pressionar, continua exibindo resultado/piscando LEDS

espera_soltar_sair:
	RCALL Mostrar_Display 
	SBIS PINB, BOTAOMODO
	RJMP espera_soltar_sair ; Loop até soltar botão

	CBI PORTC, LEDVITORIA ; Apaga LED de Vitória
	CBI PORTC, LEDVERM ; Apaga LED Vermelho
	CBI PORTB, LEDPRET ; Apaga LED Preto
	CBI PORTB, LEDVERDE ; Apaga LED Verde

	LDI flagSorteio, 0 ; Reseta flag, volta para Menu
	LDI flagModo, 0 ; Reseta modo

	RJMP Principal

Tabela_Cores:
	.db 0, 1, 2, 1, 2, 1, 2, 1, 2, 1  ; Números 0 a 9
	.db 2, 2, 1, 2, 1, 2, 1, 2, 1, 1  ; Números 10 a 19
	.db 2, 1, 2, 1, 2, 1, 2, 1, 2, 2  ; Números 20 a 29
	.db 1, 2, 1, 2, 1, 2, 1, 0        ; Números 30 a 36 e o 37 (representa o 00)
