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

    lw t0, 0(a0)                # max.data = first element

    li t1, 0                    # maxi.index
    li t2, 1                    # current.index

loop_start:
    # TODO: Add your own implementation
    beq t2, a1, done
    addi a0, a0, 4              # current.address
    lw t3, 0(a0)                # current.data

    ble t3, t0, no_change       
    mv t0, t3                   # update max
    mv t1, t2                   # update max.index

no_change:
    addi t2, t2, 1
    j loop_start

done:
    mv a0, t1
    jr ra
    
handle_error:
    li a0, 36
    j exit
