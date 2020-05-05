

#include "W5500.h"			
#include "dht11.h"

unsigned int W5500_Send_Delay_Counter=0; //W5500发送延时计数变量(ms)
unsigned int W5500_Send_Delay_Counter1=0;


char post[] = {
"GET https://api.seniverse.com/v3/weather/now.json?key=sbq02ejwqqgdg4qk&location=beijing&language=zh-Hans&unit=c\r\n"
"\r\n"
"\r\n"
};

char post1[] = {
"POST /devices/20451817/datapoints?type=3 HTTP/1.1\r\n"
"api-key:1n=rhAK4FfZArU3TxK758T=3Yt8=\r\n"
"Host:api.heclouds.com\r\n"
"Content-Length:32\r\n"
"\r\n"
"{\"temperature\":25,\"humidity\":10}\r\n"
"\r\n"
"\r\n"
};

extern char *temp_from_internet;
extern char *text_from_internet;
extern char *time_from_internet;
//extern char *name_from_internet;


/*******************************************************************************
* 函数名  : main
* 描述    : 主函数，用户程序从main函数开始运行
* 输入    : 无
* 输出    : 无
* 返回值  : int:返回值为一个16位整形数
* 说明    : 无
*******************************************************************************/
int main(void)
{
    u8 hum,temp=0;
    
	System_Initialization();	//系统初始化函数
    while(DHT11_Init());
    printf("\r\nDHT11初始化成功!\r\n");      
    
	Load_Net_Parameters();		//装载网络参数
    printf("\r\n网关ip：%d.%d.%d.%d\r\n",Gateway_IP[0],Gateway_IP[1],Gateway_IP[2],Gateway_IP[3]);
    printf("本机ip：%d.%d.%d.%d\r\n",IP_Addr[0],IP_Addr[1],IP_Addr[2],IP_Addr[3]);    
    printf("本地port：%d\r\n",S0_Port[0]*256+S0_Port[1]);

    printf("\r\nSocket0远程ip：%d.%d.%d.%d\r\n",S0_DIP[0],S0_DIP[1],S0_DIP[2],S0_DIP[3]);
    printf("Socket0远程port：%d\r\n",S0_DPort[0]*256+S0_DPort[1]);

    printf("\r\nSocket1远程ip：%d.%d.%d.%d\r\n",S1_DIP[0],S1_DIP[1],S1_DIP[2],S1_DIP[3]);
    printf("Socket1远程port：%d\r\n",S1_DPort[0]*256+S1_DPort[1]);
    
    
	W5500_Hardware_Reset();		//硬件复位W5500
    printf("\r\nW5500复位成功!\r\n");
    
	W5500_Initialization();		//W5500初始化配置
    printf("\r\nW5500初始化成功!\r\n");

    printf("\r\n正在尝试连接心知天气.....\r\n");
    printf("\r\n正在尝试连接OneNet平台.....\r\n");
    
	while (1)
	{
        W5500_Send_Delay_Counter++;
        W5500_Send_Delay_Counter1++;
        
        W5500_Socket_Set();//W5500端口初始化配置		
		W5500_Interrupt_Process();//W5500中断处理程序框架

		if(W5500_Send_Delay_Counter == 30000)//定时发送字符串
		{
            if(DHT11_Read_Data(&hum,&temp))
            {
                post1[148]=temp/10+0x30;
                post1[149]=temp%10+0x30;
                post1[162]=hum/10+0x30;
                post1[163]=hum%10+0x30;
            }
            
            printf("\r\ntemp from internet : %s ",temp_from_internet); 
            printf("temp from dht11 : %d ",temp); 
            printf("hum from dht11 : %d\r\n",hum);


			if(S1_State == (S_INIT|S_CONN))
			{
				S1_Data &=~S_TRANSMITOK;
                
                
                Write_SOCK_Data_Buffer(1, (unsigned char*)post1, strlen(post1));
                printf("\r\n成功上传至OneNet！！！\r\n");
			}
            //W5500_Send_Delay_Counter=0;
		}
        
        
        if((S0_State == (S_INIT|S_CONN)) && ((S0_Data & S_RECEIVE) == S_RECEIVE))//如果Socket0接收到数据
        {
            S0_Data&=~S_RECEIVE;
            Process_Socket_Data(0);//W5500接收并发送接收到的数据
            printf("\r\n\r\n\r\n网络天气数据已更新！！！\r\n");
            printf("\r\n温度： %s\r\n",temp_from_internet);
            printf("\r\n天气： %s\r\n",text_from_internet);
            printf("\r\n上次更新： %s\r\n\r\n\r\n",time_from_internet); 
//            W5500_Send_Delay_Counter1=0;            
        }
            
        if(W5500_Send_Delay_Counter >= 50000)//定时发送字符串
		{           
            if(S0_State == (S_INIT|S_CONN))
            {
				S0_Data &=~S_TRANSMITOK;
                Write_SOCK_Data_Buffer(0, (unsigned char*)post, strlen(post));
                printf("\r\n正在获取在线天气数据.....\r\n");
                //printf("\r\n%s\r\n",post);
            }
            W5500_Send_Delay_Counter=0;
        }
        
	}
}

