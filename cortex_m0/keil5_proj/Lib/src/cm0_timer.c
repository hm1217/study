#include "cm0_timer.h"

//配置定时器参数
void timer_cfg(TIMER_TypeDef* TIMER_TypeDef,TIMER_InitTypeDef* timer)
{	
	TIMER_TypeDef->PSC =  timer->psc;
	TIMER_TypeDef->ARR =  timer->arr;
	TIMER_TypeDef->CR  =  ((timer->mode<<2)|(timer->ie<<1));
}

//定时器使能
void timer_cmd(TIMER_TypeDef* TIMER_TypeDef,FunctionalState s)
{
	if(s == ENABLE)
		TIMER_TypeDef->CR |=  (1<<0);
	else
		TIMER_TypeDef->CR &= ~(1<<0);
}



