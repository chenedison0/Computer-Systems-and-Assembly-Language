##########################################################################
# Created by:  Chen, Edison
#              edpchen
#              25 February 2021
#
# Assignment:  Lab 5: Functions and Graphics
#              CSE 012, Computer Systems and Assembly Language
#              UC Santa Cruz, Winter 2021
#
# Description: This program stores functions that implement graphics
#              on a small simulated display.
#
# Notes:       This program is intended to be run from the MARS IDE.
##########################################################################
#
# Psuedocode
#
# push:
#	subtract 4 from $sp
#	save input to 0($sp)
# pop:
#	load 0($sp) to %reg
#	add 4 to $sp
# getCoordinates:
#	set %y to input && 0x000000ff
#	set %x to input shifted right by 16
# formatCoordinates:
#	set %output to %x shifted left by 16
#	add %y to %output
# getPixelAddress:
#	%output = %origin + 4 * (%x + 128 * %y)
# clear_bitmap:
#	load 0xFFFFFFFC into $t1
#	load originAddress into $t0
#	loop through from $t0 to $t1 by decrement -4
#	store color to each address
# draw_pixel:
#	load originAddress $t3
#	getCoordinate from $a0 into $t0 and $t1
#	getPixelAddress($t4 $t0 $t1 $t3)
#	save $t4 to $a1
# get_pixel:
#	load originAddress $t3
#	getCoordinate from $a0 into $t0 and $t1
#	getPixelAddress($t4 $t0 $t1 $t3)
#	load $t4 to $v0
# draw_horizontal_line:
#	getCoordinates from $a0 into $t0 and $t1
#	draw_Pixel
#	end loop if $t0 greater or equal to 127
#	increment $t0 by 1
#	formatCoordinates($a0 $t0 $t1)
# draw_vertical_line:
#	getCoordinates from $a0 into $t0 and $t1
#	formatCoordinates($a0 $t1 $t0)
#	draw_Pixel
#	end loop if $t0 greater or equal to 127
#	increment $t0 by 1
#	formatCoordinates($a0 $t1 $t0)
# draw_crosshair:
#	push $ra, $s1, $s2, $s3, $s4, $s5
#	create copy $s5 of $sp
#	create copy $s0 of $a0
#	create copy $s1 of $a1
#	store x and y in s2 and s3 respectively
#	get_pixel
#	create copy $s4 of $v0
#	create copy $a0 of $s3
#	draw_horizontal_line
#	create copy $a0 $s2
#	draw_vertical_line
#	create copy $a0 of $s0
#	create copy $a1 of $s4
#	draw_pixel
#	create copy $sp of $s5
#	push $ra, $s1, $s2, $s3, $s4, $s5
#
# Winter 2021 CSE12 Lab5 Template
######################################################
# Macros for instructor use (you shouldn't need these)
######################################################

# Macro that stores the value in %reg on the stack 
#	and moves the stack pointer.
.macro push(%reg)
	subi $sp $sp 4                          #subtract 4 from $sp
	sw %reg 0($sp)                          #save input to 0($sp)
.end_macro 

# Macro takes the value on the top of the stack and 
#	loads it into %reg then moves the stack pointer.
.macro pop(%reg)
	lw %reg 0($sp)                          #load 0($sp) to %reg
	addi $sp $sp 4                          #add 4 to $sp
.end_macro

#################################################
# Macros for you to fill in (you will need these)
#################################################

# Macro that takes as input coordinates in the format
#	(0x00XX00YY) and returns x and y separately.
# args: 
#	%input: register containing 0x00XX00YY
#	%x: register to store 0x000000XX in
#	%y: register to store 0x000000YY in
.macro getCoordinates(%input %x %y)
	# YOUR CODE HERE
	and %y %input 0x000000ff                #set %y to input && 0x000000ff
	srl %x %input 16                        #set %x to input shifted right by 16
.end_macro

# Macro that takes Coordinates in (%x,%y) where
#	%x = 0x000000XX and %y= 0x000000YY and
#	returns %output = (0x00XX00YY)
# args: 
#	%x: register containing 0x000000XX
#	%y: register containing 0x000000YY
#	%output: register to store 0x00XX00YY in
.macro formatCoordinates(%output %x %y)
	# YOUR CODE HERE
	sll %output %x 16                       #set %output to %x shifted left by 16
	add %output %output %y                  #add %y to %output
.end_macro 

# Macro that converts pixel coordinate to address
# 	output = origin + 4 * (x + 128 * y)
# args: 
#	%x: register containing 0x000000XX
#	%y: register containing 0x000000YY
#	%origin: register containing address of (0, 0)
#	%output: register to store memory address in
.macro getPixelAddress(%output %x %y %origin)
	# YOUR CODE HERE
	mul %y %y 128                           #implement %output = %origin + 4 * (%x + 128 * %y)
	add %x %x %y
	mul %x %x 4
	add %output %origin %x
.end_macro


.data
originAddress: .word 0xFFFF0000

.text
# prevent this file from being run as main
li $v0 10 
syscall

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#  Subroutines defined below
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#*****************************************************
# Clear_bitmap: Given a color, will fill the bitmap 
#	display with that color.
# -----------------------------------------------------
# Inputs:
#	$a0 = Color in format (0x00RRGGBB) 
# Outputs:
#	No register outputs
#*****************************************************
# Register Usage
# $t1 Ending Address
# $t0 Origin Address
clear_bitmap: nop
	# YOUR CODE HERE, only use t registers (and a, v where appropriate)
	lw $t1 0xFFFFFFFC                       #load 0xFFFFFFFC into $t1
	lw $t0 originAddress                    #load originAddress into $t0
	clearLoop:
		bge $t0 $t1 clearLoopEnd        #branch to clearLoopEnd if $t1 greater or equal to $t0
		sw $a0 ($t0)                    #store $a0 to $t0
		sub $t0 $t0 -4                  #decrement $t0 by -4
		j clearLoop
	clearLoopEnd:
 		jr $ra

#*****************************************************
# draw_pixel: Given a coordinate in $a0, sets corresponding 
#	value in memory to the color given by $a1
# -----------------------------------------------------
#	Inputs:
#		$a0 = coordinates of pixel in format (0x00XX00YY)
#		$a1 = color of pixel in format (0x00RRGGBB)
#	Outputs:
#		No register outputs
#*****************************************************
# Register Usage
# $t0 x coordinate
# $t1 y coordinate
# $t4 output of getPixelAddress
draw_pixel: nop
	# YOUR CODE HERE, only use t registers (and a, v where appropriate)
	push($t0)                               #push t0
	push($t1)                               #push t1
	lw $t3 originAddress                    #load originAddress into $t3
	getCoordinates($a0 $t0 $t1)             #store x and y in t0 and t1 respectively
	getPixelAddress($t4 $t0 $t1 $t3)        #get pixel address and store into t4
	sw $a1 ($t4)                            #store $a1 to $t4
	pop($t1)                                #pop t1
	pop($t0)                                #pop t0
	jr $ra
	
#*****************************************************
# get_pixel:
#  Given a coordinate, returns the color of that pixel	
#-----------------------------------------------------
#	Inputs:
#		$a0 = coordinates of pixel in format (0x00XX00YY)
#	Outputs:
#		Returns pixel color in $v0 in format (0x00RRGGBB)
#*****************************************************
# Register Usage
# $t0 x coordinate
# $t1 y coordinate
# $t4 output of getPixelAddress
get_pixel: nop
	# YOUR CODE HERE, only use t registers (and a, v where appropriate)
	push($t0)                               #push t0
	push($t1)                               #push t1
	lw $t3 originAddress                    #load originAddress into $t3
	getCoordinates($a0 $t0 $t1)             #store x and y in t0 and t1 respectively
	getPixelAddress($t4 $t0 $t1 $t3)        #get pixel address and store into t4
	lw $v0 ($t4)                            #load $a1 to $t4
	pop($t1)                                #pop t1
	pop($t0)                                #pop t0
	jr $ra

#*****************************************************
# draw_horizontal_line: Draws a horizontal line
# ----------------------------------------------------
# Inputs:
#	$a0 = y-coordinate in format (0x000000YY)
#	$a1 = color in format (0x00RRGGBB) 
# Outputs:
#	No register outputs
#*****************************************************
# Register Usage
# $t0 x coordinate
# $t1 y coordinate
draw_horizontal_line: nop
	# YOUR CODE HERE, only use t registers (and a, v where appropriate)
	getCoordinates($a0 $t0 $t1)             #store x and y in t0 and t1 respectively
	hloop:
		push($ra)
		jal draw_pixel                  #jump and link to draw_pixel
		pop($ra)
		bge $t0 127 hloopEnd            #branch to hloopEnd if $t0 greater equal than 127
		add $t0 $t0 1                   #increment t0 by 1
		formatCoordinates($a0 $t0 $t1)  #format $t0 and $t1 coordinates into(0x00XX00YY)
		j hloop
	hloopEnd:
 		jr $ra


#*****************************************************
# draw_vertical_line: Draws a vertical line
# ----------------------------------------------------
# Inputs:
#	$a0 = x-coordinate in format (0x000000XX)
#	$a1 = color in format (0x00RRGGBB) 
# Outputs:
#	No register outputs
#*****************************************************
# Register Usage
# $t0 x coordinate
# $t1 y coordinate
draw_vertical_line: nop
	# YOUR CODE HERE, only use t registers (and a, v where appropriate)
	getCoordinates($a0 $t0 $t1)             #store x and y in t0 and t1 respectively
	formatCoordinates($a0 $t1 $t0)          #format $t1 and $t0 coordinates into(0x00XX00YY)
	vloop:
		push($ra)
		jal draw_pixel                  #jump and link to draw_pixel
		pop($ra)
		bge $t0 127 vloopEnd            #branch to vloopEnd if $t0 greater equal than 127
		add $t0 $t0 1                   #increment t0 by 1
		formatCoordinates($a0 $t1 $t0)  #format $t1 and $t0 coordinates into(0x00XX00YY)
		j vloop
	vloopEnd:
 		jr $ra


#*****************************************************
# draw_crosshair: Draws a horizontal and a vertical 
#	line of given color which intersect at given (x, y).
#	The pixel at (x, y) should be the same color before 
#	and after running this function.
# -----------------------------------------------------
# Inputs:
#	$a0 = (x, y) coords of intersection in format (0x00XX00YY)
#	$a1 = color in format (0x00RRGGBB) 
# Outputs:
#	No register outputs
#*****************************************************
# Register Usage
# $s0 (x, y) coords in (0x00XX00YY)
# $s2 x coordinate
# $s3 y coordinate
# $s4 color
# $s5 stack pointer
draw_crosshair: nop
	push($ra)                               #push $ra, $s1, $s2, $s3, $s4, $s5
	push($s0)
	push($s1)
	push($s2)
	push($s3)
	push($s4)
	push($s5)
	move $s5 $sp                            #create copy $s5 of $sp

	move $s0 $a0                            # store 0x00XX00YY in s0
	move $s1 $a1                            # store 0x00RRGGBB in s1
	getCoordinates($a0 $s2 $s3)             # store x and y in s2 and s3 respectively
	
	# get current color of pixel at the intersection, store it in s4
	# YOUR CODE HERE, only use the s0-s4 registers (and a, v where appropriate)
	jal get_pixel                           #jump and link to get_pixel
	move $s4 $v0                            #create copy $s4 of $v0

	# draw horizontal line (by calling your `draw_horizontal_line`) function
	# YOUR CODE HERE, only use the s0-s4 registers (and a, v where appropriate)
	move $a0 $s3                            #create copy $a0 of $s3
	jal draw_horizontal_line                #jump and link to draw_horizontal_line

	# draw vertical line (by calling your `draw_vertical_line`) function
	# YOUR CODE HERE, only use the s0-s4 registers (and a, v where appropriate)
	move $a0 $s2                            #create copy $a0 of $s2
	jal draw_vertical_line                  #jump and link to draw_vertical_line

	# restore pixel at the intersection to its previous color
	# YOUR CODE HERE, only use the s0-s4 registers (and a, v where appropriate)
	move $a0 $s0                            #create copy $a0 of $s0
	move $a1 $s4                            #create copy $sa1 of $s4
	jal draw_pixel                          #jump and link to draw_pixel

	move $sp $s5                            #create copy $sp of $s5
	pop($s5)                                #pop $ra, $s1, $s2, $s3, $s4, $s5
	pop($s4)
	pop($s3)
	pop($s2)
	pop($s1)
	pop($s0)
	pop($ra)
	jr $ra
