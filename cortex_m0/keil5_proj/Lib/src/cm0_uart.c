#include "cm0_uart.h"

//�������´���,֧��printf����,������Ҫѡ��use MicroLIB	  
#if 1
#pragma import(__use_no_semihosting)             
//��׼����Ҫ��֧�ֺ���                 
struct __FILE
{
	int handle;
};

FILE __stdout;

//����_sys_exit()�Ա���ʹ�ð�����ģʽ    
void _sys_exit(int x)
{
	x = x;
}

//�ض���fputc���� 
int fputc(int ch, FILE *f)
{
    Uart->DR = (u8) ch;
    while((Uart->SR&0X02)==0);
	return ch;
}
#endif


//���ô��ڲ���
void Uart_Cfg(UART_TypeDef* UART_TypeDef,UART_InitTypeDef* usart)
{	
	if(usart->baudrate == 115200)
		UART_TypeDef->CR = ((1<<1)|(usart->ie<<4));
	else
		UART_TypeDef->CR = ((0<<1)|(usart->ie<<4));
}

//���ڷ����ֽ�
void Uart_SendData(UART_TypeDef* UART_TypeDef,char data)
{		
	UART_TypeDef->DR = data;
}

//���ڽ����ֽ�
u8 Uart_RecieveData(UART_TypeDef* UART_TypeDef)
{
	u8 data;	
	data = UART_TypeDef->DR>>8;
	return data;
}

//����ʹ��
void Uart_Cmd(UART_TypeDef * UART_TypeDef,FunctionalState s)
{
	if(s == ENABLE)
		UART_TypeDef->CR |=  (1<<0);
	else
		UART_TypeDef->CR &= ~(1<<0);
}

//��ȡ״̬λ
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

