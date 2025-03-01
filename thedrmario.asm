################# CSC258 Assembly Final Project ###################
# This file contains our implementation of Dr Mario.
# Student 1: Katherine Lambert, 1010045254
######################## Bitmap Display Configuration ########################
# - Unit width in pixels:       todo
# - Unit height in pixels:      todo
# - Display width in pixels:    33
# - Display height in pixels:   33
# - Base Address for Display:   0x10008000 ($gp)
##############################################################################
    .data
    # holds the variables and constants - memory declared for storing data

displayaddress:      .word 0x10008000
bottlemouth:         .word 0x1000874C
field:               .word 0x100087C4 # memory address of top left corner of the playing capsule
keyboardaddress:     .word 0xffff0000

top_X:               .word 3       # X-coordinate for capsule at the top
top_Y:               .word -5      # Y-coordinate for capsule at the top

X:                   .word 0       # X-coordinate
Y:                   .word 0       # Y-coordinate
color_array:         .word 0, 0    # color_array refers to the memory location of the first color
rotation:            .word 0       # 0 for horizontal, 1 for vertical

red:                 .word 0xff4746
yellow:              .word 0xffE94A
blue:                .word 0x0fd5ff
dark_grey:           .word 0x4f4f4f
light_grey:          .word 0xb3b3b3

viruses:             .space 56     # viruses is a 2D array to store the information about each virus

##############################################################################
# Code
##############################################################################
	.text
	.globl main
	# contains the program's executable instructions
	
# --- initializing main values ---- #
lw $t0, displayaddress # (base address for display) (loads value at address of displayaddress (which is 0x10008000) (base address for display))
lw $t1, red # $t1 = value at address of red (0xff4746)
lw $t2, yellow # $t2 = value at address of yellow (0xffE94A)
lw $t3, blue # $t3 = value at address of blue (0x0fd5ff)
lw $t4, dark_grey # $t4 = dark grey
lw $t5, light_grey # $t5 = light grey
li $t8, 0 # tracks the milliseconds 
la $t9, color_array # loads the address of 'color_array'; points to memory address of the first color of the array
    
# --- Run the game --- #
main:
    jal draw_init_display
    jal generate_virus
    
    jal new_cap

    j game_loop


game_loop:
    jal draw_cap # draw capsule based on the last update to the X and Y values
    
    # --- keyboard input --- #
    lw $t4, Y # load the current Y-value
    li $t5, -1
    ble $t4, $t5, skip_keyboard_check # check and react to input only if the capsule is in the bottleneck
        li $v0, 32 # check if a key has been pressed
    	li $a0, 1
    	syscall    
        lw $t7, keyboardaddress # $t7 = base address for keyboard
        lw $t4, 0($t7) # Load first word from keyboard
        beq $t4, 1, handle_input   # If first word 1, key is pressed
    skip_keyboard_check:
    
    # --- gravity --- #
    li $a0, 1  # set $a0 to 1 mls for sleep
    jal sleep
    addi $t8, $t8, 1 # increments the counter by 1
    li, $t4, 60 
    beq $t8, $t4, gravity # if 60 milliseconds has passed, time to move the capsule down    

    j game_loop



# sleep = waits a specified amount of time
# $a0 = milliseconds
sleep:
    addi $sp, $sp, -4      # Reserve space on stack
    sw $ra, 0($sp)         # Save return address

    li $v0, 32             # Syscall 32: sleep
    syscall

    lw $ra, 0($sp)         # Restore return address
    addi $sp, $sp, 4       # Restore stack pointer
    jr $ra                 # Return to caller

    
    
             # for control flow's sake
	# jal draw_pill                  # draw pill
	# jal initiate_gravity           # move everything down


    # 1a. Check if key has been pressed
    # 1b. Check which key has been pressed
    # 2a. Check for collisions
	# 2b. Update locations (capsules)
	# 3. Draw the screen
	# 4. Sleep

    # 5. Go back to Step    1
    # j game_loop

game_lost:
    jal game_over
game_end:
    li $v0, 10 # Terminate the program gracefully
    syscall

# debug
    li $a0, 6          # Load the integer to print into $a0
    li $v0, 1          # Syscall code for printing an integer
    syscall
# debug

       
                   
   

.include "capsule.asm"
.include "display.asm"
.include "movement.asm"
