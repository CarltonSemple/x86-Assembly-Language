TITLE MASM Template						(SempleCarlton_Calculator.asm)

; Carlton Semple
; Calculator Lab
; Date: 4/27/2014


INCLUDE Irvine32.inc
.data
	welcome BYTE "---------- Carlton's Calculator ----------", 0
	intro1 BYTE "1 = Addition", 0
	intro2 BYTE "2 = Subtraction", 0
	intro3 BYTE "3 = Multiplication", 0
	intro4 BYTE "4 = Division", 0
	intro5 BYTE "5 = Quit", 0
	correctiveStatement BYTE "Please enter a valid choice", 0
	farewell BYTE "Goodbye", 0

	prompt1 BYTE "Enter the first number: ", 0
	prompt2 BYTE "Enter the second number: ", 0
	success BYTE "Result: ", 0

	; symbols to make things look nicer
	plus BYTE " + ", 0
	minus BYTE " - ", 0
	star BYTE " * ", 0
	slash BYTE " / ", 0
	equalsign BYTE " = ", 0

	; zero error
	NoZeroDenominator BYTE "The denominator cannot be 0. Reenter the divisor", 0
	
	choice SDWORD ?
	number1 SDWORD ?
	number2 SDWORD ?
	result SDWORD ?
.code
main PROC
	
	Begin:
	call menu

	cmp choice, 1
	jl Retry
	cmp choice, 5
	jg Retry
	cmp choice, 5
		je Quit	; quit if 5 is the choice

	;; decide what to do based on the value of choice
	call decide
	jmp Begin
	

	Retry:
	;; remind the user to enter a valid choice
		mov edx, OFFSET correctiveStatement
		call WriteSTring
		call crlf
		call crlf
	jmp Begin	; jump back to the beginning if none of the options were chosen

	Quit:
		mov edx, OFFSET farewell
		call WriteString 
	exit
main ENDP

menu PROC
	;; print out the options using edx and WriteString

	mov edx, OFFSET welcome	; welcome message
	call WriteString
	call crlf
	mov edx, OFFSET intro1	; option 1
	call WriteString
	call crlf
	mov edx, OFFSET intro2	; option 2
	call WriteString
	call crlf
	mov edx, OFFSET intro3	; option 3
	call WriteString
	call crlf
	mov edx, OFFSET intro4	; option 4
	call WriteSTring
	call crlf
	mov edx, OFFSET intro5 ; option to quit
	call WriteString
	call crlf

	;; move the input into choice, which will be used by another function to determine what to do

	call ReadInt
	mov choice, eax
	
	ret
menu ENDP

decide PROC
	
	; Get the numbers first

	;; get the first number
	mov edx, OFFSET prompt1
	call WriteString
	call crlf
	call ReadInt ;; prepare for signed numbers
	mov number1, eax

	;; get the second number
	mov edx, OFFSET prompt2
	call WriteString
	call crlf
	call ReadInt
	mov number2, eax

	; Decide what to do based on the value of choice

	; addition
	cmp choice, 1
		je addition	

	; subtraction
	cmp choice, 2
		je subtraction
		
	; multiplication
	cmp choice, 3
		je multiplication
		
	; division
	cmp choice, 4
		je division

	ret
decide ENDP

addition PROC

	; add the numbers
	mov eax, number1
	add eax, number2
	mov result, eax	; save the result

	; display result
	mov eax, number1
	call crlf
	call WriteInt	; display first number

	mov edx, OFFSET plus	
	call WriteString	; display " + "

	mov eax, number2
	call WriteInt	; display second number

	mov edx, OFFSET equalsign	
	call WriteString	; display " = "
	
	mov eax, result
	call WriteInt	; display result

	call crlf
	call crlf
	
	ret
addition ENDP

subtraction PROC
	
	; subtract the numbers
	mov eax, number1
	sub eax, number2
	mov result, eax	; save the result

	; display result
	mov eax, number1
	call crlf
	call WriteInt	; display first number

	mov edx, OFFSET minus	
	call WriteString	; display " + "

	mov eax, number2
	call WriteInt	; display second number

	mov edx, OFFSET equalsign	
	call WriteString	; display " = "
	
	mov eax, result
	call WriteInt	; display result

	call crlf
	call crlf

	ret
subtraction ENDP

multiplication PROC
	
	; multiply the numbers
	mov eax, number1
	mov ebx, number2	; move the number to a register first
	imul ebx	; multiply eax by ebx
	mov result, eax	; save the result

	; display result
	mov eax, number1
	call crlf
	call WriteInt	; display first number

	mov edx, OFFSET star	
	call WriteString	; display " + "

	mov eax, number2
	call WriteInt	; display second number

	mov edx, OFFSET equalsign	
	call WriteString	; display " = "
	
	mov eax, result
	call WriteInt	; display result

	call crlf
	call crlf

	ret
multiplication ENDP

division PROC
	
	; divide the numbers
	mov eax, number1
	cdq
	mov ebx, number2	; move the number to a register first

	; make sure the divisor isn't 0
	Check:
	cmp ebx, 0
	jz	NoZeroesAllowed	; tell the user that 0 isn't allowed as the denominator

	idiv ebx	; divide eax by ebx
	mov result, eax	; save the result

	; display result
	mov eax, number1
	call crlf
	call WriteInt	; display first number

	mov edx, OFFSET star	
	call WriteString	; display " + "

	mov eax, number2
	call WriteInt	; display second number

	mov edx, OFFSET equalsign	
	call WriteString	; display " = "
	
	mov eax, result
	call WriteInt	; display result

	call crlf
	call crlf
	jmp EndDivision

	NoZeroesAllowed:	; tell the user that 0 isn't allowed as the denominator, then retry
		mov edx, OFFSET NoZeroDenominator
		call WriteString
		call crlf
		call ReadInt
		mov number2, eax
		jmp check

	EndDivision:
	ret
division ENDP


END main