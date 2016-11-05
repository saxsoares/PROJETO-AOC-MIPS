.data

_bmpAddress:		.word	0x10040000

Largura:		.half 128 # Largura, 128*4 = 512 pixels Largura
Altura:			.half 64 # Altura, 64*4 = 256 pixels Largura

Largura2:		.half 256 # Largura, 128*4 = 512 pixels Largura
Altura2:		.half 256 # Altura, 64*4 = 256 pixels Largura
TamanhoX:		.half 128 # Altura, 64*4 = 256 pixels Largura

Cor_preto:		.word 0x00222222
CorFundo:		.word 0xFFFFFFFF
Cor_vermelho:		.word 0xFFFF0000

.text

Main:
	lw $s7, CorFundo		# Guarda a cor de fundo no reg. S7
	lw $s5, Cor_vermelho		# Guarda a cor de fundo no reg. S7
	lw $s6, Cor_preto		# Guarda a cor de fundo no reg. S6
	# Prepare the arena
	or $a0, $zero, $s7		# Salva o S7 em A0
	jal PreencherFundo		#Chama funcao
	#nop

	jal Horizontal
	jal Vertical

Voltar:	
	#jal Bordas			#Chama funcao
	#nop
	#jal Infinito

	
Main_exit:
	ori $v0, $zero, 10		# Termina o Programa
	syscall

PreencherFundo:				# Calculos para o tamanho da tela
	lh $t1, Largura2			# Salva Largura em A1 (128; sendo que a larg real Ã© 128 * 4)
	lh $t2, Altura2			# Salva Altura em A2 (64; sendo que a larg real Ã© 64 * 4)

	multu $t1, $t2			# Multiplica Altura*Largura (Ainda nao sei porque...)
	nop
	mflo $t2			# Nao faco ideia
	sll $t2, $t2, 2			# Multiplica por 4
	add $t2, $t2, $gp		# Adiciona o ponteiro global em a2
	or $t1, $zero, $gp		# Coloca o ponteiro global em a1
	
	add $s4, $zero, $zero		#Registrador auxiliar da mudança de cor
Loop_Fundo:	
	sw $s7, ($t1)			# Pinta o pixel da posicao A0
	add $t1, $t1, 4			# Pula para a proxima pagina do A1 (Move um pixel para a direita)
	add $s4, $s4, 1
	blt $s4, 400, Loop_Fundo	#Branch para mudar a cor do fundo
	sub, $s7, $s7, 65793		#Valor da mudança
	add $s4, $zero, $zero
	blt $t1, $t2, Loop_Fundo
	lw $s7, Cor_preto
	nop	
	jr $ra
			
Horizontal:		
	lh $t3, Largura2			# Salva Largura em A1 (128; sendo que a larg real Ã© 128 * 4)
	lh $t4, Altura2			# Salva Altura em A2 (64; sendo que a larg real Ã© 64 * 4)

	multu $t3, $t4			# Multiplica Altura*Largura (Ainda nao sei porque...)
	nop
	mflo $t4			# Nao faco ideia
	add $t5, $t4, $zero	
	srl $t5, $t5, 6			# Divide por 64		
	#sll $t4, $t4, 2			# Multiplica por 4
	add $t4, $t4, $gp		# Adiciona o ponteiro global em a2
	add $t5, $t5, $gp		# Adiciona o ponteiro global em a2
	or $t3, $zero, $gp		# Coloca o ponteiro global em a1

	#add $t5, $t5, 2048		#Valor de correção para o fundo branco
	add $t5, $t5, 360		#Valor de correção para o fundo branco com gradiente de cinza
	#add $t5, $t5, $gp		# Adiciona o ponteiro global em a2
	add $t3, $zero, $gp
	#add $t4, $t4, 260000		#Valor de correção para o fundo branco
	add $t4, $t4, 150000		#Valor de correção para o fundo branco com gradiente de cinza
	#jal Render_hor

	add $s4, $zero, $zero
Render_hor:	
	sw $s6, ($t3)			# Pinta o pixel da posicao A0
	add $t3, $t3, 4			# Pula para a proxima pagina do A1 (Move um pixel para a direita)
	#add, $s6, $s6, 1
	blt $t3, $t5, Render_hor	#Preenchimento de uma linha

Salto:
	
	add $t3, $t3, 10240
	add $t5, $t5, 11264

Render_hor2:	
	sw $s6, ($t3)			# Pinta o pixel da posicao A0
	add $t3, $t3, 4			# Pula para a proxima pagina do A1 (Move um pixel para a direita)
	blt $t3, $t5, Render_hor2	#Preenchimento de uma linha
	blt $t3, $t4, Salto		#Salto para a próxima linha

	add $t4, $t4, 12288		#incremento para pintar a borda inferior

Borda_inferior:		
	sw $s6, ($t3)			# Pinta o pixel da posicao A0
	add $t3, $t3, 4			# Pula para a proxima pagina do A1 (Move um pixel para a direita)
	blt $t3, $t4, Borda_inferior
		
	jr $ra
	nop
	
Vertical:
	lh $t5, Largura2			# Calculate next ending condition
	lh $t6, Altura2
	multu $t5, $t6			# Multiply screen width by screen height
	nop
	mflo $t6			# Retreive total tiles
	sub $t6, $t6, $t5		# Minus one width
	sll $t6, $t6, 2			# Multiply by 4
	add $t6, $t6, $gp		# Add global pointer
		
	subi $t5, $t5, 1		# Take 1 from width
	sll $a3, $t5, 2			# Multiply by 4 to get mem to add
		
	or $t5, $zero, $gp		# Set loop var to global pointer
	add $t6, $t6, 295000
		
Render_vert:	
	sw $s6, ($t5)
	add $t5, $t5, 128		# Espaco entre as bordas verticais
	#sw $s6, ($t5)
	#add $s6, $s6, 1		# Caso adicione mais 4, as bordas ficarao em diagonal
	blt $t5, $t6, Render_vert
		
	jal Main_exit				# Return
	#nop		
