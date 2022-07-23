.text
	lui t0,0x00002
	lw a2,0x0(t0)		#R[a2] = n
	jal ra,Fn		#调用子程序求斐波那契数
	jal x0,END		#程序结束
	
Fn:
	addi t0,x0,1
	addi t1,x0,2
	beq a2,t0,RETURN1
	beq a2,t1,RETURN1
	addi s1,x0,1		#R[s1] = F(n-2)
	addi s2,x0,1		#R[s2] = F(n-1)
	addi t2,x0,3		#R[t2] = i
LOOP:	blt a2,t2,RETURN2
	add s3,s1,s2		#FIB(n) = FIB(n-2) + FIB(n-1)
	add s1,x0,s2
	add s2,x0,s3
	addi t2,t2,1
	jal x0,LOOP
RETURN1:
	addi s3,x0,1
	jalr x0,0(ra)
RETURN2:
	jalr x0,0(ra)
	
END:
	
.data
	n:.word 20		#寄存器存储n的值