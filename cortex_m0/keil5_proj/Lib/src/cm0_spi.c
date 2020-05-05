#include "cm0_spi.h"


//����SPI����
void Spi_Cfg(SPI_TypeDef* SPI_TypeDef,SPI_InitTypeDef* spi)
{		
	SPI_TypeDef->CR  =  (spi->ie<<1)|(spi->cpol)|(spi->cpha)|(spi->firstbit);
	SPI_TypeDef->PSC =  spi->psc;
}

//SPI�����ֽ�
void Spi_SendData(SPI_TypeDef* SPI_TypeDef,char data)
{		
	SPI_TypeDef->DR = data;
}

//SPI�����ֽ�
u8 Spi_RecieveData(SPI_TypeDef* SPI_TypeDef)
{
	u8 data;	
	data = SPI_TypeDef->DR>>8;
	return data;
}

//SPIʹ��
void Spi_Cmd(SPI_TypeDef * SPI_TypeDef,FunctionalState s)
{
	if(s == ENABLE)
		SPI_TypeDef->CR |=  (1<<0);
	else
		SPI_TypeDef->CR &= ~(1<<0);
}

//��ȡ״̬λ
FlagStatus SPI_GetFlagStatus(SPI_TypeDef* SPI_TypeDef,u32 spi_flags)
{
    FlagStatus bitstatus = RESET;
    
    if((SPI_TypeDef->SR & spi_flags) != (u16)RESET)
        bitstatus = SET;
    else
        bitstatus = RESET;
    return bitstatus;    
}

