.data
format_str: .string "%d "
newline:    .string "\n"

.text
.globl main
main:
  addi sp,sp,-64         # stack_pointer -= 64
  sd ra,0(sp)            # Save return_address
  sd s0,8(sp)            # Save n
  sd s1,16(sp)           # Save arr
  sd s2,24(sp)           # Save result
  sd s3,32(sp)           # Save stack
  sd s4,40(sp)           # Save argv
  sd s5,48(sp)           # Save i
  sd s6,56(sp)           # Save stack_ptr

  add s4,a1,x0           # argv_base = argv
  addi a0,a0,-1          # temp_n = argc - 1
  add s0,a0,x0           # n = temp_n
  blez s0,to_end         # if (n <= 0) goto to_end

  addi t0,x0,12          # bytes_per_element = 12
  mul a0,s0,t0           # total_bytes = n * 12
  call malloc            # memory_base = malloc(total_bytes)

  add s1,a0,x0           # arr = memory_base
  addi t0,x0,4           # int_size = 4
  mul t1,s0,t0           # offset = n * 4
  add s2,s1,t1           # result = arr + offset
  add s3,s2,t1           # stack = result + offset

  li s5,0                # i = 0
convert_loop:
  bge s5,s0,done_convert # if (i >= n) break loop
  
  addi t0,s5,1           # arg_index = i + 1
  slli t0,t0,3           # byte_offset = arg_index * 8
  add t0,s4,t0           # string_ptr_address = argv_base + byte_offset
  ld a0,0(t0)            # string_ptr = memory[string_ptr_address]
  
  call atoi              # parsed_int = atoi(string_ptr)
  
  slli t1,s5,2           # byte_offset = i * 4
  add t1,s1,t1           # target_address = arr + byte_offset
  sw a0,0(t1)            # arr[i] = parsed_int
  
  addi s5,s5,1           # i++
  j convert_loop         # continue loop
done_convert:

  li s6,0                # stack_ptr = 0
  addi s5,s0,-1          # i = n - 1
loop:
  bltz s5,done_loop      # if (i < 0) break loop
  
  slli t1,s5,2           # byte_offset = i * 4
  add t2,s1,t1           # arr_address = arr + byte_offset
  lw t3,0(t2)            # current_val = arr[i]

while:
  blez s6,while_done     # if (stack_ptr <= 0) break while loop
  
  addi t4,s6,-1          # top_index = stack_ptr - 1
  slli t4,t4,2           # top_byte_offset = top_index * 4
  add t4,s3,t4           # stack_address = stack + top_byte_offset
  lw t5,0(t4)            # stack_top_val = stack[top_index]
  
  slli t6,t5,2           # array_byte_offset = stack_top_val * 4
  add t6,s1,t6           # array_address = arr + array_byte_offset
  lw t6,0(t6)            # top_array_val = arr[stack_top_val]
  
  bgt t6,t3,while_done   # if (top_array_val > current_val) break while loop
  
  addi s6,s6,-1          # stack_ptr--
  j while                # continue while loop
while_done:   
  slli t1,s5,2           # byte_offset = i * 4
  add t2,s2,t1           # result_address = result + byte_offset
  beq s6,x0,not_pos      # if (stack_ptr == 0) goto not_pos
  
  addi t4,s6,-1          # top_index = stack_ptr - 1
  slli t4,t4,2           # top_byte_offset = top_index * 4
  add t4,s3,t4           # stack_address = stack + top_byte_offset
  lw t5,0(t4)            # stack_top_val = stack[top_index]
  sw t5,0(t2)            # result[i] = stack_top_val
  j push                 # goto push
  
not_pos:
  li t4,-1               # val = -1
  sw t4,0(t2)            # result[i] = val
  
push:
  slli t4,s6,2           # byte_offset = stack_ptr * 4
  add t4,s3,t4           # target_stack_address = stack + byte_offset
  sw s5,0(t4)            # stack[stack_ptr] = i
  addi s6,s6,1           # stack_ptr++
  
  addi s5,s5,-1          # i--
  j loop                 # continue main loop
done_loop:

  li s5,0                # i = 0
print_loop:
  bge s5,s0,print_done   # if (i >= n) break loop
  
  slli t0,s5,2           # byte_offset = i * 4
  add t0,s2,t0           # result_address = result + byte_offset
  lw a1,0(t0)            # print_val = result[i]
  
  la a0,format_str       # load "%d "
  call printf            # print(print_val)
  
  addi s5,s5,1           # i++
  j print_loop           # continue loop
print_done:

  la a0,newline          # load "\n"
  call printf            # print(newline)

to_end:
  ld ra,0(sp)            # Restore return_address
  ld s0,8(sp)            # Restore n
  ld s1,16(sp)           # Restore arr
  ld s2,24(sp)           # Restore result
  ld s3,32(sp)           # Restore stack
  ld s4,40(sp)           # Restore argv
  ld s5,48(sp)           # Restore i
  ld s6,56(sp)           # Restore stack_ptr
  addi sp,sp,64          # stack_pointer += 64
  
  li a0,0                # return 0
  ret                    # exit