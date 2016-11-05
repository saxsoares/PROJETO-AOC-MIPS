.data

#Unit width in pixels: 2
#Unit height in pixels: 2
#Display width in pixels: 512
#Display height in pixels: 512
#Base address for display 0x10008000 ($gp)

#Largura:		.half 128 # Largura, 128*4 = 512 pixels Largura
#Altura:		.half 64 # Altura, 64*4 = 256 pixels Largura

Largura:		.half 256 # Largura, 256*4 = 1024 pixels Largura
Altura:			.half 256 # Altura, 256*4 = 1024 pixels Largura

Cor_grade:		.word 0xFFAAAAAA
CorFundo:		.word 0xFFFFFFFF
Cor_selecionada:	.word 0xFF000000
Vermelho:		.word 0xFFFF0000

.text

Main:
	lh $t1, Largura
	lh $t2, Altura
	mul $t3, $t1, $t2		# Registrador que guarda a �rea da tela
	nop
	mul $t3, $t3, 4
	nop
	lw $s7, CorFundo		# Guarda a cor de fundo (branco) no reg. S7
	lw $s6, Cor_grade		# Guarda a cor da malha (cinza) no reg. S6
	lw $s5, Cor_selecionada		# Guarda a cor da malha (preto) no reg. S5
	lw $s4, Vermelho		# Guarda a cor da malha (preto) no reg. S5
	# Prepare the arena
	or $a0, $zero, $s7		# Salva o S7 em A0
	
	sub $t5, $t5, $t5
	add $t5, $t5, 2168		#Posi��o de refer�ncia para a c�lula A0
	sub $t6, $t6, $t6
	sub $t7, $t7, $t7
	sub $t8, $t8, $t8
	sub $t9, $t9, $t9
	sub $s1, $s1, $s1

Main2:	
	jal PreencherFundo		#Pinta o fundo de branco
	jal Horizontal			#Desenha as linhas horizontais
	jal Vertical			#Desenha as linhas verticais
	jal Celula_selecionada
	
	j Execucao

Main_exit:
	ori $v0, $zero, 10		# Termina o Programa
	syscall

PreencherFundo:				# Calculos para o tamanho da tela
	#mflo $t2			# Par�metro de refer�ncia para a fun��o Loop_fundo#
	sub $t2, $t2, $t2
	add $t2, $t2, $t3
	add $t2, $t2, $gp		# Adiciona o ponteiro global em t2
	or $t1, $zero, $gp		# Coloca o ponteiro global em t1

Loop_Fundo:	
	sw $s7, ($t1)			# Pinta o pixel da posicao t1
	add $t1, $t1, 4			# Pula para a proxima pagina do t1 (Move um pixel para a direita)

	blt $t1, $t2, Loop_Fundo
	#lw $s7, Cor_grade
	nop	
	jr $ra
			
Horizontal:		
	#mflo $t2			# Par�metro de refer�ncia para a Render_hor
	sub $t2, $t2, $t2
	add $t2, $t2, $t3
	sub $t2, $t2, 2144
	sub $t4, $t4, $t4	

	add $t2, $t2, $gp		# Adiciona o ponteiro global em t4
	add $t4, $t4, $gp		# Adiciona o ponteiro global em t5
	or $t1, $zero, $gp		# Coloca o ponteiro global em t3

	add $t4, $t4, 2048		#Valor de corre��o para o fundo branco

Render_hor:	
	sw $s6, ($t1)			# Pinta o pixel da posicao t3
	add $t1, $t1, 4			# Pula para a proxima pagina do t4 (Move um pixel para a direita)
	blt $t1, $t4, Render_hor	#Preenchimento de uma linha

Salto:
	add $t1, $t1, 10240
	add $t4, $t4, 11264

Render_hor2:	
	sw $s6, ($t1)			# Pinta o pixel da posicao t3
	add $t1, $t1, 4			# Pula para a proxima pagina do t3 (Move um pixel para a direita)
	blt $t1, $t4, Render_hor2	#Preenchimento de uma linha
	blt $t1, $t2, Salto		#Salto para a pr�xima linha

	add $t2, $t2, 2144		#incremento para pintar a borda inferior

Borda_inferior:		
	sw $s6, ($t1)			# Pinta o pixel da posicao t3
	add $t1, $t1, 4			# Pula para a proxima pagina do t3 (Move um pixel para a direita)
	blt $t1, $t2, Borda_inferior
		
	jr $ra
	nop
	
Vertical:
	add $t2, $zero, 262144		
	add $t2, $t2, $gp		# Add global pointer
	
	or $t1, $zero, $gp		# Set loop var to global pointer
	
Render_vert:	
	sw $s6, ($t1)
	add $t1, $t1, 128		# Espaco entre as bordas verticais
	blt $t1, $t2, Render_vert
		
	jr $ra

Celula_selecionada:			# Calculos para o tamanho da tela
	add $t2, $zero, $t5
	add $t2, $t2, $gp		# Adiciona o ponteiro global em t2
	
			
	or $t1, $zero, $gp		# Coloca o ponteiro global em t1
	add $t1, $t1, $t5
	sub $t1, $t1, 124
	
Loop_celula:	
	add $t1, $t1, 8			# Pula para a proxima pagina do t1 (Move um pixel para a direita)
	sw $s5, ($t1)			# Pinta o pixel da posicao t1
	
	blt $t1, $t2, Loop_celula
	add $t2, $t2, 8192

Loop_celula2:
	add $t1, $t1, 1928
	sw $s5, ($t1)			# Pinta o pixel da posicao t1
	add $t1, $t1, 120			# Pula para a proxima pagina do t1 (Move um pixel para a direita)
	sw $s5, ($t1)

	blt $t1, $t2, Loop_celula2

	add $t1, $t1, 900
	add $t2, $t2, 1024
Loop_celula3:	
	add $t1, $t1, 8			# Pula para a proxima pagina do t1 (Move um pixel para a direita)
	sw $s5, ($t1)			# Pinta o pixel da posicao t1
	
	blt $t1, $t2, Loop_celula3
	
	nop	
	jr $ra

Celula_branco:			# Calculos para o tamanho da tela
	#11264 incremento para mudar de linha
	#128 incremento para mudar de coluna
	
#	mflo $t2			# Par�metro de refer�ncia para a fun��o Loop_fundo
#	sub $t2, $t2, $t2
	add $t2, $zero, $t5
	add $t2, $t2, $gp		# Adiciona o ponteiro global em t2
	
			
	or $t1, $zero, $gp		# Coloca o ponteiro global em t1
	add $t1, $t1, $t5
	sub $t1, $t1, 124
	
Loop_branco:	
	add $t1, $t1, 8			# Pula para a proxima pagina do t1 (Move um pixel para a direita)
	sw $s7, ($t1)			# Pinta o pixel da posicao t1
	
	blt $t1, $t2, Loop_branco
	add $t2, $t2, 8192

Loop_branco2:
	add $t1, $t1, 1928
	sw $s7, ($t1)			# Pinta o pixel da posicao t1
	add $t1, $t1, 120			# Pula para a proxima pagina do t1 (Move um pixel para a direita)
	sw $s7, ($t1)

	blt $t1, $t2, Loop_branco2

	add $t1, $t1, 900
	add $t2, $t2, 1024
	
Loop_branco3:	
	add $t1, $t1, 8			# Pula para a proxima pagina do t1 (Move um pixel para a direita)
	sw $s7, ($t1)			# Pinta o pixel da posicao t1
	
	blt $t1, $t2, Loop_branco3
	
	nop	
	jr $ra


Execucao:
Main_waitLoop:
	# Wait for the player to press a key
	jal Sleep			# Zzzzzzzzzzz...
	nop
	lw $t0, 0xFFFF0000		# Retrieve transmitter control ready bit
	blez $t0, Main_waitLoop		# Check if a key was pressed
	jal GetDir
	beq  $t6, $zero Main_waitLoop
	
	nop
	bgt $t6, 4 Zera_$t6
	jal Celula_branco
	add $t5, $t5, $t7
	sub $t7, $t7, $t7
	jal Celula_selecionada
Zera_$t6:
	sub $t6, $t6, $t6
	j Main_waitLoop
	
###########################################################################################
# Sleep function for game loop
# Takes none
# Returns none
Sleep:
	ori $v0, $zero, 32		# Syscall sleep
	ori $a0, $zero, 60		# For this many miliseconds
	syscall
	jr $ra				# Return
	nop

###########################################################################################
# Function to retrieve input from the kyboard and return it as an alpha channel direction
# Takes none
# Returns v0 = direction
GetDir:
		lw $t0, 0xFFFF0004		# Load input value
		
GetDir_right:
		bne, $t0, 100, GetDir_up		#C�digo do caractere 'd' em ASCII
		nop
		add $t6, $t6, 1
		
		add $t9, $t9, 1
		add $t7, $t7, 128
		bge $t9, 8, Volta_linha
		j Right
	Volta_linha:
		sub $t9, $t9, 8
		sub $t7, $t7, 1024
	Right:	
		ori $v0, $zero, 0x01000000	# Right
		j GetDir_done
		nop
GetDir_up:
		bne, $t0, 119, GetDir_left		#C�digo do caractere 'w' em ASCII
		nop
		add $t6, $t6, 2
		
		sub $t8, $t8, 1
		bltz $t8, Volta_coluna
		sub $t7, $t7, 11264
		j Up
	Volta_coluna:
		add $t8, $t8, 23
		add $t7, $t7, 247808
	Up:		
		ori $v0, $zero, 0x02000000	# Up
		j GetDir_done
		nop
GetDir_left:
		bne, $t0, 97, GetDir_down		#C�digo do caractere 'a' em ASCII
		nop
		add $t6, $t6, 3
		
		sub $t9, $t9, 1
		sub $t7, $t7, 128
		bltz $t9, Vai_linha
		j Left
	Vai_linha:
		add $t9, $t9, 8
		add $t7, $t7, 1024
	Left:	
		ori $v0, $zero, 0x03000000	# Left
		j GetDir_done
		nop
GetDir_down:
		bne, $t0, 115, Set_patametros_numeros		#C�digo do caractere 's' em ASCII
		nop
		add $t6, $t6, 4
		add $t8, $t8, 1
		bge $t8, 23, Vai_coluna
		add $t7, $t7, 11264
		j Down
	Vai_coluna:
		sub $t8, $t8, 23
		sub $t7, $t7, 247808
	Down:
		ori $v0, $zero, 0x04000000	# Down
		j GetDir_done
		nop

Set_patametros_numeros:
	mflo $t2			# Par�metro de refer�ncia para a fun��o Loop_fundo
	sub $t2, $t2, $t2
	add $t2, $t2, $t5
	add $t2, $t2, $gp		# Adiciona o ponteiro global em t2
	
			
	or $s1, $zero, $gp		# Coloca o ponteiro global em t1
	add $s1, $s1, $t5
	sub $s1, $s1, 124


GetNumber_0:
		#bne, $t0, 48, GetNumber_1		#C�digo do caractere '0' em ASCII
		bne, $t0, 112, GetNumber_1		#C�digo do caractere 'p' em ASCII
		add $s1, $s1, $t7
		add $s1, $s1, 2068
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		add $s1, $s1, 4
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		add $s1, $s1, 4
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		add $s1, $s1, 1012
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		add $s1, $s1, 1024
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		add $s1, $s1, 1024
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		add $s1, $s1, 1024
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		add $s1, $s1, 1024
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		add $s1, $s1, 1028
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		add $s1, $s1, 4
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		add $s1, $s1, 4
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		sub $s1, $s1, 1020
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		sub $s1, $s1, 1024
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		sub $s1, $s1, 1024
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		sub $s1, $s1, 1024
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		sub $s1, $s1, 1024
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		sub $s1, $s1, 1028
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		nop
		add $t6, $t6, 5

		j GetDir_done
		nop
GetNumber_1:
		#bne, $t0, 49, GetNumber_2		#C�digo do caractere '0' em ASCII
		bne, $t0, 113, GetNumber_2		#C�digo do caractere 'q' em ASCII
		add $s1, $s1, $t7
		add $s1, $s1, 3092
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		sub $s1, $s1, 1020
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		add $s1, $s1, 1024
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		add $s1, $s1, 1024
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		add $s1, $s1, 1024
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		add $s1, $s1, 1024
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		add $s1, $s1, 1024
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		add $s1, $s1, 1016
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		add $s1, $s1, 4
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		add $s1, $s1, 4
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		add $s1, $s1, 4
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		add $s1, $s1, 4
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		# Pinta o pixel da posicao s1
		nop
		add $t6, $t6, 6

		j GetDir_done
		nop
GetNumber_2:
		#bne, $t0, 50, GetNumber_3		#C�digo do caractere '0' em ASCII
		bne, $t0, 120, GetNumber_3		#C�digo do caractere 'x' em ASCII
		add $s1, $s1, $t7
		add $s1, $s1, 3088
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		sub $s1, $s1, 1020
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		add $s1, $s1, 4
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		add $s1, $s1, 4
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		add $s1, $s1, 1028
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		add $s1, $s1, 1024
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		add $s1, $s1, 1020
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		add $s1, $s1, 1020
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		add $s1, $s1, 1020
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		add $s1, $s1, 1020
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		add $s1, $s1, 4
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		add $s1, $s1, 4
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		add $s1, $s1, 4
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		add $s1, $s1, 4
		sw $s4, ($s1)			# Pinta o pixel da posicao s1

		nop
		add $t6, $t6, 7

		j GetDir_done
		nop
GetNumber_3:
		#bne, $t0, 51, GetNumber_4		#C�digo do caractere '0' em ASCII
		bne, $t0, 101, GetNumber_4		#C�digo do caractere 'e' em ASCII
		add $s1, $s1, $t7
		add $s1, $s1, 3088
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		sub $s1, $s1, 1020
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		add $s1, $s1, 4
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		add $s1, $s1, 4
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		add $s1, $s1, 1028
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		add $s1, $s1, 1024
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		add $s1, $s1, 1020
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		sub $s1, $s1, 4
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		add $s1, $s1, 1032
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		add $s1, $s1, 1024
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		add $s1, $s1, 1020
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		sub $s1, $s1, 4
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		sub $s1, $s1, 4
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		sub $s1, $s1, 1028
		sw $s4, ($s1)			# Pinta o pixel da posicao s1

		nop
		add $t6, $t6, 8

		j GetDir_done
		nop
GetNumber_4:
		#bne, $t0, 52, GetNumber_5		#C�digo do caractere '0' em ASCII
		bne, $t0, 114, GetNumber_5		#C�digo do caractere 'r' em ASCII
		add $s1, $s1, $t7
		add $s1, $s1, 8220
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		sub $s1, $s1, 1024
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		sub $s1, $s1, 1024
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		sub $s1, $s1, 1024
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		sub $s1, $s1, 1024
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		sub $s1, $s1, 1024
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		sub $s1, $s1, 1024
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		sub $s1, $s1, 4
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		add $s1, $s1, 1020
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		add $s1, $s1, 1020
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		add $s1, $s1, 1024
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		add $s1, $s1, 4
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		add $s1, $s1, 4
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		add $s1, $s1, 4
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		add $s1, $s1, 4
		sw $s4, ($s1)			# Pinta o pixel da posicao s1

		nop
		add $t6, $t6, 9

		j GetDir_done
		nop
GetNumber_5:
		#bne, $t0, 53, GetNumber_6		#C�digo do caractere '0' em ASCII
		bne, $t0, 116, GetNumber_6		#C�digo do caractere 't' em ASCII
		add $s1, $s1, $t7
		add $s1, $s1, 2064
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		add $s1, $s1, 4
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		add $s1, $s1, 4
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		add $s1, $s1, 4
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		add $s1, $s1, 4
		sw $s4, ($s1)			# Pinta o pixel da posicao s1	
		add $s1, $s1, 1008
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		add $s1, $s1, 1024
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		add $s1, $s1, 1028
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		add $s1, $s1, 4
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		add $s1, $s1, 4
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		add $s1, $s1, 1028
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		add $s1, $s1, 1024
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		add $s1, $s1, 1020
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		sub $s1, $s1, 4
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		sub $s1, $s1, 4
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		sub $s1, $s1, 1028
		sw $s4, ($s1)			# Pinta o pixel da posicao s1

		nop
		add $t6, $t6, 10

		j GetDir_done
		nop
GetNumber_6:
		#bne, $t0, 54, GetNumber_7		#C�digo do caractere '0' em ASCII
		bne, $t0, 121, GetNumber_7		#C�digo do caractere 'y' em ASCII
		add $s1, $s1, $t7
		add $s1, $s1, 3104
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		sub $s1, $s1, 1028
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		sub $s1, $s1, 4
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		sub $s1, $s1, 4
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		add $s1, $s1, 1020
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		add $s1, $s1, 1024
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		add $s1, $s1, 1024
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		add $s1, $s1, 1024
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		add $s1, $s1, 1024
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		add $s1, $s1, 1028
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		add $s1, $s1, 4
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		add $s1, $s1, 4
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		sub $s1, $s1, 1020
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		sub $s1, $s1, 1024
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		sub $s1, $s1, 1028
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		sub $s1, $s1, 4
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		sub $s1, $s1, 4	
		sw $s4, ($s1)			# Pinta o pixel da posicao s1

		nop
		add $t6, $t6, 11
		j GetDir_done
		nop
GetNumber_7:
		#bne, $t0, 55, GetNumber_8		#C�digo do caractere '0' em ASCII
		bne, $t0, 117, GetNumber_8		#C�digo do caractere 'u' em ASCII
		add $s1, $s1, $t7
		add $s1, $s1, 2064
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		add $s1, $s1, 4
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		add $s1, $s1, 4
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		add $s1, $s1, 4
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		add $s1, $s1, 4
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		add $s1, $s1, 1024
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		add $s1, $s1, 1020
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		add $s1, $s1, 1020
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		add $s1, $s1, 1024
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		add $s1, $s1, 1024
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		add $s1, $s1, 1024
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		nop
		add $t6, $t6, 12

		j GetDir_done
		nop
GetNumber_8:
		#bne, $t0, 56, GetNumber_9		#C�digo do caractere '0' em ASCII
		bne, $t0, 105, GetNumber_9		#C�digo do caractere 'i' em ASCII
		add $s1, $s1, $t7
		add $s1, $s1, 2068
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		add $s1, $s1, 4
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		add $s1, $s1, 4
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		add $s1, $s1, 1028
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		add $s1, $s1, 1024
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		sub $s1, $s1, 16
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		sub $s1, $s1, 1024
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		add $s1, $s1, 3072
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		add $s1, $s1, 1024
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		add $s1, $s1, 1028
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		add $s1, $s1, 4
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		add $s1, $s1, 4
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		sub $s1, $s1, 1020
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		sub $s1, $s1, 1024
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		sub $s1, $s1, 1028
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		sub $s1, $s1, 4
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		sub $s1, $s1, 4
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		nop
		add $t6, $t6, 13

		j GetDir_done
		nop
GetNumber_9:
		#bne, $t0, 57, GetDir_done		#C�digo do caractere '0' em ASCII
		bne, $t0, 111, Digito_Mais		#C�digo do caractere 'o' em ASCII
		add $s1, $s1, $t7
		add $s1, $s1, 2068
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		add $s1, $s1, 4
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		add $s1, $s1, 4
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		add $s1, $s1, 1028
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		add $s1, $s1, 1024
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		sub $s1, $s1, 16
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		sub $s1, $s1, 1024
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		add $s1, $s1, 4096
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		add $s1, $s1, 1028
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		add $s1, $s1, 4
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		add $s1, $s1, 4
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		sub $s1, $s1, 1020
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		sub $s1, $s1, 1024
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		sub $s1, $s1, 1024
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		sub $s1, $s1, 4
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		sub $s1, $s1, 4
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		sub $s1, $s1, 4
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		nop
		
		add $t6, $t6, 14

		j GetDir_done
		nop
		
Digito_Mais:
		#bne, $t0, 57, GetDir_done		#C�digo do caractere '0' em ASCII
		bne, $t0, 107, Digito_Menos		#C�digo do caractere 'k' em ASCII
		add $s1, $s1, $t7
		add $s1, $s1, 3096
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		add $s1, $s1, 1024
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		add $s1, $s1, 1024
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		add $s1, $s1, 1024
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		add $s1, $s1, 1024
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		sub $s1, $s1, 2056
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		add $s1, $s1, 4
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		add $s1, $s1, 8
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		add $s1, $s1, 4
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		nop

		add $t6, $t6, 15

		j GetDir_done
		nop

Digito_Menos:
		#bne, $t0, 57, GetDir_done		#C�digo do caractere '0' em ASCII
		bne, $t0, 108, Digito_Multiplicacao	#C�digo do caractere 'l' em ASCII
		add $s1, $s1, $t7
		add $s1, $s1, 5136
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		add $s1, $s1, 4
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		add $s1, $s1, 4
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		add $s1, $s1, 4
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		add $s1, $s1, 4
		sw $s4, ($s1)			# Pinta o pixel da posicao s1

		add $t6, $t6, 16
		nop

		j GetDir_done
		nop
	
Digito_Multiplicacao:
		#bne, $t0, 57, GetDir_done		#C�digo do caractere '0' em ASCII
		bne, $t0, 109, Digito_Divisao		#C�digo do caractere 'm' em ASCII
		add $s1, $s1, $t7
		add $s1, $s1, 3088
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		add $s1, $s1, 1028
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		add $s1, $s1, 1028
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		add $s1, $s1, 1028
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		add $s1, $s1, 1028
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		sub $s1, $s1, 16
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		sub $s1, $s1, 1020
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		sub $s1, $s1, 1020
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		sub $s1, $s1, 1020
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		sub $s1, $s1, 1020
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		
		add $t6, $t6, 15

		j GetDir_done
		nop

Digito_Divisao:
		#bne, $t0, 57, GetDir_done		#C�digo do caractere '0' em ASCII
		bne, $t0, 110, GetDir_done		#C�digo do caractere 'n' em ASCII
		add $s1, $s1, $t7
		add $s1, $s1, 7184
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		sub $s1, $s1, 1020
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		sub $s1, $s1, 1020
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		sub $s1, $s1, 1020
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		sub $s1, $s1, 1020
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		sub $s1, $s1, 1020
		sw $s4, ($s1)			# Pinta o pixel da posicao s1
		
		add $t6, $t6, 15

		j GetDir_done
		nop

GetDir_none:
						# Do nothing
GetDir_done:
		jr $ra				# Return
		nop
