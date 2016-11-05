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
		add $a1, $a1, 10240
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
		add $t0, $zero, 1024
		add $t0, $t0, %x
		add $a2, $a2, $t0
		add $a1, $a1, $t0
DHL_Loop:
		sw $s6, ($a1)
		add $a1, $a1, 4
		blt $a1, $a2, DHL_Loop
		nop
.end_macro
#######################################################################################################
.macro number (%x, %coord)
zero:	bne %x, 0, one
	
one: 	bne %x, 1, two
two:	bne %x, 2, tree
tree: 	bne %x, 3, four	
four:	bne %x, 0, five
five: 	bne %x, 1, six
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
			for ($s0, 0, 896, 128, DrawVLine)
			nop
			DrawVLine 1020		# nao consegui desenhar essa linha pelo for
			nop 
			for ($s0, 9216, 256000, 10240, DrawHLine)	# a macro DrawHline tem q utilizar o registrador do primeiro parametro 
			nop				# como seu proprio parametro. No caso, é o numero da linha a ser desenhada
							# Este for apenas funciona para macros que necessitem de UM parametro
			DrawHLine 259072		# Last line, Nao consegui colocar no for casando certinho com o fim
			nop
################################################################################################################
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
	
#	mflo $t2			# Parâmetro de referência para a função Loop_fundo
#	sub $t2, $t2, $t2
	add $t2, $zero, $t5
	add $t2, $t2, $gp		# Adiciona o ponteiro global em t2
	
			
	or $t1, $zero, $gp		# Coloca o ponteiro global em t1
	add $t1, $t1, $t5
	sub $t1, $t1, 124
###########################################################################################
Main_waitLoop:
			# Wait for the player to press a key
			ori $v0, $zero, 32		# Syscall sleep
			ori $a0, $zero, 60		# For this many miliseconds
			syscall
			nop
			lw $t0, 0xFFFF0000		# Retrieve transmitter control ready bit
			blez $t0, Main_waitLoop		# Check if a key was pressed
			nop
			jr $ra
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
