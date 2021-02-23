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
#go from $a1 to argument use load address or load word
#arguments are null terminated for when looping through the file name
#increment 
#main:
#create copy of program argument
#get first byte and check that it is a letter
#
.data
buffer: .space 128
userInput: .asciiz "You entered the file:\n"
fileErrorMsg: .asciiz "ERROR: Invalid program argument.\n"
.text

mainLoop:	
	lw $s0($a1)	#print file name
	li $v0 4
	la $a0 userInput
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
	jal Stack
	
	j exit
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
	li $v0 4 #print contents of buffer
	la $a0 buffer
	syscall
	jr $ra
Stack:
	lb $t0 buffer($0)#print the first byte of buffer
	li $v0 11
	la $a0 ($t0)
	syscall
	
closeFile:
	li $v0 16
	move $a0 $s0
	syscall
	
exit:
	li $v0, 10
	syscall

