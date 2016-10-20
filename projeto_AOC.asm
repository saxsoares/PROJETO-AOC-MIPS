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

.text

Main:
	lh $t1, Largura
	lh $t2, Altura
	mul $t3, $t1, $t2		# Registrador que guarda a área da tela
	mul $t3, $t3, 4
	lw $s7, CorFundo		# Guarda a cor de fundo (branco) no reg. S7
	lw $s6, Cor_grade		# Guarda a cor da malha (cinza) no reg. S6
	lw $s5, Cor_selecionada		# Guarda a cor da malha (preto) no reg. S5
	# Prepare the arena
	or $a0, $zero, $s7		# Salva o S7 em A0
	
	sub $t5, $t5, $t5
	add $t5, $t5, 2168		#Posição de referência para a célula A0
	sub $t6, $t6, $t6
	sub $t7, $t7, $t7
	sub $t8, $t8, $t8
	sub $t9, $t9, $t9

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
	mflo $t2			# Parâmetro de referência para a função Loop_fundo
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
	mflo $t2			# Parâmetro de referência para a Render_hor
	sub $t2, $t2, $t2
	add $t2, $t2, $t3
	sub $t2, $t2, 2144
	sub $t4, $t4, $t4	

	add $t2, $t2, $gp		# Adiciona o ponteiro global em t4
	add $t4, $t4, $gp		# Adiciona o ponteiro global em t5
	or $t1, $zero, $gp		# Coloca o ponteiro global em t3

	add $t4, $t4, 2048		#Valor de correção para o fundo branco

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
	blt $t1, $t2, Salto		#Salto para a próxima linha

	add $t2, $t2, 2144		#incremento para pintar a borda inferior

Borda_inferior:		
	sw $s6, ($t1)			# Pinta o pixel da posicao t3
	add $t1, $t1, 4			# Pula para a proxima pagina do t3 (Move um pixel para a direita)
	blt $t1, $t2, Borda_inferior
		
	jr $ra
	nop
	
Vertical:
	mflo $t2
	sub $t2, $t2, $t2
	add $t2, $t2, 262144		
	add $t2, $t2, $gp		# Add global pointer
	
	or $t1, $zero, $gp		# Set loop var to global pointer
	
Render_vert:	
	sw $s6, ($t1)
	add $t1, $t1, 128		# Espaco entre as bordas verticais
	blt $t1, $t2, Render_vert
		
	jr $ra

Celula_selecionada:			# Calculos para o tamanho da tela
	#11264 incremento para mudar de linha
	#128 incremento para mudar de coluna
	
	mflo $t2			# Parâmetro de referência para a função Loop_fundo
	sub $t2, $t2, $t2
	add $t2, $t2, $t5
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
	
	mflo $t2			# Parâmetro de referência para a função Loop_fundo
	sub $t2, $t2, $t2
	add $t2, $t2, $t5
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
	sub $t6, $t6, $t6
	jal Celula_branco
	add $t5, $t5, $t7
	sub $t7, $t7, $t7
	jal Celula_selecionada
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
		bne, $t0, 100, GetDir_up
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
		bne, $t0, 119, GetDir_left
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
		bne, $t0, 97, GetDir_down
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
		bne, $t0, 115, GetDir_none
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
GetDir_none:
						# Do nothing
GetDir_done:
		jr $ra				# Return
		nop
