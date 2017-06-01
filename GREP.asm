section .data
	strFormat db "%s", 0x00
	colorFormat db "%s%s%s", 0x00
	lnFormat db "%s%d: %s", 0x00
	fmt_green db 0x1b,"[0;32m",0
	fmt_normal db 0x1b,"[0;0m",0
	fmt_red db 0x1b,"[0;31m",0

section .bss
	buffer resb 255
	print resb 2
	SrchCnt resb 4

section .text
	global _start
	EXTERN printf
	EXTERN fgets
	EXTERN strstr
	EXTERN strlen
	EXTERN stdin

_start:
	push ebp
	mov ebp, esp

	mov edi, 0	;line counter

	push dword [ebp+12]
	call strlen
	add esp, 4

	mov [SrchCnt], eax	;ESI holds len of search string
	
_compare:
	push dword [stdin]
	push dword 255
	push dword buffer
	call fgets
	add esp, 12

	cmp eax, 0		;Looks for Newline
	je _exit		;Exits if reached

	inc edi

	mov eax, 0		;Helps determine if string is found see line 50
	push dword [ebp+12]	;Holds argv
	push buffer
	call strstr
	add esp, 8

	cmp eax, 0		;If the string is found eax, will contain memory address, not 0
	je _compare

_FoundString:
	sub eax, buffer		;Find Location of Word

	push eax
	push fmt_normal		;Returns color back to normal
	push edi		;Line Count
	push fmt_green		;Makes Line color green
	push lnFormat
	call printf		
	add esp, 16
	pop eax

	mov ebx, buffer
	mov edx, 0

	_PrintString:
		cmp eax, edx
		je _colorprintsetup

		mov byte cl, [ebx]
		cmp cl, 0x0a
		je _finalprint

		mov byte [print], cl
		mov byte [print+1], 0x00

		push edx
		push eax
		push print
		push strFormat
		call printf
		add esp, 8
		pop eax
		pop edx

		inc ebx
		inc edx	
		jmp _PrintString

_finalprint:
	mov byte [print], cl
	mov byte [print+1], 0x00

	push print
	push strFormat
	call printf
	add esp, 8

	mov eax, 0

	jmp _compare

_colorprintsetup:
	mov esi, [SrchCnt]

	_colorprint:
		mov byte cl, [ebx]
		cmp cl, 0x0a
		je _finalprint

		mov byte [print], cl
		mov byte [print+1], 0x00

		push esi
		push fmt_normal
		push print
		push fmt_red
		push colorFormat
		call printf
		add esp, 16
		pop esi
	
		inc ebx
	
		dec esi
		cmp esi, 0
		je _PrintString

		jmp _colorprint

_exit:
	mov ebx, 0
	mov eax, 1
	int 0x80
