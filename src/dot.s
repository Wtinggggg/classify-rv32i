.globl dot

.text
# =======================================================
# FUNCTION: Strided Dot Product Calculator
#
# Calculates sum(arr0[i * stride0] * arr1[i * stride1])
# where i ranges from 0 to (element_count - 1)
#
# Args:
#   a0 (int *): Pointer to first input array
#   a1 (int *): Pointer to second input array
#   a2 (int):   Number of elements to process
#   a3 (int):   Skip distance in first array
#   a4 (int):   Skip distance in second array
#
# Returns:
#   a0 (int):   Resulting dot product value
#
# Preconditions:
#   - Element count must be positive (>= 1)
#   - Both strides must be positive (>= 1)
#
# Error Handling:
#   - Exits with code 36 if element count < 1
#   - Exits with code 37 if any stride < 1
# =======================================================
dot:
    li t0, 1
    blt a2, t0, error_terminate  
    blt a3, t0, error_terminate   
    blt a4, t0, error_terminate  

    li t0, 0               
    li t6, 0    # dot product value
    mv t5, a2 

loop_start:
    beqz t5, loop_end
    # TODO: Add your own implementation
    lw t0, 0(a0)
    lw t1, 0(a1)
    # mul t2, t0, t1          
    # TODO=================================================
    # mul a0, t0, t1 # FIXME: Replace 'mul' with your own implementation
    # ===============================================
    addi sp, sp, -16
    sw t3, 0(sp)
    sw t4, 4(sp)
    sw t5, 8(sp)
    sw a0, 12(sp)

    li a0, 0            # Initialize the result to 0
    beqz t0, done1
    beqz t1, done1      # multiplicand or multiplier = 0, return 0

    li t5, 32           # 32bits counter
    li t4, 0            # mythical bit (bit_-1)
    
booth_start1:
    andi t2, t1, 1      # extract bit_0
    xor t3, t2, t4      # LSB^mythical bit
    beqz t3, next_loop1 # 00 and 11 do nothing
    
    beqz t4, sub1       # 10 do subtract
add1:                   # 01 do add
    add a0, a0, t0
    j next_loop1
sub1:
    sub a0, a0, t0
    
next_loop1:
    slli t0, t0, 1
    andi t4, t1, 1      # extract bit_-1
    srli t1, t1, 1
    
    addi t5, t5, -1 
    bnez t5, booth_start1
done1:
    mv t2, a0
    lw t3, 0(sp)
    lw t4, 4(sp)
    lw t5, 8(sp)
    lw a0, 12(sp)
    addi sp, sp, 16
    # ===============================================
    add t6, t6, t2      # add products

    addi t5, t5, -1
    beqz t5, loop_end
    slli t3, a3, 2      # 
    add a0, a0, t3      # load next element's address
    slli t3, a4, 2      # 
    add a1, a1, t3      # load next element's address
    j loop_start

loop_end:
    mv a0, t6
    jr ra

error_terminate:
    blt a2, t0, set_error_36
    li a0, 37
    j exit

set_error_36:
    li a0, 36
    j exit
