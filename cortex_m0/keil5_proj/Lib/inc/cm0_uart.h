#ifndef __CM0_UART_H
#define __CM0_UART_H

#include "stdio.h"	
#include "my32.h"

//uart参数
typedef struct 
{
	unsigned int cmd;
	unsigned int data;
	unsigned int baudrate;
	unsigned int ie;
} UART_InitTypeDef;


#define Uart_TXE  ((u16)0x0008)
#define Uart_RXNE ((u16)0x0004)
#define Uart_TC   ((u16)0x0002)
#define Uart_RC   ((u16)0x0001)

#define IS_USART_ALL_PERIPH(UART_TypeDef) ((UART_TypeDef) == Uart)
#define IS_UART_FLAGS(uart_flags) (((uart_flags) == Uart_TC) || ((uart_flags) == Uart_RC))

//uart配置函数
void Uart_Cfg(UART_TypeDef* UART_TypeDef,UART_InitTypeDef* usart);

//uart发送字节
void Uart_SendData(UART_TypeDef* UART_TypeDef,char data);

//串口接收字节
u8 Uart_RecieveData(UART_TypeDef* UART_TypeDef);

//uart使能
void Uart_Cmd(UART_TypeDef* UART_TypeDef,FunctionalState s);

//读取状态位
FlagStatus UART_GetFlagStatus(UART_TypeDef* UART_TypeDef,u32 uart_flags);
    
#endif
