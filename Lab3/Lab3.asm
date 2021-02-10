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
#Psuedocode
#.data
#prompt = "Enter the height of the pattern (must be greater than 0):"
#error = "Invalid Entry!"
#.text
#userInput:
#	print prompt
#	print tab
#	ask for user input
#	if user input > 0:
#		jump to noError
#	else:
#		jump to userInputError
#userInputError:
#	print error
#	print New Line
#	jump to userInput:
#noError:
#	$t1 = user's input
#	$t2 = 1
#	print $t2
#	print New Line
#loopStart:
#	if $t2 >= $t1:
#		jump to loopEnd
#	$t3 = 1
#	jump to frontPatternLoopStart:
#fPattrnLoopEnd:
#	print New Line
#	$t4 = 1
#	jump to backPatternLoopStart
#bPattrnLoopEnd:
#	Print New Line
#	jump to LoopStart
#frontPatternLoopStart:
#	if $t3 > $t2:
#		jump to fPattrnLoopEnd
#	$t3++
#	print *
#	print Tab
#	jump to frontPatternLoopStart
#backPatternLoopStart:
#	if $t4 > $t2:
#		jump to fPattrnLoopEnd
#	$t4++
#	print Tab
#	print "*"
# 	jump to backPatternLoopStart:
#LoopEnd:
#	Exit
#
#REGISTER USAGE
#$t1: user input
#$t2: loop counter
#$t3: front pattern loop counter
#$t4: back pattern loop counter
.data
prompt: .asciiz "Enter the height of the pattern (must be greater than 0):"
error: .asciiz "Invalid Entry!"

.text
userInput:
	li $v0 4                  #prep for print string syscall
	la $a0 prompt             #print string stored in prompt
	syscall
	li $v0 11                 #prep for print ASCII syscall
	li $a0 9                  #set $a0 to 9 (Horizontal tab)
	syscall
	li $v0 5                  #prep for user input syscall
	syscall
	ble $v0 0 userInputError  #Branch to userInputError if $v0 is less than or equal to 0
	j noError                 #Jump to noError:
	nop                       
userInputError:
	li $v0 4                  #prep for print string syscall
	la $a0 error              #print string stored in error
	syscall
	li $v0 11                 #prep for print ASCII syscall
	li $a0 10                 #set $a0 to 10 (New Line)
	syscall
	j userInput               #jump to userinput:
	nop
noError:
	move $t1 $v0              #move user input into $t1
	li $t2 1                  #store 1 into $t2
	move $a0 $t2              #copy $t2 into $a0
	li $v0 1                  #prep for print integer syscall
	syscall
	li $v0 11                 #prep for print ASCII syscall
	li $a0 10                 #set $a0 to 10 (New Line)
	syscall
loopStart:
	bge $t2 $t1 loopEnd       #Branch to loopEnd if $t2 is greater than or equal to $t1
	add $t2 $t2 1             #Increment $t2 by 1
	li $t3 1                  #Load 1 into $t3
	j frontPatternLoopStart   #jump to frontPatternLoopStart
	nop
fPattrnLoopEnd:
	move $a0 $t2              #copy $t2 to $a0
	li $v0 1                  #prep for print integer syscall
	syscall
	li $t4 1                  #load 1 into $t4
	j backPatternLoopStart    #jump to backPatternLoopStart:
	nop
bPattrnLoopEnd:
	li $v0 11                 #prep for print ASCII
	li $a0 10                 #set $a0 to 10 (New Line)
	syscall
	j loopStart               #jump to loopStart:
	nop
frontPatternLoopStart:
	bge $t3 $t2 fPattrnLoopEnd#if $t3 is greater or equal to $t2 branch to fPattrnLoopEnd
	add $t3 $t3 1             #add 1 to $t3
	li $v0 11                 #prep for print ASCII syscall
	li $a0 42                 #set $a0 to 42(*)
	syscall
	li $a0 9                  #set $a0 to 9 (Horizontal Tab)
	syscall
	j frontPatternLoopStart   #jump to frontPatternLoopStart:
	nop
backPatternLoopStart:
	bge $t4 $t2 bPattrnLoopEnd# if $t3 is greater or equal to $t2 branch to bPattrnLoopEnd
	add $t4 $t4 1
	li $v0 11                 #prep for print ASCII syscall
	li $a0 9                  #set $a0 to 9 (Horizontal Tab)
	syscall
	li $a0 42                 #set $a0 to 42(*)
	syscall
	j backPatternLoopStart    #jump to backPatternLoopStart:
	nop
loopEnd:
	li $v0 10                 #prep for exit syscall
	syscall
