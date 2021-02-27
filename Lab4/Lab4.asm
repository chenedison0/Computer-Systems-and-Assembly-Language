##########################################################################
# Created by:  Chen, Edison
#              edpchen
#              25 February 2021
#
# Assignment:  Lab 4: Syntax Checker
#              CSE 012, Computer Systems and Assembly Language
#              UC Santa Cruz, Winter 2021
#
# Description: The program will print success or error messages for 
#              brace syntax based on file input.
#
# Notes:       This program is intended to be run from the MARS IDE.
##########################################################################
#
# Psuedocode
#
# mainLoop:
#	print "You entered the file:"
#	create copies of argument address
#	get the first char of file 
#	jump to checkCharError
#	jump to fileNameLen
#	print New Line
#	jump and link to openFile
#	jump and link to readfile
#	jump to stack
# checkCharError:
#	check that first char either is between 64 and 91 or between 96 and 123
#	if true: branch to jumpBack
#	else: jump to error
# fileNameLen:
#	set counter to 0
#	loop through the program argument
#	increment counter
#	if counter > 20: branch to error
#	else: jump to jumpBack
# error:
#	print New Line
#	print "ERROR: Invalid program argument."
# jumpBack:
#	jump register to last jal
# openFile:
#	open file and copy file descriptor
#	jump to jumpBack
# readFile:
#	read file using file descriptor
#	load contents into buffer
#	print New Line
#	jump to stack
# stack:
#	set counter to 0
# stackLoop:
#	get the byte in buffer corresponding to counter
#	if (,[,{ branch to push
#	if },],} branch to corresponding pop
#	jump and link to increaseIndex
#	branch to checkStack if end of buffer
#	jump to stackLoop
# push:
#	store current brace to buffer
#	increment stackSize by 1
#	jump and link to increaseIndex
#	jump to stackLoop
# pop: (seperate pop function for each brace)
#	check if current closed brace in buffer corresponds to open brace in stack
#	branch to braceMismatch if they don't correspond
#	increment stackSize by 1
#	jump and link to increaseIndex
#	increment pairs by 1
#	jump to stackLoop
# braceMismatch:
#	print "ERROR - There is a brace mismatch: "
#	print closed brace that doesn't correspond
#	print " at index "
#	print index
# checkStack
#	branch to success if stackSize equal 0
#	print "ERROR - Brace(s) still on stack: "
# checkStackLoop
#	branch to exit if stackSize is 0
#	decrement stackSize by 1
#	print current brace at top of stack
#	remove top of stack
#	jump to stackStackLoop
# success:
#	print "SUCCESS: There are "
#	print pairs
#	print " pairs of braces."
#	jump to exit
# increaseIndex:
#	increment index by 1
# exit:
#	print New Line
#	close file
#	exit

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
# REGISTER USAGE
# $a3: copy of argument address to be used in openFile
# $t0: first char of program argument
mainLoop:	
	lw $s0($a1)               #load program argument word into $s0
	li $v0 4                  #prep for print string
	la $a0 userInputMsg       #print userInputMsg
	syscall
	move $a0 $s0              #create copy of argument address in $a0
	move $a3 $s0              #create copy of argument address in $a3
	syscall
	lb $t0 0($a0)             #load first bit of $a0 into $t0
	jal checkCharError        #jump to checkCharError
	jal fileNameLen           #jump to fileNameLen
	li $v0 11                 #prep for print char
	li $a0 10                 #print New Line
	syscall
	jal openFile              #jump to openFile
	jal readFile              #jump to readFile
	j stack                   #jump to Stack
	
# REGISTER USAGE
# $t1 - $t4: logic 
checkCharError:
	sgt $t1 $t0 64            #check if $t0 is greater than 64 and store 1 or 0 in $t1
	slti $t2 $t0 9            #check if $t0 is less than 91 and store 1 or 0 in $t2
	and $t3 $t1 $t2           #and $t1 and $t2 and store 1 or 0 in $t3
	sgt $t1 $t0 96            #check if $t0 is greater than 96 and store 1 or 0 in $t1
	slti $t2 $t0 123          #check if $t0 is greater than 64 and store 1 or 0 in $t2
	and $t4 $t1 $t2           #and $t1 and $t2 and store 1 or 0 in $t4
	or $t1 $t3 $t4            #or $t3 and $t4 and store 1 or 0 in $t1
	bnez $t1 jumpBack         #if $t1 is not 0 then branch to jumpBack
	j error                   #jump to error
	
# REGISTER USAGE
# $t0: loop counter
# $t1: byte from buffer
fileNameLen:
	li $t0 0                  #load 0 into $t0
loop:
	lb $t1 0($s0)             #load byte 0 of $s0 into $t1
	beqz $t1 jumpBack         #branch to jumpback if nullterminated
	add $s0 $s0 1             #increment $s0 by 1
	add $t0 $t0 1             #increment $t0 by 1
	bge $t0 21 error          #branch to error if $t0 greater than 21
	j loop                    #jump to loop
error:
	li $v0 11                 #prep for print char
	li $a0 10                 #print New Line
	syscall
	syscall
	li $v0 4                  #prep for print string 
	la $a0 fileErrorMsg       #print fileCharErrorMsg:        
	syscall
	j exit                    #jump to exit
jumpBack:
	jr $ra                    #jump register to last jal
	
# REGISTER USAGE
# $s0: file descriptor
openFile:
	li $v0 13                 #prep for open file
	la $a0 ($a3)              #load $a3 into $a0
	li $a1 0                  #load 0 into $a1
	li $a2 0                  #load 0 into $a2
	syscall
	move $s0 $v0              #copy $v0 on to $s0
	jr $ra                    #jump register to last jal

readFile:
	li $v0 14                 #prep for read file syscall
	move $a0 $s0              #copy $s0 onto $a0
	la $a1 buffer             #load buffer into $a1
	li $a2 128                #hardcode maximum read 128 bytes
	syscall
	li $v0 11                 #prep for char sycall
	li $a0 10                 #print New Line
	syscall
	j stack                   #jump to stackLoop
	
# REGISTER USAGE
# $t1: loop counter
# $t0: byte from buffer`
# $t7: copy of byte from buffer
stack:
	li $t1 0                  #load 0 on to $t1
stackLoop:
	lb $t0 buffer($t1)        #load the first byte of buffer into $t0
	move $t7 $t0              #copy $t0 onto $t7
	add $t1 $t1 1             #increment $t1 by 1
	beq $t0 40 push           #branch to push if $t0 equal 40
	beq $t0 91 push           #branch to push if $t0 equal 91
	beq $t0 123 push          #branch to push if $t0 equal 123
	beq $t0 41 popB1          #branch to popB1 if $t0 equal 41
	beq $t0 93 popB2          #branch to popB2 if $t0 equal 93
	beq $t0 125 popB3         #branch to popB3 if $t0 equal 125
	jal increaseIndex         #jump and link increaseIndex
	beqz $t0 checkStack       #branch to checkStack if $t0 equal 0
	j stackLoop               #jump to stackLoop
	
# REGISTER USAGE
# $t0: byte from buffer
# $t5: proxy to increment stackSize
push:
	add $sp $sp -4            #subtract 4 from stack pointer
	sw $t0 0($sp)             #store $t0 into stack
	lw $t5 stackSize          #load stackSize on to $t5
	add $t5 $t5 1             #increment #t5 by 1
	sw $t5 stackSize          #save $t5 on to stackSize
	jal increaseIndex         #jump and link to increase Index
	j stackLoop               #jump to stackLoop
	
# REGISTER USAGE
# $t0: popped from stack
# $t2: corresponding brace
# $t3: logic
# $t5: proxy to increment stackSize
# $t6: proxy to increment pair

popB1:	
	lw $t2 brace1             #load brace1 into $t2
	lw $t0 0($sp)             #load top of stack onto $t0
	seq $t3 $t2 $t0           #set $t3 to 0 or 1 if $t2 equal $t0
	beqz $t3 braceMismatch    #branch to braceMismatch if $t3 equal 0
	lw $t5 stackSize          #load stackSize on to $t5
	add $t5 $t5 -1            #increment #t5 by -1
	sw $t5 stackSize          #save $t5 on to stackSize
	add $sp $sp 4             #add 4 to $sp
	jal increaseIndex         #jump and link increaseIndex
	lw $t6 pairs              #load pairs on to $t6
	add $t6 $t6 1             #increment #t6 by 1
	sw $t6 pairs              #save $t6 on to pairs
	j stackLoop               #jump to stackLoop
popB2:	
	lw $t2 brace2             #load brace1 into $t2
	lw $t0 0($sp)             #load top of stack onto $t0
	seq $t3 $t2 $t0           #set $t3 to 0 or 1 if $t2 equal $t0
	beqz $t3 braceMismatch    #branch to braceMismatch if $t3 equal 0
	lw $t5 stackSize          #load stackSize on to $t5
	add $t5 $t5 -1            #increment #t5 by -1
	sw $t5 stackSize          #save $t5 on to stackSize
	add $sp $sp 4             #add 4 to $sp
	jal increaseIndex         #jump and link increaseIndex
	lw $t6 pairs              #load pairs on to $t6
	add $t6 $t6 1             #increment #t6 by 1
	sw $t6 pairs              #save $t6 on to pairs
	j stackLoop               #jump to stackLoop
popB3:	
	lw $t2 brace3             #load brace1 into $t2
	lw $t0 0($sp)             #load top of stack onto $t0
	seq $t3 $t2 $t0           #set $t3 to 0 or 1 if $t2 equal $t0
	beqz $t3 braceMismatch    #branch to braceMismatch if $t3 equal 0
	lw $t5 stackSize          #load stackSize on to $t5
	add $t5 $t5 -1            #increment #t5 by -1
	sw $t5 stackSize          #save $t5 on to stackSize
	add $sp $sp 4             #add 4 to $sp
	jal increaseIndex         #jump and link increaseIndex
	lw $t6 pairs              #load pairs on to $t6
	add $t6 $t6 1             #increment #t6 by 1
	sw $t6 pairs              #save $t6 on to pairs
	j stackLoop               #jump to stackLoop
	
# REGISTER USAGE
# $t7: byte from buffer
braceMismatch:
	li $v0 4                  #prep for print string
	la $a0 mismatchErrorMsg   #print mismatchErrorMsg
	syscall
	li $v0 11                 #prep for print char
	la $a0 ($t7)              #load $t7 into $a0
	syscall
	li $v0 4                  #prep for print string
	la $a0 mismatchErrorMsg2  #print mismatchErrorMsg2
	syscall
	li $v0 1                  #prep for print int
	lw $a0 index              #print index
	syscall
	j exit                    #jump to exit
	
# REGISTER USAGE
# $t5: stackSize
# $t1: byte from stack

checkStack:
	lw $t5 stackSize          #load stackSize onto $t5
	beqz $t5 success          #branch to success if $t5 equal 0
	li $v0 4                  #prep for print string
	la $a0 checkStackErrorMsg #print checkStackErrorMsg
	syscall
checkStackLoop:
	beqz $t5 exit             #branch to exit if $t5 equal 0
	add $t5 $t5 -1            #decrement $t5 by 1
	sw $t5 stackSize          #save $t5 to stackSize
	lw $t1 0($sp)             #load $sp onto $t1
	add $sp $sp 4             #add 4 to $sp
	li $v0 11                 #prep for print char
	la $a0 ($t1)              #print $t1
	syscall
	j checkStackLoop          #jump to checkStackLoop
	
success:
	li $v0 4                  #prep for print string
	la $a0 successMsg         #print successMsg
	syscall
	li $v0 1                  #prep for print int
	lw $a0 pairs              #print pairs
	syscall
	li $v0 4                  #prep for print string
	la $a0 successMsg2        #print successMsg2
	syscall
	j exit                    #jump to exit
	
# REGISTER USAGE
# $t2: proxy to increment index

increaseIndex:
	lw $t2 index              #load index on to $t2
	add $t2 $t2 1             #increment $t2 by 1
	sw $t2 index              #save $t2 onto index
	jr $ra                    #jump register to last jal
exit:
	li $v0 11                 #prep for print char
	li $a0 10                 #print New Line
	syscall
	li $v0 16                 #prep for close file
	move $a0 $s0              #copy $s0 onto $a0
	syscall
	li $v0 10                 #prep for exit
	syscall

