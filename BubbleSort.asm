TITLE MASM Template						(homework5.asm)

; Carlton Semple
; BubbleSort Lab
; Revision date:


INCLUDE Irvine32.inc
.data
	makecount = 10000
	count DWORD ?
	innercount = 9999
	;array DWORD makecount DUP(?)
	array DWORD makecount DUP(?)

	startTime DWORD ?
	message1 BYTE "Elapsed Time in Milliseconds: ", 0

.code
main PROC

	mov esi, 0	; used to iterate through the array
	mov ecx, makecount	; ecx contains the number of times the loop should run
	;mov ebx, 100 ; use ebx for a test
	call Randomize
	GenerateRandomArray:
		mov eax, 10000
		call RandomRange
		mov array[esi * TYPE array], eax	; switch to ebx for testing 1 - 10
											;;;;;; mov ebx, array[esi * TYPE array] ; test to see that the array values are correct
		inc esi
		dec ebx
		loop GenerateRandomArray

	; timer
	
	call GetMSeconds
	mov startTime, eax

	call bubbleSort
	
	
	call printArray

	call GetMSeconds
	sub eax, startTime

	mov edx, OFFSET message1
	call WriteString
	call WriteDec
	call Crlf

	exit
main ENDP


bubbleSort PROC
	mov ecx, makecount	; initialize ecx

	OuterLoop:
		mov count, ecx	; save outer loop count (page 126 in book)

		; the following is for the inner loop
		mov ecx, innercount	; count - 1, the count for the inner loop
		mov esi, 0 ; esi is the index
		mov edi, 1 ; edi is the ahead index: esi + 1

		InnerLoop:
			mov ebx, array[esi * TYPE array]
			mov edx, array[edi * TYPE array] 
			cmp ebx, edx ; compare array[i] & array[i+1]
			JLE next	; do nothing if array[i] <= array[i+1]
		
			; else if (array[i] > array[i+1])

			; swap
				mov ebx, array[esi * TYPE array]	; ebx = array[i]
				xchg ebx, array[edi * TYPE array]	; ebx = array[i+1]. array[i+1] = array[i]
				xchg ebx, array[esi * TYPE array] ; ebx = array[i]. array[i] = array[i+1]

			next:
				inc esi
				inc edi
			loop InnerLoop	; end of the inner loop
		
		mov ecx, count	; restore the value of ecx for the outer loop
		loop OuterLoop	; ecx = ecx - 1

		ret
bubbleSort ENDP

printArray PROC

	mov ecx, makecount
	mov esi, 0
	print:
		mov eax, array[esi * TYPE array]
		call WriteDec
		call Crlf ; newline
		inc esi
	loop print

	ret
printArray ENDP


END main