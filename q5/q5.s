.data
file: .string "input.txt"
read: .string "r"
yes:  .string "Yes\n"
no:   .string "No\n"
.text
.globl main
main:
  addi sp, sp, -80       # stack_pointer -= 80
  sd ra, 0(sp)           # save retaddr
  sd s1, 8(sp)           # save Forward_A
  sd s2, 16(sp)          # save Reverse_A
  sd s3, 24(sp)          # save Power_A
  sd s4, 32(sp)          # save Forward_B
  sd s5, 40(sp)          # save Reverse_B
  sd s6, 48(sp)          # save Power_B
  sd s7, 56(sp)          # save fileadr
  sd s8, 64(sp)          # save Mask_A
  sd s9, 72(sp)          # save Mask_B
  lui a0, %hi(file)
  addi a0, a0, %lo(file) # arg0 = "input.txt"
  lui a1, %hi(read)
  addi a1, a1, %lo(read) # arg1 = "r"
  call fopen             # fileadr=fopen("input.txt", "r")
  beq a0, x0, exit_program # if (fileadr==0) goto exit_program
  add s7, a0, x0         # fileadr=return_value
  addi s1, x0, 0         # Forward_A = 0
  addi s2, x0, 0         # Reverse_A = 0
  addi s3, x0, 1         # Power_A = 1
  addi s4, x0, 0         # Forward_B = 0
  addi s5, x0, 0         # Reverse_B = 0
  addi s6, x0, 1         # Power_B = 1
  addi s8, x0, 1         # Mask_A = 1
  slli s8, s8, 31        # Mask_A = 2147483648
  addi s8, s8, -1        # Mask_A = 2147483647 (2^31 - 1)
  addi s9, x0, 1         # Mask_B = 1
  slli s9, s9, 19        # Mask_B = 524288
  addi s9, s9, -1        # Mask_B = 524287 (2^19 - 1)
read_loop:
  add a0, s7, x0         # arg0 = fileadr
  call fgetc             # char = fgetc(fileadr)
  blt a0, x0, compare    # if (char < 0) goto compare
  addi t2, x0, 10        # temp_char = '\n'
  beq a0, t2, read_loop  # if (char == '\n') goto read_loop
  addi t3, x0, 31        # Base_A = 31
  addi t4, x0, 37        # Base_B = 37
  mul s1, s1, t3         # Forward_A = Forward_A * Base_A
  add s1, s1, a0         # Forward_A = Forward_A + char
  srli t1, s1, 31        # temp1 = Forward_A >> 31
  and t2, s1, s8         # temp2 = Forward_A & Mask_A
  add s1, t1, t2         # Forward_A = temp1 + temp2
  mul t6, a0, s3         # temp_val = char * Power_A
  add s2, s2, t6         # Reverse_A = Reverse_A + temp_val
  srli t1, s2, 31        # temp1 = Reverse_A >> 31
  and t2, s2, s8         # temp2 = Reverse_A & Mask_A
  add s2, t1, t2         # Reverse_A = temp1 + temp2
  mul s3, s3, t3         # Power_A = Power_A * Base_A
  srli t1, s3, 31        # temp1 = Power_A >> 31
  and t2, s3, s8         # temp2 = Power_A & Mask_A
  add s3, t1, t2         # Power_A = temp1 + temp2
  mul s4, s4, t4         # Forward_B = Forward_B * Base_B
  add s4, s4, a0         # Forward_B = Forward_B + char
  srli t1, s4, 19        # temp1 = Forward_B >> 19
  and t2, s4, s9         # temp2 = Forward_B & Mask_B
  add s4, t1, t2         # Forward_B = temp1 + temp2
  mul t6, a0, s6         # temp_val = char * Power_B
  add s5, s5, t6         # Reverse_B = Reverse_B + temp_val
  srli t1, s5, 19        # temp1 = Reverse_B >> 19
  and t2, s5, s9         # temp2 = Reverse_B & Mask_B
  add s5, t1, t2         # Reverse_B = temp1 + temp2
  mul s6, s6, t4         # Power_B = Power_B * Base_B
  srli t1, s6, 19        # temp1 = Power_B >> 19
  and t2, s6, s9         # temp2 = Power_B & Mask_B
  add s6, t1, t2         # Power_B = temp1 + temp2
  jal x0, read_loop      # goto read_loop

compare:
  srli t1, s1, 31        # temp1 = Forward_A >> 31
  and t2, s1, s8         # temp2 = Forward_A & Mask_A
  add s1, t1, t2         # Forward_A = temp1 + temp2
  srli t1, s2, 31        # temp1 = Reverse_A >> 31
  and t2, s2, s8         # temp2 = Reverse_A & Mask_A
  add s2, t1, t2         # Reverse_A = temp1 + temp2
  bne s1, s2, failure    # if (Forward_A != Reverse_A) goto failure
  srli t1, s4, 19        # temp1 = Forward_B >> 19
  and t2, s4, s9         # temp2 = Forward_B & Mask_B
  add s4, t1, t2         # Forward_B = temp1 + temp2
  srli t1, s5, 19        # temp1 = Reverse_B >> 19
  and t2, s5, s9         # temp2 = Reverse_B & Mask_B
  add s5, t1, t2         # Reverse_B = temp1 + temp2
  bne s4, s5, failure    # if (Forward_B != Reverse_B) goto failure

success:
  lui a0, %hi(yes)
  addi a0, a0, %lo(yes)  # arg0 = "Yes\n"
  call printf            # print("Yes\n")
  jal x0, close_file     # goto close_file

failure:
  lui a0, %hi(no)
  addi a0, a0, %lo(no)   # arg0 = "No\n"
  call printf            # print("No\n")

close_file:
  add a0, s7, x0         # arg0 = fileadr
  call fclose            # fclose(fileadr)

exit_program:
  ld ra, 0(sp)           # restore retaddr
  ld s1, 8(sp)           # restore Forward_A
  ld s2, 16(sp)          # restore Reverse_A
  ld s3, 24(sp)          # restore Power_A
  ld s4, 32(sp)          # restore Forward_B
  ld s5, 40(sp)          # restore Reverse_B
  ld s6, 48(sp)          # restore Power_B
  ld s7, 56(sp)          # restore fileadr
  ld s8, 64(sp)          # restore Mask_A
  ld s9, 72(sp)          # restore Mask_B
  addi sp, sp, 80        # stack_pointer += 80
  addi a0, x0, 0         # return 0;
  jalr x0, 0(ra)         # exit