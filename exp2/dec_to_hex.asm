.text
main:
	lui t0,0x00002
	lw a2,0x0(t0)
	jal ra,CONV		#�����ӳ�����н���ת��
	jal x0,END		#�������
	
CONV:
	addi a0,x0,16
	addi a1,x0,0		#i=0
	LOOP:	beq a2,x0,RETURN
		rem t0,a2,a0	#ԭ����16ȡ��
		srai a2,a2,4	#ԭ������16
		slli a3,a1,2	#i=i*4
		sll t0,t0,a3
		addi a1,a1,1
		add s3,s3,t0
		jal x0,LOOP
RETURN:
	jalr x0,0(ra)		#�ӳ������
END:
	
.data
	number:.word 200111205	
