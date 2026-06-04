.ORG 0x090

Display:

testa_inicial
CPI flagModo, 0x00
BRNE testa_par


testa_par:
CPI flagModo, 0x01
BRNE testa_impar

testa_impar:
CPI flagModo, 0x02
BRNE testa_vermelho

testa_vermelho:
CPI flagModo, 0x03
BRNE testa_preto

testa_preto:
CPI flagModo, 0x04
BRNE testa_numEsp

testa_numEsp:



