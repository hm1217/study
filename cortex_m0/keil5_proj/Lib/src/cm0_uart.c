#include "cm0_uart.h"

//加入以下代码,支持printf函数,而不需要选择use MicroLIB	  
#if 1
#pragma import(__use_no_semihosting)             
//标准库需要的支持函数                 
struct __FILE
{
	int handle;
};

FILE __stdout;

//定义_sys_exit()以避免使用半主机模式    
void _sys_exit(int x)
{
	x = x;
}

//重定义fputc函数 
int fputc(int ch, FILE *f)
{
    Uart->DR = (u8) ch;
    while((Uart->SR&0X02)==0);
	return ch;
}
#endif


//配置串口参数
void Uart_Cfg(UART_TypeDef* UART_TypeDef,UART_InitTypeDef* usart)
{	
	if(usart->baudrate == 115200)
		UART_TypeDef->CR = ((1<<1)|(usart->ie<<4));
	else
		UART_TypeDef->CR = ((0<<1)|(usart->ie<<4));
}

//串口发送字节
void Uart_SendData(UART_TypeDef* UART_TypeDef,char data)
{		
	UART_TypeDef->DR = data;
}

//串口接收字节
u8 Uart_RecieveData(UART_TypeDef* UART_TypeDef)
{
	u8 data;	
	data = UART_TypeDef->DR>>8;
	return data;
}

//串口使能
void Uart_Cmd(UART_TypeDef * UART_TypeDef,FunctionalState s)
{
	if(s == ENABLE)
		UART_TypeDef->CR |=  (1<<0);
	else
		UART_TypeDef->CR &= ~(1<<0);
}

//获取状态位
FlagStatus UART_GetFlagStatus(UART_TypeDef* UART_TypeDef,u32 uart_flags)
{
    FlagStatus bitstatus = RESET;
    
    assert_param(IS_USART_ALL_PERIPH(UART_TypeDef));
    assert_param(IS_UART_FLAGS(uart_flags));
    
    if((UART_TypeDef->SR & uart_flags) != (u16)RESET)
        bitstatus = SET;
    else
        bitstatus = RESET;
    return bitstatus;    
}

