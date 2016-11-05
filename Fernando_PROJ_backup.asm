# MIPS assembly program written by D.Taylor to be snake.
.macro DrawL (%x)

		add $t1, $zero, 256		# Calculate ending possition
		add $t2, $zero, 256
		multu $t1, $t2			# Multiply screen width by screen height
		nop
		mflo $t2			# Retreive total tiles
		sub $t2, $t2, $t1		# Minus one width
		sll $t2, $t2, 2			# Multiply by 4
		add $t2, $t2, $gp		# Add global pointer
		
#		subi $a1, $a1, 1		# Take 1 from width
		sll $t3, $t1, 2			# Multiply by 4 to get mem to add
		
		or $t1, $zero, $gp		# Set loop var to global pointer
		add $t1, $t1, %x
		add $t4, $zero, 10240
		add $t1, $t1, $t4
DrawLine_L:
		sw $s6, ($t1)
		add $t1, $t1, $t3
		blt $t1, $t2, DrawLine_L
		nop
.end_macro

.kdata
drawColour:		.word 0x00000000		# Store colour to draw objects
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
			or $a0, $zero, $s7		# Clear stage to background colour
			jal FillMemory
			nop
			jal AddBoundaries		# Add walls
			nop
			DrawL 128
Main_waitLoop:
			# Wait for the player to press a key
			jal Sleep			# Zzzzzzzzzzz...
			nop
			lw $t0, 0xFFFF0000		# Retrieve transmitter control ready bit
			blez $t0, Main_waitLoop		# Check if a key was pressed
			nop
####
#			add $a1, $zero, 128
#			jal DrawLineV	
#			nop			
#			add $a1, $zero, 256
#			jal DrawLineV				
#			nop			
Main_exit:
			ori $v0, $zero, 10		# Syscall terminate
			syscall
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
# Function to fill the stage memory with a given colour
# Takes a0 = colour
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
		sw $a0, ($a1)
		add $a1, $a1, 4
		blt $a1, $a2, FillMemory_l
		nop
		
		jr $ra				# Return
		nop
###########################################################################################
# Function to add boundary walls
# Takes none
# Returns none
AddBoundaries:
		lh $a1, stageWidth		# Calculate ending possition
		sll $a1, $a1, 2			# Multiply by 4
		add $a2, $a1, $gp		# Add global pointer
		
		
		or $a1, $zero, $gp		# Set loop var to global pointer
		lh $t1, oneLine
		add $a2, $a2, $t1
		add $a1, $a1, $t1
AddBoundaries_t:	
		sw $s6, ($a1)
		add $a1, $a1, 4
		blt $a1, $a2, AddBoundaries_t
		nop
		
		lh $a1, stageWidth		# Calculate ending possition
		lh $a2, stageHeight
		multu $a1, $a2			# Multiply screen width by screen height
		nop
		mflo $a2			# Retreive total tiles
		sub $a2, $a2, $a1		# Minus one width
		sll $a2, $a2, 2			# Multiply by 4
		add $a2, $a2, $gp		# Add global pointer
		
		subi $a1, $a1, 1		# Take 1 from width
		sll $a3, $a1, 2			# Multiply by 4 to get mem to add
		
		or $a1, $zero, $gp		# Set loop var to global pointer
		add $a1, $a1, $t1
AddBoundaries_s:
		sw $s6, ($a1)
		add $a1, $a1, $a3
		sw $s6, ($a1)
		add $a1, $a1, 4
		blt $a1, $a2, AddBoundaries_s
		nop
		
		or $a3, $zero, $a1		# backup a1 (current possition)
		
		lh $a1, stageWidth		# Calculate ending possition
		lh $a2, stageHeight
		multu $a1, $a2			# Multiply screen width by screen height
		nop
		mflo $a2			# Retreive total tiles
		sll $a2, $a2, 2			# Multiply by 4
		add $a2, $a2, $gp		# Add global pointer
		
		or $a1, $zero, $a3		# restore previous possition
AddBoundaries_b:
		sw $s6, ($a1)
		add $a1, $a1, 4
		blt $a1, $a2, AddBoundaries_b
		nop

		jr $ra				# Return
		nop
###########################################################################################
# Function to draw the given colour to the given stage memory address (gp)
# Takes a0 = colour, a1 = address
# Returns none
PaintMemory:
		sw $a0, ($a1)			# Set colour
		jr $ra				# Return
		nop
###########################################################################################
DrawLineV:
		lh $t1, stageWidth		# Calculate ending possition
		lh $t2, stageHeight
		multu $t1, $t2			# Multiply screen width by screen height
		nop
		mflo $t2			# Retreive total tiles
		sub $t2, $t2, $t1		# Minus one width
		sll $t2, $t2, 2			# Multiply by 4
		add $t2, $t2, $gp		# Add global pointer
		
#		subi $a1, $a1, 1		# Take 1 from width
		sll $t3, $t1, 2			# Multiply by 4 to get mem to add
		
		or $t1, $zero, $gp		# Set loop var to global pointer
		add $t1, $t1, $a1
		lh $t4, oneLine
		add $t1, $t1, $t4
DrawLine_L:
		sw $s6, ($t1)
		add $t1, $t1, $t3
		blt $t1, $t2, DrawLine_L
		nop
		
		or $t3, $zero, $t1		# backup a1 (current possition)

		jr $ra				# Return
		nop		