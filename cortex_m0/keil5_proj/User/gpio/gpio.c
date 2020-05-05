#include "gpio.h"

void gpio_init(void)
{
	GPIO_InitTypeDef GPIO_InitStruct;
	GPIO_InitStruct.mode = OUTPUT;
	GPIO_InitStruct.pin = 1;	
	
	GPIO_Init(gpio,&GPIO_InitStruct);
}
