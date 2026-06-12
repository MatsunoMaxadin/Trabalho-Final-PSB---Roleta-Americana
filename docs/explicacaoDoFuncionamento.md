# 3.4 Explicação do Funcionamento
Para o funcionamento da roleta americana, foram utilizados um total de 7 módulos diferentes e mais 2 módulos auxiliares (`definições.inc` e `m328Pdef.inc`) que serão explicados em seguida, módulo a módulo.

## 3.4.1 Atrasos.asm
O funcionamento de um ATMega328 e outros microcontroladores ocorre em frequências na escala de Megahertz(MHz), o que torna a execução das instruções imperceptíveis aos olhos humanos. Para tornar perceptível cada etapa do programa, a equipe implementou um módulo de temporização baseada na utilização e decrementação de registradores.

Este módulo é subdivido em três rotinas fundamentais, cada uma com um propósito específico para alinhar o funcionamento do circuito digital com o físico.

### 3.4.1.1 Temporização para a Multiplexação
Chamada no módulo de `Atraso` consiste em um atraso simples que utiliza um laço de repetição (loop) decrementando um Registrador de 8 bits (R9) carregado com seu valor máximo (255). A instrução `BRNE` mantém o loop até que o Registrador chegue a 0. 

No Hardware, esse atraso dura uma fração de milissegundos, mas permite que o display tenha tempo suficiente para acender um LED, antes de apagar e passar para o próximo dígito, gerando a ilusão de que todos estão ligados simultaneamente, sem que ocorra o efeito de cintilação.

### 3.4.1.2 Temporização da Animação
Chamada no módulo de `Atraso Maior`, utiliza 3 registradores de 8 bits (R7, R8 e R9), funcionando através de loops aninhados. Neste caso, R7 funciona como o `mestre` pois é carregado com 6, fator multiplicativo para os demais registradores, R8 e R9, carregados com 255. Utilizando também da instrução `BRNE`, faz o processador executar centenas de milhares de ciclos.

No Hardware, esse atraso torna possível o olho humano enxergar as animações mostradas no Display, como a animação da roleta 

### 3.4.1.3 Temporização para Tratamento de Ruído
Ao pressionar um botão físico são geradas pequenas centelhas elétricas que fazem com que o microcontrolador leia como diversos pressionamentos ao mesmo tempo (o chamado bounce). Para isso, a rotina `Atraso_Debounce` executa um laço de 150 repetições, chamando a rotina `Mostrar_Display` em seu interior. Desse modo, o sistema gasta o tempo necessário para ignorar o ruído elétrico do botão, enquanto mantém os display multiplexados ativos.

## 3.4.2 Display.asm
Este é o módulo responsável pela interpretaçao dos sinais elétricos e variáveis em números que serão exibidos nos quatro displays de 7 segmentos.
### 3.4.2.1 Máquina de Estados (Mostrar_Display)
Essa é a rotina principal do Display. É orientada principalmente atráves do `flagSorteio` e as instruções `CPI` e `BREQ`. 
- `flagSorteio` = 0 - Sorteio ainda não começou. Leva para subrotina `testa_inicial` em que o `flagModo` que vai de 0 a 5 será testado. 

- `flagSorteio` = 1 - Sorteio em andamento. Vai para a rotina `jump_loop` e executa a animação do giro da roleta.

- Não sendo nenhum dos casos, exibe resultado no Display através da subrotina `mostra_resultado`.

### 3.4.2.2 Multiplexação dos Displays
Para acender os quatro display simultaneamente utilizando o PORTC e o PORTD (que atua enviando o desenho do segmento). As subrotinas que compõem essa lógica são: `decod_A`, `decod_B`, `decod_C` e `decod_D`. E como funciona?

- O algoritmo liga o pino comum de apenas um display (`SBI PORTC, flagX`)
- Em seguida, envia o desenho do segmento para o barramento (`OUT DISPLAY, AUX`)
- Após isso, chama o `RCALL` Atraso para o processo de exibição dos Displays citados no módulo anterior.

Essa alternância entre os quatro dígitos ocorre em uma frequência superior à percepção humana, criando a ilusão de que todos os dígitos estão acesos ao mesmo tempo.

### 3.4.2.3 Algoritmo de Conversão Decimal (BCD)
O ATMega328 não possui uma instrução de divisão nativa. Essa lógica se torna necessária, uma vez que é necessário exibir a dezena e a unidade em displays separados (Números como o 27 por exemplo, devem ser exibidos como `2` e `7`, um em cada display). Desse modo, a rotina `encontrar_dezena_e_unidade` utiliza o método de subtrações sucessivas.

O processador subtrai o valor 10 (`SUBI AUX, 10`) em um laço de repetição. Sempre que a operação for bem sucedida, incrementa em um registrador de dezenas (`INC AUXB`). O laço termina quando o número restante é menor do que 10 (`BRLO FimDiv`) que fica em em AUX. Assim, foi separada a dezena da unidade.

### 3.4.2.4 Mapeamento de Caracteres
Números variáveis ou quadros de animação não podem ser colocados como valores fixos no código. Para isso, utilizamos matrizes de dados gravados na memória Flash (As subrotinas Tabela_numero e Tabela_roleta).

- Os registradores ZH e ZL são utilizados em conjunto para formar um ponteiro de 16 bits apontando para o ínicio da tabela ( `LDI ZH, HIGH` e `LDI ZL, LOW`).
- A variável numérica a ser exibida no Display é somada à parte baixa do ponteiro (`ADD ZL, AUX`) com um tratamento para caso de estouro do Carry, que se ocorrer, gera o vai-um, incrementando a parte alta do ponteiro (`INC ZH`)
- Por fim, é usada a instrução `LPM` para varrer o endereço gerado, trazendo o código de segmentos direto para o registrador da CPU.

### 3.4.2.5 Rotina de Animação da Roleta

Rotina utilizada para gerar o efeito de `giro` da roleta. A rotina utiliza um contador, que vai de 0 a 7. Dependendo onde esse contador se encontra, a multiplexação é alterada. Diferente do padrão de multiplexação utilizado anteriormente, essa rotina aciona os displays aos pares (`SBI PORTC, flagA` e `SBI PORTC, flagC`, por exemplo) e chama o `Atraso Maior`, estratégia utilizada para proporcionar maior fluidez na animação.

## 3.4.3 Escolher_numero.asm
Este módulo é utilizado exclusivamente para o Modo 5 da roleta, para a escolha de um número específico. Ele realiza as funções de incremento e decremento, além de coletar o número selecionado pelo usuário.

O registrador escolhido para armazenar o número escolhido (numEscolhido) começa em 0.

A rotina `Verifica_botoes` consiste em um loop infinito. O microcontrolador verifica sequencialmente os bits do registrador de entrada PINB, neste módulo associados aos botões de controle: BOTAOINC, BOTAODEC, BOTAOMODO, BOTAOROLETAR. Essa etapa irá redirecionar o fluxo para a sua respectiva função (Incrementar, Decrementar, Retornar ao Modo ou Roletar)

Como os pinos estão configurados com resistores de pull-up internos, o sistema opera como ativo em nível lógico baixo (0). Nesse sentido, são utilizadas as instruções `SBIS PINB, BOTAOINC` e `RJMP` para verificar estado do botão. Enquanto ele estiver em nível lógico 0 (pressionado), ficará preso no loop e só seguirá o fluxo quando o botão for solto. A mesma lógica de esperar soltar o botão será usada para incrementar e decrementar. 

Nas subrotinas `Incrementar` e `Decrementar` serão feitos os incrementos ou decrementos até os valores limites - 0 para o decremento e 37 (representante do 00) para o incremento. Decrementando do 0, volta para o 37 e incrementando do 37, volta para o 0.

As rotinas também utilizam as funções `Atraso_Debounce` para lidar com o ruído dos botões e `Mostrar_Display` para manter o Display ativo.

## 3.4.4 Interrupcao.asm
Este é um módulo simples, responsável por executar a interrupção do loop infinito do sorteio. 

Se a roleta estiver "girando" (`CPI flagLoop, 0x01`) vai para a subrotina `PararLoop`, que interrompe o loop e seta o `flagSorteio` em 0x02, que faz o Display mostrar o resultado.

Se a roleta não estiver girando, vai diretamente para a rotina `FimInterrup` que sai da rotina e descarta a interrupção.

## 3.4.5 Resultado_roleta.asm
Este módulo é o principal responsável por identificar qual foi o modo de jogo selecionado e principalmente, se o usuário foi vitorioso ou não.

Primeiramente, é importante saber que a Roleta Americana não segue um padrão simples para a relação entre o número e sua cor. Nesse sentido, a equipe decidiu por utilizar a memória de programa para criar uma Tabela de cores (Tabela_cores) que relaciona o número à sua respectiva cor.

- O processador carrega o ponteiro Z (ZH:ZL) com o endereço base da tabela e soma ao valor do resultado (0 a 37).
- A instrução `LPM` então extrai de Z o código da cor correspondente (0 = Verde, 1 = Vermelho, 2 = Preto) e coloca em R16.
- Antes de avaliar qualquer aposta, o código testa se a cor é verde (Fisicamente, o número 0 e 37/00). Se o usuário estiver no modo 1 a 4, é imediatamente direcionado para a subrotina `define_derrota`. Caso contrário, vai para a subrotina para checar número específico.

Se o processador chegou na rotina `checa_vermelho`, significa que certamente não é verde. Através das instruções `CPI` e `BRNE`, o programa verifica a cor sorteada e redireciona para as respectivas subrotinas. Se for vermelho, acende o LED Vermelho e se for Preto, acende o LED Preto (Azul no circuito físico).

A próxima etapa é a análise dos modo escolhido, através da função `avalia_modo`, que utiliza a instrução `CPI` `flagModo`, 0X0**Y**, em que Y vai de 1 a 5. A instrução `BREQ` é usada para direcionar o fluxo para a subrotina de cada um dos modos.

Após isso, temos as subrotinas: checa_par, checa_impar, checa_modo_verm e checa_modo_preto.

As rotinas de par e ímpar utilizam duas instruções fundamentais:`SBRS` (Skip If Bit Set) e `SBRC`(Skip If Bit Cleared), que verificam se o Bit menos significativo é 1 e 0, respectivamente. Pela propriedade de números binários, é possível afirmar que, caso seja 0, é par, e caso seja 1, é ímpar. A partir dessa lógica, as rotinas direcionam para o `define_vitoria` ou `define_derrota`.

A verificação de Vermelho e Preto utiliza `CPI` em R16 para saber se é 1 (Vermelho) ou 2 (Preto) e define a vitória ou derrota a partir disso.

As rotinas `define_vitoria` e `define_derrota` utilizam o registrador R26 como flag. Grava 1 se for Vitória e 0 se for derrota.

Por fim, o código entra no loop `loop_fim_jogo`. Se houver vitória, o `LEDVITORIA` precisa piscar. Se houver derrota, o `LEDVITORIA` se mantém desligado. 

Nesse mesmo loop, é utilizado um atraso com os registradores R27 e R28 para o piscar do LED, além de ser reaplicado o `Atraso_Debounce` e o `Mostrar_Display` continuamente, para que ele se mantenha visualmente ativado.

## 3.4.6 Roletar.asm
Este é o módulo responsável por simular o giro da roleta e definir o número vencedor. Nele, foi implementada a pseudo-aleatoriedade necessária para uma roleta.

Dentro da função `Roleta`, é verificado se o flagLoop = 1 (girando). Se for, segue para o loop

Enquanto o resultado for menor que 0x25 (37 em decimal), incrementa. Se for igual ou maior, volta a 0. 

A rotina `incrementa_resultado` é responsável por fazer o incremento e por chamar as funções `Mostrar_Display`, `Atraso` e retornar à `Roleta`. O loop é encerrado no momento que o `flagLoop` mudar de estado, mantendo o resultado do instante em que foi encerrado.

## 3.4.7 Roleta.asm
Este é o módulo principal de todo o projeto. É aqui que é gerenciada a inicialização do hardware, contém o todos os requisitos funcionais do programa: menu, aposta, giro e resultado; e contém todos os módulos anteriores, atuando como a interface do projeto.

Logo no início da memória de programa, é definido e origem e o endereço da interrupção (INT0 - PD2).

A rotina `Inicializacoes` define:
- Os pinos de entrada e saída do Display (Somente um pino como entrada, sendo o da interrupção)
- Os pinos de entrada e saída da PORTC
- pinos de entrada e saída da PORTB (botões e LEDs)
- Liga o Display
- Zera os valores da roleta
- Configura a interrupção (borda de descida)
- Seta os flags em 0

No Loop principal:
- Atualiza o Display continuamente 
- Uso da instrução `CLI` para garantir que interrupção esteja desativada
- Verifica continuamente o BOTAOMODO e BOTAOROLETAR

Caso o Botão de Modo tenha sido pressionado, vai para a rotina `TrataBotaoModo`. Essa rotina lida com o ruído do sistema, espera o botão ser solto e alterna entre os modos 0 a 5 ciclicamente. Nessa mesma rotina, existe a subrotina `AtualizaLEDsModo` que liga o LED correspondente ao modo usando `CPI` e `flagModo`.
- Modo 0 (play) - Nenhum LED aceso
- Modo 1 (Par) - LED Verde
- Modo 2 (Ímpar) - LED Verde
- Modo 3 (Vermelho) - LED Vermelho
- Modo 4 (Preto) - LED Azul
- Modo 5 (Número específico) - Nenhum LED aceso

Se BOTAOROLETAR for pressionado, vai para a rotina que verifica o Modo `VerificaModo`. Enquanto não for roletado, o loop se mantém.

Na rotina `VerificaModo` faz o tratamento do sistema antes de chamar a Roleta. Ela:
- Verifica se o botão foi pressionado e solto.
- Verifica o `flagModo` para saber se está em um estado em que o sorteio não é possível ou inválido.
- Seta o `flagSorteio` em 0x01, indicando que está no modo de animação da roleta, quando for acionada
- Limpa cliques ruídos residuais no registrador EIFR e, somente com o sistema limpo, ativa as interrupções globais (SEI) para permitir o sorteio.
- Chama o loop do sorteio
- Chama a Roleta
- Chama o Avaliar_resultado
- Volta ao início do programa, após o número ser sorteado, dando um `reset` no programa.
