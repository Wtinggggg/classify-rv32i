# Assignment 2: Classify

## Part A: Mathematical Functions
### abs
The `abs` is used to return the **absolute value** of a number.
1. Retrieve the value that needs to be made absolute from memory. (assume the value store at `t0`)
2. Confirm `t0` is greater than or less than zero. `bge t0, zero, done` 
    * If greater than zero, skip step 2
3. Change t0 to positive. `neg t0, t0`
4. Get the absolute value, than store back it.

### Relu
Applies ReLU (Rectified Linear Unit) operation in-place:
For each element x in array: x = max(0, x)
1. Load element in array into `t2`
2. Check `t2` less than `0` or not, if no skip step 3.
3. Assign `t2` to `0`
4. Store `t2` back to array.

Code:
```
loop_start:
    lw t2, 0(a0)
    bge t2, zero, x
    mv, t2, zero
x:
    sw t2, 0(a0)
    addi a0, a0, 4
    addi a1, a1, -1
    bnez a1, loop_start

    jr ra
```

### ArgMax
The `argmax` is to **find the position of the first maximum element in an array**.
1. Temporarily set the max value to the first element of the array. (index = 0)
2. Iterate through the entire array, and if a value greater than the max value is encountered, update the max value and record its index.

code:
```
lw t0, 0(a0)                    # max.data = first element

    li t1, 0                    # max.index
    li t2, 1                    # current.index

loop_start:
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
```

## Dot product
**Strided Dot Product Calculator**
Calculates sum(arr0[i * stride0] * arr1[i * stride1]) 
Where i ranges from 0 to (element_count - 1)

1. Initialize Values:
    * `t6` is initialized to `0` to accumulate the final dot product result.
2. Loop through Array Elements:
    * The loop starts with a check: if `t5` is zero (indicating all elements have been processed), jump to loop_end.
    * Load the current element of the array into `t0` and `t1`.
3. Calculate Product and Accumulate:
     * Multiply `t0` and `t1` (using Booth's algorithm), storing the result in `t2`.
     * Add `t2` to `t6` to accumulate the dot product value.
4. Next Iteration:
    * Decrement `t5` by `1`, If `t5` is zero, jump to loop_end.
    * Calculate the address of the next element in the array by multiplying `a3` and `a4` (skip distance) by `4` (interger size) and adding it to `a0` and `a1`
    * Jump back to the start of the loop.

5. Output Result:
    * move the final dot product result from `t6` into `a0`
    * Return to the calling function

## Matrix Multiplication
In this function, we need to do Matrix Multiplication Implementation

In `matmul.s`, the functionality of each part of the code.
1. The outer loop iterates through each row of M~0~, while the inner loop iterates through each column of M~1~
2. In each iteration(in `inner_loop_start`
), the dot product of the row_i of M~0~ and the column_j of M~1~ is computed.
3. Store computed result in D[i][j].
4. When inner loop end(`inner_loop_end`), we need to calculate the address of the next row in matrix M~0~. 
```
inner_loop_end:
    slli t0, a2, 2    # a2 = M0's Column count
                      # shift letf 2 is because interger size = 4
    add s3, s3, t0    # point to matrix M0 next row 
    
    addi s0, s0, 1    # loop counter
    j outer_loop_start
```

## Part B: File Operations and Main
### Read Matrix 
In `read_matrix.s`, we need to implement `mul s1, t1, t2`, `t1` and `t2` represent the row and column, respectively.

Since rows and columns cannot be negative, Booth's algorithm is not used. Instead, general iterative addition is employed.

Code:
```
    mv s1, zero        # initialize result to 0
loop:
    beq t2, zero, done
    add s1, s1, t1     # add multiplicand to s1
    addi t2, t2, -1
    j loop
done:
```

### Write Matrix
For the same reason as Read Matrix.
```
    mul s4, s2, s3
```
```
    li s4, 0         # Initialize result to 0
loop:
    beq s2, zero, done
    add s4, s4, s3   # add multiplicand to s4
    addi s2, s2, -1  
    j loop
done:
```

### Classify
In the `classify.s`, I can only use the RV32i instruction set to implement the mul functionality.

In explaining my approach, I need to first introduce the [Booth's algorithm](https://zh.wikipedia.org/zh-tw/%E5%B8%83%E6%96%AF%E4%B9%98%E6%B3%95%E7%AE%97%E6%B3%95) for signed number multiplication in hardware.
![image](https://hackmd.io/_uploads/Bygvfyd1z1e.png)
1. Initialization:
    * Set up the multiplicand (M), the multiplier (Q), and an accumulator (A). The multiplier (Q) is appended with an extra bit (Q-1), initially set to 0.
    * Initialize the Accumulator (A) to 0 and determine the number of bits (n) in the multiplier.

2. Examine the bits:
    * For each bit of the multiplier, examine the least significant bit (LSB) of Q (Q0) and the extra bit (Q-1).

3. Perform the operation based on Q0 and Q-1:
    * If (Q0, Q-1) is (0, 0) or (1, 1), do nothing.
    * If (Q0, Q-1) is (0, 1), add the multiplicand (M) to the accumulator (A).
    * If (Q0, Q-1) is (1, 0), subtract the multiplicand (M) from the accumulator (A).

4. Arithmetic Shift Right:
    * Perform an arithmetic shift right on the combined A, Q, and Q-1. This means shifting all bits to the right, and the sign bit (the most significant bit of A) is replicated.

5. Repeat:
    * Repeat steps 2-4 for n times (where n is the number of bits in the multiplier. In RV32i, n = 32).

6. Final Result:
    * After n iterations, the combined value of the accumulator (A) and the multiplier (Q) contains the product of the original multiplicand and multiplier.

Code:
==notice:== According to step 4, the product should be shifted right, but since this is not a hardware design, it is changed to left-shifting the multiplicand.
```
mul a0, t0, t1
```
```
    li a0, 0            # Initialize the result to 0
    beqz t0, done
    beqz t1, done       # multiplicand or multiplier = 0, return 0

    li t5, 32           # 32bits counter
    li t4, 0            # mythical bit (bit_-1)
    
booth_start:
    andi t2, t1, 1      # extract bit_0
    xor t3, t2, t4      # LSB ^ mythical bit
    beqz t3, next_loop  # 00 and 11 do nothing
    
    beqz t4, sub        # 10 do subtract
add:                    # 01 do add
    add a0, a0, t0
    j next_loop
sub:
    sub a0, a0, t0
    
next_loop:
    slli t0, t0, 1
    andi t4, t1, 1      # extract bit_-1
    srli t1, t1, 1
    
    addi t5, t5, -1 
    bnez t5, booth_start
done:
    jr ra
```


## Result 
```
test_abs_minus_one (__main__.TestAbs.test_abs_minus_one) ... ok
test_abs_one (__main__.TestAbs.test_abs_one) ... ok
test_abs_zero (__main__.TestAbs.test_abs_zero) ... ok
test_argmax_invalid_n (__main__.TestArgmax.test_argmax_invalid_n) ... ok
test_argmax_length_1 (__main__.TestArgmax.test_argmax_length_1) ... ok
test_argmax_standard (__main__.TestArgmax.test_argmax_standard) ... ok
test_chain_1 (__main__.TestChain.test_chain_1) ... ok
test_classify_1_silent (__main__.TestClassify.test_classify_1_silent) ... ok
test_classify_2_print (__main__.TestClassify.test_classify_2_print) ... ok
test_classify_3_print (__main__.TestClassify.test_classify_3_print) ... ok
test_classify_fail_malloc
(__main__.TestClassify.test_classify_fail_malloc) ... ok
test_classify_not_enough_args
(__main__.TestClassify.test_classify_not_enough_args) ... ok
test_dot_length_1 (__main__.TestDot.test_dot_length_1) ... ok
test_dot_length_error (__main__.TestDot.test_dot_length_error) ... ok
test_dot_length_error2 (__main__.TestDot.test_dot_length_error2) ... ok
test_dot_standard (__main__.TestDot.test_dot_standard) ... ok
test_dot_stride (__main__.TestDot.test_dot_stride) ... ok
test_dot_stride_error1 (__main__.TestDot.test_dot_stride_error1) ... ok
test_dot_stride_error2 (__main__.TestDot.test_dot_stride_error2) ... ok
test_matmul_incorrect_check
(__main__.TestMatmul.test_matmul_incorrect_check) ... ok
test_matmul_length_1 (__main__.TestMatmul.test_matmul_length_1) ... ok
test_matmul_negative_dim_m0_x
(__main__.TestMatmul.test_matmul_negative_dim_m0_x) ... ok
test_matmul_negative_dim_m0_y
(__main__.TestMatmul.test_matmul_negative_dim_m0_y) ... ok
test_matmul_negative_dim_m1_x
(__main__.TestMatmul.test_matmul_negative_dim_m1_x) ... ok
test_matmul_negative_dim_m1_y
(__main__.TestMatmul.test_matmul_negative_dim_m1_y) ... ok
test_matmul_nonsquare_1 (__main__.TestMatmul.test_matmul_nonsquare_1) ... ok
test_matmul_nonsquare_2 (__main__.TestMatmul.test_matmul_nonsquare_2) ... ok
test_matmul_nonsquare_outer_dims
(__main__.TestMatmul.test_matmul_nonsquare_outer_dims) ... ok
test_matmul_square (__main__.TestMatmul.test_matmul_square) ... ok
test_matmul_unmatched_dims
(__main__.TestMatmul.test_matmul_unmatched_dims) ... ok
test_matmul_zero_dim_m0 (__main__.TestMatmul.test_matmul_zero_dim_m0) ... ok
test_matmul_zero_dim_m1 (__main__.TestMatmul.test_matmul_zero_dim_m1) ... ok
test_read_1 (__main__.TestReadMatrix.test_read_1) ... ok
test_read_2 (__main__.TestReadMatrix.test_read_2) ... ok
test_read_3 (__main__.TestReadMatrix.test_read_3) ... ok
test_read_fail_fclose (__main__.TestReadMatrix.test_read_fail_fclose) ... ok
test_read_fail_fopen (__main__.TestReadMatrix.test_read_fail_fopen) ... ok
test_read_fail_fread (__main__.TestReadMatrix.test_read_fail_fread) ... ok
test_read_fail_malloc (__main__.TestReadMatrix.test_read_fail_malloc) ... ok
test_relu_invalid_n (__main__.TestRelu.test_relu_invalid_n) ... ok
test_relu_length_1 (__main__.TestRelu.test_relu_length_1) ... ok
test_relu_standard (__main__.TestRelu.test_relu_standard) ... ok
test_write_1 (__main__.TestWriteMatrix.test_write_1) ... ok
test_write_fail_fclose (__main__.TestWriteMatrix.test_write_fail_fclose) ... ok
test_write_fail_fopen (__main__.TestWriteMatrix.test_write_fail_fopen) ... ok
test_write_fail_fwrite (__main__.TestWriteMatrix.test_write_fail_fwrite) ... ok

----------------------------------------------------------------------
Ran 46 tests in 86.432s

OK
```