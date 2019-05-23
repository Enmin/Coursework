#include <unistd.h>
#include <sys/syscall.h>
#include <sys/types.h>

void delete(){
	asm("\
		movq $0x57, %rax\n\
		movq $0x7fffffffcfd5, %rdi\n\
		syscall\n\
	");
}
