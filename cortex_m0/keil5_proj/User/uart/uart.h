#ifndef __UART_H
#define __UART_H

#include "cm0_uart.h"

void uart_init(void);
void uart_sendstring(UART_TypeDef* UART_TypeDef,u8* s);

#endif
