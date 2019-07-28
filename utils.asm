%define lseek 0x13
section .text
global memset
global cycle_len
global four_pow
global flen
;void memset(void *mem, unsigned char b, size_t count);
memset:
	push ebp
	mov ebp, esp
	push esi
	mov esi, [ebp+0x8]
.loop:
	cmp dword [ebp+0x10], 0x0
	je .quit
	mov al, [ebp+0xc]
	mov [esi], al
	inc esi
	dec dword [ebp+0x10]
	jmp .loop
.quit:
	pop esi
	mov esp, ebp
	pop ebp
	ret
;int cycle_len(char *buf, int len)
cycle_len:
	push ebp
	mov ebp, esp
	push ebx
	push ecx
	push edi
	mov eax, -0x1
	xor ebx, ebx
	xor ecx, ecx
	mov edi, [ebp+0x8]
.loop:
	cmp ecx, [ebp+0xc]
	je .quit
	cmp byte [edi], 0x5b ;compare with [
	je .lb
	cmp byte [edi], 0x5d ;compare with ]
	je .rb
	jmp .continue
.lb:
	inc ebx
	jmp .continue
.rb:
	dec ebx
	test ebx, ebx
	jge .continue
	mov eax, ecx
	jmp .quit
.continue:
	inc edi
	inc ecx
	jmp .loop
.quit:
	pop edi
	pop ecx
	pop ebx
	mov esp, ebp
	pop ebp
	ret
;int four_pow(int num)
four_pow:
	push ebp
	mov ebp, esp
	push ebx
	push edx

	xor edx, edx
	mov eax, [ebp+0x8]
	mov ebx, 0x4
	div ebx

	test edx, edx
	jne .quit
.not:
	inc eax
.quit:
	shl eax, 2
	pop edx
	pop ebx
	mov esp, ebp
	pop ebp
	ret
;int flen(int fd);
flen:
	push ebp
	mov ebp, esp
	sub esp, 0x4
	push ebx
	push ecx
	push edx

	mov eax, lseek
	mov ebx, [ebp+0x8]
	xor ecx, ecx
	mov edx, 0x2
	int 0x80
	mov [ebp-0x4], eax

	mov eax, lseek
	xor edx, edx
	int 0x80

	mov eax, [ebp-0x4]
	pop edx
	pop ecx
	pop ebx
	mov esp, ebp
	pop ebp
	ret
