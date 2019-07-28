%define exit  0x1
%define read  0x3
%define write 0x4
%define open  0x5
%define close 0x6
extern memset
extern cycle_len
extern four_pow
extern flen
section .data
	help_msg:      db "Usage: asmfuck <filename>", 0xa
	file_error_msg db "Failed to open file", 0xa
	it: dd 0                 ;iterator
section .bss
	cells: resb 0x7530       ;char arr[30000]
section .text
;void interpreter(char *cmd, size_t len);
interpreter:
	push ebp
	mov ebp, esp
	push eax
	push ebx
	push ecx
	push edx
	push esi
	mov esi, [ebp+0x8]
.loop:
	cmp dword [ebp+0xc], 0x0 ;cmp len with 0
	jle .quit
	dec dword [ebp+0xc]      ;len--

	cmp byte [esi], 0x3e     ;compare with >
	je .case_g
	cmp byte [esi], 0x3c     ;compare with <
	je .case_l
	cmp byte [esi], 0x2b     ;compare with +
	je .case_p
	cmp byte [esi], 0x2d     ;compare with -
	je .case_m
	cmp byte [esi], 0x2e     ;compare with .
	je .case_d
	cmp byte [esi], 0x2c     ;compare with ,
	je .case_c
	cmp byte [esi], 0x5b     ;compare with [
	je .case_lb
	jmp .switch_end

.case_g:
	inc dword [it]
	jmp .switch_end
.case_l:
	dec dword [it]
	jmp .switch_end
.case_p:
	lea eax, [cells]
	add eax, dword [it]
	inc byte [eax]
	jmp .switch_end
.case_m:
	lea eax, [cells]
	add eax, [it]
	dec byte [eax]
	jmp .switch_end
.case_d:
	mov eax, write
	mov ebx, 0x1
	lea ecx, [cells]
	add ecx, [it]
	mov edx, 0x1
	int 0x80
	jmp .switch_end
.case_c:
	mov eax, read
	xor ebx, ebx
	lea ecx, [cells]
	add ecx, [it]
	mov edx, 0x1
	int 0x80
	jmp .switch_end
.case_lb:
	push dword [ebp+0xc]
	lea ebx, [esi+1]
	push ebx
	call cycle_len
	add esp, 0x8
.bf_loop:
	push eax
	push ebx
	call interpreter
	add esp, 0x8
	lea ecx, [cells]
	add ecx, [it]
	cmp byte [ecx], 0x0
	jne .bf_loop
	sub dword [ebp+0xc], eax ;len - eax
	add esi, eax
.switch_end:
	inc esi
	jmp .loop
.quit:
	pop esi
	pop edx
	pop ecx
	pop ebx
	pop eax
	mov esp, ebp
	pop ebp
	ret
global _start
;filename
_start:
	mov ebp, esp
	sub esp, 0xc ;int fd, int flen, char *buf

	cmp dword [ebp], 0x2
	jne .print_help_msg

	push dword 0x7530
	push dword 0x0
	push dword cells
	call memset
	add esp, 0xc

	mov eax, open
	mov ebx, [ebp+0x8]
	xor ecx, ecx
	int 0x80
	test eax, eax
	jl .print_file_error
	mov [ebp-0x4], eax

	push eax
	call flen
	add esp, 0x4

	push eax
	call four_pow
	add esp, 0x4
	mov [ebp-0x8], eax
	sub esp, eax
	mov [ebp-0xc], esp

	mov eax, read
	mov ebx, [ebp-0x4]
	mov ecx, esp
	mov edx, [ebp-0x8]
	int 0x80

	push eax             ;push len
	push dword [ebp-0xc] ;push cmd
	call interpreter
	add esp, 0x8

	mov eax, close
	mov ebx, [ebp-0x4]
	int 0x80
	jmp .quit
.print_help_msg:
	mov ecx, help_msg
	mov edx, 0x1a
	jmp .print
.print_file_error:
	mov ecx, file_error_msg
	mov edx, 0x14
.print:
	mov eax, write
	mov ebx, 0x2
	int 0x80
.quit:
	mov eax, exit
	xor ebx, ebx
	int 0x80
