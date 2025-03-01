


# --------------
    # gravity
    # capsule moves down every 60 ms
    # if the pixel below the lowest point in the capsule is not black - stop moving down
    # leave the capsule there, update x and y to point to initial location, sleep before starting movement of new capsule or accepting input
    # if pixel below is black - move the whole capsule down (erase the prev x, y, coords, update x, y, coords, draw the capsule at new x and y coords)

gravity:
    lw $a0, X # loads the x-coordinate into a0
    lw $a1, Y # loads the y-coordinate into a1
    
    lw $t7, rotation # load the rotation value into $t7
    li $t5, 0        # store 0 in $t5
    li $t6, 1        # store 1 in $t6
    # need to check the value of the pixel below the capsule; coordinates depend on rotation
    beq $t7, $t5, update_horizontal  # if the capsule is positioned horizontally
    beq $t7, $t6, update_vertical    # if the capsule is positioned vertically

update_horizontal: addi $a1, $a1, 1 # increment row number by 1
                   j gravity_set_ptr
update_vertical:   addi $a1, $a1, 2 # increment row number by 2
    gravity_set_ptr:
    # set the t0 pointer to the (x, y) coordinate below the capsule
    lw $t0, field # moves the pointer to the top left corner of the capsule field
    mul $t4, $a0, 4 # calculates the column offset (each cell is 4 bytes)
    mul $t5, $a1, 132 # calculates the row offset (33 (cells per row) * 4 (bytes per cell))
    add $t4, $t4, $t5 # Combine row and column offsets
    add $t0, $t0, $t4 # Computes the final address of the cell referenced by (x, y)
    
    lw $t4, 0($t0) # load color value of cell below
        li $t5, 0        # store 0 in $t5
    bne $t4, $zero, settle # the pixel below is not empty, it is not safe to move down
    bne $t7, $t5, move_down # if the capsule is not horizontal, the check above was sufficient and it's safe to move down
    lw $t4, 4($t0) # load the color value of the next pixel below
    bne $t4, $zero, settle # the right pixel below is not empty, it is not safe to move down
    j move_down # the checks were passed, it is safe to move down
    
move_down: # free to move the capsule down
    jal erase_cap
    
    # updates the (x, y) coordinate
    lw $t4, Y        # stores the value of y-coordinate in $t4
    addi $t4, $t4, 1 # updates row value by 1
    sw, $t4, Y       # stores the new row value back in Y

    lw $t0, displayaddress   # resets $t0 to contain the base address of the display
    li $t8, 0 # reset the value to track the milliseconds 
    j game_loop

settle: # capsule colided with something below
    li $t6, 3 # load the coords indicating the entry to bottleneck
    li $t7, -1
    
    # Check if the capsule is blocking the bottleneck
    bne $a0, $t6, continue_settle  # If X != 3, skip the bottleneck check

    # If X == 3, check if Y is at the bottleneck top
    beq $a1, $t7, game_lost        # If Y == -1, game is lost
    
    continue_settle:
    jal new_cap
    li $a0, 60 # wait for a second before going to the new capsule
    
    jal sleep
    
    lw $t0, displayaddress   # resets $t0 to contain the base address of the display
    li $t8, 0 # reset the value to track the milliseconds 
    j game_loop



# -------------
# movement
# has the current state of the capsule
# responds to keyed inputs
# checks the surroundings based on keyed input
#   right (left)
#   check that the rightmost pixel is free to use (i.e. it is black)
#   if free to use, update x coordinate (+1) and draw capsule at new location
#   rotate 
#   (check gravity before rotation)
#   if horizontal = check that the pixel below the first pixel is free
#       if free, update rotation, draw the capsule
#   if vertical = check that the pixel to the right of the first pixel is free
#       if free, update rotation, draw the capsule
    
    
# collision detection
    # based on the capsule's orientation, check if there's anything 
    
# either way, draw the new capsule based on x and y

# handle_input = gets called when a key is pressed
handle_input:     
    lw $a0, 4($t7) # Load second word from keyboard
    
    # Movement scanner
    # Move left
    beq $a0, 0x61, move_left     # Check if the key A was pressed
    # move right
    beq $a0, 0x64, move_right    # Check if the key D was pressed
    # Drop
    beq $a0, 0x73, drop_down     # Check if the key S was pressed
    # rotate
    beq $a0, 0x77, rotate        # Check if the key W was pressed
    # Quit
    beq $a0, 0x71, quit          # Check if the key Q was pressed
    
    j game_loop    
    
move_left:
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

    addi $t0, $t0, -4 # references the leftmost value of the capsule
    lw $t5, 0($t0) # stores the color value of the leftmost pixel
    bne $zero, $t5, end_move_right # the rightmost pixel is not black, can't move right
    
    li $t7, 1 # stores 1 in $t7
    beq $a2, $t7, vertical_left # if the capsule is vertical, perform another check for the bottom left pixel
    j can_move_left # otherwise, the capsule can move left
    
    vertical_left:  lw $t5, 132($t0) # stores the color value of the bottom left pixel
                    beq $zero, $t5, can_move_left # the leftmost pixel is black, so can move left
                    j end_move_left # if the above check didn't pass, exit the function
    
    can_move_left:  jal erase_cap # erases old capsule
                    lw $t4, X # loads the value of the X-coordinate
                    addi $t4, $t4, -1 # updates the column value by -1
                    sw $t4, X # loads the updated value back into X
                    jal draw_cap # draws the capsule one pixel left
 
    end_move_left: lw $t0, displayaddress   # resets $t0 to contain the base address of the display
                   lw $ra, 0($sp)           # Restore $ra from the stack
                   addi $sp, $sp, 4         # Restore the stack pointer
                   jr $ra  
move_right:
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
    
    beq $a2, $t6, horizontal_right # jumps to update the rightmost value based for horizontal capsule
    beq $a2, $t7, vertical_right   # jumps to update the rightmost value based for vartical capsule 

    horizontal_right: lw $t5, 8($t0) # stores the color value of the rightmost pixel
                      beq $zero, $t5, can_move_right # the rightmost pixel is black, so can move right
                      j end_move_right # if the above check didn't pass, exit the function
                      
    vertical_right:   lw $t5, 4($t0) # stores the color value of the rightmost pixel
                      beq $zero, $t5, can_move_right_top # the rightmost top pixel is black, so can move right
                      can_move_right_top: # check the bottom pixel isn't unobstructed as well
                            lw $t5, 136($t0) # stores the color value of the rightmost pixel
                            beq $zero, $t5, can_move_right # the rightmost bottom pixel is black, so can move right
                      j end_move_right # if the above check didn't pass, exit the function
    
    can_move_right:  jal erase_cap # erases old capsule
                     lw $t4, X # loads the value of the X-coordinate
                     addi $t4, $t4, 1 # updates the column value by 1
                     sw $t4, X # loads the updated value back into X
                     jal draw_cap # draws the capsule one pixel right
 
    end_move_right: lw $t0, displayaddress   # resets $t0 to contain the base address of the display
                    lw $ra, 0($sp)           # Restore $ra from the stack
                    addi $sp, $sp, 4         # Restore the stack pointer
                    jr $ra  

drop_down:
    # save $ra
    addi $sp, $sp, -4        # Reserve space on the stack
    sw $ra, 0($sp)           # Save $ra on the stack

    lw $a0, X # loads the x-coordinate into a0
    lw $a1, Y # loads the y-coordinate into a1
    
    lw $t7, rotation # load the rotation value into $t7
    li $t5, 0        # store 0 in $t5
    li $t6, 1        # store 1 in $t6
    # need to check the value of the pixel below the capsule; coordinates depend on rotation
    beq $t7, $t5, update_drop_horizontal  # if the capsule is positioned horizontally
    beq $t7, $t6, update_drop_vertical    # if the capsule is positioned vertically

    update_drop_horizontal: addi $a1, $a1, 1 # increment row number by 1
                            j drop_set_ptr
    update_drop_vertical:   addi $a1, $a1, 2 # increment row number by 2
    drop_set_ptr:
    # set the t0 pointer to the (x, y) coordinate below the capsule
    lw $t0, field # moves the pointer to the top left corner of the capsule field
    mul $t4, $a0, 4 # calculates the column offset (each cell is 4 bytes)
    mul $t5, $a1, 132 # calculates the row offset (33 (cells per row) * 4 (bytes per cell))
    add $t4, $t4, $t5 # Combine row and column offsets
    add $t0, $t0, $t4 # Computes the final address of the cell referenced by (x, y)
    
    lw $t4, 0($t0) # load color value of cell below
        li $t5, 0  # store 0 in $t5
    bne $t4, $zero, end_move_down # the pixel below is not empty, it is not safe to move down
    bne $t7, $t5, can_move_down # if the capsule is not horizontal, the check above was sufficient and it's safe to move down
    lw $t4, 4($t0) # load the color value of the next pixel below
    bne $t4, $zero, end_move_down # the right pixel below is not empty, it is not safe to move down
     # the checks were passed, it is safe to move down
    
    can_move_down:  jal erase_cap
                    lw $t4, Y        # stores the value of y-coordinate in $t4
                    addi $t4, $t4, 1 # updates row value by 1
                    sw, $t4, Y       # stores the new row value back in Y
                    jal draw_cap     # draws the capsule below
    
    end_move_down: lw $t0, displayaddress   # resets $t0 to contain the base address of the display
                   lw $ra, 0($sp)           # Restore $ra from the stack
                   addi $sp, $sp, 4         # Restore the stack pointer
                   jr $ra  
            
rotate:
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
    
    beq $a2, $t6, horizontal_rotate # perfrom checks for horizontal capsule
    beq $a2, $t7, vertical_rotate   # perfrom checks for vertical capsule

    horizontal_rotate: lw $t5, 132($t0) # store the value of the pixel below
                       bne $zero, $t5, end_rotate # the bottom pixel isn't black, so can't rotate
                       
                       jal erase_cap
                       addi $a2, $a2, 1 # updates the rotation value to 1 (vertical) 
                       sw $a2, rotation # loads the updated value back into rotation variable
                       jal draw_cap
                       j end_rotate
                       
    vertical_rotate:   lw $t5, 4($t0) # store the value of the pixel to the right
                       bne $zero, $t5, end_rotate # the right pixel isn't black, so can't rotate
                       
                       jal erase_cap
                       addi $a2, $a2, -1 # updates the rotation value to 0 (horizontal) 
                       sw $a2, rotation # loads the updated value back into rotation variable
                       jal draw_cap
                       j end_rotate
                       
    end_rotate:     lw $t0, displayaddress   # resets $t0 to contain the base address of the display
                    lw $ra, 0($sp)           # Restore $ra from the stack
                    addi $sp, $sp, 4         # Restore the stack pointer
                    jr $ra  

quit: j game_end




