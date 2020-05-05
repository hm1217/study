#ifndef __DHT11_H
#define __DHT11_H 

#include "my32.h"   
#include "delay.h"

//IO��������
#define DHT11_IO_IN()  {Gpio->MR|= (1<<1);}//����������
#define DHT11_IO_OUT() {Gpio->MR&=~(1<<1);}//ͨ���������

////IO��������											   
#define	DHT11_DQ_OUT (Gpio->DR) //���ݶ˿�
#define	DHT11_DQ_IN  (((Gpio->DR>>16)&(1<<1))>>1)  //���ݶ˿�


u8 DHT11_Init(void);                    //��ʼ��DHT11
u8 DHT11_Read_Data(u8 *temp,u8 *humi);  //��ȡ��ʪ��
u8 DHT11_Read_Byte(void);               //����һ���ֽ�
u8 DHT11_Read_Bit(void);                //����һ��λ
u8 DHT11_Check(void);                   //����Ƿ����DHT11
void DHT11_Rst(void);                   //��λDHT11  

#endif

