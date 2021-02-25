##########################################################################
# Created by:  Chen, Edison
#              edpchen
#              25 February 2021
#
# Assignment:  Lab 4: Syntax Checker
#              CSE 012, Computer Systems and Assembly Language
#              UC Santa Cruz, Winter 2021
#
# Description: The program will print variable-sized ASCII diamonds 
#              and a sequence of embedded numbers based on user input.
#
# Notes:       This program is intended to be run from the MARS IDE.
##########################################################################
#Psuedocode
#main:
#create copy of program argument
#get first byte and check that it is a letter
#check that file name is less than 20 chars
#loop through buffer
#increment index
#add to stack if opening brace
#increment stackSize
#remove from stack if correspondint exit brace
#decrement stackSize
#increment pairs
#if incorrect exit brace throw mismatch error
#if no more char in buffer and still chars in brace throw checkStackerror
#if no more chars in buffer and no chars in stack print success
.data
buffer: .space 128
stackSize: .word 0
pairs: .word 0
index: .word 0
brace1: .word 40
brace2: .word 91
brace3: .word 123
successMsg: .asciiz "SUCCESS: There are "
successMsg2: .asciiz " pairs of braces."
userInputMsg: .asciiz "You entered the file:\n"
fileErrorMsg: .asciiz "ERROR: Invalid program argument."
checkStackErrorMsg: .asciiz "ERROR - Brace(s) still on stack: "
mismatchErrorMsg: .asciiz "ERROR - There is a brace mismatch: "
mismatchErrorMsg2: .asciiz " at index "
.text

mainLoop:	
	lw $s0($a1)	#print file name
	li $v0 4
	la $a0 userInputMsg
	syscall
	move $a0 $s0 #create copy of argument address in $a0
	move $a3 $s0 #create copy of argument address in $a3
	syscall
	lb $t0 0($a0)
	jal checkCharError
	jal fileNameLen
	li $v0 11
	li $a0 10
	syscall
	jal openFile
	jal readFile
	j Stack
checkCharError:
	sgt $t1 $t0 64
	slti $t2 $t0 91
	and $t3 $t1 $t2
	sgt $t1 $t0 96
	slti $t2 $t0 123
	and $t4 $t1 $t2
	or $t1 $t3 $t4
	bnez $t1 jumpBack
	j error
fileNameLen:
	li $t0 0
loop:
	lb $t1 0($s0)
	beqz $t1 jumpBack #jumpback if nullterminated
	add $s0 $s0 1
	add $t0 $t0 1
	bge $t0 21 error
	j loop
error:
	li $v0 11
	li $a0 10
	syscall
	syscall
	li $v0 4              #prep for print string syscall
	la $a0 fileErrorMsg   #print fileCharErrorMsg:        
	syscall
	j exit
jumpBack:
	jr $ra
openFile:
	li $v0 13 #open file
	la $a0 ($a3)
	li $a1 0
	li $a2 0
	syscall
	move $s0 $v0
	jr $ra
readFile:
	li $v0 14
	move $a0 $s0
	la $a1 buffer
	li $a2 128#buffer length
	syscall
	li $v0 11 # print newLine
	li $a0 10
	syscall
	jr $ra
Stack:
	li $t1 0
stackLoop:
	lb $t0 buffer($t1)#load the first byte of buffer into $t0
	move $t7 $t0
	add $t1 $t1 1 #increment $t1 by 1
	beq $t0 40 push
	beq $t0 91 push
	beq $t0 123 push
	beq $t0 41 popB1
	beq $t0 93 popB2
	beq $t0 125 popB3
	jal increaseIndex
	beqz $t0 checkStack
	j stackLoop
push:
	add $sp $sp -4
	sw $t0 0($sp)
	lw $t5 stackSize
	add $t5 $t5 1
	sw $t5 stackSize
	jal increaseIndex
	j stackLoop
popB1:	
	lw $t2 brace1
	lw $t0 0($sp)
	seq $t3 $t2 $t0
	beqz $t3 braceMismatch
	lw $t5 stackSize
	add $t5 $t5 -1
	sw $t5 stackSize
	add $sp $sp 4
	jal increaseIndex
	lw $t6 pairs
	add $t6 $t6 1
	sw $t6 pairs
	j stackLoop
popB2:	
	lw $t2 brace2
	lw $t0 0($sp)
	seq $t3 $t2 $t0
	beqz $t3 braceMismatch
	lw $t5 stackSize
	add $t5 $t5 -1
	sw $t5 stackSize
	add $sp $sp 4
	jal increaseIndex
	lw $t6 pairs
	add $t6 $t6 1
	sw $t6 pairs
	j stackLoop
popB3:	
	lw $t2 brace3
	lw $t0 0($sp)
	seq $t3 $t2 $t0
	beqz $t3 braceMismatch
	lw $t5 stackSize
	add $t5 $t5 -1
	sw $t5 stackSize
	add $sp $sp 4
	jal increaseIndex
	lw $t6 pairs
	add $t6 $t6 1
	sw $t6 pairs
	j stackLoop
braceMismatch:
	li $v0 4
	la $a0 mismatchErrorMsg
	syscall
	li $v0 11
	la $a0 ($t7)
	syscall
	li $v0 4
	la $a0 mismatchErrorMsg2
	syscall
	li $v0 1
	lw $a0 index
	syscall
	j exit
checkStack:
	lw $t5 stackSize
	beqz $t5 success
	li $v0 4
	la $a0 checkStackErrorMsg
	syscall
checkStackLoop:
	beqz $t5 exit
	add $t5 $t5 -1
	sw $t5 stackSize
	lw $t1 0($sp)
	add $sp $sp 4
	li $v0 11
	la $a0 ($t1)
	syscall
	j checkStackLoop
success:
	li $v0 4
	la $a0 successMsg
	syscall
	li $v0 1
	lw $a0 pairs
	syscall
	li $v0 4
	la $a0 successMsg2
	syscall
	j exit
increaseIndex:
	lw $t2 index
	add $t2 $t2 1
	sw $t2 index
	jr $ra
closeFile:
	li $v0 16
	move $a0 $s0
	syscall
exit:
	li $v0 11
	li $a0 10
	syscall
	li $v0 10
	syscall

