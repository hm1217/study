#include "cm0_gpio.h"

void GPIO_Init(GPIO_TypeDef* GPIOx, GPIO_InitTypeDef* GPIO_InitStruct)
{
	GPIOx->MR |= ((GPIO_InitStruct->mode) << (GPIO_InitStruct->pin));
}

void GPIO_SetBits(GPIO_TypeDef* GPIOx, uint16_t GPIO_Pin)
{
	GPIOx->DR = ((u16)GPIOx->DR) | GPIO_Pin;
}

void GPIO_ResetBits(GPIO_TypeDef* GPIOx, uint16_t GPIO_Pin)
{
	GPIOx->DR = ((u16)GPIOx->DR) & ~GPIO_Pin;
}

void GPIO_Write(GPIO_TypeDef* GPIOx, uint16_t PortVal)
{
	GPIOx->DR = PortVal;
}

uint8_t GPIO_ReadInputDataBit(GPIO_TypeDef* GPIOx, uint16_t GPIO_Pin)
{
	u16 data;
	data = (GPIOx->DR >> 16) & GPIO_Pin;
	if(data == 0)
		return 0;
	else
		return 1;
}

uint16_t GPIO_ReadInputData(GPIO_TypeDef* GPIOx)
{
	u16 data;
	data = (GPIOx->DR >> 16);
		return data;
}
