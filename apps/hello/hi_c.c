volatile unsigned int * const UART0DR = (unsigned int *)0x101f1000;
 
void print_uart0(const char *s) {
	while(*UART0DR = (unsigned int)(*s++));
}
 
int rust_entry();

int c_entry() {
  char buffer[2];
  buffer[0] = 64 + rust_entry();
  buffer[1] = 0;
  print_uart0(&buffer);
}
