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
		add $t0, $zero, 1024		# soma 1024 a t0, pq?
		add $t0, $t0, %x
		add $a2, $a2, $t0
		add $a1, $a1, $t0
DHL_Loop:
		sw $s6, ($a1)
		add $a1, $a1, 4
		blt $a1, $a2, DHL_Loop
		nop
.end_macro
###########################################################################################
###############################################################################################################
.macro SelecionaCelula (%sx, %x1, %x2)  #cor, cord X, comprimento da linha
		add $a1, $zero, %x2		# Calculate ending possition
		add $a2, $a1, $gp		# Add global pointer
		
		add $a1, $zero, $gp		# Set loop var to global pointer
		add $t0, $zero, 1024		# soma 1024 a t0, pq?
		add $t0, $t0, %x1
		add $a2, $a2, $t0
		add $a1, $a1, $t0
		add $a3, $a1, 8192		# a3 pinta a linha de baixo tracejada, 8192 é o espaço entre as linhas
		move $t0, $a1
DHLT_Loop:
		sw %sx, ($a1)
		sw %sx, ($a3)		
		add $a1, $a1, 8
		add $a3, $a3, 8		
		blt $a1, $a2, DHLT_Loop
		nop

		add $a1, $zero, 256		# Calculate ending possition
		sll $a3, $a1, 2			# Multiply by 4 to get mem to add
		
		move $a1, $t0
		add $a0, $a1, 128		# a0 desenha a linha tracejada oposta a que $a1 desenha com espaço de uma celula
		add $a2, $a1, 9216
DVTL_Loop:
		sw %sx, ($a1)			# s6 must have drawColor value
		sw %sx, ($a0)
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
			for ($a0, 64, 900, 136, DrawVLine)
			nop
			DrawVLine 1020		# nao consegui desenhar essa linha pelo for
			nop 
			for ($a0, 14336, 256000, 10240, DrawHLine)	# a macro DrawHline tem q utilizar o registrador do primeiro parametro 
			nop				# como seu proprio parametro. No caso, � o numero da linha a ser desenhada
							# Este for apenas funciona para macros que necessitem de UM parametro
			DrawHLine 259072		# Last line, Nao consegui colocar no for casando certinho com o fim
			nop
################################################################################################################
Seleciona_Celula:	
			SelecionaCelula ($s6, 15428, 132)
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
			#jal GetDir
			#beq  $t6, $zero Main_waitLoop
			#nop
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
		