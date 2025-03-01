
# ----- CAPSULE ----- #

# generate_colors = populates the color_array with two random color values
generate_colors:
    la $t9, color_array # load address of the first element of the color array
    
    # generate first color
    li $v0, 42 # random num generator ID
    li $a0, 0  # min number 0
    li $a1, 3  # max number 2
    syscall    # generates the first random number between 0 & 2 and stores it in $a0
    
    beq $a0, 0, load_red_1    # if the generated num is 0, first color is red
    beq $a0, 1, load_yellow_1 # if the generated num is 1, first color is yellow
    beq $a0, 2, load_blue_1   # if the generated num is 2, first color is blue
    
    load_red_1:    sw $t1, 0($t9)         # Store the red color in the first element
                   j generate_second_color   # Jump to generating the second color
    load_yellow_1: sw $t2, 0($t9)         # Store the yellow color in the first element
                   j generate_second_color   # Jump to generating the second color
    load_blue_1:   sw $t3, 0($t9)         # Store the blue color in the first element
                   j generate_second_color   # Jump to generating the second color
        
    # generate second color
    generate_second_color:
    li $v0, 42 # random num genervator ID
    li $a0, 0  # min number 0
    li $a1, 3  # max number 2
    syscall    # generates the second random number between 0 & 2 and stores it in $a0
    
    beq $a0, 0, load_red_2    # if the generated num is 0, first color is red
    beq $a0, 1, load_yellow_2 # if the generated num is 1, first color is yellow
    beq $a0, 2, load_blue_2   # if the generated num is 2, first color is blue
    
    load_red_2:    sw $t1, 4($t9)         # Store the red color in the first element
                   j end_generate_colors   # Jump to generating the second color
    load_yellow_2: sw $t2, 4($t9)         # Store the yellow color in the first element
                   j end_generate_colors   # Jump to generating the second color
    load_blue_2:   sw $t3, 4($t9)         # Store the blue color in the first element
                   j end_generate_colors   # Jump to generating the second color    
    end_generate_colors: jr $ra           # Return to the caller
    
    

# new_cap = sets up value for a new capsule to be drawn
new_cap:
    # save $ra
    addi $sp, $sp, -4        # Reserve space on the stack
    sw $ra, 0($sp)           # Save $ra on the stack
    
    jal generate_colors # generates new colors for the color_array
    # loads the coordinates for initial capsule generation
    lw $t4, top_X
    lw $t5, top_Y
    # updates x and y to point to initial capsule generation location
    sw, $t4, X  
    sw $t5, Y   
    
    # updates the rotation
    li $t4, 0
    sw $t4, rotation
    
    lw $ra, 0($sp)           # Restore $ra from the stack
    addi $sp, $sp, 4         # Restore the stack pointer
    jr $ra   

    
# draw_cap = draws the capsule at the specified (x, y) coordinate
draw_cap:
    # save $ra
    addi $sp, $sp, -4        # Reserve space on the stack
    sw $ra, 0($sp)           # Save $ra on the stack
    
    # load X and Y coordinates
    lw $a0, X # $a0 = x (column #) (integer)
    lw $a1, Y # $a1 = y (row #) (integer)
    lw $a2, rotation # $a2 = rotation (0 or 1)
    
    # sets the t0 pointer to the (x, y) coordinate
    lw $t0, field # moves the pointer to the top left corner of the capsule field
    mul $t4, $a0, 4 # calculates the column offset (each cell is 4 bytes)
    mul $t5, $a1, 132 # calculates the row offset (33 (cells per row) * 4 (bytes per cell))
    add $t4, $t4, $t5 # Combine row and column offsets
    add $t0, $t0, $t4 # Computes the final address of the cell referenced by (x, y)
    
    la $t9, color_array # loads the address of color_array to point to the first element
    lw $t4, 0($t9)      # first color
    lw $t5, 4($t9)      # second color
    
    li $t6, 0 # stores 0 in $t6
    li $t7, 1 # stores 1 in $t7
    
    sw $t4, 0($t0) # draws the first pixel
    
    beq $t6, $a2, horizontal_draw # jumps to draw the capsule horizontally 
    beq $t7, $a2, vertical_draw   # jumps to draw the capsule vertically
    
    horizontal_draw: sw $t5, 4($t0) # draws the second pixel to the right
                     j end_draw_cap # skips drawing the pixel vertically
    vertical_draw:   sw $t5, 132($t0) # draws the second pixel below
    end_draw_cap:    lw $t0, displayaddress   # resets $t0 to contain the base address of the display
    
    lw $ra, 0($sp)           # Restore $ra from the stack
    addi $sp, $sp, 4         # Restore the stack pointer
    jr $ra   



# erase
# erases the existing capsule based on (x, y) coordinates and rotation
erase_cap:
    # save $ra
    addi $sp, $sp, -4        # Reserve space on the stack
    sw $ra, 0($sp)           # Save $ra on the stack
    
    # load X and Y coordinates
    lw $a0, X # $a0 = x (column #) (integer)
    lw $a1, Y # $a1 = y (row #) (integer)
    lw $a2, rotation # $a2 = rotation (0 or 1)
    
    # sets the t0 pointer to the (x, y) coordinate
    lw $t0, field # moves the pointer to the top left corner of the capsule field
    mul $t4, $a0, 4 # calculates the column offset (each cell is 4 bytes)
    mul $t5, $a1, 132 # calculates the row offset (33 (cells per row) * 4 (bytes per cell))
    add $t4, $t4, $t5 # Combine row and column offsets
    add $t0, $t0, $t4 # Computes the final address of the cell referenced by (x, y)
    
    li $t6, 0 # stores 0 in $t6
    li $t7, 1 # stores 1 in $t7
    
    sw $zero, 0($t0) # erases the first pixel (paints it black)
    
    beq $t6, $a2, horizontal_erase # jumps to erase the capsule horizontally 
    beq $t7, $a2, vertical_erase   # jumps to erase the capsule vertically
    
    horizontal_erase: sw $zero, 4($t0) # erases the second pixel to the right
                      j end_erase_cap # skips drawing the pixel vertically
    vertical_erase:   sw $zero, 132($t0) # draws the second pixel below
    end_erase_cap:    lw $t0, displayaddress   # resets $t0 to contain the base address of the display
    
    lw $ra, 0($sp)           # Restore $ra from the stack
    addi $sp, $sp, 4         # Restore the stack pointer
    jr $ra 


# ----- VIRUS ----- #

# generate_virus = generates a random virus in the capsule
generate_virus:
    # initializes the counters
    li $t7, 0  # t7 = loop counter
    li $t6, 4  # sets the number of viruses to 4
    
    plant_virus:
    # responsible for drawing the viruses
    
    # generate random x-value
    li $v0, 42 # random num generator ID
    li $a0, 0  # min number 0
    li $a1, 8  # max number 7
    syscall    # generates the first random number between 0 & 7 and stores it in $a0
    move $t4, $a0 # stores the coordinate in $t4
    
    # generate random y-value
    li $v0, 42 # random num generator ID
    li $a0, 0  # min number 2 (so that it isn't too high)
    li $a1, 14  # max number 13
    syscall    # generates the first random number between 2 & 15 and stores it in $a0
    addi $a0, $a0, 2 # increments y-value by 2 to avoid drawing viruses too close to the top
    move $t5, $a0 # stores the coordinate in $t5
    
    move $a0, $t4  # stores the generated x-int in $a0 for code portability
    move $a1, $t5  # stores the generated y-int in $a1 for code portability

    # set the t0 pointer to the (x, y) coordinate
    lw $t0, field # moves the pointer to the top left corner of the capsule field
    mul $t4, $a0, 4 # calculates the column offset (each cell is 4 bytes)
    mul $t5, $a1, 132 # calculates the row offset (33 (cells per row) * 4 (bytes per cell))
    add $t4, $t4, $t5 # Combine row and column offsets
    add $t0, $t0, $t4 # Computes the final address of the cell referenced by (x, y)
    
    lw $t5, 0($t0) # t5 = color of the new address
    bne $t5, $zero, plant_virus # checks if the value of the pixel is non-zero, which means a virus already exists there; jumps to try again
    
    # generate a random color
    li $v0, 42 # random num generator ID
    li $a0, 0  # min number 0
    li $a1, 3  # max number 2
    syscall    # generates the first random number between 0 & 2 and stores it in $a0
    beq $a0, 0, virus_red
    beq $a0, 1, virus_yellow
    beq $a0, 2, virus_blue     # jump to draw based on color
    
    virus_red:    sw $t1, 0($t0) # draw a yellow virus in the pixel
                  addi $t7, $t7, 1 # increments loop by 1
                  bne $t7, $t6, plant_virus
                  j end_virus
    virus_yellow: sw $t2, 0($t0) # draw a yellow virus in the pixel
                  addi $t7, $t7, 1 # increments loop by 1
                  bne $t7, $t6, plant_virus
                  j end_virus
    virus_blue:   sw $t3, 0($t0) # draw a yellow virus in the pixel
                  addi $t7, $t7, 1 # increments loop by 1
                  bne $t7, $t6, plant_virus
                  j end_virus
    
    # NEED TO STORE VIRUS LOCATION!
    
    end_virus:
        lw $t0, displayaddress   # resets $t0 to contain the base address of the display
        jr $ra
    
    
