Interrup:
	LDI flagLoop, 0				; altera o flagLoop para quebrar o loop infinito
	LDI flagSorteio, 2			; altera o flagSorteio para saber que a partir daqui entraremos em modo de Resultado
	RETI
