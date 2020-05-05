#ifndef __DHT11_H
#define __DHT11_H 

#include "my32.h"   
#include "delay.h"

//IO方向设置
#define DHT11_IO_IN()  {Gpio->MR|= (1<<1);}//上下拉输入
#define DHT11_IO_OUT() {Gpio->MR&=~(1<<1);}//通用推挽输出

////IO操作函数											   
#define	DHT11_DQ_OUT (Gpio->DR) //数据端口
#define	DHT11_DQ_IN  (((Gpio->DR>>16)&(1<<1))>>1)  //数据端口


u8 DHT11_Init(void);                    //初始化DHT11
u8 DHT11_Read_Data(u8 *temp,u8 *humi);  //读取温湿度
u8 DHT11_Read_Byte(void);               //读出一个字节
u8 DHT11_Read_Bit(void);                //读出一个位
u8 DHT11_Check(void);                   //检测是否存在DHT11
void DHT11_Rst(void);                   //复位DHT11  

#endif

