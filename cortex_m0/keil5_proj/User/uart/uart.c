#include "uart.h"
#include "gpio.h"

void uart_init()
{
//  NVIC_InitTypeDef NVIC_InitStructure;
	UART_InitTypeDef uart1;
	
	uart1.baudrate  = 115200;
//	uart1.ie = Uart_TC;
	Uart_Cfg(Uart,&uart1);
    
//  NVIC_InitStructure.NVIC_IRQChannel = UART_IRQn;
//	NVIC_InitStructure.NVIC_IRQChannelPriority=0 ;//优先级2
//	NVIC_InitStructure.NVIC_IRQChannelCmd = ENABLE;			//IRQ通道使能
//	NVIC_Init(&NVIC_InitStructure);
	
	Uart_Cmd(Uart,ENABLE);
}


void uart_sendstring(UART_TypeDef* UART_TypeDef,u8* s)
{
	while(*s!='\0')
	{
		Uart_SendData(UART_TypeDef,*s++);
        while(UART_GetFlagStatus(UART_TypeDef,Uart_TC) == RESET);
	}
}

void UART_IRQHandler(void)
{
//    if(UART_GetFlagStatus(Uart,Uart_RC) == SET)
//    {
 //       Led = 0x04;
    
//    }
}
