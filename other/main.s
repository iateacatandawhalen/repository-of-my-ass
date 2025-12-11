
%define SYSCALL_EXIT 60

BITS 64
CPU X64

section .text
global _start

_start:
	mov rax, SYSCALL_EXIT
	mov rdi, 0
	
	syscall		
