make_node: 
   addi sp,sp,-16                 # sp = sp - 16
   sw a0,0(sp)                    # stack[0] = val
   sd ra,8(sp)                    # stack[1] = ra
   li a0,24                       # bytes = 24
   call malloc                    # ptr = malloc(bytes)
   lw t0,0(sp)                    # val = stack[0]
   ld ra,8(sp)                    # ra = stack[1]
   addi sp,sp,16                  # sp = sp + 16
   sw t0,0(a0)                    # ptr->val = val
   sd x0,8(a0)                    # ptr->left = NULL
   sd x0,16(a0)                   # ptr->right = NULL 
   ret                            # return ptr

insert:
   addi sp,sp,-32                 # sp = sp - 32 
   sd ra,0(sp)                    # stack[0] = ra
   sd a0,8(sp)                    # stack[1] = node
   sw a1,16(sp)                   # stack[2] = val
   beq a0,x0,base                 # if (node == NULL) goto base
   lw t0,0(a0)                    # curr = node->val
   blt a1,t0,left                 # if (val < curr) goto left
   bgt a1,t0,right                # if (val > curr) goto right
   ld a0,8(sp)                    # node = stack[1]
   ld ra,0(sp)                    # ra = stack[0]
   addi sp,sp,32                  # sp = sp + 32
   ret                            # return node
right:
   ld a0,16(a0)                   # next = node->right
   call insert                    # res = insert(next, val)
   ld t1,8(sp)                    # node = stack[1]
   sd a0,16(t1)                   # node->right = res
   add a0,t1,x0                   # ret_val = node
   ld ra,0(sp)                    # ra = stack[0]
   addi sp,sp,32                  # sp = sp + 32
   ret                            # return ret_val
left:
   ld a0,8(a0)                    # next = node->left
   call insert                    # res = insert(next, val)
   ld t1,8(sp)                    # node = stack[1]
   sd a0,8(t1)                    # node->left = res
   add a0,t1,x0                   # ret_val = node
   ld ra,0(sp)                    # ra = stack[0]
   addi sp,sp,32                  # sp = sp + 32
   ret                            # return ret_val
base:
   add a0,a1,x0                   # arg0 = val
   call make_node                 # res = make_node(val)
   ld ra,0(sp)                    # ra = stack[0]
   addi sp,sp,32                  # sp = sp + 32
   ret                            # return res

get:
  addi sp,sp,-16                  # sp = sp - 16
  sd ra,0(sp)                     # stack[0] = ra
  sd a0,8(sp)                     # stack[1] = node
  beq a0,x0,base_1                # if (node == NULL) goto base_1
  lw t0,0(a0)                     # curr = node->val
  beq t0,a1,base_1                # if (curr == val) goto base_1
  blt a1,t0,left_get              # if (val < curr) goto left_get
  bgt a1,t0,right_get             # if (val > curr) goto right_get
  ld a0,8(sp)                     # node = stack[1]
  ld ra,0(sp)                     # ra = stack[0]
  addi sp,sp,16                   # sp = sp + 16
  ret                             # return node
left_get:
  ld a0,8(a0)                     # next = node->left
  call get                        # res = get(next, val)
  ld ra,0(sp)                     # ra = stack[0]
  addi sp,sp,16                   # sp = sp + 16
  ret                             # return res
right_get:
  ld a0,16(a0)                    # next = node->right
  call get                        # res = get(next, val)
  ld ra,0(sp)                     # ra = stack[0]
  addi sp,sp,16                   # sp = sp + 16
  ret                             # return res
base_1:
  ld ra,0(sp)                     # ra = stack[0]
  addi sp,sp,16                   # sp = sp + 16
  ret                             # return node

getAtMost:
  li t1,-1                        # best = -1
  loop:
    beq a1,x0,to_end              # if (node == NULL) goto to_end
    lw t0,0(a1)                   # curr = node->val
    beq a0,t0,equal               # if (val == curr) goto equal
    blt a0,t0,less                # if (val < curr) goto less
    bgt a0,t0,more                # if (val > curr) goto more
equal:
  add t1,t0,x0                    # best = curr
  j to_end                        # goto to_end
more:
   add t1,t0,x0                   # best = curr
   ld a1,16(a1)                   # node = node->right
   j loop                         # goto loop
less:
  ld a1,8(a1)                     # node = node->left
  j loop                          # goto loop 
to_end:
  add a0,t1,x0                    # ret_val = best
  ret                             # return ret_val
