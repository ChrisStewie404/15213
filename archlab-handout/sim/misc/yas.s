	.file	"yas.c"
	.text
	.type	hexstuff, @function
hexstuff:
.LFB56:
	.cfi_startproc
	movl	$0, %r8d
	jmp	.L2
.L3:
	addl	$87, %eax
.L4:
	movl	%edx, %ecx
	subl	%r8d, %ecx
	movslq	%ecx, %rcx
	movb	%al, -1(%rdi,%rcx)
	addl	$1, %r8d
.L2:
	cmpl	%edx, %r8d
	jge	.L6
	leal	0(,%r8,4), %ecx
	movq	%rsi, %rax
	sarq	%cl, %rax
	andl	$15, %eax
	cmpl	$9, %eax
	jg	.L3
	addl	$48, %eax
	jmp	.L4
.L6:
	ret
	.cfi_endproc
.LFE56:
	.size	hexstuff, .-hexstuff
	.section	.rodata.str1.1,"aMS",@progbits,1
.LC0:
	.string	"Usage: %s [-V[n]] file.ys\n"
	.section	.rodata.str1.8,"aMS",@progbits,1
	.align 8
.LC1:
	.string	"   -V[n]  Generate memory initialization in Verilog format (n-way blocking)"
	.text
	.type	usage, @function
usage:
.LFB73:
	.cfi_startproc
	pushq	%rax
	.cfi_def_cfa_offset 16
	popq	%rax
	.cfi_def_cfa_offset 8
	subq	$8, %rsp
	.cfi_def_cfa_offset 16
	movq	%rdi, %rdx
	leaq	.LC0(%rip), %rsi
	movl	$2, %edi
	movl	$0, %eax
	call	__printf_chk@PLT
	leaq	.LC1(%rip), %rdi
	call	puts@PLT
	movl	$0, %edi
	call	exit@PLT
	.cfi_endproc
.LFE73:
	.size	usage, .-usage
	.section	.rodata.str1.1
.LC2:
	.string	"Error on line %d: %s\n"
.LC3:
	.string	"Line %d, Byte 0x%.4x: %s\n"
	.text
	.globl	fail
	.type	fail, @function
fail:
.LFB58:
	.cfi_startproc
	endbr64
	subq	$8, %rsp
	.cfi_def_cfa_offset 16
	cmpl	$0, error_mode(%rip)
	je	.L12
.L10:
	movl	$1, error_mode(%rip)
	movl	$1, hit_error(%rip)
	addq	$8, %rsp
	.cfi_remember_state
	.cfi_def_cfa_offset 8
	ret
.L12:
	.cfi_restore_state
	movq	%rdi, %r8
	movl	lineno(%rip), %ecx
	leaq	.LC2(%rip), %rdx
	movl	$2, %esi
	movq	stderr(%rip), %rdi
	movl	$0, %eax
	call	__fprintf_chk@PLT
	leaq	input_line(%rip), %r9
	movl	bytepos(%rip), %r8d
	movl	lineno(%rip), %ecx
	leaq	.LC3(%rip), %rdx
	movl	$2, %esi
	movq	stderr(%rip), %rdi
	movl	$0, %eax
	call	__fprintf_chk@PLT
	jmp	.L10
	.cfi_endproc
.LFE58:
	.size	fail, .-fail
	.section	.rodata.str1.1
.LC4:
	.string	"Input Line too long"
	.text
	.globl	save_line
	.type	save_line, @function
save_line:
.LFB53:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	pushq	%rbx
	.cfi_def_cfa_offset 24
	.cfi_offset 3, -24
	subq	$8, %rsp
	.cfi_def_cfa_offset 32
	movq	%rdi, %rbp
	call	strlen@PLT
	movq	%rax, %rbx
	cmpl	$4095, %eax
	jg	.L18
.L14:
	movl	$4096, %edx
	movq	%rbp, %rsi
	leaq	input_line(%rip), %rdi
	call	__strcpy_chk@PLT
	leal	-1(%rbx), %eax
	jmp	.L15
.L18:
	leaq	.LC4(%rip), %rdi
	call	fail
	jmp	.L14
.L16:
	movslq	%eax, %rdx
	leaq	input_line(%rip), %rcx
	movb	$0, (%rcx,%rdx)
	subl	$1, %eax
.L15:
	movslq	%eax, %rdx
	leaq	input_line(%rip), %rcx
	movzbl	(%rcx,%rdx), %edx
	cmpb	$10, %dl
	je	.L16
	cmpb	$13, %dl
	je	.L16
	addq	$8, %rsp
	.cfi_def_cfa_offset 24
	popq	%rbx
	.cfi_def_cfa_offset 16
	popq	%rbp
	.cfi_def_cfa_offset 8
	ret
	.cfi_endproc
.LFE53:
	.size	save_line, .-save_line
	.section	.rodata.str1.1
.LC5:
	.string	" [%c "
.LC6:
	.string	"%s]"
.LC7:
	.string	"%lld]"
.LC8:
	.string	"%c]"
.LC9:
	.string	"ERR]"
.LC10:
	.string	"?]"
.LC11:
	.string	"Unknown token type"
	.text
	.globl	print_token
	.type	print_token, @function
print_token:
.LFB54:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	pushq	%rbx
	.cfi_def_cfa_offset 24
	.cfi_offset 3, -24
	subq	$8, %rsp
	.cfi_def_cfa_offset 32
	movq	%rdi, %rbp
	movq	%rsi, %rbx
	movl	20(%rsi), %eax
	leaq	token_type_names(%rip), %rdx
	movsbl	(%rdx,%rax), %ecx
	leaq	.LC5(%rip), %rdx
	movl	$2, %esi
	movl	$0, %eax
	call	__fprintf_chk@PLT
	movl	20(%rbx), %eax
	cmpl	$5, %eax
	ja	.L20
	movl	%eax, %eax
	leaq	.L22(%rip), %rdx
	movslq	(%rdx,%rax,4), %rax
	addq	%rdx, %rax
	notrack jmp	*%rax
	.section	.rodata
	.align 4
	.align 4
.L22:
	.long	.L24-.L22
	.long	.L25-.L22
	.long	.L24-.L22
	.long	.L24-.L22
	.long	.L23-.L22
	.long	.L21-.L22
	.text
.L24:
	movq	(%rbx), %rcx
	leaq	.LC6(%rip), %rdx
	movl	$2, %esi
	movq	%rbp, %rdi
	movl	$0, %eax
	call	__fprintf_chk@PLT
.L19:
	addq	$8, %rsp
	.cfi_remember_state
	.cfi_def_cfa_offset 24
	popq	%rbx
	.cfi_def_cfa_offset 16
	popq	%rbp
	.cfi_def_cfa_offset 8
	ret
.L25:
	.cfi_restore_state
	movq	8(%rbx), %rcx
	leaq	.LC7(%rip), %rdx
	movl	$2, %esi
	movq	%rbp, %rdi
	movl	$0, %eax
	call	__fprintf_chk@PLT
	jmp	.L19
.L23:
	movsbl	16(%rbx), %ecx
	leaq	.LC8(%rip), %rdx
	movl	$2, %esi
	movq	%rbp, %rdi
	movl	$0, %eax
	call	__fprintf_chk@PLT
	jmp	.L19
.L21:
	movq	%rbp, %rcx
	movl	$4, %edx
	movl	$1, %esi
	leaq	.LC9(%rip), %rdi
	call	fwrite@PLT
	jmp	.L19
.L20:
	movq	%rbp, %rcx
	movl	$2, %edx
	movl	$1, %esi
	leaq	.LC10(%rip), %rdi
	call	fwrite@PLT
	leaq	.LC11(%rip), %rdi
	call	fail
	jmp	.L19
	.cfi_endproc
.LFE54:
	.size	print_token, .-print_token
	.section	.rodata.str1.1
.LC12:
	.string	"Line %d, Byte %d: "
.LC13:
	.string	" Code: "
.LC14:
	.string	"%.2x "
	.text
	.globl	print_instruction
	.type	print_instruction, @function
print_instruction:
.LFB55:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	pushq	%rbx
	.cfi_def_cfa_offset 24
	.cfi_offset 3, -24
	subq	$8, %rsp
	.cfi_def_cfa_offset 32
	movq	%rdi, %rbp
	movl	bytepos(%rip), %r8d
	movl	lineno(%rip), %ecx
	leaq	.LC12(%rip), %rdx
	movl	$2, %esi
	movl	$0, %eax
	call	__fprintf_chk@PLT
	movl	$0, %ebx
	jmp	.L29
.L30:
	movslq	%ebx, %rax
	leaq	(%rax,%rax,2), %rdx
	leaq	tokens(%rip), %rax
	leaq	(%rax,%rdx,8), %rsi
	movq	%rbp, %rdi
	call	print_token
	addl	$1, %ebx
.L29:
	cmpl	%ebx, tcount(%rip)
	jg	.L30
	movq	%rbp, %rcx
	movl	$7, %edx
	movl	$1, %esi
	leaq	.LC13(%rip), %rdi
	call	fwrite@PLT
	movl	$0, %ebx
	jmp	.L31
.L32:
	movslq	%ebx, %rax
	leaq	code(%rip), %rdx
	movzbl	(%rdx,%rax), %ecx
	leaq	.LC14(%rip), %rdx
	movl	$2, %esi
	movq	%rbp, %rdi
	movl	$0, %eax
	call	__fprintf_chk@PLT
	addl	$1, %ebx
.L31:
	cmpl	%ebx, bcount(%rip)
	jg	.L32
	movq	%rbp, %rsi
	movl	$10, %edi
	call	fputc@PLT
	addq	$8, %rsp
	.cfi_def_cfa_offset 24
	popq	%rbx
	.cfi_def_cfa_offset 16
	popq	%rbp
	.cfi_def_cfa_offset 8
	ret
	.cfi_endproc
.LFE55:
	.size	print_instruction, .-print_instruction
	.section	.rodata.str1.1
.LC15:
	.string	"Code address limit exceeded"
.LC16:
	.string	"//%s%s\n"
.LC17:
	.string	"    bank%d[%d] = 8'h%.2x;\n"
.LC18:
	.string	"    mem[%d] = 8'h%.2x;\n"
.LC19:
	.string	"%s%s\n"
	.text
	.globl	print_code
	.type	print_code, @function
print_code:
.LFB57:
	.cfi_startproc
	endbr64
	pushq	%r12
	.cfi_def_cfa_offset 16
	.cfi_offset 12, -16
	pushq	%rbp
	.cfi_def_cfa_offset 24
	.cfi_offset 6, -24
	pushq	%rbx
	.cfi_def_cfa_offset 32
	.cfi_offset 3, -32
	subq	$48, %rsp
	.cfi_def_cfa_offset 80
	movq	%rdi, %r12
	movl	%esi, %ebp
	movq	%fs:40, %rax
	movq	%rax, 40(%rsp)
	xorl	%eax, %eax
	cmpl	$4095, %esi
	jle	.L35
	cmpl	$0, tcount(%rip)
	je	.L36
	cmpl	$65535, %esi
	jg	.L53
	movabsq	$2322221541387958320, %rax
	movabsq	$2314885530818453536, %rdx
	movq	%rax, (%rsp)
	movq	%rdx, 8(%rsp)
	movabsq	$2314885530818453536, %rax
	movabsq	$9143676674514976, %rdx
	movq	%rax, 16(%rsp)
	movq	%rdx, 24(%rsp)
	movslq	%esi, %rsi
	leaq	2(%rsp), %rdi
	movl	$4, %edx
	call	hexstuff
	movl	$0, %ebx
	jmp	.L38
.L53:
	leaq	.LC15(%rip), %rdi
	call	fail
	movl	$1, %edi
	call	exit@PLT
.L39:
	movslq	%ebx, %rdx
	leal	(%rbx,%rbx), %eax
	cltq
	leaq	code(%rip), %rcx
	movzbl	(%rcx,%rdx), %esi
	leaq	7(%rsp,%rax), %rdi
	movl	$2, %edx
	call	hexstuff
	addl	$1, %ebx
.L38:
	cmpl	%ebx, bcount(%rip)
	jg	.L39
.L40:
	cmpl	$0, vcode(%rip)
	je	.L44
	movq	%rsp, %rcx
	leaq	input_line(%rip), %r8
	leaq	.LC16(%rip), %rdx
	movl	$2, %esi
	movq	%r12, %rdi
	movl	$0, %eax
	call	__fprintf_chk@PLT
	cmpl	$0, tcount(%rip)
	je	.L34
	movl	$0, %ebx
	jmp	.L45
.L36:
	movabsq	$2314885530818453536, %rax
	movabsq	$2314885530818453536, %rdx
	movq	%rax, (%rsp)
	movq	%rdx, 8(%rsp)
	movabsq	$2314885530818453536, %rax
	movabsq	$9143676674514976, %rdx
	movq	%rax, 16(%rsp)
	movq	%rdx, 24(%rsp)
	jmp	.L40
.L35:
	cmpl	$0, tcount(%rip)
	je	.L41
	movabsq	$2314914187109759024, %rax
	movabsq	$2314885530818453536, %rdx
	movq	%rax, (%rsp)
	movq	%rdx, 8(%rsp)
	movabsq	$2314885530818453536, %rax
	movabsq	$9143676674514976, %rdx
	movq	%rax, 15(%rsp)
	movq	%rdx, 23(%rsp)
	movslq	%esi, %rsi
	leaq	2(%rsp), %rdi
	movl	$3, %edx
	call	hexstuff
	movl	$0, %ebx
	jmp	.L42
.L43:
	movslq	%ebx, %rdx
	leal	(%rbx,%rbx), %eax
	cltq
	leaq	code(%rip), %rcx
	movzbl	(%rcx,%rdx), %esi
	leaq	7(%rsp,%rax), %rdi
	movl	$2, %edx
	call	hexstuff
	addl	$1, %ebx
.L42:
	cmpl	%ebx, bcount(%rip)
	jg	.L43
	jmp	.L40
.L41:
	movabsq	$2314885530818453536, %rax
	movabsq	$2314885530818453536, %rdx
	movq	%rax, (%rsp)
	movq	%rdx, 8(%rsp)
	movabsq	$2314885530818453536, %rax
	movabsq	$9143676674514976, %rdx
	movq	%rax, 15(%rsp)
	movq	%rdx, 23(%rsp)
	jmp	.L40
.L47:
	movslq	%ebx, %rax
	leal	(%rbx,%rbp), %ecx
	leaq	code(%rip), %rdx
	movzbl	(%rdx,%rax), %r8d
	leaq	.LC18(%rip), %rdx
	movl	$2, %esi
	movq	%r12, %rdi
	movl	$0, %eax
	call	__fprintf_chk@PLT
.L48:
	addl	$1, %ebx
.L45:
	cmpl	$0, tcount(%rip)
	je	.L34
	cmpl	%ebx, bcount(%rip)
	jle	.L34
	movl	block_factor(%rip), %esi
	testl	%esi, %esi
	je	.L47
	movslq	%ebx, %rdi
	leal	(%rbx,%rbp), %eax
	cltd
	idivl	%esi
	movl	%edx, %ecx
	leaq	code(%rip), %rdx
	movzbl	(%rdx,%rdi), %r9d
	movl	%eax, %r8d
	leaq	.LC17(%rip), %rdx
	movl	$2, %esi
	movq	%r12, %rdi
	movl	$0, %eax
	call	__fprintf_chk@PLT
	jmp	.L48
.L44:
	movq	%rsp, %rcx
	leaq	input_line(%rip), %r8
	leaq	.LC19(%rip), %rdx
	movl	$2, %esi
	movq	%r12, %rdi
	movl	$0, %eax
	call	__fprintf_chk@PLT
.L34:
	movq	40(%rsp), %rax
	subq	%fs:40, %rax
	jne	.L54
	addq	$48, %rsp
	.cfi_remember_state
	.cfi_def_cfa_offset 32
	popq	%rbx
	.cfi_def_cfa_offset 24
	popq	%rbp
	.cfi_def_cfa_offset 16
	popq	%r12
	.cfi_def_cfa_offset 8
	ret
.L54:
	.cfi_restore_state
	call	__stack_chk_fail@PLT
	.cfi_endproc
.LFE57:
	.size	print_code, .-print_code
	.section	.rodata.str1.1
.LC20:
	.string	"Expecting Register ID"
	.text
	.globl	get_reg
	.type	get_reg, @function
get_reg:
.LFB59:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	pushq	%rbx
	.cfi_def_cfa_offset 24
	.cfi_offset 3, -24
	subq	$8, %rsp
	.cfi_def_cfa_offset 32
	movl	tpos(%rip), %eax
	movslq	%eax, %rdx
	leaq	(%rdx,%rdx,2), %rcx
	leaq	tokens(%rip), %rdx
	cmpl	$2, 20(%rdx,%rcx,8)
	je	.L56
	leaq	.LC20(%rip), %rdi
	call	fail
.L55:
	addq	$8, %rsp
	.cfi_remember_state
	.cfi_def_cfa_offset 24
	popq	%rbx
	.cfi_def_cfa_offset 16
	popq	%rbp
	.cfi_def_cfa_offset 8
	ret
.L56:
	.cfi_restore_state
	movl	%edi, %ebx
	movl	%esi, %ebp
	cltq
	leaq	(%rax,%rax,2), %rdx
	leaq	tokens(%rip), %rax
	movq	(%rax,%rdx,8), %rdi
	call	find_register@PLT
	movl	%eax, %edx
	movslq	%ebx, %rax
	leaq	code(%rip), %rcx
	movzbl	(%rcx,%rax), %eax
	testl	%ebp, %ebp
	je	.L58
	andl	$15, %eax
	sall	$4, %edx
	orl	%edx, %eax
.L59:
	movslq	%ebx, %rbx
	leaq	code(%rip), %rdx
	movb	%al, (%rdx,%rbx)
	addl	$1, tpos(%rip)
	jmp	.L55
.L58:
	andl	$-16, %eax
	orl	%edx, %eax
	jmp	.L59
	.cfi_endproc
.LFE59:
	.size	get_reg, .-get_reg
	.globl	start_line
	.type	start_line, @function
start_line:
.LFB62:
	.cfi_startproc
	endbr64
	movl	$0, error_mode(%rip)
	movl	$0, tpos(%rip)
	movl	$0, tcount(%rip)
	movl	$0, bcount(%rip)
	movl	$0, strpos(%rip)
	movl	$0, %eax
	jmp	.L62
.L63:
	movslq	%eax, %rdx
	leaq	(%rdx,%rdx,2), %rcx
	leaq	0(,%rcx,8), %rdx
	leaq	tokens(%rip), %rcx
	movl	$5, 20(%rcx,%rdx)
	addl	$1, %eax
.L62:
	cmpl	$11, %eax
	jle	.L63
	ret
	.cfi_endproc
.LFE62:
	.size	start_line, .-start_line
	.section	.rodata.str1.1
.LC21:
	.string	"Line too long"
	.text
	.globl	add_token
	.type	add_token, @function
add_token:
.LFB64:
	.cfi_startproc
	endbr64
	pushq	%r14
	.cfi_def_cfa_offset 16
	.cfi_offset 14, -16
	pushq	%r13
	.cfi_def_cfa_offset 24
	.cfi_offset 13, -24
	pushq	%r12
	.cfi_def_cfa_offset 32
	.cfi_offset 12, -32
	pushq	%rbp
	.cfi_def_cfa_offset 40
	.cfi_offset 6, -40
	pushq	%rbx
	.cfi_def_cfa_offset 48
	.cfi_offset 3, -48
	movl	%edi, %r13d
	movq	%rsi, %rbx
	movq	%rdx, %r12
	movl	%ecx, %ebp
	cmpl	$0, tcount(%rip)
	je	.L71
.L65:
	cmpl	$10, tpos(%rip)
	jg	.L72
	testq	%rbx, %rbx
	je	.L68
	movq	%rbx, %rdi
	call	strlen@PLT
	leal	1(%rax), %r14d
	movl	strpos(%rip), %eax
	leal	(%rax,%r14), %edx
	cmpl	$4096, %edx
	jg	.L73
	cltq
	leaq	strbuf(%rip), %rdi
	addq	%rax, %rdi
	movl	$4096, %edx
	cmpq	%rdx, %rax
	cmovnb	%rax, %rdx
	subq	%rax, %rdx
	movq	%rbx, %rsi
	call	__strcpy_chk@PLT
	movq	%rax, %rbx
	addl	%r14d, strpos(%rip)
.L68:
	movl	tcount(%rip), %ecx
	leaq	tokens(%rip), %rsi
	movslq	%ecx, %rdx
	leaq	(%rdx,%rdx), %rax
	leaq	(%rax,%rdx), %rdi
	movl	%r13d, 20(%rsi,%rdi,8)
	movq	%rbx, (%rsi,%rdi,8)
	movq	%r12, 8(%rsi,%rdi,8)
	movb	%bpl, 16(%rsi,%rdi,8)
	addl	$1, %ecx
	movl	%ecx, tcount(%rip)
.L64:
	popq	%rbx
	.cfi_remember_state
	.cfi_def_cfa_offset 40
	popq	%rbp
	.cfi_def_cfa_offset 32
	popq	%r12
	.cfi_def_cfa_offset 24
	popq	%r13
	.cfi_def_cfa_offset 16
	popq	%r14
	.cfi_def_cfa_offset 8
	ret
.L71:
	.cfi_restore_state
	movl	$0, %eax
	call	start_line
	jmp	.L65
.L72:
	leaq	.LC21(%rip), %rdi
	call	fail
	jmp	.L64
.L73:
	leaq	.LC21(%rip), %rdi
	call	fail
	jmp	.L64
	.cfi_endproc
.LFE64:
	.size	add_token, .-add_token
	.globl	add_ident
	.type	add_ident, @function
add_ident:
.LFB65:
	.cfi_startproc
	endbr64
	subq	$8, %rsp
	.cfi_def_cfa_offset 16
	movq	%rdi, %rsi
	movl	$32, %ecx
	movl	$0, %edx
	movl	$0, %edi
	call	add_token
	addq	$8, %rsp
	.cfi_def_cfa_offset 8
	ret
	.cfi_endproc
.LFE65:
	.size	add_ident, .-add_ident
	.globl	add_instr
	.type	add_instr, @function
add_instr:
.LFB66:
	.cfi_startproc
	endbr64
	subq	$8, %rsp
	.cfi_def_cfa_offset 16
	movq	%rdi, %rsi
	movl	$32, %ecx
	movl	$0, %edx
	movl	$3, %edi
	call	add_token
	addq	$8, %rsp
	.cfi_def_cfa_offset 8
	ret
	.cfi_endproc
.LFE66:
	.size	add_instr, .-add_instr
	.globl	add_reg
	.type	add_reg, @function
add_reg:
.LFB67:
	.cfi_startproc
	endbr64
	subq	$8, %rsp
	.cfi_def_cfa_offset 16
	movq	%rdi, %rsi
	movl	$32, %ecx
	movl	$0, %edx
	movl	$2, %edi
	call	add_token
	addq	$8, %rsp
	.cfi_def_cfa_offset 8
	ret
	.cfi_endproc
.LFE67:
	.size	add_reg, .-add_reg
	.globl	add_num
	.type	add_num, @function
add_num:
.LFB68:
	.cfi_startproc
	endbr64
	subq	$8, %rsp
	.cfi_def_cfa_offset 16
	movq	%rdi, %rdx
	movl	$32, %ecx
	movl	$0, %esi
	movl	$1, %edi
	call	add_token
	addq	$8, %rsp
	.cfi_def_cfa_offset 8
	ret
	.cfi_endproc
.LFE68:
	.size	add_num, .-add_num
	.globl	add_punct
	.type	add_punct, @function
add_punct:
.LFB69:
	.cfi_startproc
	endbr64
	subq	$8, %rsp
	.cfi_def_cfa_offset 16
	movsbl	%dil, %ecx
	movl	$0, %edx
	movl	$0, %esi
	movl	$4, %edi
	call	add_token
	addq	$8, %rsp
	.cfi_def_cfa_offset 8
	ret
	.cfi_endproc
.LFE69:
	.size	add_punct, .-add_punct
	.globl	add_symbol
	.type	add_symbol, @function
add_symbol:
.LFB70:
	.cfi_startproc
	endbr64
	pushq	%r13
	.cfi_def_cfa_offset 16
	.cfi_offset 13, -16
	pushq	%r12
	.cfi_def_cfa_offset 24
	.cfi_offset 12, -24
	pushq	%rbp
	.cfi_def_cfa_offset 32
	.cfi_offset 6, -32
	pushq	%rbx
	.cfi_def_cfa_offset 40
	.cfi_offset 3, -40
	subq	$8, %rsp
	.cfi_def_cfa_offset 48
	movq	%rdi, %rbp
	movl	%esi, %r12d
	call	strlen@PLT
	leaq	1(%rax), %r13
	movq	%r13, %rdi
	call	malloc@PLT
	movq	%rax, %rbx
	movq	%r13, %rdx
	movq	%rbp, %rsi
	movq	%rax, %rdi
	call	__strcpy_chk@PLT
	movl	symbol_cnt(%rip), %eax
	movslq	%eax, %rcx
	salq	$4, %rcx
	leaq	symbol_table(%rip), %rdx
	addq	%rcx, %rdx
	movq	%rbx, (%rdx)
	movl	%r12d, 8(%rdx)
	addl	$1, %eax
	movl	%eax, symbol_cnt(%rip)
	addq	$8, %rsp
	.cfi_def_cfa_offset 40
	popq	%rbx
	.cfi_def_cfa_offset 32
	popq	%rbp
	.cfi_def_cfa_offset 24
	popq	%r12
	.cfi_def_cfa_offset 16
	popq	%r13
	.cfi_def_cfa_offset 8
	ret
	.cfi_endproc
.LFE70:
	.size	add_symbol, .-add_symbol
	.section	.rodata.str1.1
.LC22:
	.string	"Can't find label"
	.text
	.globl	find_symbol
	.type	find_symbol, @function
find_symbol:
.LFB71:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	pushq	%rbx
	.cfi_def_cfa_offset 24
	.cfi_offset 3, -24
	subq	$8, %rsp
	.cfi_def_cfa_offset 32
	movq	%rdi, %rbp
	movl	$0, %ebx
	jmp	.L87
.L88:
	addl	$1, %ebx
.L87:
	cmpl	%ebx, symbol_cnt(%rip)
	jle	.L92
	movslq	%ebx, %rax
	salq	$4, %rax
	leaq	symbol_table(%rip), %rdx
	movq	(%rdx,%rax), %rsi
	movq	%rbp, %rdi
	call	strcmp@PLT
	testl	%eax, %eax
	jne	.L88
	movslq	%ebx, %rbx
	salq	$4, %rbx
	leaq	symbol_table(%rip), %rax
	movl	8(%rax,%rbx), %eax
	jmp	.L86
.L92:
	leaq	.LC22(%rip), %rdi
	call	fail
	movl	$-1, %eax
.L86:
	addq	$8, %rsp
	.cfi_def_cfa_offset 24
	popq	%rbx
	.cfi_def_cfa_offset 16
	popq	%rbp
	.cfi_def_cfa_offset 8
	ret
	.cfi_endproc
.LFE71:
	.size	find_symbol, .-find_symbol
	.section	.rodata.str1.1
.LC23:
	.string	"Number Expected"
	.text
	.globl	get_num
	.type	get_num, @function
get_num:
.LFB60:
	.cfi_startproc
	endbr64
	pushq	%r12
	.cfi_def_cfa_offset 16
	.cfi_offset 12, -16
	pushq	%rbp
	.cfi_def_cfa_offset 24
	.cfi_offset 6, -24
	pushq	%rbx
	.cfi_def_cfa_offset 32
	.cfi_offset 3, -32
	movl	%edi, %ebp
	movl	%esi, %ebx
	movl	%edx, %r12d
	movl	tpos(%rip), %eax
	movslq	%eax, %rdx
	leaq	(%rdx,%rdx,2), %rcx
	leaq	tokens(%rip), %rdx
	movl	20(%rdx,%rcx,8), %edx
	cmpl	$1, %edx
	je	.L101
	testl	%edx, %edx
	jne	.L96
	cltq
	leaq	(%rax,%rax,2), %rdx
	leaq	tokens(%rip), %rax
	movq	(%rax,%rdx,8), %rdi
	call	find_symbol
	cltq
.L95:
	movslq	%r12d, %r12
	subq	%r12, %rax
	movl	$0, %edx
	jmp	.L98
.L101:
	leaq	tokens(%rip), %rax
	movq	8(%rax,%rcx,8), %rax
	jmp	.L95
.L96:
	leaq	.LC23(%rip), %rdi
	call	fail
	jmp	.L93
.L99:
	leal	0(,%rdx,8), %ecx
	movq	%rax, %rdi
	sarq	%cl, %rdi
	leal	(%rdx,%rbp), %ecx
	movslq	%ecx, %rcx
	leaq	code(%rip), %rsi
	movb	%dil, (%rsi,%rcx)
	addl	$1, %edx
.L98:
	cmpl	%ebx, %edx
	jl	.L99
	addl	$1, tpos(%rip)
.L93:
	popq	%rbx
	.cfi_def_cfa_offset 24
	popq	%rbp
	.cfi_def_cfa_offset 16
	popq	%r12
	.cfi_def_cfa_offset 8
	ret
	.cfi_endproc
.LFE60:
	.size	get_num, .-get_num
	.section	.rodata.str1.1
.LC24:
	.string	"Expecting Register Id"
.LC25:
	.string	"Expecting ')'"
	.text
	.globl	get_mem
	.type	get_mem, @function
get_mem:
.LFB61:
	.cfi_startproc
	endbr64
	pushq	%r12
	.cfi_def_cfa_offset 16
	.cfi_offset 12, -16
	pushq	%rbp
	.cfi_def_cfa_offset 24
	.cfi_offset 6, -24
	pushq	%rbx
	.cfi_def_cfa_offset 32
	.cfi_offset 3, -32
	movl	%edi, %ebp
	movl	tpos(%rip), %eax
	movslq	%eax, %rdx
	leaq	(%rdx,%rdx,2), %rcx
	leaq	tokens(%rip), %rdx
	movl	20(%rdx,%rcx,8), %edx
	cmpl	$1, %edx
	je	.L117
	testl	%edx, %edx
	je	.L118
	movl	$0, %ebx
.L104:
	cmpl	$4, %edx
	je	.L119
	movl	$15, %edx
.L105:
	leaq	code(%rip), %rsi
	movslq	%ebp, %rcx
	movzbl	(%rsi,%rcx), %eax
	andl	$-16, %eax
	andl	$15, %edx
	orl	%edx, %eax
	leal	1(%rbp), %edi
	movb	%al, (%rsi,%rcx)
	movl	$0, %eax
	jmp	.L110
.L117:
	leal	1(%rax), %edx
	movl	%edx, tpos(%rip)
	leaq	tokens(%rip), %rcx
	cltq
	leaq	(%rax,%rax,2), %rax
	movq	8(%rcx,%rax,8), %rbx
	movslq	%edx, %rax
	leaq	(%rax,%rax,2), %rax
	movl	20(%rcx,%rax,8), %edx
	jmp	.L104
.L118:
	leal	1(%rax), %edx
	movl	%edx, tpos(%rip)
	leaq	tokens(%rip), %r12
	cltq
	leaq	(%rax,%rax,2), %rax
	movq	(%r12,%rax,8), %rdi
	call	find_symbol
	movslq	%eax, %rbx
	movslq	tpos(%rip), %rax
	leaq	(%rax,%rax,2), %rax
	movl	20(%r12,%rax,8), %edx
	jmp	.L104
.L119:
	movl	tpos(%rip), %edx
	movslq	%edx, %rax
	leaq	(%rax,%rax,2), %rcx
	leaq	tokens(%rip), %rax
	cmpb	$40, 16(%rax,%rcx,8)
	je	.L120
	movl	$15, %edx
	jmp	.L105
.L120:
	leal	1(%rdx), %eax
	movl	%eax, tpos(%rip)
	movslq	%eax, %rcx
	leaq	(%rcx,%rcx,2), %rsi
	leaq	tokens(%rip), %rcx
	cmpl	$2, 20(%rcx,%rsi,8)
	jne	.L106
	addl	$2, %edx
	movl	%edx, tpos(%rip)
	movq	%rcx, %r12
	movq	(%rcx,%rsi,8), %rdi
	call	find_register@PLT
	movl	%eax, %edx
	movl	tpos(%rip), %eax
	movslq	%eax, %rcx
	leaq	(%rcx,%rcx,2), %rcx
	cmpl	$4, 20(%r12,%rcx,8)
	jne	.L107
	leal	1(%rax), %ecx
	movl	%ecx, tpos(%rip)
	cltq
	leaq	(%rax,%rax,2), %rcx
	leaq	tokens(%rip), %rax
	cmpb	$41, 16(%rax,%rcx,8)
	je	.L105
.L107:
	leaq	.LC25(%rip), %rdi
	call	fail
	jmp	.L102
.L106:
	leaq	.LC24(%rip), %rdi
	call	fail
	jmp	.L102
.L111:
	leal	0(,%rax,8), %ecx
	movq	%rbx, %rsi
	sarq	%cl, %rsi
	leal	(%rax,%rdi), %edx
	movslq	%edx, %rdx
	leaq	code(%rip), %rcx
	movb	%sil, (%rcx,%rdx)
	addl	$1, %eax
.L110:
	cmpl	$7, %eax
	jle	.L111
.L102:
	popq	%rbx
	.cfi_def_cfa_offset 24
	popq	%rbp
	.cfi_def_cfa_offset 16
	popq	%r12
	.cfi_def_cfa_offset 8
	ret
	.cfi_endproc
.LFE61:
	.size	get_mem, .-get_mem
	.section	.rodata.str1.1
.LC26:
	.string	"Missing Colon"
.LC27:
	.string	"Bad Instruction"
.LC28:
	.string	".pos"
.LC29:
	.string	"Invalid Address"
.LC30:
	.string	".align"
.LC31:
	.string	"Invalid Alignment"
.LC32:
	.string	"Invalid Instruction"
.LC33:
	.string	"Expecting Comma"
	.text
	.globl	finish_line
	.type	finish_line, @function
finish_line:
.LFB63:
	.cfi_startproc
	endbr64
	pushq	%r12
	.cfi_def_cfa_offset 16
	.cfi_offset 12, -16
	pushq	%rbp
	.cfi_def_cfa_offset 24
	.cfi_offset 6, -24
	pushq	%rbx
	.cfi_def_cfa_offset 32
	.cfi_offset 3, -32
	movl	bytepos(%rip), %ebp
	movl	$0, tpos(%rip)
	movl	$0, codepos(%rip)
	cmpl	$0, tcount(%rip)
	je	.L149
	cmpl	$0, error_mode(%rip)
	jne	.L150
	cmpl	$0, 20+tokens(%rip)
	jne	.L126
	movabsq	$-4294967041, %rax
	andq	40+tokens(%rip), %rax
	movabsq	$17179869242, %rdx
	cmpq	%rdx, %rax
	jne	.L151
	cmpl	$1, pass(%rip)
	je	.L152
.L128:
	addl	$2, tpos(%rip)
	cmpl	$2, tcount(%rip)
	je	.L153
.L126:
	movl	tpos(%rip), %ebx
	movslq	%ebx, %rax
	leaq	(%rax,%rax,2), %rdx
	leaq	tokens(%rip), %rax
	cmpl	$3, 20(%rax,%rdx,8)
	jne	.L154
	movslq	%ebx, %rax
	leaq	(%rax,%rax,2), %rdx
	leaq	tokens(%rip), %rax
	movq	(%rax,%rdx,8), %r12
	leaq	.LC28(%rip), %rsi
	movq	%r12, %rdi
	call	strcmp@PLT
	testl	%eax, %eax
	jne	.L131
	addl	$1, %ebx
	movl	%ebx, tpos(%rip)
	movslq	%ebx, %rax
	leaq	(%rax,%rax,2), %rdx
	leaq	tokens(%rip), %rax
	cmpl	$1, 20(%rax,%rdx,8)
	jne	.L155
	movslq	%ebx, %rbx
	leaq	(%rbx,%rbx,2), %rdx
	leaq	tokens(%rip), %rax
	movq	8(%rax,%rdx,8), %rax
	movl	%eax, %esi
	movl	%eax, bytepos(%rip)
	cmpl	$1, pass(%rip)
	jg	.L156
.L133:
	movl	$0, %eax
	call	start_line
	jmp	.L121
.L149:
	cmpl	$1, pass(%rip)
	jg	.L157
.L123:
	movl	$0, %eax
	call	start_line
.L121:
	popq	%rbx
	.cfi_remember_state
	.cfi_def_cfa_offset 24
	popq	%rbp
	.cfi_def_cfa_offset 16
	popq	%r12
	.cfi_def_cfa_offset 8
	ret
.L157:
	.cfi_restore_state
	movl	%ebp, %esi
	movq	outfile(%rip), %rdi
	call	print_code
	jmp	.L123
.L150:
	movl	$0, %eax
	call	start_line
	jmp	.L121
.L151:
	leaq	.LC26(%rip), %rdi
	call	fail
	movl	$0, %eax
	call	start_line
	jmp	.L121
.L152:
	movl	%ebp, %esi
	movq	tokens(%rip), %rdi
	call	add_symbol
	jmp	.L128
.L153:
	cmpl	$1, pass(%rip)
	jg	.L158
.L129:
	movl	$0, %eax
	call	start_line
	jmp	.L121
.L158:
	movl	%ebp, %esi
	movq	outfile(%rip), %rdi
	call	print_code
	jmp	.L129
.L154:
	leaq	.LC27(%rip), %rdi
	call	fail
	movl	$0, %eax
	call	start_line
	jmp	.L121
.L155:
	leaq	.LC29(%rip), %rdi
	call	fail
	movl	$0, %eax
	call	start_line
	jmp	.L121
.L156:
	movq	outfile(%rip), %rdi
	call	print_code
	jmp	.L133
.L131:
	leaq	.LC30(%rip), %rsi
	movq	%r12, %rdi
	call	strcmp@PLT
	testl	%eax, %eax
	jne	.L134
	addl	$1, %ebx
	movl	%ebx, tpos(%rip)
	movslq	%ebx, %rax
	leaq	(%rax,%rax,2), %rdx
	leaq	tokens(%rip), %rax
	cmpl	$1, 20(%rax,%rdx,8)
	jne	.L135
	movq	8(%rax,%rdx,8), %rcx
	testl	%ecx, %ecx
	jle	.L135
	movl	%ecx, %eax
	addl	bytepos(%rip), %eax
	subl	$1, %eax
	cltd
	idivl	%ecx
	imull	%ecx, %eax
	movl	%eax, bytepos(%rip)
	cmpl	$1, pass(%rip)
	jg	.L159
.L137:
	movl	$0, %eax
	call	start_line
	jmp	.L121
.L135:
	leaq	.LC31(%rip), %rdi
	call	fail
	movl	$0, %eax
	call	start_line
	jmp	.L121
.L159:
	movl	%eax, %esi
	movq	outfile(%rip), %rdi
	call	print_code
	jmp	.L137
.L134:
	addl	$1, %ebx
	movl	%ebx, tpos(%rip)
	movq	%r12, %rdi
	call	find_instr@PLT
	movq	%rax, %rbx
	testq	%rax, %rax
	je	.L160
.L138:
	movl	12(%rbx), %eax
	addl	%eax, bytepos(%rip)
	movl	%eax, bcount(%rip)
	cmpl	$1, pass(%rip)
	je	.L161
	movzbl	8(%rbx), %eax
	movb	%al, code(%rip)
	movb	$-1, 1+code(%rip)
	movl	16(%rbx), %eax
	cmpl	$1, %eax
	je	.L140
	cmpl	$2, %eax
	je	.L141
	testl	%eax, %eax
	jne	.L142
	movl	24(%rbx), %esi
	movl	20(%rbx), %edi
	call	get_reg
.L142:
	movl	28(%rbx), %edx
	cmpl	$3, %edx
	je	.L143
	movl	tpos(%rip), %eax
	movslq	%eax, %rcx
	leaq	(%rcx,%rcx,2), %rsi
	leaq	tokens(%rip), %rcx
	cmpl	$4, 20(%rcx,%rsi,8)
	jne	.L144
	leaq	tokens(%rip), %rcx
	cmpb	$44, 16(%rcx,%rsi,8)
	je	.L145
.L144:
	leaq	.LC33(%rip), %rdi
	call	fail
	movl	$0, %eax
	call	start_line
	jmp	.L121
.L160:
	leaq	.LC32(%rip), %rdi
	call	fail
	movl	$0, %eax
	call	bad_instr@PLT
	movq	%rax, %rbx
	jmp	.L138
.L161:
	movl	$0, %eax
	call	start_line
	jmp	.L121
.L140:
	movl	20(%rbx), %edi
	call	get_mem
	jmp	.L142
.L141:
	movl	24(%rbx), %esi
	movl	20(%rbx), %edi
	movl	$0, %edx
	call	get_num
	jmp	.L142
.L145:
	addl	$1, %eax
	movl	%eax, tpos(%rip)
	cmpl	$1, %edx
	je	.L146
	cmpl	$2, %edx
	je	.L147
	testl	%edx, %edx
	jne	.L143
	movl	36(%rbx), %esi
	movl	32(%rbx), %edi
	call	get_reg
.L143:
	movl	%ebp, %esi
	movq	outfile(%rip), %rdi
	call	print_code
	movl	$0, %eax
	call	start_line
	jmp	.L121
.L146:
	movl	32(%rbx), %edi
	call	get_mem
	jmp	.L143
.L147:
	movl	36(%rbx), %esi
	movl	32(%rbx), %edi
	movl	$0, %edx
	call	get_num
	jmp	.L143
	.cfi_endproc
.LFE63:
	.size	finish_line, .-finish_line
	.section	.rodata.str1.8
	.align 8
.LC34:
	.string	"Missing end-of-line on final line\n"
	.section	.rodata.str1.1
.LC35:
	.string	"Symbol Table:"
.LC36:
	.string	" %s\t0x%x\n"
	.text
	.globl	yywrap
	.type	yywrap, @function
yywrap:
.LFB72:
	.cfi_startproc
	endbr64
	pushq	%rbx
	.cfi_def_cfa_offset 16
	.cfi_offset 3, -16
	cmpl	$0, tcount(%rip)
	jg	.L168
.L163:
	cmpl	$0, verbose(%rip)
	je	.L164
	cmpl	$1, pass(%rip)
	jg	.L169
.L164:
	movl	$1, %eax
	popq	%rbx
	.cfi_remember_state
	.cfi_def_cfa_offset 8
	ret
.L168:
	.cfi_restore_state
	leaq	.LC34(%rip), %rdi
	call	fail
	jmp	.L163
.L169:
	leaq	.LC35(%rip), %rdi
	call	puts@PLT
	movl	$0, %ebx
	jmp	.L165
.L166:
	movslq	%ebx, %rdx
	salq	$4, %rdx
	leaq	symbol_table(%rip), %rax
	addq	%rdx, %rax
	movl	8(%rax), %ecx
	movq	(%rax), %rdx
	leaq	.LC36(%rip), %rsi
	movl	$2, %edi
	movl	$0, %eax
	call	__printf_chk@PLT
	addl	$1, %ebx
.L165:
	cmpl	%ebx, symbol_cnt(%rip)
	jg	.L166
	jmp	.L164
	.cfi_endproc
.LFE72:
	.size	yywrap, .-yywrap
	.section	.rodata.str1.1
.LC37:
	.string	"Unknown blocking factor %d\n"
.LC38:
	.string	".ys"
.LC39:
	.string	"File name too long\n"
.LC40:
	.string	"r"
.LC41:
	.string	"Can't open input file '%s'\n"
.LC42:
	.string	".yo"
.LC43:
	.string	"w"
.LC44:
	.string	"Can't open output file '%s'\n"
	.text
	.globl	main
	.type	main, @function
main:
.LFB74:
	.cfi_startproc
	endbr64
	pushq	%r14
	.cfi_def_cfa_offset 16
	.cfi_offset 14, -16
	pushq	%r13
	.cfi_def_cfa_offset 24
	.cfi_offset 13, -24
	pushq	%r12
	.cfi_def_cfa_offset 32
	.cfi_offset 12, -32
	pushq	%rbp
	.cfi_def_cfa_offset 40
	.cfi_offset 6, -40
	pushq	%rbx
	.cfi_def_cfa_offset 48
	.cfi_offset 3, -48
	subq	$1040, %rsp
	.cfi_def_cfa_offset 1088
	movq	%rsi, %rbp
	movq	%fs:40, %rax
	movq	%rax, 1032(%rsp)
	xorl	%eax, %eax
	cmpl	$1, %edi
	jle	.L186
	movq	8(%rsi), %rdi
	cmpb	$45, (%rdi)
	je	.L187
	movl	$1, %eax
.L172:
	cltq
	leaq	0(%rbp,%rax,8), %r12
	movq	(%r12), %r14
	movq	%r14, %rdi
	call	strlen@PLT
	leal	-3(%rax), %r13d
	movslq	%r13d, %rbx
	leaq	(%r14,%rbx), %rdi
	leaq	.LC38(%rip), %rsi
	call	strcmp@PLT
	testl	%eax, %eax
	jne	.L188
	cmpl	$500, %r13d
	jg	.L189
	movq	%rsp, %rbp
	movl	$512, %ecx
	movq	%rbx, %rdx
	movq	%r14, %rsi
	movq	%rbp, %rdi
	call	__strncpy_chk@PLT
	leaq	0(%rbp,%rbx), %rdi
	movl	$512, %ecx
	cmpq	%rcx, %rbx
	cmovnb	%rbx, %rcx
	subq	%rbx, %rcx
	movl	$4, %edx
	leaq	.LC38(%rip), %rsi
	call	__memcpy_chk@PLT
	leaq	.LC40(%rip), %rsi
	movq	%rbp, %rdi
	call	fopen@PLT
	movq	%rax, yyin(%rip)
	testq	%rax, %rax
	je	.L190
	cmpl	$0, vcode(%rip)
	je	.L177
	movq	stdout(%rip), %rax
	movq	%rax, outfile(%rip)
.L178:
	movl	$1, pass(%rip)
	movl	$0, %eax
	call	yylex@PLT
	movq	yyin(%rip), %rdi
	call	fclose@PLT
	cmpl	$0, hit_error(%rip)
	jne	.L191
	movl	$2, pass(%rip)
	movl	$1, lineno(%rip)
	movl	$0, error_mode(%rip)
	movl	$0, bytepos(%rip)
	movq	%rsp, %rdi
	leaq	.LC40(%rip), %rsi
	call	fopen@PLT
	movq	%rax, yyin(%rip)
	testq	%rax, %rax
	je	.L192
	movl	$0, %eax
	call	yylex@PLT
	movq	yyin(%rip), %rdi
	call	fclose@PLT
	movq	outfile(%rip), %rdi
	call	fclose@PLT
	movl	hit_error(%rip), %eax
	movq	1032(%rsp), %rdx
	subq	%fs:40, %rdx
	jne	.L193
	addq	$1040, %rsp
	.cfi_remember_state
	.cfi_def_cfa_offset 48
	popq	%rbx
	.cfi_def_cfa_offset 40
	popq	%rbp
	.cfi_def_cfa_offset 32
	popq	%r12
	.cfi_def_cfa_offset 24
	popq	%r13
	.cfi_def_cfa_offset 16
	popq	%r14
	.cfi_def_cfa_offset 8
	ret
.L186:
	.cfi_restore_state
	movq	(%rsi), %rdi
	call	usage
.L187:
	cmpb	$86, 1(%rdi)
	jne	.L173
	movl	$1, vcode(%rip)
	cmpb	$0, 2(%rdi)
	jne	.L194
	movl	$2, %eax
	jmp	.L172
.L194:
	addq	$2, %rdi
	movl	$10, %edx
	movl	$0, %esi
	call	strtol@PLT
	movl	%eax, %ecx
	movl	%eax, block_factor(%rip)
	cmpl	$8, %eax
	jne	.L195
	movl	$2, %eax
	jmp	.L172
.L195:
	leaq	.LC37(%rip), %rdx
	movl	$2, %esi
	movq	stderr(%rip), %rdi
	movl	$0, %eax
	call	__fprintf_chk@PLT
	movl	$1, %edi
	call	exit@PLT
.L173:
	movq	(%rsi), %rdi
	call	usage
.L188:
	movq	0(%rbp), %rdi
	call	usage
.L189:
	movq	stderr(%rip), %rcx
	movl	$19, %edx
	movl	$1, %esi
	leaq	.LC39(%rip), %rdi
	call	fwrite@PLT
	movl	$1, %edi
	call	exit@PLT
.L190:
	movq	%rsp, %rcx
	leaq	.LC41(%rip), %rdx
	movl	$2, %esi
	movq	stderr(%rip), %rdi
	call	__fprintf_chk@PLT
	movl	$1, %edi
	call	exit@PLT
.L177:
	movq	(%r12), %rsi
	leaq	512(%rsp), %rbp
	movl	$512, %ecx
	movq	%rbx, %rdx
	movq	%rbp, %rdi
	call	__strncpy_chk@PLT
	leaq	0(%rbp,%rbx), %rdi
	movl	$512, %ecx
	cmpq	%rcx, %rbx
	cmovnb	%rbx, %rcx
	subq	%rbx, %rcx
	movl	$4, %edx
	leaq	.LC42(%rip), %rsi
	call	__memcpy_chk@PLT
	leaq	.LC43(%rip), %rsi
	movq	%rbp, %rdi
	call	fopen@PLT
	movq	%rax, outfile(%rip)
	testq	%rax, %rax
	jne	.L178
	movq	%rbp, %rcx
	leaq	.LC44(%rip), %rdx
	movl	$2, %esi
	movq	stderr(%rip), %rdi
	call	__fprintf_chk@PLT
	movl	$1, %edi
	call	exit@PLT
.L191:
	movl	$1, %edi
	call	exit@PLT
.L192:
	movq	%rsp, %rcx
	leaq	.LC41(%rip), %rdx
	movl	$2, %esi
	movq	stderr(%rip), %rdi
	call	__fprintf_chk@PLT
	movl	$1, %edi
	call	exit@PLT
.L193:
	call	__stack_chk_fail@PLT
	.cfi_endproc
.LFE74:
	.size	main, .-main
	.globl	atollh
	.type	atollh, @function
atollh:
.LFB75:
	.cfi_startproc
	endbr64
	subq	$8, %rsp
	.cfi_def_cfa_offset 16
	movl	$16, %edx
	movl	$0, %esi
	call	strtoull@PLT
	addq	$8, %rsp
	.cfi_def_cfa_offset 8
	ret
	.cfi_endproc
.LFE75:
	.size	atollh, .-atollh
	.globl	symbol_table
	.bss
	.align 32
	.type	symbol_table, @object
	.size	symbol_table, 16000
symbol_table:
	.zero	16000
	.globl	symbol_cnt
	.align 4
	.type	symbol_cnt, @object
	.size	symbol_cnt, 4
symbol_cnt:
	.zero	4
	.globl	token_type_names
	.data
	.type	token_type_names, @object
	.size	token_type_names, 5
token_type_names:
	.ascii	"INRXP"
	.globl	bcount
	.bss
	.align 4
	.type	bcount, @object
	.size	bcount, 4
bcount:
	.zero	4
	.globl	codepos
	.align 4
	.type	codepos, @object
	.size	codepos, 4
codepos:
	.zero	4
	.globl	code
	.align 8
	.type	code, @object
	.size	code, 10
code:
	.zero	10
	.globl	input_line
	.align 32
	.type	input_line, @object
	.size	input_line, 4096
input_line:
	.zero	4096
	.globl	strpos
	.align 4
	.type	strpos, @object
	.size	strpos, 4
strpos:
	.zero	4
	.globl	strbuf
	.align 32
	.type	strbuf, @object
	.size	strbuf, 4096
strbuf:
	.zero	4096
	.globl	tpos
	.align 4
	.type	tpos, @object
	.size	tpos, 4
tpos:
	.zero	4
	.globl	tcount
	.align 4
	.type	tcount, @object
	.size	tcount, 4
tcount:
	.zero	4
	.globl	tokens
	.align 32
	.type	tokens, @object
	.size	tokens, 288
tokens:
	.zero	288
	.globl	pass
	.data
	.align 4
	.type	pass, @object
	.size	pass, 4
pass:
	.long	1
	.globl	hit_error
	.bss
	.align 4
	.type	hit_error, @object
	.size	hit_error, 4
hit_error:
	.zero	4
	.globl	error_mode
	.align 4
	.type	error_mode, @object
	.size	error_mode, 4
error_mode:
	.zero	4
	.globl	bytepos
	.align 4
	.type	bytepos, @object
	.size	bytepos, 4
bytepos:
	.zero	4
	.globl	block_factor
	.align 4
	.type	block_factor, @object
	.size	block_factor, 4
block_factor:
	.zero	4
	.globl	vcode
	.align 4
	.type	vcode, @object
	.size	vcode, 4
vcode:
	.zero	4
	.globl	verbose
	.align 4
	.type	verbose, @object
	.size	verbose, 4
verbose:
	.zero	4
	.globl	outfile
	.align 8
	.type	outfile, @object
	.size	outfile, 8
outfile:
	.zero	8
	.globl	gui_mode
	.align 4
	.type	gui_mode, @object
	.size	gui_mode, 4
gui_mode:
	.zero	4
	.globl	lineno
	.data
	.align 4
	.type	lineno, @object
	.size	lineno, 4
lineno:
	.long	1
	.ident	"GCC: (Ubuntu 13.2.0-23ubuntu4) 13.2.0"
	.section	.note.GNU-stack,"",@progbits
	.section	.note.gnu.property,"a"
	.align 8
	.long	1f - 0f
	.long	4f - 1f
	.long	5
0:
	.string	"GNU"
1:
	.align 8
	.long	0xc0000002
	.long	3f - 2f
2:
	.long	0x3
3:
	.align 8
4:
