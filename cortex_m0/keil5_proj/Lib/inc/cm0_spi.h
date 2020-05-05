#ifndef __CM0_SPI_H
#define __CM0_SPI_H

#include "stdio.h"	
#include "my32.h"

//uart����
typedef struct 
{
	unsigned int psc;
    unsigned int cpol;
    unsigned int cpha;
    unsigned int firstbit;
	unsigned int ie;
} SPI_InitTypeDef;


#define Spi_TC           ((uint16_t)0x0001)
#define Spi_RC           ((uint16_t)0x0001)
#define SPI_CPOL_Low     ((uint16_t)0x0000)
#define SPI_CPOL_High    ((uint16_t)0x0004)
#define SPI_CPHA_1Edge   ((uint16_t)0x0008)
#define SPI_CPHA_2Edge   ((uint16_t)0x0000)
#define SPI_FirstBit_MSB ((uint16_t)0x0010)
#define SPI_FirstBit_LSB ((uint16_t)0x0000)

//uart���ú���
void Spi_Cfg(SPI_TypeDef* SPI_TypeDef,SPI_InitTypeDef* spi);

//uart�����ֽ�
void Spi_SendData(SPI_TypeDef* SPI_TypeDef,char data);

//���ڽ����ֽ�
u8 Spi_RecieveData(SPI_TypeDef* SPI_TypeDef);

//uartʹ��
void Spi_Cmd(SPI_TypeDef * SPI_TypeDef,FunctionalState s);

//��ȡ״̬λ
FlagStatus SPI_GetFlagStatus(SPI_TypeDef* SPI_TypeDef,u32 spi_flags);
    
#endif
