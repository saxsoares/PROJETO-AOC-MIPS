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

Cor_grade:		.word 0x00AAAAAA
CorFundo:		.word 0xFFFFFFFF

.text

Main:
	lw $s7, CorFundo		# Guarda a cor de fundo (branco) no reg. S7
	lw $s6, Cor_grade		# Guarda a cor da malha (preto) no reg. S6
	# Prepare the arena
	or $a0, $zero, $s7		# Salva o S7 em A0
	
	jal PreencherFundo		#Pinta o fundo de branco
	jal Horizontal			#Desenha as linhas horizontais
	jal Vertical			#Desenha as linhas verticais

Main_exit:
	ori $v0, $zero, 10		# Termina o Programa
	syscall

PreencherFundo:				# Calculos para o tamanho da tela
	lh $t1, Largura			# Salva Largura em t1 (256; sendo que a larg real é 1024)
	lh $t2, Altura			# Salva Altura em t2 (256; sendo que a larg real é 1024)

	multu $t1, $t2			# Multiplica Altura*Largura
	nop
	mflo $t2			# Parâmetro de referência para a função Loop_fundo
	sll $t2, $t2, 2			# Multiplica por 4
	add $t2, $t2, $gp		# Adiciona o ponteiro global em t2
	or $t1, $zero, $gp		# Coloca o ponteiro global em t1
	
	#add $s4, $zero, $zero		#Registrador auxiliar da mudança de cor
	
Loop_Fundo:	
	sw $s7, ($t1)			# Pinta o pixel da posicao t1
	add $t1, $t1, 4			# Pula para a proxima pagina do t1 (Move um pixel para a direita)
	#add $s4, $s4, 1
	#blt $s4, 400, Loop_Fundo	#Branch para mudar a cor do fundo
	#sub, $s7, $s7, 65793		#Valor da mudança
	#add $s4, $zero, $zero
	blt $t1, $t2, Loop_Fundo
	lw $s7, Cor_grade
	nop	
	jr $ra
			
Horizontal:		
	lh $t3, Largura			# Salva Largura em t3 (256; sendo que a larg real é 1024)
	lh $t4, Altura			# Salva Altura em t4 (256; sendo que a larg real é 1024)

	multu $t3, $t4			# Multiplica Altura*Largura
	nop
	mflo $t4			# Parâmetro de referência para a Render_hor
	add $t5, $t4, $zero	
	srl $t5, $t5, 6			# Divide por 64		
	add $t4, $t4, $gp		# Adiciona o ponteiro global em t4
	add $t5, $t5, $gp		# Adiciona o ponteiro global em t5
	or $t3, $zero, $gp		# Coloca o ponteiro global em t3

	add $t5, $t5, 2048		#Valor de correção para o fundo branco
	#add $t5, $t5, 360		#Valor de correção para o fundo branco com gradiente de cinza
	#add $t5, $t5, $gp		# Adiciona o ponteiro global em a2
	#add $t3, $zero, $gp
	add $t4, $t4, 260000		#Valor de correção para o fundo branco
	#add $t4, $t4, 152000		#Valor de correção para o fundo branco com gradiente de cinza
	#jal Render_hor

Render_hor:	
	sw $s6, ($t3)			# Pinta o pixel da posicao t3
	add $t3, $t3, 4			# Pula para a proxima pagina do t4 (Move um pixel para a direita)
	#add, $s6, $s6, 1
	blt $t3, $t5, Render_hor	#Preenchimento de uma linha

Salto:
	add $t3, $t3, 10240
	add $t5, $t5, 11264

Render_hor2:	
	sw $s6, ($t3)			# Pinta o pixel da posicao t3
	add $t3, $t3, 4			# Pula para a proxima pagina do t3 (Move um pixel para a direita)
	blt $t3, $t5, Render_hor2	#Preenchimento de uma linha
	blt $t3, $t4, Salto		#Salto para a próxima linha

	add $t4, $t4, 2200		#incremento para pintar a borda inferior

Borda_inferior:		
	sw $s6, ($t3)			# Pinta o pixel da posicao t3
	add $t3, $t3, 4			# Pula para a proxima pagina do t3 (Move um pixel para a direita)
	blt $t3, $t4, Borda_inferior
		
	jr $ra
	nop
	
Vertical:
	lh $t5, Largura			
	lh $t6, Altura
	multu $t5, $t6			
	nop
	mflo $t6			
	
	#sub $t6, $t6, $t5		# Parâmetros de fundo com gradiente
	#sll $t6, $t6, 1		#
	
	sll $t6, $t6, 20		# Desloca os bits 20 casas à esquerda
	add $t6, $t6, $gp		# Add global pointer
	
	or $t5, $zero, $gp		# Set loop var to global pointer
	
	#add $t6, $t6, 200000		# Parâmetro de fundo com gradiente
		
Render_vert:	
	sw $s6, ($t5)
	add $t5, $t5, 128		# Espaco entre as bordas verticais
	blt $t5, $t6, Render_vert
		
	jal Main_exit			# Return
