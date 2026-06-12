## 3.5. Guia de utilização
Após clonar o repositório, siga os passos a seguir.

### 3.5.1. Compilação do programa através do Microchip Studio
1. Abra o Microchip Studio e crie um novo projeto indo em *File -> New -> Project*;
2. Selecione a opção **AVR Assembler Project**, dê um nome para o projeto e clique em OK;
3. Na janela de seleção do microcontrolador, digite **ATmega328P** na barra de pesquisa, selecione-o na lista e confirme em OK;
4. Será gerado, automaticamente, o arquivo *main.asm*, apague o conteúdo padrão e cole o código do *Roleta.asm*;
5. Vá até a janela *Solution Explorer* (localizado à direita) e clique na pasta raiz do projeto com o botão direito, selecione *Add -> Existing Item...* e selecione os outros arquivos *.asm* e também o *definicoes.inc*;
6. No menu superior da IDE, localize e clique na opção *Build*. Em seguida, clique em *Build Solution* (atalho: *F7*);
7. Certifique-se de que a operação foi concluída com sucesso (mensagem indicando Build: 1 succeeded, 0 failed).

Ao final desses passos, será gerado o executável (arquivo *.hex*).

### 3.5.2. Inicialização
O uso do circuito físico é similar ao uso do circuito no simulador, sendo a forma de inicialiação, a única diferença existente entre os dois. Nesse caso, primeiramente serão apresentados os dois modos de inicialização separadamente e, em seguida, os demais tópicos de instruções serão comuns entre os dois circuitos.

#### - Inicialização no simulador (**SimulIDE**)
1. Abra o simulador;
2. Selecione: *Abrir circuito* (*Ctrl+O*), localizado na barra superior;
3. Navegue até a pasta do arquivo do ciruito e escolha **roleta_americana.sim1**;
4. Clique com o botão direito do mouse sobre o arduino;
5. Deixe o cursor sobre o tópico *mega328-109* e selecione a opção *Carregar firmware*;
6. Navegue até a pasta arquivo do programa e escolha o arquivo *.hex* gerado pela compilação;
7. Clique no botão *Start Simulation*, localizado na barra superior.

#### - Inicialização no circuito físico (**Arduino Uno**)
1. Faça a conexão entre o arduino e o computador via cabo usb (é recomendável desconectar os jumpers ligados aos pinos **TX** e **RX** quando for executar o upload do programa).
2. O processo detalhado para esta etapa pode ser verificado acessando este [link](https://forum.arduino.cc/t/the-simplest-way-to-upload-a-compiled-hex-file-without-the-ide/401996) do fórum arduino.
3. Após o upload, reconecte os jumpers aos pinos **TX** e **RX** do arduino. 

Observação: O upload do executável só precisa ser realizado uma única vez.

### 3.5.3. Seleção dos modos de jogo e ativação da roleta 
1. Inicialmente, será exibido a tela inicial: "*PLAY*".
2. Pressione o botão *Modo* para navegar entre os modos de jogo: *PAr*(par) -> *IPr*(ímpar) -> *vEr*(vermelho) -> *PrE*(preto) -> *n - 00*(número específico).
    - Observação: No modo de número específico, o usuário pode escolher um número dentro do intervalo que vai de 0 a 36, além do valor 00. Nesse modo, os botões *Incrementar* e *Decrementar* são habilitados para que o usuário escolha o número desejado, que aparecerá no display.
3. Após a seleção do modo (e do número, caso esteja no modo de número específico), pressione o botão *Roletar*, que irá ativar o giro da roleta, representada pela animação nos displays.

### 3.5.4. Realização do sorteio e apresentação do resultado
1. Enquanto a roleta gira, o usuário é livre para decidir o momento em que a roleta deve parar. Para realizar essa ação, pressione o botão *Sortear*, e então será feito o sorteio de uma casa da roleta e a apresentação do resultado da aposta.
2. Interpretação do resultado:
    - A casa sorteada será identificada através da exibição do número da casa no display, além da sua respectiva cor identificada em um dos LEDs (Vermelho, Azul(representa a casa **preta**) ou Verde).
    - O Usuário sairá vencedor caso o LED da vitória (Amarelo) esteja piscando, indicando que o usuário acertou a aposta. Caso contrário, o mesmo LED estará apagado, indicando o fracasso do apostador.
3. Após o fim da rodada, o usuáro pode apostar novamente. Para tanto, ele deve clicar no botão *Modo* e seguir o processo de escolha.