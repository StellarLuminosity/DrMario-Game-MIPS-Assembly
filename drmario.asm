################# CSC258 Assembly Final Project ###################
# This file contains our implementation of Dr Mario.
#
# Student 1: Katherine Lambert, 1010045254
#
######################## Bitmap Display Configuration ########################
# - Unit width in pixels:       todo
# - Unit height in pixels:      todo
# - Display width in pixels:    33
# - Display height in pixels:   33
# - Base Address for Display:   0x10008000 ($gp)
##############################################################################
    .data
displayaddress:      .word 0x10008000

Capsule_X:           .word 5       # X-coordinate
Capsule_Y:           .word 10      # Y-coordinate
Capsule_Color1:      .word 0xff0000  # Red component of one half
Capsule_Color2:      .word 0x00ff00  # Green component of other half
Capsule_Orientation: .word 0         # 0 for horizontal, 1 for vertical

red:                 .word 0xff4746
yellow:              .word 0xffE94A
blue:                .word 0x0fd5ff
dark_grey:           .word 0x4f4f4f
light_grey:          .word 0xb3b3b3

FIELD:               .space 512  # '2D' array to store the pixel color values inside the playing field
field:               .word  0x100087C4 # memory address of top left corner of the playing capsule

##############################################################################
# Immutable Data
##############################################################################
# The address of the bitmap display. Don't forget to connect it!
ADDR_DSPL:
    .word 0x10008000
# The address of the keyboard. Don't forget to connect it!
ADDR_KBRD:
    .word 0xffff0000

##############################################################################
# Mutable Data
##############################################################################

##############################################################################
# Code
##############################################################################
	.text
lw $t0, displayaddress # (base address for display) (loads value at address of displayaddress (which is 0x10008000) (base address for display))
lw $t1, red # $t1 = value at address of red (0xff4746)
lw $t2, yellow # $t2 = value at address of yellow (0xffE94A)
lw $t3, blue # $t3 = value at address of blue (0x0fd5ff)
lw $t4, dark_grey # $t4 = dark grey
lw $t5, light_grey # $t5 = light grey
la $t8, FIELD # (loads the address of 'FIELD') (points to memory address of the first element of FIELD array)
lw $t9, field # (loads the field address) (value at address of field (0x100087C4))

# some notes:
#   lw = loads the value stored at the memory address to a register (assumes the operand is a memory address and fetches the 32-bit (4-byte) word stored at that address)
#   la  = loads the memory address itself into the register (when working with the address rather than the value at the address)

# ----- DRAW DISPLAY ----- #

# DRAW CAPSULE
# left side
li $t6, 14           # starting row
mul $t6, $t6, 132    # moving down to the 14th row (Each row is 132 bytes)
add $t6, $t6, $t0    # add the base address of the display to get the final location to draw
li $t7, 31           # ending row
mul $t7, $t7, 132    # moving down to the 31t row
add $t7, $t7, $t0    # adding the base address 
capsule_left_paint_loop:
    bgt $t6, $t7, capsule_left_paint_end # jump to end of loop if all rows have been drawn
    sw $t4, 4( $t6 ) # draw pixel on that row
    addi $t6, $t6, 132 # move down one row
    j capsule_left_paint_loop # repeat for the next row
capsule_left_paint_end:

# right side
li $t6, 14           # starting row
mul $t6, $t6, 132    # moving down to the 14th row (Each row is 132 bytes)
add $t6, $t6, $t0    # add the base address of the display to get the final location to draw
li $t7, 31           # ending row
mul $t7, $t7, 132    # moving down to the 31t row
add $t7, $t7, $t0    # adding the base address 
capsule_right_paint_loop:
    bgt $t6, $t7, capsule_right_paint_end # jump to end of loop if all rows have been drawn
    sw $t4, 40( $t6 ) # draw pixel on that row
    addi $t6, $t6, 132 # move down one row
    j capsule_right_paint_loop # repeat for the next row
capsule_right_paint_end:

# bottom side
li $t6, 31           # starting row
mul $t6, $t6, 132    # moving down to the 31st row (Each row is 132 bytes)
add $t6, $t6, $t0    # add the base address of the display to get the final location to draw
addi $t6, $t6, 4     # add offset
li $t7, 31           # starting row
mul $t7, $t7, 132    # moving down to the 31st row (Each row is 132 bytes)
add $t7, $t7, $t0    # add the base address of the display to get the final location to draw
addi $t7, $t7, 40    # add offset (width of bottom = 10 pixels)
capsule_bottom_paint_loop:
    bgt $t6, $t7, capsule_bottom_paint_end # jump to end of loop if the bottom has been drawn
    sw $t4, 0( $t6 )  # draw pixel
    addi $t6, $t6, 4  # t6 refers to the next pixel on the right
    j capsule_bottom_paint_loop
capsule_bottom_paint_end:

# add bottleneck
li $t6, 13          # start with pixel on row 13
mul $t6, $t6, 132   # moving down to the 13th row (Each row is 132 bytes)
add $t6, $t6, $t0   # add the base address of the display to get the final location to draw
sw $t4, 16( $t6 )   # draw pixel
sw $t4, 28( $t6 )   # draw pixel
add $t6, $t6, 132   # move down a row
sw $t4, 8( $t6 )    # draw pixel
sw $t4, 12( $t6 )   # draw pixel
sw $t4, 16( $t6 )   # draw pixel
sw $t4, 28( $t6 )   # draw pixel
sw $t4, 32( $t6 )   # draw pixel
sw $t4, 36( $t6 )   # draw pixel

# DRAW SCORE, HI, and LVL
# score
li $t6, 1           # start with pixel on row 1
mul $t6, $t6, 132   # moving down to the 1st row (Each row is 132 bytes)
addi $t6, $t6, 48 # calculating offset
add $t6, $t6, $t0   # add the base address of the display to get the final location to draw
sw $t5, 0( $t6 )   # draw pixel
sw $t5, 4( $t6 )   # draw pixel
sw $t5, 8( $t6 )   # draw pixel
addi $t6, $t6, 132   # moving down to the next row & next pixel
sw $t5, 0( $t6 )     # draw pixel
addi $t6, $t6, 132   # moving down to the next row & next pixel
sw $t5, 0( $t6 )     # draw pixel
sw $t5, 4( $t6 )     # draw pixel
sw $t5, 8( $t6 )     # draw pixel
sw $t5, 24( $t6 )     # draw pixel
addi $t6, $t6, 132   # moving down to the next row & next pixel
sw $t5, 8( $t6 )     # draw pixel
addi $t6, $t6, 132   # moving down to the next row & next pixel
sw $t5, 0( $t6 )    # draw pixel
sw $t5, 4( $t6 )    # draw pixel
sw $t5, 8( $t6 )    # draw pixel
sw $t5, 24( $t6 )     # draw pixel

# hi
li $t6, 7           # start with pixel on row 7
mul $t6, $t6, 132   # moving down to the 1st row (Each row is 132 bytes)
addi $t6, $t6, 48 # calculating offset
add $t6, $t6, $t0   # add the base address of the display to get the final location to draw
sw $t5, 0( $t6 )   # draw pixel
sw $t5, 8( $t6 )   # draw pixel
addi $t6, $t6, 132   # moving down to the next row & next pixel
sw $t5, 0( $t6 )     # draw pixel
sw $t5, 8( $t6 )     # draw pixel
sw $t5, 16( $t6 )     # draw pixel
addi $t6, $t6, 132   # moving down to the next row & next pixel
sw $t5, 0( $t6 )     # draw pixel
sw $t5, 4( $t6 )     # draw pixel
sw $t5, 8( $t6 )     # draw pixel
sw $t5, 24( $t6 )     # draw pixel
addi $t6, $t6, 132   # moving down to the next row & next pixel
sw $t5, 0( $t6 )     # draw pixel
sw $t5, 8( $t6 )     # draw pixel
sw $t5, 16( $t6 )     # draw pixel
addi $t6, $t6, 132   # moving down to the next row & next pixel
sw $t5, 0( $t6 )     # draw pixel
sw $t5, 8( $t6 )     # draw pixel
sw $t5, 16( $t6 )     # draw pixel
sw $t5, 24( $t6 )     # draw pixel

# lvl
li $t6, 27           # start with pixel on row 27
mul $t6, $t6, 132   # moving down to the 1st row (Each row is 132 bytes)
addi $t6, $t6, 48 # calculating offset
add $t6, $t6, $t0   # add the base address of the display to get the final location to draw
sw $t5, 0( $t6 )   # draw pixel
addi $t6, $t6, 132   # moving down to the next row & next pixel
sw $t5, 0( $t6 )   # draw pixel
addi $t6, $t6, 132   # moving down to the next row & next pixel
sw $t5, 0( $t6 )   # draw pixel
sw $t5, 24( $t6 )   # draw pixel
addi $t6, $t6, 132   # moving down to the next row & next pixel
sw $t5, 0( $t6 )   # draw pixel
addi $t6, $t6, 132   # moving down to the next row & next pixel
sw $t5, 0( $t6 )   # draw pixel
sw $t5, 4( $t6 )   # draw pixel
sw $t5, 8( $t6 )   # draw pixel
sw $t5, 24( $t6 )   # draw pixel

# sample capsule draw
li $t6, 10          # start with pixel on row 10
mul $t6, $t6, 132   # moving down to the 1st row (Each row is 132 bytes)
addi $t6, $t6, 20   # calculating offset
add $t6, $t6, $t0   # add the base address of the display to get the final location to draw
lw $t1, red
sw $t1, 0( $t6 )   # draw pixel

# ----- CAPSULE ARRAY FUNCTIONS ----- #

# init_cell - for the cell referenced by (x,y) coordinates, function encodes the color and type
# Inputs:
#   $a0 = x (column #: 0000 - 0111) (integer)
#   $a1 = y (row #:    0000 - 1111) (integer)
#   $a2 = color (11 red, 10 yellow, 01 blue, 00 black)
#   $a3 = type (10 virus, 01 capsule, 00 neither)
# Returns:
#   void

# Questions:
#   correct offset calculation below?
#   how to pass in bit values / inputs above and decode them
#   have to set the memory of the FIELD array to 0?
#   how do I make the screen update 60 times per second? Is it a loop that runs in main?

init_cell:
    # sets the t8 pointer to the (x, y) coordinate
    mul $t4, $a0, 4 # calculates the column offset (each cell is 4 bytes)
    mul $t5, $a1, 32 # calculates the row offset (8 (cells per row) * 4 (bytes per cell))
    add $t4, $t4, $t5 # Combine row and column offsets
    add $t8, $t8, $t4 # Computes the final address of FIELD cell referenced by (x, y)
    
    # ...
    
    lw $t8, FIELD # resets $t8 to point to the first element of FIELD array
    
    



	.globl main

    # Run the game.
main:
    # Initialize the game

game_loop:
    # 1a. Check if key has been pressed
    # 1b. Check which key has been pressed
    # 2a. Check for collisions
	# 2b. Update locations (capsules)
	# 3. Draw the screen
	# 4. Sleep

    # 5. Go back to Step 1
    j game_loop
