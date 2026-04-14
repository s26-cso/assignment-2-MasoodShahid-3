.data
file: .string "input.txt"
read: .string "r"
yes:  .string "Yes\n"
no:   .string "No\n"

.text
.globl main
main:
    addi sp, sp, -80         # stack_pointer -= 80
    sd ra, 0(sp)             # save retaddr
    sd s1, 8(sp)             # save hashfd1
    sd s2, 16(sp)            # save hashbwd1
    sd s3, 24(sp)            # save pow1
    sd s4, 32(sp)            # save hashfd2
    sd s5, 40(sp)            # save hashbwd2
    sd s6, 48(sp)            # save pow2
    sd s7, 56(sp)            # save fileadr
    sd s8, 64(sp)            # save mask1
    sd s9, 72(sp)            # save mask2
    lui a0, %hi(file)
    addi a0, a0, %lo(file)   # arg0 = "input.txt"
    lui a1, %hi(read)
    addi a1, a1, %lo(read)   # arg1 = "r"
    call fopen               # fileadr=fopen("input.txt", "r")
    beq a0, x0, exit_program # if (fileadr==0) goto exit_program
    add s7, a0, x0           # fileadr=return_value
    addi s1, x0, 0           # hashfd1 = 0
    addi s2, x0, 0           # hashbwd1 = 0
    addi s3, x0, 1           # pow1 = 1
    addi s4, x0, 0           # hashfd2 = 0
    addi s5, x0, 0           # hashbwd2 = 0
    addi s6, x0, 1           # pow2 = 1
    addi s8, x0, 1           # mask1 = 1
    slli s8, s8, 31          # mask1 = 2147483648
    addi s8, s8, -1          # mask1 = 2147483647 (2^31 - 1)
    addi s9, x0, 1           # mask2 = 1
    slli s9, s9, 19          # mask2 = 524288
    addi s9, s9, -1          # mask2 = 524287 (2^19 - 1)

read_loop:
    add a0, s7, x0           # arg0 = fileadr
    call fgetc               # char = fgetc(fileadr)
    blt a0, x0, compare      # if (char < 0) goto compare
    addi t3, x0, 31          # base1 = 31
    addi t4, x0, 37          # base2 = 37
    mul s1, s1, t3           # hashfd1 = hashfd1 * base1
    add s1, s1, a0           # hashfd1 = hashfd1 + char
    srli t1, s1, 31          # temp1 = hashfd1 >> 31
    and t2, s1, s8           # temp2 = hashfd1 & mask1
    add s1, t1, t2           # hashfd1 = temp1 + temp2
    mul t6, a0, s3           # temp_val = char * pow1
    add s2, s2, t6           # hashbwd1 = hashbwd1 + temp_val
    srli t1, s2, 31          # temp1 = hashbwd1 >> 31
    and t2, s2, s8           # temp2 = hashbwd1 & mask1
    add s2, t1, t2           # hashbwd1 = temp1 + temp2
    mul s3, s3, t3           # pow1 = pow1 * base1
    srli t1, s3, 31          # temp1 = pow1 >> 31
    and t2, s3, s8           # temp2 = pow1 & mask1
    add s3, t1, t2           # pow1 = temp1 + temp2
    mul s4, s4, t4           # hashfd2 = hashfd2 * base2
    add s4, s4, a0           # hashfd2 = hashfd2 + char
    srli t1, s4, 19          # temp1 = hashfd2 >> 19
    and t2, s4, s9           # temp2 = hashfd2 & mask2
    add s4, t1, t2           # hashfd2 = temp1 + temp2
    mul t6, a0, s6           # temp_val = char * pow2
    add s5, s5, t6           # hashbwd2 = hashbwd2 + temp_val
    srli t1, s5, 19          # temp1 = hashbwd2 >> 19
    and t2, s5, s9           # temp2 = hashbwd2 & mask2
    add s5, t1, t2           # hashbwd2 = temp1 + temp2
    mul s6, s6, t4           # pow2 = pow2 * base2
    srli t1, s6, 19          # temp1 = pow2 >> 19
    and t2, s6, s9           # temp2 = pow2 & mask2
    add s6, t1, t2           # pow2 = temp1 + temp2
    jal x0, read_loop        # goto read_loop

compare:
    srli t1, s1, 31          # temp1 = hashfd1 >> 31
    and t2, s1, s8           # temp2 = hashfd1 & mask1
    add s1, t1, t2           # hashfd1 = temp1 + temp2
    srli t1, s2, 31          # temp1 = hashbwd1 >> 31
    and t2, s2, s8           # temp2 = hashbwd1 & mask1
    add s2, t1, t2           # hashbwd1 = temp1 + temp2
    bne s1, s2, failure      # if (hashfd1 != hashbwd1) goto failure
    srli t1, s4, 19          # temp1 = hashfd2 >> 19
    and t2, s4, s9           # temp2 = hashfd2 & mask2
    add s4, t1, t2           # hashfd2 = temp1 + temp2
    srli t1, s5, 19          # temp1 = hashbwd2 >> 19
    and t2, s5, s9           # temp2 = hashbwd2 & mask2
    add s5, t1, t2           # hashbwd2 = temp1 + temp2
    bne s4, s5, failure      # if (hashfd2 != hashbwd2) goto failure

success:
    lui a0, %hi(yes)
    addi a0, a0, %lo(yes)    # arg0 = "Yes\n"
    call printf              # print("Yes\n")
    jal x0, close_file       # goto close_file

failure:
    lui a0, %hi(no)
    addi a0, a0, %lo(no)     # arg0 = "No\n"
    call printf              # print("No\n")

close_file:
    add a0, s7, x0           # arg0 = fileadr
    call fclose              # fclose(fileadr)

exit_program:
    ld ra, 0(sp)             # restore retaddr
    ld s1, 8(sp)             # restore hashfd1
    ld s2, 16(sp)            # restore hashbwd1
    ld s3, 24(sp)            # restore pow1
    ld s4, 32(sp)            # restore hashfd2
    ld s5, 40(sp)            # restore hashbwd2
    ld s6, 48(sp)            # restore pow2
    ld s7, 56(sp)            # restore fileadr
    ld s8, 64(sp)            # restore mask1
    ld s9, 72(sp)            # restore mask2
    addi sp, sp, 80          # stack_pointer += 80
    addi a0, x0, 0           # return 0;
    jalr x0, 0(ra)           # exit
