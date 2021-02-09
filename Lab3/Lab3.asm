##########################################################################
# Created by: Chen, Edison
# edpchen
# 11 February 2021
#
# Assignment: Lab 3: ASCII-risks (Asterisks)
# CSE 012, Computer Systems and Assembly Language
# UC Santa Cruz, Winter 2021
#
# Description: This program prints ‘Hello world.’ to the screen.
#
# Notes: This program is intended to be run from the MARS IDE.
##########################################################################

.data
prompt: .asciiz "Enter the height of the pattern (must be greater than 0):	"
error: .asciiz "Invalid Entry!"

.text

userInput:
	li $v0 4	#prep for string
	la $a0 prompt	#print string stored in prompt
	syscall
	li $v0 5	#prep for user input
	syscall
	ble $v0 0 userInputError
	j noError
	userInputError:
		li $v0 4
		la $a0 error
		syscall
		li $v0 11 
		li $a0 10 
		syscall
		j userInput
	noError:
		move $t1 $v0	#move user input into t1
		li $t2 1	#store 1 into t2
		move $a0 $t2	#move t2 into a0
		li $v0 1	#prep for print integer
		syscall
		li $v0 11 	#prep for ascii
		li $a0 10  	#print new line
		syscall
loopStart:
	bge $t2 $t1 loopEnd
	add $t2 $t2 1 #Increment t2 by 1
	li $t3 1
	j frontPatternLoopStart #jump to the subroutine to create the front of the pattern
	frontPatternLoopEnd:
	
	move $a0 $t2
	li $v0 1
	syscall
	li $t4 1
	j backPatternLoopStart
	backPatternLoopEnd:
	
	li $v0 11 
	li $a0 10 
	syscall
	j loopStart
	nop
frontPatternLoopStart:
	bge $t3 $t2 frontPatternLoopEnd
	add $t3 $t3 1
	li $v0 11
	li $a0 42
	syscall
	li $a0 9
	syscall
	j frontPatternLoopStart
	nop
backPatternLoopStart:
	bge $t4 $t2 backPatternLoopEnd
	add $t4 $t4 1
	li $v0 11
	li $a0 9
	syscall
	li $a0 42
	syscall
	j backPatternLoopStart
	nop
loopEnd:
	li $v0 10
	syscall
