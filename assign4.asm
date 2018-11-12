;Code modified/updated by Ryan Sowers
;Submitted: 03/11/2018
;CS3140 Assignment 4
;Assemble: 	nasm -f elf64 start.asm
;Assemble:	nasm -f elf64 assign4.asm
;Compile:	gcc -o assign4 -m64 main.c assign4.o start.o -nostdlib -nodefaultlibs -fno-builtin -nostartfiles
;Run:		./assign4 <optional file>


bits 64

global l_exit
global l_strlen
global l_write
global l_puts
global l_strcmp
global l_gets
global l_open
global l_close
global l_atoi
global l_itoa
global l_rand

section .text			;section declaration 

l_exit: 
	mov rax, 60			;exit syscall number
	syscall


l_strlen:
	xor r9, r9
.start:
	mov r8, rdi			;move str pointer to r8
	cmp [r8], byte 0	;compare contents to null term
	je .return			;if equal jump to return
	inc r9				;increment length counter
	inc rdi				;move to next index
	jmp .start			;keep counting

.return:
	mov rax, r9			;return value
	ret


l_write:
	mov rax, 1			;write system call number
	syscall
	cmp rax, rdx
	jne .error
	ret
.error:
	mov rax, -1
	ret


l_puts:
	push r12
	mov r12, rdi		;save message pointer
	call l_strlen
	mov rdx, rax		;move length of string to rdx
	mov rsi, r12		;move message pointer to rsi
	mov rdi, 1			;output to stdout
	mov rax, 1			;write system call number
	syscall	
	pop r12
	ret


l_strcmp:
	mov r8, rdi			;save pointer to str1
	mov r9, rsi			;save pointer to str2
	mov r10b, byte [r8]	;move character at r8 to r10
	mov r11b, byte [r9]	;move character at r9 to r11
	cmp r10b, r11b		;compare chars
	jne .not_eq			;jump if strings not equal
	cmp r10b, byte 0	;compare contents to null term
	je .eq				;jump, strings equal
	inc rdi				;index to next char
	inc rsi				;index to next char
	jmp l_strcmp
.not_eq:
	mov rax, 1			;return 1 if not equal
	ret
.eq:
	mov rax, 0			;return 0 if equal
	ret


l_gets:
	xor r9, r9
	mov r10, rdx		;save length to r10
.start:
	cmp r9, r10			;compare length to bytes read
	je .done			;if equal, done
	mov rdx, 1			;read size 1 byte
	mov rax, 0			;read syscall
	syscall
	cmp rax, 1			;check for good read
	jne .done			;if not, done
	inc r9				;read bytes counter
	mov r8b, [rsi]	;get value read
	cmp r8b, 10			;compare value read to new line
	je .done			;if it is, done
	inc rsi				;increment pointer
	jmp .start			;do it again

.done:
	inc rsi
	mov [rsi], byte 0	;append a null
	mov rax, r9
	ret


l_open:
	mov rax, 2			;open syscall
	syscall
	test rax, rax
	jle .error
	ret
.error:	
	mov rax, -1
	ret


l_close:
	mov rax, 3			;close syscall
	syscall
	test rax, rax
	jle .error
	ret
.error:	
	mov rax, -1
	ret


l_atoi:
	xor r8, r8	;result
.start:
	movzx r9, byte [rdi]	;move value at rdi to r9
	cmp r9, 48				;compare to value of '0'
	jl .done				;not a digit, done
	cmp r9, 57				;compare to value of '9'
	jg .done				;not a digit, done
	mov rax, 10				;move multiplier to rax
	mul r8					;multiply by current result
	mov r10, r9				;move value into r10
	sub r10, 48				;substract '0'
	add rax, r10 			;add value to rax
	mov r8, rax				;move result back to r8
	inc rdi					;increment pointer
	jmp .start				;repeat
.done:
	mov rax, r8
	ret


l_itoa:
	push r12
	xor r9, r9		;pushed digits counter
	mov rax, rdi	;move number into rax
	mov r12, rsi	;mov buffer pointer to r12
.multiply:
	xor rdx, rdx
	mov r8, 10		;divisor
	div r8			;divide number by 10
	add rdx, 48		;add 48 for ascii
	push rdx		;push remainder
	inc r9			;inc pushed digits counter
	cmp rax, 0		;if quotient 0, done
	je .out_buf		;done
	jmp .multiply	;continue dividing
.out_buf:
	pop r11			;pop digit to reg
	mov [r12], r11	;mov digit to buffer
	dec r9			;dec digits counter
	inc r12			;inc r12 for null terminator
	cmp r9, 0		;check if all digits popped
	je .done
	jmp .out_buf
.done:
	mov [r12], byte 0	;move null term to end of buffer
	mov rax, rsi
	pop r12
	ret


l_rand:
	push r12
	mov r12, rdi		;save n
	mov rdi, filepath	;move address of string to rdi
	mov rsi, 0			;move 0 for l_open flags
	mov rdx, 0			;move 0 for l_open mode
	call l_open
	mov r8, rax			;move fd into r8
	
	mov rdi, rax		;move return value to rdi for l_gets
	mov rsi, randbuf	;move address of buffer as second arg
	mov rdx, 4			;get 4 bytes
	call l_gets
	
	mov rdi, r8			;move fd into rdi
	call l_close		;close fd

	mov rax, [randbuf]	;move 4 byte value to rax
	div r12				;divide
	
	mov rax, rdx		;modulus is return value
	pop r12
	ret
		

section .bss
randbuf: resb 4

section .rodata
filepath: db '/dev/urandom',0











