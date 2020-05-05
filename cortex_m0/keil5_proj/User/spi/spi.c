#include "spi.h"


void spi_init()
{
    NVIC_InitTypeDef NVIC_InitStructure;
	SPI_InitTypeDef spi;
	
	spi.psc = 0x04;
    spi.cpol=SPI_CPOL_High;
    spi.cpha=SPI_CPHA_1Edge;
    spi.firstbit=SPI_FirstBit_MSB;
    spi.ie=Spi_TC;
	Spi_Cfg(Spi,&spi);
    
    NVIC_InitStructure.NVIC_IRQChannel = SPI_IRQn;
	NVIC_InitStructure.NVIC_IRQChannelPriority=1 ;//优先级1
	NVIC_InitStructure.NVIC_IRQChannelCmd = ENABLE;			//IRQ通道使能
	NVIC_Init(&NVIC_InitStructure);
	
	Spi_Cmd(Spi,ENABLE);
}

void SPI_IRQHandler(void)
{
    static u8 i = 0;
    if(SPI_GetFlagStatus(Spi,Spi_TC) == SET)
    {
        if(i==1)
        {
            Led = 0x99;
            i=0;
        }
        else
            Led = 0x88;
        i++;
    }
}

