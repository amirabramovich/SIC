section .data
input:
        db "%ld",32, 0
fs_malloc_failed:
	db "A call to malloc() failed", 10, 0
fs_done:
	db 10, 0

section .bss

number: resq 1
array: resq 1
length: resq 1

extern printf, scanf, calloc, free

global main

section .text

main:
	enter 0, 0
	mov r15, 0
	mov rdi, input
	mov rsi, number
	mov rax, 0
	call scanf
	
.input_loop:
        push qword[number]
	inc r15
	mov rdi, input
	mov rsi, number
	mov rax, 0
	call scanf
        cmp rax, 1
        je .input_loop 
	
	mov qword [length], r15
        mov rdi, r15
	mov rsi, 8
	call calloc
	cmp rax, 0
	je .malloc_failed
	mov qword [array], rax
	mov r10, rax ;r10 contains the first index of the array
	
	mov r14, 8
	mov rax, r15
	dec rax
	mul r14
	add r10, rax ;r10 contains the last index of the array
	
.array_loop:
        pop r14
        mov [r10], r14
        sub r10, 8
        dec r15
        cmp r15, 0
        jne .array_loop 
        
        mov r15, qword [array] ;r15 contains the first index of the array
        mov r10, [r15];r10=m[i]
        add r15, 8 ;r15 contains the second index of the array
        mov r11, [r15];r11=m[i+1]
        add r15, 8 ;r15 contains the third index of the array
        mov r12, [r15];r12=m[i+2]
        sub r15, 16
        
.while_loop: 
        mov r14, r10 ;r14=m[i]
        add r14, r11 ;r14=m[i]+m[i+1]
        add r14, r12 ;r14=m[i]+m[i+1]+m[i+2]
        cmp r14, 0
        je .finish
        mov r14, qword [array]
        lea r8, [r14 + 8 * r10] ;r8=M[i]
        mov r13, r8 ;r13=M[i]
        mov r8, [r8] ;r8=M[M[i]]
        lea r9, [r14 + 8 * r11] ;r9=M[i+1]
        mov r9, [r9] ;r9=M[M[i+1]]
        sub r8, r9 
        mov [r13], r8
        cmp r8, 0
        jl .lets_jump
        add r15, 24 ;r15 contains the first index of the array
        mov r10, [r15];r10=m[i]
        add r15, 8 ;r15 contains the second index of the array
        mov r11, [r15];r11=m[i+1]
        add r15, 8 ;r15 contains the third index of the array
        mov r12, [r15];r12=m[i+2]
        sub r15, 16
        jmp .while_loop
	
.lets_jump:
        mov r14, qword [array]
	lea r15, [r14 + 8 * r12] ;r15=m[i+2]
	mov r10, [r15];r10=m[i]
        add r15, 8 ;r15 contains the second index of the array
        mov r11, [r15];r11=m[i+1]
        add r15, 8 ;r15 contains the third index of the array
        mov r12, [r15];r12=m[i+2]
        sub r15, 16
        jmp .while_loop
	
.finish:	
	mov r14, qword [length] ;r14 is the length
	mov r15, qword [array] ;r15 contains the first index of the array
.print_loop:
	mov rdi, input
	mov rsi, [r15]
	mov rax, 0
	call printf
	add r15, 8
	dec r14
	cmp r14, 0
	jne .print_loop
	
	mov rdi, fs_done
	mov rax, 0
	call printf
	
        mov rdi, qword [array]
	call free
	jmp .end
	
.malloc_failed:
	mov rdi, fs_malloc_failed
	mov rax, 0
	call printf
	jmp .end

.end:
	leave
	ret	