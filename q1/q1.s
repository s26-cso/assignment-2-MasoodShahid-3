make_node: 
   addi sp,sp,-16                 
   sw a0,0(sp)
   sd ra,8(sp)
   li a0,24               #first 4 lines are prep for calling malloc(saving ra,a0 and storing 24(node size)in a0)
   call malloc            #after this a0 is pointer to out struct
   lw t0,0(sp)            
   ld ra,8(sp)
   addi sp,sp,16          #restoring from stack ,now t0 has val
   sw t0,0(a0)            #val of node is set
   sd x0,8(a0)
   sd x0,16(a0)           #storing left and right as null 
   ret

insert:
   addi sp,sp,-32          
   sd ra,0(sp)
   sd a0,8(sp)
   sw a1,16(sp)
   beq a0,x0,base
   lw t0,0(a0)
   blt a1,t0,left
   bgt a1,t0,right
   ld a0,8(sp)
   ld ra,0(sp)
   addi sp,sp,32
   ret
right:
   ld a0,16(a0)
   call insert
   ld t1,8(sp)
   sd a0,16(t1)
   add a0,t1,x0
   ld ra,0(sp)
   addi sp,sp,32
   ret
left:
   ld a0,8(a0)
   call insert
   ld t1,8(sp)
   sd a0,8(t1)
   add a0,t1,x0
   ld ra,0(sp)
   addi sp,sp,32
   ret
base:
   add a0,a1,x0
   call make_node
   ld ra,0(sp)
   addi sp,sp,32
   ret

get:
  addi sp,sp,-16
  sd ra,0(sp)
  sd a0,8(sp)
  beq a0,x0,base_1
  lw t0,0(a0)
  beq t0,a1,base_1
  blt a1,t0,left_get
  bgt a1,t0,right_get
  ld a0,8(sp)
  ld ra,0(sp)
  addi sp,sp,16
  ret
left_get:
  ld a0,8(a0)
  call get
  ld ra,0(sp)
  addi sp,sp,16
  ret
right_get:
  ld a0,16(a0)
  call get
  ld ra,0(sp)
  addi sp,sp,16
  ret
base_1:
  ld ra,0(sp)
  addi sp,sp,16
  ret

getAtMost:
  li t1,-1
  loop:
    beq a1,x0,to_end
    lw t0,0(a1)
    beq a0,t0,equal
    blt a0,t0,less
    bgt a0,t0,more
equal:
  add t1,t0,x0
  j to_end
more:
   add t1,t0,x0
   ld a1,16(a1)
   j loop
less:
  ld a1,8(a1)
  j loop 
to_end:
  add a0,t1,x0
  ret
  
