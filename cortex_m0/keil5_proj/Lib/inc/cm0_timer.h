#ifndef __CM0_TIMER_H
#define __CM0_TIMER_H

#include "my32.h"

//timer参数
typedef struct 
{
	unsigned int mode;
	unsigned int psc;
	unsigned int arr;
	unsigned int ie;
} TIMER_InitTypeDef;

//定时器模式
typedef enum
{
	NORMAL,
	RELOAD
} timer_mode;


//timer配置函数
void timer_cfg(TIMER_TypeDef* TIMER_TypeDef,TIMER_InitTypeDef* timer);

//timer使能
void timer_cmd(TIMER_TypeDef* TIMER_TypeDef,FunctionalState s);


#endif
