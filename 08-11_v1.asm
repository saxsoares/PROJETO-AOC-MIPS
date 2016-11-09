# MIPS assembly program written by D.Taylor to be snake.
.macro for (%regIterator, %from, %to, %step, %bodyMacroName)
	add %regIterator, $zero, %from
	Loop:
	%bodyMacroName (%regIterator)
	add %regIterator, %regIterator, %step
	ble %regIterator, %to, Loop
.end_macro
#######################################################################################
.macro DrawVLine (%x)

		add $a1, $zero, 256		# Calculate ending possition
		add $a2, $zero, 256
		multu $a1, $a2			# Multiply screen width by screen height
		nop
		mflo $a2			# Retreive total tiles
		sub $a2, $a2, $a1		# Minus one width
		sll $a2, $a2, 2			# Multiply by 4
		add $a2, $a2, $gp		# Add global pointer
		
#		subi $a1, $a1, 1		# Take 1 from width
		sll $a3, $a1, 2			# Multiply by 4 to get mem to add
		
		or $a1, $zero, $gp		# Set loop var to global pointer
		add $a1, $a1, %x
		add $a1, $a1, 15360
DVL_Loop:
		sw $s6, ($a1)			# s6 must have drawColor value
		add $a1, $a1, $a3
		blt $a1, $a2, DVL_Loop
		nop
.end_macro
######################################################################################
.macro DrawHLine (%x)
		lh $a1, stageWidth		# Calculate ending possition
		sll $a1, $a1, 2			# Multiply by 4
		add $a2, $a1, $gp		# Add global pointer
		
		or $a1, $zero, $gp		# Set loop var to global pointer
		add $t0, $zero, 1024		# soma 1024 a t0, uma linha abaixo
		add $t0, $t0, %x
		add $a2, $a2, $t0
		add $a1, $a1, $t0
DHL_Loop:					# começa a printar os pixels da linha
		sw $s6, ($a1)
		add $a1, $a1, 4
		blt $a1, $a2, DHL_Loop
		nop
.end_macro
###########################################################################################
.macro SelecionaCelula		# Recebe novos valores de $s1 e $s0, (pra onde irá "andar" )
	mul $t1, $s2, 136	# settando paramentros da celula a apagar
	mul $t2, $s3, 10240	#
	SelecionaCelula_aux ($s7, $t1, $t2)	# apaga seleção anterior
	mul $t1, $s0, 136			# setando parametros da celula à selecionar
	mul $t2, $s1, 10240			#
	SelecionaCelula_aux ($s6, $t1, $t2)	# selecionando celula
.end_macro
###############################################################################################################
.macro SelecionaCelula_aux (%sx, %x1, %x2)  #cor, cord X, comprimento da linha
		add $a1, $zero, 132		# Calculate ending possition
		add $a2, $a1, $gp		# Add global pointer
		
		add $a1, $zero, $gp		# Set loop var to global pointer
		add $t0, $zero, 1024		# soma 1024 a t0, puma linha abaixo
		add $t0, $t0, 14404
		add $t0, $t0, %x1
		add $t0, $t0, %x2
		add $a2, $a2, $t0
		add $a1, $a1, $t0		#
		add $a3, $a1, 8192		# a3 pinta a linha de baixo tracejada, 8192 Ã© o espaÃ§o entre as linhas
		
		move $t0, $a1			# fazendo backup do valor de $a1, ele é necessário para o segundo loop
DHLT_Loop:
		sw %sx, ($a1)			# esse loop desenha as linhas tracejadas horizontais
		sw %sx, ($a3)			#
		add $a1, $a1, 8			#
		add $a3, $a3, 8			#
		blt $a1, $a2, DHLT_Loop		#
		nop

		add $a1, $zero, 256		# Calculate ending possition
		sll $a3, $a1, 2			# Multiply by 4 to get mem to add
		
		move $a1, $t0			# devolvendo valor de $a1
		add $a0, $a1, 128		# a0 desenha a linha tracejada oposta a que $a1 desenha com espaÃ§o de uma celula
		add $a2, $a1, 9216
DVTL_Loop:
		sw %sx, ($a1)			# s6 must have drawColor value
		sw %sx, ($a0)			# esse loop desenha as linhas tracejadas verticais
		add $a1, $a1, $a3
		add $a1, $a1, $a3
		add $a0, $a0, $a3
		add $a0, $a0, $a3
		blt $a1, $a2, DVTL_Loop
		nop
.end_macro
###############################################################################################################
.macro number (%x, %coord)
zero:	bne %x, 0, one

one: 	bne %x, 1, two
two:	bne %x, 2, tree


tree: 	bne %x, 3, four	
four:	bne %x, 4, five
five: 	bne %x, 5, six
six:	bne %x, 2, seven
seven: 	bne %x, 3, eight	
eight:	bne %x, 0, nine
nine: 	bne %x, 1, fim
fim:
.end_macro
########################################################################################################
#
########################################################################################################
.kdata
drawColour:		.word 0xFFAAAAAA		# Store colour to draw objects
bgColour:		.word 0xFFFFFFFF		# Store colour to draw background
stageWidth:		.half 256			# Store stage size
stageHeight:		.half 256			# Usual settings $gp, 32x32, 16xScaling, 512x512
oneLine: 		.half 10240
BaseCelSelection: 	.word 15428
LineWidth: 		.word 132

.text
Main:
# Load colour info
			lw $s6, drawColour		# Store drawing colour in s6
			lw $s7, bgColour		# Store background colour in s7

			# Prepare the arena
			#or $a0, $zero, $s7		# Clear stage to background colour
			jal FillMemory
			nop
#################### Look at this :
			DrawVLine 0		# nao consegui desenhar essa linha pelo for
			for ($a0, 64, 900, 136, DrawVLine)
			nop
			DrawVLine 1020		# nao consegui desenhar essa linha pelo for
			nop 
			for ($a0, 13312, 259100, 10240, DrawHLine)	# a macro DrawHline tem q utilizar o registrador do primeiro parametro 
			nop				# como seu proprio parametro. No caso, ï¿½ o numero da linha a ser desenhada
							# Este for apenas funciona para macros que necessitem de UM parametro
			#DrawHLine 259072		# Last line, Nao consegui colocar no for casando certinho com o fim
			nop
			li $s0, 0	#s0 irá armazenar coluna selecionada
			li $s1, 0	#s1 irá armazenar linha selecionada
			SelecionaCelula
			jal Main_waitLoop
			#SelecionaCelula ($s7, 10244, 121)
			
			nop			
###########################################################################################
Main_waitLoop:
			# Wait for the player to press a key
			ori $v0, $zero, 32		# Syscall sleep
			ori $a0, $zero, 60		# For this many miliseconds
			syscall
			nop
			lw $t0, 0xFFFF0000		# Retrieve transmitter control ready bit
			blez $t0, Main_waitLoop		# Check if a key was pressed
			jal GetKey
			beq  $t6, $zero Main_waitLoop
			nop
			jr $ra
###############################################################################################################	
# Function to retrieve input from the kyboard and return it as an alpha channel direction
# Takes none
# Returns v0 = direction
GetKey:
		lw $t0, 0xFFFF0004		# Load input value
		move $s2, $s0
		move $s3, $s1
GetDir_right:
		bne, $t0, 100, GetDir_up
		nop
		ori $v0, $zero, 0x01000000	# Right
		add $s0, $s0, 1
		j GetKey_done
		nop
GetDir_up:
		bne, $t0, 119, GetDir_left
		nop
		ori $v0, $zero, 0x02000000	# Up
		sub $s1, $s1, 1
		j GetKey_done
		nop
GetDir_left:
		bne, $t0, 97, GetDir_down
		nop
		ori $v0, $zero, 0x03000000	# Left
		sub $s0, $s0, 1
		j GetKey_done
		nop
GetDir_down:
		bne, $t0, 115, GetDir_none
		nop
		ori $v0, $zero, 0x04000000	# Down
		add $s1, $s1, 1
		j GetKey_done
		nop
GetDir_none:
						# Do nothing
GetKey_done:
		bge $s0, $zero, GetKey_done_1
		li $s0, 6
		j GetKey_done_2
GetKey_done_1:	blt $s0, 7, GetKey_done_2
		li $s0, 0
GetKey_done_2:  bge $s1, $zero, GetKey_done_3
		li $s1, 23
		j GetKey_done_4
GetKey_done_3:	blt $s1, 24, GetKey_done_4
		li $s1, 0
GetKey_done_4:
		SelecionaCelula
		li $t0, 0
		jr $ra				# Return
		nop	
###############################################################################################################	
Main_exit:
			ori $v0, $zero, 10		# Syscall terminate
			syscall
###########################################################################################
# Sleep function - # Takes none # Returns none
Sleep:
			ori $v0, $zero, 32		# Syscall sleep
			ori $a0, $zero, 60		# For this many miliseconds
			syscall
			jr $ra				# Return
			nop								
###########################################################################################
# Function to fill the stage memory with a given colour
# Takes s7 = colour
# Returns none
FillMemory:
		lh $a1, stageWidth		# Calculate ending possition
		lh $a2, stageHeight
		multu $a1, $a2			# Multiply screen width by screen height
		nop
		mflo $a2			# Retreive total tiles
		sll $a2, $a2, 2			# Multiply by 4
		add $a2, $a2, $gp		# Add global pointer
		or $a1, $zero, $gp		# Set loop var to global pointer
FillMemory_l:	
		sw $s7, ($a1)
		add $a1, $a1, 4
		blt $a1, $a2, FillMemory_l
		nop
	
		jr $ra				# Return
		nop
		
