#include "timer.h"

extern unsigned int W5500_Send_Delay_Counter;
extern unsigned int W5500_Send_Delay_Counter1;

void timer_init()
{
	TIMER_InitTypeDef timer1;
	NVIC_InitTypeDef NVIC_InitStructure;
	
	timer1.psc  = 200;
	timer1.arr  = (65535-50000);
	timer1.mode = RELOAD;
	timer1.ie   = ENABLE;
	
	timer_cfg(Timer,&timer1);

    NVIC_InitStructure.NVIC_IRQChannel = TIM_IRQn;
	NVIC_InitStructure.NVIC_IRQChannelPriority=3 ;//抢占优先级3
	NVIC_InitStructure.NVIC_IRQChannelCmd = ENABLE;			//IRQ通道使能
	NVIC_Init(&NVIC_InitStructure);
    
    timer_cmd(Timer,ENABLE);
}


void TIM_IRQHandler(void)
{
	W5500_Send_Delay_Counter++;
    W5500_Send_Delay_Counter1++;
}
