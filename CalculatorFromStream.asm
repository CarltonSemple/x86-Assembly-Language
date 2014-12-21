TITLE MASM Template						(SempleCarlton_CalculatorFromStream.asm)

; Carlton Semple
; Calculator Lab
; Date: 4/27/2014


INCLUDE Irvine32.inc

ENTER_KEY = 13
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
	moducode BYTE " % ", 0
	equalsign BYTE " = ", 0

	; zero error
	NoZeroDenominator BYTE "The denominator cannot be 0. Try again: ", 0

	; overflow error
	overflowMessage BYTE "Error. Overflow.", 0
	overflowVar BYTE ?

	; instructions
	quitInstructions BYTE "Enter equation. 0 + 0 = quit", 0
	Instructions BYTE "Enter equation.", 0

	; modulo error
	moduloError BYTE "The numbers have to be positive. Try again", 0

	; invalidInputError
	invalidInputError BYTE "Error: Invalid Input. Try again", 0

	count WORD ?
	holdcount WORD ?
	count2 WORD ?
	num1 BYTE ?
	num1x DWORD ?
	operand DWORD ?
	negCheck BYTE ?
	currentNumber BYTE ?
	signHit	BYTE ?
	
	tempMultiplier DWORD ?
	temp DWORD ?
	choice SDWORD ?
	number1 SDWORD ?
	number2 SDWORD ?
	result SDWORD ?

	InvalidInputMsg BYTE "Invalid input",13,10,0
.code
main PROC
		mov edx, OFFSET quitInstructions
		call WriteString
		call crlf
		
	ReadState:
		mov number1, 0
		mov number2, 0
		mov overflowVar, 0
		mov operand, 0
		mov result, 0
								; handle number 1
		mov currentNumber, 1	; signifies that we're doing the first number
		call readNumber			; read from the input stream for a whole number until an operation is reached or the ENTER_KEY is pressed
		cmp overflowVar, 1	; OVERFLOW CHECK
		je overflowError
		cmp negCheck, 1
		jne num2				; don't negate
		cmp signHit, 1
		jg invalidInput			; if multiple signs were hit in a row, give error
		call negateNumber		; negate if negCheck = 1

		num2:					; handle number 2
		mov currentNumber, 2
		call readNumber
		cmp overflowVar, 1	; OVERFLOW CHECK
		je overflowError
		cmp negCheck, 1
		jne continue			; don't negate if negCheck = 0
		call negateNumber		; negate if negCheck = 1

		continue:
			; quit if both numbers are 0
			cmp number1, 0
			jne calculate
			cmp number2, 0
			je finish

		calculate:
			call decide
			jo overflowError	; handle overflow for all operations here

			; display result	
			mov eax, result
			call WriteInt		; display result

			call crlf
			call crlf

			mov edx, OFFSET Instructions	; print instructions
			call WriteString
			call crlf

		jmp ReadState		; loop back to beginning

		overflowError:
			mov edx, OFFSET overflowMessage
			call crlf
			call crlf
			call WriteString
			call crlf
			call crlf
			mov edx, OFFSET Instructions	; print instructions
			call WriteString
			call crlf
			
			jmp ReadState	; loop back to beginning

		invalidInput:
			mov edx, OFFSET invalidInputError
			call WriteString
			call crlf
			call crlf
			jmp ReadState
				
		finish:

	exit
main ENDP



readNumber PROC
	; read in a number, handling the case where a '-' is in the beginning of a number, 
	; signaling that the number has to be negated

	mov esi, 0
	mov count, 0

	mov signHit, 0	; prevent error when a sign is hit twice in a row '-''-'

	mov negCheck, 0	; reset the check for negation

	; check at the beginning to see if this is a negative number
	call Getnext
		cmp al, '-'
		je	markForNegation	; prepare for any negative numbers
		jmp CheckNum

	BeginScan:	; begin the scan of the actual number

	call Getnext
		; exit the function if any of the operations are entered now
		cmp al, '+'	
			je q			
		cmp al, '-'
			je q
		cmp al, '*'
			je q
		cmp al, '/'
			je q
		cmp al, '%'
			je q
		cmp al, ENTER_KEY
			je qo	; exit the function when the user hits enter

	CheckNum:

	call IsDigit				; check the char to see if it's a digit
		jnz nonValidInput		; output an error if the char is not a number. zf = 1 if al contains a digit
		mov num1, al
		movzx eax, num1
		push eax				; add this value to the stack
		add esi, 4				; use esi for cleaning the stack
		inc count
		mov signHit, 0			; reset the sign hit
		jmp BeginScan			; loop back to scan again

	markForNegation:
		mov negCheck, 1				; bh will be the marker for negation. 1 = negate. 0 = don't negate. 
		mov signHit, 1
		jmp BeginScan			; loop to get the next char

	nonValidInput:
		; print error
		jmp BeginScan	; scan again

	q:
	inc signHit		; signHit is reset to 0 when a number is hit, and so it should only end up with a value of 1 right here
	cmp signHit, 1
	jg en			; end if two signs in a row are hit
	movzx eax, al	; save the operater
	mov operand, eax
	qo:
	mov ax, count
	mov holdcount, ax
	cmp currentNumber, 2
	je second

	call storeFirstNumber
	jmp qq

	second:
	call storeSecondNumber

	qq:
	;add esp, 12	; clean the stack by removing the arguments from the stack so that the function can successfully return
	
	movzx ecx, holdcount
	L1:
		add esp, 4
		loop L1
	en:

	ret	4; successfully escaped!
readNumber ENDP

storeFirstNumber PROC
	mov edx, 1	; bx will be the multiplier for the digits' place. (1s, 10s, 100s, 1000s, 10000s, etc.)
	mov eax, 0

	mov esi, 8
	mov ax, count
	mov count2, ax
	dec count2
	
	movzx ecx, count
	
	;L1:
	;	add esi, 4
	;	loop L1
	;sub esi, 4 ; stack's first thing is at 4

	push ebp
	mov ebp, esp
	
	mov eax, 0
	movzx ecx, count
	store:
		mov temp, eax	; eax contains the cumulative sum of the number
		mov ebx, [ebp + esi]
		call convertToInt
		
		next:
		mov eax, ebx
		mov tempMultiplier, edx ; save edx
		mul edx
		add temp, eax
		
		mov edx, tempMultiplier
		mov eax, edx
		mov edx, 10
		mul edx
		mov edx, eax	; the new multiplier value
		mov eax, temp	; restore eax to the value
		jo extra		; OVERFLOW CHECK
		dec count
		add esi, 4
	loop store
	
	mov number1, eax	
	jo extra	; overflow

	finish:
		jmp realfinish

	extra:
		mov overflowVar, 1

	realfinish:

	add esp, 4	; clean the stack
	ret
storeFirstNumber ENDP


storeSecondNumber PROC
	mov edx, 1	; bx will be the multiplier for the digits' place. (1s, 10s, 100s, 1000s, 10000s, etc.)
	mov eax, 0

	mov esi, 8
	mov ax, count
	mov count2, ax
	dec count2
	
	movzx ecx, count
	
	;L1:
	;	add esi, 4
	;	loop L1
	;sub esi, 4 ; stack's first thing is at 4

	push ebp
	mov ebp, esp
	
	mov eax, 0
	movzx ecx, count
	store:
		mov temp, eax	; eax contains the cumulative sum of the number
		mov ebx, [ebp + esi]
		call convertToInt
		
		next:
		mov eax, ebx
		mov tempMultiplier, edx ; save edx
		mul edx
		add temp, eax
		mov edx, tempMultiplier
		mov eax, edx
		mov edx, 10
		mul edx
		mov edx, eax	; the new multiplier value
		mov eax, temp	; restore eax to the value
		jo extra		; OVERFLOW CHECK
		dec count
		add esi, 4
	loop store
	
	mov number2, eax	
	jo extra	; overflow

	finish:
		jmp realfinish

	extra:
		mov overflowVar, 1

	realfinish:

	add esp, 4	; clean the stack
	ret
storeSecondNumber ENDP


Getnext PROC
	;
	; Reads a character from standard input.
	; Receives: nothing
	; Returns: AL contains the character
	;-----------------------------------------------

	call ReadChar ; input from keyboard
	call WriteChar ; echo on screen
	ret
Getnext ENDP


DisplayErrorMsg PROC
	;
	; Displays an error message indicating that
	; the input stream contains illegal input.
	; Receives: nothing.
	; Returns: nothing
	;-----------------------------------------------

	push edx
	mov edx,OFFSET InvalidInputMsg
	call WriteString
	pop edx
	ret
DisplayErrorMsg ENDP


convertToInt PROC
;; take the value in ebx and convert to an int/dec, returning the new value in ebx
				cmp ebx, '0'
				je zero
				cmp ebx, '1'
				je one
				cmp ebx, '2'
				je two
				cmp ebx, '3'
				je three
				cmp ebx, '4'
				je four
				cmp ebx, '5'
				je five
				cmp ebx, '6'
				je six
				cmp ebx, '7'
				je seven
				cmp ebx, '8'
				je eight
				cmp ebx, '9'
				je nine				

				zero:
					mov ebx, 0
					jmp en
				one:
					mov ebx, 1
					jmp en
				two:
					mov ebx, 2
					jmp en
				three:
					mov ebx, 3
					jmp en
				four:
					mov ebx, 4
					jmp en
				five:
					mov ebx, 5
					jmp en
				six:
					mov ebx, 6
					jmp en
				seven:
					mov ebx, 7
					jmp en
				eight:
					mov ebx, 8
					jmp en
				nine:
					mov ebx, 9
	en:

	ret
convertToInt ENDP

decide PROC
	cmp operand, '+'
		je addi
	cmp operand, '-'
		je subtracti
	cmp operand, '*'
		je multi
	cmp operand, '/'
		je divi
	cmp operand, '%'
		je modu

	addi:
		call addition
		jmp en
	subtracti:
		call subtraction
		jmp en
	multi:
		call multiplication
		jmp en
	divi:
		call division
		jmp en
	modu:
		call modulo
	
	en:
	ret
decide ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Calculations ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;
;;;
;;;
;;;
negateNumber PROC
		cmp currentNumber, 2	; if it's the second number
		je second

		; else, if it's the first number
		mov eax, number1
		not eax
		mov number1, eax
		inc number1
		jmp en
	second:
		mov eax, number2
		not eax
		mov number2, eax
		inc number2
	en:
	ret
negateNumber ENDP

addition PROC

	; add the numbers
	mov eax, number1
	add eax, number2
	mov result, eax	; save the result

	; display result	
		mov eax, number1
		call WriteInt			; display first number
		mov edx, OFFSET plus
		call WriteString		; display operand
		mov eax, number2
		call WriteInt			; display second number
		mov edx, OFFSET equalsign	
		call WriteString		; display " = "

	ret
addition ENDP


subtraction PROC
	
	; subtract the numbers
	mov eax, number1
	sub eax, number2
	mov result, eax	; save the result

	; display result	
		mov eax, number1
		call WriteInt			; display first number
		mov edx, OFFSET minus
		call WriteString		; display operand
		mov eax, number2
		call WriteInt			; display second number
		mov edx, OFFSET equalsign	
		call WriteString		; display " = "
	
	ret
subtraction ENDP


multiplication PROC
	
	; multiply the numbers
	mov eax, number1
	mov ebx, number2	; move the number to a register first
	imul ebx	; multiply eax by ebx
	jo overflowerrr
	mov result, eax	; save the result

	; display result	
		mov eax, number1
		call WriteInt			; display first number
		mov edx, OFFSET star	
		call WriteString		; display operand
		mov eax, number2
		call WriteInt			; display second number
		mov edx, OFFSET equalsign	
		call WriteString		; display " = "

	overflowerrr:

	ret
multiplication ENDP


division PROC
	
	; divide the numbers
	mov eax, number1
	cdq
	mov ebx, number2		; move the number to a register first

	; make sure the divisor isn't 0
	Check:
	cmp ebx, 0
	jz	NoZeroesAllowed		; tell the user that 0 isn't allowed as the denominator

	idiv ebx				; divide eax by ebx
	mov result, eax			; save the result

	; display result	
		mov eax, number1
		call WriteInt			; display first number
		mov edx, OFFSET slash	
		call WriteString		; display operand
		mov eax, number2
		call WriteInt			; display second number
		mov edx, OFFSET equalsign	
		call WriteString		; display " = "

	jmp EndDivision

	NoZeroesAllowed:	; tell the user that 0 isn't allowed as the denominator, then retry
		mov result, 0
		mov edx, OFFSET NoZeroDenominator
		call WriteString


	EndDivision:
	ret
division ENDP

modulo PROC
	cmp number1, 0
	jl notPositive

	cmp number2, 0
	jl notPositive

	; if the numbers are positive, divide
	mov eax, number1
	cdq
	mov ebx, number2
	idiv ebx				; divide eax by ebx
	mov result, edx		; remainder goes into edx

	; display result	
		mov eax, number1
		call WriteInt			; display first number
		mov edx, OFFSET moducode
		call WriteString		; display operand
		mov eax, number2
		call WriteInt			; display second number
		mov edx, OFFSET equalsign	
		call WriteString		; display " = "


	jmp en

	notPositive:
		mov edx, OFFSET moduloError
		call WriteString

	en:

	ret
modulo ENDP



END main
