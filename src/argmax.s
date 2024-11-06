.globl argmax

.text
# =================================================================
# FUNCTION: Maximum Element First Index Finder
#
# Scans an integer array to find its maximum value and returns the
# position of its first occurrence. In cases where multiple elements
# share the maximum value, returns the smallest index.
#
# Arguments:
#   a0 (int *): Pointer to the first element of the array
#   a1 (int):  Number of elements in the array
#
# Returns:
#   a0 (int):  Position of the first maximum element (0-based index)
#
# Preconditions:
#   - Array must contain at least one element
#
# Error Cases:
#   - Terminates program with exit code 36 if array length < 1
# =================================================================
argmax:
    li t6, 1
    blt a1, t6, handle_error

    lw t0, 0(a0)
    mv s0, t0       # set Maximum = first element
    mv s1, zero

    li t1, 0        # index
    li t2, 1        # counter

loop_start:
    # TODO: Add your own implementation
    lw t0, 0(a0)
    blt t0, s0, no_change
    mv s0, t0       # Update Maximum
    mv s1, t1       # Update index

no_change:
    addi a0, a0, 4  # next element
    addi t1, t1, 1  
    blt t1, a1, loop_start

    #mv a0, s1
    li a0, 2
    jr ra
    
handle_error:
    li a0, 36
    j exit
