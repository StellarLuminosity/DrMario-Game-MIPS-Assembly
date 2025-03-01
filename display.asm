

# draw_init_display = draws the capsule display as well as fields for Hi, Lvl, and S 
draw_init_display:
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
    
    jr $ra 


game_over:
    lw $t4, dark_grey # $t4 = dark grey
    lw $t5, light_grey # $t5 = light grey
    lw $t0, displayaddress

    li $t6, 1           # start with pixel on row 1
    mul $t6, $t6, 132   # moving down to the 1st row (Each row is 132 bytes)
    addi $t6, $t6, 48 # calculating offset
    add $t6, $t6, $t0   # add the base address of the display to get the final location to draw
    sw $t5, 0( $t6 )   # draw pixel
    sw $t5, 4( $t6 )   # draw pixel
    sw $t5, 8( $t6 )   # draw pixel
    sw $t5, 12( $t6 )   # draw pixel
    addi $t6, $t6, 132   # moving down to the next row & next pixel
    sw $t5, 0( $t6 )     # draw pixel
    sw $t5, 24( $t6 )    # draw pixel
    sw $t5, 36( $t6 )    # draw pixel
    sw $t5, 60( $t6 )    # draw pixel
    sw $t5, 64( $t6 )    # draw pixel
    sw $t5, 68( $t6 )    # draw pixel
    addi $t6, $t6, 132   # moving down to the next row & next pixel
    sw $t5, 0( $t6 )     # draw pixel
    sw $t5, 8( $t6 )     # draw pixel
    sw $t5, 12( $t6 )    # draw pixel
    sw $t5, 20( $t6 )    # draw pixel
    sw $t5, 28( $t6 )    # draw pixel
    sw $t5, 36( $t6 )    # draw pixel
    sw $t5, 40( $t6 )    # draw pixel
    sw $t5, 44( $t6 )    # draw pixel
    sw $t5, 48( $t6 )    # draw pixel
    sw $t5, 52( $t6 )    # draw pixel
    sw $t5, 60( $t6 )    # draw pixel
    sw $t5, 64( $t6 )    # draw pixel
    sw $t5, 68( $t6 )    # draw pixel
    addi $t6, $t6, 132   # moving down to the next row & next pixel
    sw $t5, 0( $t6 )     # draw pixel
    sw $t5, 12( $t6 )    # draw pixel
    sw $t5, 20( $t6 )    # draw pixel
    sw $t5, 24( $t6 )    # draw pixel
    sw $t5, 28( $t6 )    # draw pixel
    sw $t5, 36( $t6 )    # draw pixel
    sw $t5, 44( $t6 )    # draw pixel
    sw $t5, 52( $t6 )    # draw pixel
    sw $t5, 60( $t6 )    # draw pixel
    addi $t6, $t6, 132   # moving down to the next row & next pixel
    sw $t5, 0( $t6 )    # draw pixel
    sw $t5, 4( $t6 )    # draw pixel
    sw $t5, 8( $t6 )    # draw pixel
    sw $t5, 12( $t6 )   # draw pixel
    sw $t5, 20( $t6 )   # draw pixel
    sw $t5, 28( $t6 )   # draw pixel
    sw $t5, 36( $t6 )   # draw pixel
    sw $t5, 44( $t6 )   # draw pixel
    sw $t5, 52( $t6 )   # draw pixel
    sw $t5, 60( $t6 )    # draw pixel
    sw $t5, 64( $t6 )    # draw pixel
    sw $t5, 68( $t6 )    # draw pixel
    addi $t6, $t6, 132   # moving down to the next row & next pixel
    addi $t6, $t6, 132   # moving down to the next row & next pixel
    sw $t5, 0( $t6 )    # draw pixel
    sw $t5, 4( $t6 )    # draw pixel
    sw $t5, 8( $t6 )    # draw pixel
    addi $t6, $t6, 132   # moving down to the next row & next pixel
    sw $t5, 0( $t6 )     # draw pixel
    sw $t5, 8( $t6 )     # draw pixel
    sw $t5, 16( $t6 )    # draw pixel
    sw $t5, 24( $t6 )    # draw pixel
    sw $t5, 32( $t6 )    # draw pixel
    sw $t5, 36( $t6 )    # draw pixel
    sw $t5, 40( $t6 )    # draw pixel
    sw $t5, 48( $t6 )    # draw pixel
    sw $t5, 52( $t6 )    # draw pixel
    sw $t5, 56( $t6 )    # draw pixel
    addi $t6, $t6, 132   # moving down to the next row & next pixel
    sw $t5, 0( $t6 )     # draw pixel
    sw $t5, 8( $t6 )     # draw pixel
    sw $t5, 16( $t6 )    # draw pixel
    sw $t5, 24( $t6 )    # draw pixel
    sw $t5, 32( $t6 )    # draw pixel
    sw $t5, 36( $t6 )    # draw pixel
    sw $t5, 40( $t6 )    # draw pixel
    sw $t5, 48( $t6 )    # draw pixel
    addi $t6, $t6, 132   # moving down to the next row & next pixel
    sw $t5, 0( $t6 )     # draw pixel
    sw $t5, 8( $t6 )     # draw pixel
    sw $t5, 16( $t6 )    # draw pixel
    sw $t5, 24( $t6 )    # draw pixel
    sw $t5, 32( $t6 )    # draw pixel
    sw $t5, 48( $t6 )    # draw pixel
    addi $t6, $t6, 132   # moving down to the next row & next pixel
    sw $t5, 0( $t6 )     # draw pixel
    sw $t5, 4( $t6 )     # draw pixel
    sw $t5, 8( $t6 )     # draw pixel
    sw $t5, 20( $t6 )    # draw pixel
    sw $t5, 32( $t6 )    # draw pixel
    sw $t5, 36( $t6 )    # draw pixel
    sw $t5, 40( $t6 )    # draw pixel
    sw $t5, 48( $t6 )    # draw pixel
    
    jr $ra


