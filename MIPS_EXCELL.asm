#################################################################################
#      MIPS assembly program written by Daniel, Fernando, Gustavo, Lucas.	#
#################################################################################
.kdata
	BlackColor: 		.word 0x00000000
	DrawColor:		.word 0xFFAAAAAA		# Store colour to draw objects
	BgColor:		.word 0xFFFFFFFF		# Store colour to draw background
	stageWidth:		.half 256			# Store stage size
	stageHeight:		.half 256			# Usual settings $gp, 32x32, 16xScaling, 512x512
	BaseVLine: 	 	.half 15360
	SelectCelBase: 		.half 14396
	CelWidth: 	 	.half 160
	CelHeight:		.half 10240
	TraceLineWidth: 	.half 132
	TraceLineHeight: 	.half 8192
	OneLine: 		.half 1024
	BasePrintCel: 		.half 16456
	BreakCellMsg:		.asciiz "You can't write more than 6 digits"
	replayMessage:		.asciiz "Back to program?"
##############################################################################
# macro for, recebe (iterator_reg, start_point, end_point, step, color, macro_label)
# return none
.macro for (%regIterator, %from, %to, %step, %color, %bodyMacroName) ###
	add %regIterator, $zero, %from
	Loop:
	%bodyMacroName (%color, %regIterator)
	add %regIterator, %regIterator, %step
	ble %regIterator, %to, Loop		
.end_macro
#######################################################################################
.macro DrawVLine (%color, %x)
		lh $t0, stageWidth		# Calculate ending possition{
		lh $t1, stageHeight		#
		mul $t1, $t0, $t1		# 	Multiply screen width by screen height

		sub $t1, $t1, $t0		# 	Minus one width
		sll $t1, $t1, 2			# 	Multiply by 4
		add $t1, $t1, $gp		# 	Add global pointer
						# }
		lh $t2, stageHeight		# getting height of each line
		sll $t2, $t2, 2
		
		add $t0, $zero, %x		# Getting line number to draw
		sll $t0, $t0, 2			# 	remember, 4 bytes by dot
		add $t0, $t0, 15360		# This is for Vertical lines starts after 14 horizontal line ( espaço em branco em cima)
		add $t0, $t0, $gp
DVL_Loop:
		sw %color, ($t0)		# Loop to paint memory address
		add $t0, $t0, $t2
		blt $t0, $t1, DVL_Loop
		nop
.end_macro
######################################################################################
.macro DrawHLine (%color, %x)
		lh $t0, stageWidth		# Calculate ending possition
		sll $t0, $t0, 2			# Multiply by 4

		li $t1, 1			# %x plus one ( line 1 will be zero)
		add $t1, $t1, %x		# obtendo posição correspondente a linha (inicio)
		mul $t2, $t0, $t1		# obtendo posição correspondente a linha (fim)

		sub $t1, $t2, $t0		
		add $t2, $t2, $gp
		add $t1, $t1, $gp
DHL_Loop:					# começa a printar os pixels da linha
		sw %color, ($t1)
		add $t1, $t1, 4
		blt $t1, $t2, DHL_Loop
		nop
.end_macro
#########################################################################################################
.macro ApagaCelula (%x1, %x2)
		xor $t0, $t0, $t0	# zerando registradores temporarios 
		xor $t1, $t1, $t1	# zerando registradores temporarios 
		xor $t2, $t2, $t2	# idem acima
		lh $t1, CelWidth	# Loading Cel Width
		sub $t1, $t1, 8
		lh $t2, CelHeight	# Loading Cel Height
		sub $t2, $t2, 2048	# menos uma linha
		lh  $t0, SelectCelBase
		
		add $t0, $t0, 1024	# Uma linha abaixo da referencia de selecao ( parte branca )
		add $t0, $t0, 4		# um pixel a direita da referencia de selecao (parte branca)
		
		add $t0, $t0, %x1	# somando a t0 valor de referencia da coluna da celula a apagar
		add $t0, $t0, %x2	# somando a t0 valor de referencia da linha da celula a apagar
		add $t0, $t0, $gp	# somando ponteiro global (referencia da tela)
		
		add $t4, $t0, $t1
		add $t4, $t4, $t2		
Pulo:		add $t3, $t0, $t1
Apagando:	sw $s0, ($t0)
		add $t0, $t0, 4		# apaga pixel a pixel
		ble $t0, $t3, Apagando
		sub $t0, $t0, $t1
		add $t0, $t0, 1020
		ble $t0, $t4, Pulo
		nop
.end_macro
#########################################################################################################
.macro SelecionaCelula		# Recebe novos valores de $s1 e $s0, (pra onde irá "andar" )
		xor $t0, $t0, $t0	# zerando registradores temporarios 
		xor $t1, $t1, $t1	# idem acima
		lh $t0, CelWidth	# Loading Cel Width
		lh $t1, CelHeight	# Loading Cel Height
		
		mul $a1, $a1, $t0	# settando paramentros da celula a apagar
		mul $a2, $a2, $t1	#
		SelecionaCelula_aux ($s1, $a1, $a2)	# apaga seleção anterior
		nop
		
		xor $t0, $t0, $t0	# zerando registradores temporarios (podem ter sido alterados na chamada acima
		xor $t1, $t1, $t1	# idem acima.
		lh $t0, CelWidth	# Loading Cel Width
		lh $t1, CelHeight	# Loading Cel Height
		
		mul $a1, $s2, $t0			# setando parametros da celula à selecionar
		mul $a2, $s3, $t1			#
		SelecionaCelula_aux ($s0, $a1, $a2)	# selecionando celula
		ApagaCelula ($a1, $a2)
		nop
.end_macro
###############################################################################################################
.macro SelecionaCelula_aux (%sx, %x1, %x2)  #cor, column, line
		xor $t0, $t0, $t0
		xor $t1, $t1, $t1
		xor $t2, $t2, $t2
		xor $t7, $t7, $t7
		
		lh $t0, SelectCelBase
		lh $t1, CelWidth		# Loading Cel Width
		lh $t2, CelHeight		# Loading Cel Height
		lh $t7, OneLine
		
		add $t0, $t0, %x1		# %x1 guarda a referencia para  a coluna da celula a selecionar/deselecionar
		add $t0, $t0, %x2		# %x2 guarda a referencia para  a linha da celula a selecionar/deselecionar
		add $t0, $t0, $gp		# Adicionando global point( referencia para tela )
		
		move $t3, $t0			# fazendo backup do valor de $a1, ele é necessário para o segundo loot0
		add $t3, $t3, $t7		# As linhas verticais começa um pixel abaixo da linha horizontal
		
		add $t4, $t0, $t2		# $t4 pinta a linha de baixo, por isso $t0 + $t2(altura da celula)
		add $t5, $t0, $t1		# $t5 é o parametro de parada do loop por isso t1 + t1(altura da celula)
DHLT_Loop:
		sw %sx, ($t0)			# esse loop desenha as linhas tracejadas horizontais
		sw %sx, ($t4)			#
		add $t0, $t0, 8			# um pixel sim outro nao ( 8 em 8 )
		add $t4, $t4, 8			#
		ble $t0, $t5, DHLT_Loop		#
		nop

		move $t0, $t3			# devolvendo valor de $a1
		add $t4, $t0, $t1		# a0 desenha a linha tracejada oposta a que $a1 desenha com espaÃ§o de uma celula
		add $t5, $t0, $t2
DVTL_Loop:
		sw %sx, ($t0)			# s6 must have drawColor value
		sw %sx, ($t4)			# esse loop desenha as linhas tracejadas verticais
		add $t0, $t0, $t7
		add $t0, $t0, $t7
		add $t4, $t4, $t7
		add $t4, $t4, $t7
		blt $t0, $t5, DVTL_Loop
		nop
.end_macro
###############################################################################################################
.macro number (%x, %coord)
zero:		
		bne %x, 48, one
		add $t1, $zero, %coord
		add $t1, $t1, $gp
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		add $t1, $t1, 4
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		add $t1, $t1, 4
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		add $t1, $t1, 1012
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		add $t1, $t1, 1024
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		add $t1, $t1, 1024
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		add $t1, $t1, 1024
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		add $t1, $t1, 1024
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		add $t1, $t1, 1028
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		add $t1, $t1, 4
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		add $t1, $t1, 4
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		sub $t1, $t1, 1020
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		sub $t1, $t1, 1024
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		sub $t1, $t1, 1024
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		sub $t1, $t1, 1024
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		sub $t1, $t1, 1024
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		sub $t1, $t1, 1028
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		jal fim		
one: 	
		bne %x, 49, two
		add $t1, $zero, %coord
		add $t1, $t1, $gp
		add $t1, $t1, 1024
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		sub $t1, $t1, 1020
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		add $t1, $t1, 1024
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		add $t1, $t1, 1024
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		add $t1, $t1, 1024
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		add $t1, $t1, 1024
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		add $t1, $t1, 1024
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		add $t1, $t1, 1016
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		add $t1, $t1, 4
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		add $t1, $t1, 4
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		add $t1, $t1, 4
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		add $t1, $t1, 4
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		jal fim
two:	bne %x, 50, tree
		add $t1, $zero, %coord
		add $t1, $t1, $gp
		add $t1, $t1, 1020
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		sub $t1, $t1, 1020
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		add $t1, $t1, 4
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		add $t1, $t1, 4
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		add $t1, $t1, 1028
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		add $t1, $t1, 1024
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		add $t1, $t1, 1020
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		add $t1, $t1, 1020
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		add $t1, $t1, 1020
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		add $t1, $t1, 1020
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		add $t1, $t1, 4
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		add $t1, $t1, 4
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		add $t1, $t1, 4
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		add $t1, $t1, 4
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		jal fim
tree: 	
		bne %x, 51, four	
		add $t1, $zero, %coord
		add $t1, $t1, $gp
		add $t1, $t1, 1020
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		sub $t1, $t1, 1020
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		add $t1, $t1, 4
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		add $t1, $t1, 4
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		add $t1, $t1, 1028
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		add $t1, $t1, 1024
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		add $t1, $t1, 1020
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		sub $t1, $t1, 4
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		add $t1, $t1, 1032
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		add $t1, $t1, 1024
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		add $t1, $t1, 1020
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		sub $t1, $t1, 4
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		sub $t1, $t1, 4
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		sub $t1, $t1, 1028
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		jal fim
four:	
		bne %x, 52, five
		add $t1, $zero, %coord
		add $t1, $t1, $gp
		add $t1, $t1, 6152		
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		sub $t1, $t1, 1024
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		sub $t1, $t1, 1024
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		sub $t1, $t1, 1024
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		sub $t1, $t1, 1024
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		sub $t1, $t1, 1024
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		sub $t1, $t1, 1024
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		sub $t1, $t1, 4
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		add $t1, $t1, 1020
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		add $t1, $t1, 1020
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		add $t1, $t1, 1024
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		add $t1, $t1, 4
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		add $t1, $t1, 4
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		add $t1, $t1, 4
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		add $t1, $t1, 4
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		jal fim
five: 	
		bne %x, 53, six
		add $t1, $zero, %coord
		add $t1, $t1, $gp
		sub $t1, $t1, 4		
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		add $t1, $t1, 4
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		add $t1, $t1, 4
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		add $t1, $t1, 4
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		add $t1, $t1, 4
		sw $s1, ($t1)			# Pinta o pixel da posicao s1	
		add $t1, $t1, 1008
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		add $t1, $t1, 1024
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		add $t1, $t1, 1028
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		add $t1, $t1, 4
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		add $t1, $t1, 4
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		add $t1, $t1, 1028
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		add $t1, $t1, 1024
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		add $t1, $t1, 1020
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		sub $t1, $t1, 4
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		sub $t1, $t1, 4
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		sub $t1, $t1, 1028
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		jal fim
six:	
		bne %x, 54, seven
		add $t1, $zero, %coord
		add $t1, $t1, $gp
		add $t1, $t1, 1036		
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		sub $t1, $t1, 1028
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		sub $t1, $t1, 4
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		sub $t1, $t1, 4
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		add $t1, $t1, 1020
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		add $t1, $t1, 1024
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		add $t1, $t1, 1024
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		add $t1, $t1, 1024
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		add $t1, $t1, 1024
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		add $t1, $t1, 1028
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		add $t1, $t1, 4
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		add $t1, $t1, 4
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		sub $t1, $t1, 1020
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		sub $t1, $t1, 1024
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		sub $t1, $t1, 1028
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		sub $t1, $t1, 4
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		sub $t1, $t1, 4	
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		jal fim
seven: 	
		bne %x, 55, eight	
		add $t1, $zero, %coord
		add $t1, $t1, $gp
		sub $t1, $t1, 4
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		add $t1, $t1, 4
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		add $t1, $t1, 4
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		add $t1, $t1, 4
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		add $t1, $t1, 4
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		add $t1, $t1, 1024
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		add $t1, $t1, 1020
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		add $t1, $t1, 1020
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		add $t1, $t1, 1024
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		add $t1, $t1, 1024
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		add $t1, $t1, 1024
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		jal fim
eight:	
		bne %x, 56, nine
		add $t1, $zero, %coord
		add $t1, $t1, $gp
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		add $t1, $t1, 4
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		add $t1, $t1, 4
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		add $t1, $t1, 1028
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		add $t1, $t1, 1024
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		sub $t1, $t1, 16
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		sub $t1, $t1, 1024
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		add $t1, $t1, 3072
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		add $t1, $t1, 1024
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		add $t1, $t1, 1028
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		add $t1, $t1, 4
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		add $t1, $t1, 4
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		sub $t1, $t1, 1020
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		sub $t1, $t1, 1024
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		sub $t1, $t1, 1028
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		sub $t1, $t1, 4
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		sub $t1, $t1, 4
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		jal fim
nine:
	 	bne %x, 57, fim		
		add $t1, $zero, %coord
		add $t1, $t1, $gp	 	
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		add $t1, $t1, 4
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		add $t1, $t1, 4
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		add $t1, $t1, 1028
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		add $t1, $t1, 1024
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		sub $t1, $t1, 16
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		sub $t1, $t1, 1024
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		add $t1, $t1, 4096
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		add $t1, $t1, 1028
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		add $t1, $t1, 4
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		add $t1, $t1, 4
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		sub $t1, $t1, 1020
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		sub $t1, $t1, 1024
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		sub $t1, $t1, 1024
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		sub $t1, $t1, 4
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		sub $t1, $t1, 4
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
		sub $t1, $t1, 4
		sw $s1, ($t1)			# Pinta o pixel da posicao s1
fim:
.end_macro
###############################################################################################################
.text
	lw $s1, DrawColor 			# Store drawing colour in s6
	lw $s0, BgColor	 			# Store background colour in s7
	xor $s2, $s2, 0				# Store cel to select s2 => colum
	xor $s3, $s2, 0				# Store cel to select s3 => line
	li $s4, -24
	# Inicializing Window:
		lh $a1, stageWidth			# Store WindowWidth in $a1 to pass to for below
		for ($a0, 0, $a1, 1, $s0, DrawHLine)	# Clear all Display (painting 'stageWidth' white lines)
		# Desenhando Linhas Horizontais
		for ($a0, 14, $a1, 10, $s1, DrawHLine)	# Drawing all Horizontal lines
		DrawHLine ($s1, 255)			# Last Line
		# Desenhando Linhas Verticais
		for ($a0, 15, $a1, 40, $s1, DrawVLine)	# Drawing all Vertical lines
		DrawVLine ($s1, 0)
		# Selecionando Primeira Célula
		move $a1, $s2
		move $a2, $s3
		SelecionaCelula
	# End_Inicialization
	# Execucao:
Main_waitLoop:
		# Wait for the player to press a key
		ori $v0, $zero, 32		# Syscall sleep
		ori $a0, $zero, 60		# For this many miliseconds
		syscall
		nop
		lw $a0, 0xFFFF0000		# Retrieve transmitter control ready bit
		blez $a0, Main_waitLoop		# Check if a key was pressed
		jal GetKey
		beq  $a0, $zero, Main_waitLoop
		nop
		jr $ra
###############################################################################################################			
MainExit:
	ori $v0, $zero, 10		# Syscall terminate
	syscall
################################################################################################
# Function to retrieve input from the kyboard and return it as an alpha channel direction
# Takes none
GetKey:
		lw $a0, 0xFFFF0004		# Load input value
		move $a1, $s2			# guardando valores da celula anteriormente selecionada (sera usada para "des"selecao
		move $a2, $s3			# idem acima
GetDir_right:
		bne, $a0, 100, GetDir_up
		nop
		ori $v0, $zero, 0x01000000	# Right
		add $s2, $s2, 1			# moveu uma celula a direita
		j GetKey_done
		nop
GetDir_up:
		bne, $a0, 119, GetDir_left
		nop
		ori $v0, $zero, 0x02000000	# Up
		sub $s3, $s3, 1			# moveu uma celula acima
		j GetKey_done
		nop
GetDir_left:
		bne, $a0, 97, GetDir_down
		nop
		ori $v0, $zero, 0x03000000	# Left
		sub $s2, $s2, 1			# moveu uma celula a esquerda
		j GetKey_done
		nop
GetDir_down:
		bne, $a0, 115, GetKey_num
		nop
		ori $v0, $zero, 0x04000000	# Down
		add $s3, $s3, 1			# moveu uma celula abaixo
		j GetKey_done
		nop
GetKey_done:
		li $s4, -24			# parametro referencia para inicio de impressao de numeros teclados
		bge $s2, $zero, GetKey_done_1	# se s2 nao for maior que zero
		li $s2, 5			# entao deve ser a ultima coluna
		j GetKey_done_2			# va para verificacao de linhas agora
GetKey_done_1:	blt $s2, 6, GetKey_done_2	# Se s2 não for menor que numeros de colunas
		li $s2, 0			# entao deve ser a primeira coluna
GetKey_done_2:  bge $s3, $zero, GetKey_done_3	# Se s3 nao for maior que zero
		li $s3, 23			# entao deve ser a ultima linha
		j GetKey_done_4			# finaliza verificacao de linha
GetKey_done_3:	blt $s3, 24, GetKey_done_4	# mas se s3 nao for menor que 24
		li $s3, 0			# entao deve ser a primeira linha
GetKey_done_4:
		SelecionaCelula			# seleciona celula de acordo com a configuracao feita acima
		li $a0, 0
		jr $ra				# Return
		nop
GetKey_num:	
		ble, $a0, 47, Main_waitLoop
		bge $a0, 58, Main_waitLoop
 		# getting coordinate to print
 		add $s4, $s4, 24		# Atualizando onde vai printar
 		bge $s4, 144, Exit		# Digitando mais numeros do que é permitido
 		xor $t0, $t0, $t0		# zerando $t0 para uso
 		xor $t1, $t1, $t1 		# zerando $t1 para uso
 		xor $t3, $t3, $t3		# zerando $t3 para uso
 		lh $t0, CelWidth		# carregando valores para uso
 		lh $t1, CelHeight
		lh $t2, BasePrintCel		# carregando referencia inicial para impressao
 		mul $t0, $s2, $t0		# msm calculo da celula selecionada, adquirindo coordenada onde imprimit
		mul $t1, $s3, $t1		# msm calculo da celula selecionada, adquirindo coordenada onde imprimit
		add $t2, $t2, $t0		# com isso a impressao vai ser na celula selecionada
		add $t2, $t2, $t1		# idem acima
		add $t2, $t2, $s4		# movendo cursor para proximo digito
		move $a1, $t2
print_num: 	number ($a0, $a1)
		nop
		jal Main_waitLoop		# Do nothing
GetDir_none:
Exit:   
	#play a sound tune to signify game over
	li $v0, 31
	li $a0, 28
	li $a1, 250
	li $a2, 32
	li $a3, 127
	syscall
		
	li $a0, 33
	li $a1, 250
	li $a2, 32
	li $a3, 127
	syscall
	
	li $a0, 47
	li $a1, 1000
	li $a2, 32
	li $a3, 127
	syscall
	
	li $v0, 55 #syscall value for dialog
	la $a0, BreakCellMsg #get message
	syscall
	
	li $v0, 50 #syscall for yes/no dialog
	la $a0, replayMessage #get message
	syscall
	
	beqz $a0, Main_waitLoop#jump back to start of program
	#end program
	li $v0, 10
	syscall


