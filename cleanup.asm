


# ------------
# cleanup function for consecutive lines with the same color
scan_consecutives:
    # called after the settle function
    # specify row to be scanned
    # column to be scanned
    
    # scan the row of the y-value
    # scan the row of the y-value below (if vertical)
    # scan the column of the x-value
    # scan the column of the x-value to the right (if horizontal)

    # scan horizontally
    # scan vertically
    # keep track of color; increment counter if the same color is encountered 4 times
    # reset counter to 1 if another color is encountered; to 0 is black
    # when 4 in a row were reached, store the x and y coords of the first pixel
    # remove the pattern + keep track and update viruses if virus location was encountered
    # use the stored x and y as well and whether the capsule was horizontal or vertical
        #  to shift everything down
    # vertical 
        # get the value of the top pixel; store it in the pixel 4 below; paint the top pixel black
        # move one up
        # repeat the procedure until the next top pixel is black (or is grey)
    # horizontal
        # get the value of the top pixel; store it in the bottom pixel; paint the top pixel black
        # move one up
        # repeat the procedure until the next top pixel is black (or grey)
        # repeat the procedure 4 times for every column 
    
    # $a0 = x-value
    # $a1 = y-value
    # $a2 = rotation
    
    # start with (0, 0)
    # loop through the check and update the values accordingly
    # update the x-value until it goes up to 5; once bigger than 5, reset to 0; move $t0 132 pixels
    # loop through the y-value until it goes up to 16
    # once it did, end check
    # reset back to (0, 0) shifting down every time 
    
    # start with checking the first row
    j check_pixel
    
    
    
    
    li $t5, 0 # color tracker (0x0 = black; 0x0xff4746 = red, 0x0xffE94A = yellow, 0x0x0fd5ff = blue)
    li $t6, 0 # $t6 = column increment
    li $t7, 0 # counter
    
    li $t4, 4 # max value column check should reach to avoid checking the capsule wall
    blt $t4, $t6, next_check # checked everything in this row - can move on to the next check

    jal check_row
    
    add $t0, $t0, 132 # check the next row, below the capsule
    li $t5, 0 # color tracker
    li $t6, 0 # $t6 = column increment
    li $t7, 0 # counter
    
    jal check_row
    
    
    
    check_pixel:
    # sets the t0 pointer to point to ($a0, $a1)
    lw $t0, field # moves the pointer to the top left corner of the capsule field
    mul $t4, $a0, 4 # calculates the column offset (each cell is 4 bytes)
    mul $t5, $a1, 132 # calculates the row offset (33 (cells per row) * 4 (bytes per cell))
    add $t4, $t4, $t5 # Combine row and column offsets
    add $t0, $t0, $t4 # Computes the final address of the cell referenced by (x, y)
    
    lw $t4, 0($t0) # loads the pixel color into $t4
    beq $t4, $t5, increment_match # colors match
    beq $t4, $t1, red_match # color at pixel is red
    beq $t4, $t1, yellow_match # color at pixel is yellow
    beq $t4, $t1, blue_match # color at pixel is blue
    j blank_match # black pixel
    
    increment_match: addi $t6, $t6, 1 # increments the row by 1
                     addi $t7, $t7, 1 # increments the counter by 1
                     beq $t7, 4, shift_down
                     # reset values
                     li $t6, 0 # $t6 = column increment
                     j scan_consecutiveness # continue scanning for more possible input

    red_match:      lw $t5, red # update the color stored in $t5
                    j update_color_match
    yellow_match:   lw $t5, yellow # update the color stored in $t5
                    j update_color_match
    blue_match:     lw $t5, blue # update the color stored in $t5
    
    update_color_match:
                    addi $t6, $t6, 1 # increments the row by 1
                    li $t7, 1 # resets counter to 1
                    j check_pixel # check the next pixel
                    
    blank_match:    addi $t6, $t6, 1 # increments the row by 1
                    li $t7, 1 # resets counter to 0
                    j check_pixel # check the next pixel
    

    
    

shift_down:

   
draw_game_over_box:
    addi $t7, $ra, 0 
    # Reset Registers
    add $t0, $zero, 0
    add $t1, $zero, 0
    add $t2, $zero, 0
    add $t3, $zero, 0
    add $t4, $zero, 0
    add $t5, $zero, 0
    add $t6, $zero, 0
    
    ## Drawing Outer Box
    addi $a0, $zero, 3      # Set X coordinate for starting point
    addi $a1, $zero, 5      # Set Y coordinate for starting point
    
    li $t1, 0xc4b200        # color of the box
    add $t3, $zero, 25       # width in terms of unit
    add $t4, $zero, 20       # height in terms of unit
    jal draw_box
    
    # Reset Registers
    add $t0, $zero, 0
    add $t1, $zero, 0
    add $t2, $zero, 0
    add $t3, $zero, 0
    add $t4, $zero, 0
    add $t5, $zero, 0
    add $t6, $zero, 0
    
    ## Drawing Inner Box
    addi $a0, $zero, 4      # Set X coordinate for starting point
    addi $a1, $zero, 6      # Set Y coordinate for starting point
    
    li $t1, 0x0000ff        # color of the box
    add $t3, $zero, 23       # width in terms of unit
    add $t4, $zero, 18       # height in terms of unit
    jal draw_box
    
    addi $ra, $t7, 0
    jr $ra


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
