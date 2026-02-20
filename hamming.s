
# calls the user input
    .section .data
prompt1:
    .string "Enter first string:  "
prompt1_len = . - prompt1

prompt2:
    .string "Enter second string: "
prompt2_len = . - prompt2

result_msg:
    .string "The Hamming distance between the following two strings is: "
result_len = . - result_msg



    .section .bss
    .lcomm buf1, 256
    .lcomm buf2, 256
    .lcomm num_buf, 20

    .section .text
    .global main


# main
main:
    pushq   %rbp
    movq    %rsp, %rbp

    # Prompt 1
    movq    $1,           %rax
    movq    $1,           %rdi
    movq    $prompt1,     %rsi
    movq    $prompt1_len, %rdx
    syscall

    # print 1
    movq    $0,    %rax
    movq    $0,    %rdi
    movq    $buf1, %rsi
    movq    $256,  %rdx
    syscall
    movq    %rax,  %rcx
    decq    %rcx
    movb    $0,    buf1(%rcx)

    # Prompt 2
    movq    $1,           %rax
    movq    $1,           %rdi
    movq    $prompt2,     %rsi
    movq    $prompt2_len, %rdx
    syscall

    # print 2
    movq    $0,    %rax
    movq    $0,    %rdi
    movq    $buf2, %rsi
    movq    $256,  %rdx
    syscall
    movq    %rax,  %rcx
    decq    %rcx
    movb    $0,    buf2(%rcx)

    # Compute hamming 
    movq    $buf1, %rdi
    movq    $buf2, %rsi
    call    hamming_distance

    # Print  hamming
    pushq   %rax
    movq    $1,          %rax
    movq    $1,          %rdi
    movq    $result_msg, %rsi
    movq    $result_len, %rdx
    syscall
    popq    %rax

    call    print_number_newline

    movq    $0, %rax
    popq    %rbp
    ret


# finds hamming distance
hamming_distance:
    xorq    %rax, %rax          

.hd_loop:
    movzbq  (%rdi), %r8        
    movzbq  (%rsi), %r9        

   
    testq   %r8, %r8
    jz      .hd_done
    testq   %r9, %r9
    jz      .hd_done

   
    xorq    %r9, %r8

    
    xorq    %r10, %r10          

.hd_bitcount:
    testq   %r8, %r8
    jz      .hd_bitdone
    movq    %r8,  %rcx
    decq    %rcx
    andq    %rcx, %r8           
    incq    %r10
    jmp     .hd_bitcount

.hd_bitdone:
    addq    %r10, %rax          

    incq    %rdi
    incq    %rsi
    jmp     .hd_loop

.hd_done:
    ret

# Prints the number
print_number_newline:
    pushq   %rbx
    pushq   %rcx
    pushq   %rdx
    pushq   %rdi
    pushq   %rsi

    movq    $num_buf, %rbx
    addq    $19,      %rbx
    movb    $10,      (%rbx)    
    decq    %rbx

    testq   %rax, %rax
    jnz     .pnn_convert
    movb    $'0',     (%rbx)    
    jmp     .pnn_print

.pnn_convert:
    movq    $10,  %rcx

.pnn_div_loop:
    testq   %rax, %rax
    jz      .pnn_print
    xorq    %rdx, %rdx
    divq    %rcx                
    addb    $'0', %dl
    movb    %dl,  (%rbx)
    decq    %rbx
    jmp     .pnn_div_loop

.pnn_print:
    leaq    1(%rbx),    %rsi
    leaq    num_buf+20, %rdx
    subq    %rsi,       %rdx

    movq    $1,   %rax
    movq    $1,   %rdi
    syscall

    popq    %rsi
    popq    %rdi
    popq    %rdx
    popq    %rcx
    popq    %rbx
    ret
