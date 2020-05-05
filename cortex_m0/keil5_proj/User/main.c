

#include "W5500.h"			
#include "dht11.h"

unsigned int W5500_Send_Delay_Counter=0; //W5500������ʱ��������(ms)
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
* ������  : main
* ����    : ���������û������main������ʼ����
* ����    : ��
* ���    : ��
* ����ֵ  : int:����ֵΪһ��16λ������
* ˵��    : ��
*******************************************************************************/
int main(void)
{
    u8 hum,temp=0;
    
	System_Initialization();	//ϵͳ��ʼ������
    while(DHT11_Init());
    printf("\r\nDHT11��ʼ���ɹ�!\r\n");      
    
	Load_Net_Parameters();		//װ���������
    printf("\r\n����ip��%d.%d.%d.%d\r\n",Gateway_IP[0],Gateway_IP[1],Gateway_IP[2],Gateway_IP[3]);
    printf("����ip��%d.%d.%d.%d\r\n",IP_Addr[0],IP_Addr[1],IP_Addr[2],IP_Addr[3]);    
    printf("����port��%d\r\n",S0_Port[0]*256+S0_Port[1]);

    printf("\r\nSocket0Զ��ip��%d.%d.%d.%d\r\n",S0_DIP[0],S0_DIP[1],S0_DIP[2],S0_DIP[3]);
    printf("Socket0Զ��port��%d\r\n",S0_DPort[0]*256+S0_DPort[1]);

    printf("\r\nSocket1Զ��ip��%d.%d.%d.%d\r\n",S1_DIP[0],S1_DIP[1],S1_DIP[2],S1_DIP[3]);
    printf("Socket1Զ��port��%d\r\n",S1_DPort[0]*256+S1_DPort[1]);
    
    
	W5500_Hardware_Reset();		//Ӳ����λW5500
    printf("\r\nW5500��λ�ɹ�!\r\n");
    
	W5500_Initialization();		//W5500��ʼ������
    printf("\r\nW5500��ʼ���ɹ�!\r\n");

    printf("\r\n���ڳ���������֪����.....\r\n");
    printf("\r\n���ڳ�������OneNetƽ̨.....\r\n");
    
	while (1)
	{
        W5500_Send_Delay_Counter++;
        W5500_Send_Delay_Counter1++;
        
        W5500_Socket_Set();//W5500�˿ڳ�ʼ������		
		W5500_Interrupt_Process();//W5500�жϴ��������

		if(W5500_Send_Delay_Counter == 30000)//��ʱ�����ַ���
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
                printf("\r\n�ɹ��ϴ���OneNet������\r\n");
			}
            //W5500_Send_Delay_Counter=0;
		}
        
        
        if((S0_State == (S_INIT|S_CONN)) && ((S0_Data & S_RECEIVE) == S_RECEIVE))//���Socket0���յ�����
        {
            S0_Data&=~S_RECEIVE;
            Process_Socket_Data(0);//W5500���ղ����ͽ��յ�������
            printf("\r\n\r\n\r\n�������������Ѹ��£�����\r\n");
            printf("\r\n�¶ȣ� %s\r\n",temp_from_internet);
            printf("\r\n������ %s\r\n",text_from_internet);
            printf("\r\n�ϴθ��£� %s\r\n\r\n\r\n",time_from_internet); 
//            W5500_Send_Delay_Counter1=0;            
        }
            
        if(W5500_Send_Delay_Counter >= 50000)//��ʱ�����ַ���
		{           
            if(S0_State == (S_INIT|S_CONN))
            {
				S0_Data &=~S_TRANSMITOK;
                Write_SOCK_Data_Buffer(0, (unsigned char*)post, strlen(post));
                printf("\r\n���ڻ�ȡ������������.....\r\n");
                //printf("\r\n%s\r\n",post);
            }
            W5500_Send_Delay_Counter=0;
        }
        
	}
}

