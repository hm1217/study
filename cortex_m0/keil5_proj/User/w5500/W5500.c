/**********************************************************************************
 * �ļ���  ��W5500.c
 * ����    ��W5500 ����������         
 * ��汾  ��ST_v3.5

 * �Ա�    ��http://yixindianzikeji.taobao.com/
**********************************************************************************/


#include "W5500.h"	

char *temp_from_internet = "12";
char *text_from_internet = "04";
char *time_from_internet = "08";

    
/***************----- ��������������� -----***************/
unsigned char Gateway_IP[4];//����IP��ַ 
unsigned char Sub_Mask[4];	//�������� 
unsigned char Phy_Addr[6];	//�����ַ(MAC) 
unsigned char IP_Addr[4];	//����IP��ַ 

unsigned char S0_Port[2];	//�˿�0�Ķ˿ں�(5000) 
unsigned char S0_DIP[4];	//�˿�0Ŀ��IP��ַ 
unsigned char S0_DPort[2];	//�˿�0Ŀ�Ķ˿ں�(6000) 

unsigned char S1_Port[2];	//�˿�1�Ķ˿ں�(5000) 
unsigned char S1_DIP[4];	//�˿�1Ŀ��IP��ַ 
unsigned char S1_DPort[2];	//�˿�1Ŀ�Ķ˿ں�(6000) 

unsigned char UDP_DIPR[4];	//UDP(�㲥)ģʽ,Ŀ������IP��ַ
unsigned char UDP_DPORT[2];	//UDP(�㲥)ģʽ,Ŀ�������˿ں�

/***************----- �˿ڵ�����ģʽ -----***************/
unsigned char S0_Mode =3;	//�˿�0������ģʽ,0:TCP������ģʽ,1:TCP�ͻ���ģʽ,2:UDP(�㲥)ģʽ
unsigned char S1_Mode =3;
#define TCP_SERVER	0x00	//TCP������ģʽ
#define TCP_CLIENT	0x01	//TCP�ͻ���ģʽ 
#define UDP_MODE	0x02	//UDP(�㲥)ģʽ 

/***************----- �˿ڵ�����״̬ -----***************/
unsigned char S0_State =0;	//�˿�0״̬��¼,1:�˿���ɳ�ʼ��,2�˿��������(����������������) 
unsigned char S1_State =0;
#define S_INIT		0x01	//�˿���ɳ�ʼ�� 
#define S_CONN		0x02	//�˿��������,���������������� 

/***************----- �˿��շ����ݵ�״̬ -----***************/
unsigned char S0_Data;		//�˿�0���պͷ������ݵ�״̬,1:�˿ڽ��յ�����,2:�˿ڷ���������� 
unsigned char S1_Data;
#define S_RECEIVE	 0x01	//�˿ڽ��յ�һ�����ݰ� 
#define S_TRANSMITOK 0x02	//�˿ڷ���һ�����ݰ���� 

/***************----- �˿����ݻ����� -----***************/
unsigned char Rx_Buffer[2048];	//�˿ڽ������ݻ����� 
unsigned char Tx_Buffer[2048];	//�˿ڷ������ݻ����� 

//unsigned char W5500_Interrupt;	//W5500�жϱ�־(0:���ж�,1:���ж�)

/*******************************************************************************
* ������  : W5500_GPIO_Configuration
* ����    : W5500 GPIO��ʼ������
* ����    : ��
* ���    : ��
* ����ֵ  : ��
* ˵��    : ��
*******************************************************************************/
void W5500_GPIO_Configuration(void)
{
	GPIO_InitTypeDef GPIO_InitStructure;

    GPIO_InitStructure.mode = INPUT;
    GPIO_InitStructure.pin = 4;		//miso
	GPIO_Init(Gpio,&GPIO_InitStructure);
	
	GPIO_SetBits(W5500_SCS_PORT, W5500_SCS); //��W5500��SCSΪ�ߵ�ƽ
}


/*******************************************************************************
* ������  : SPI_ReadByte
* ����    : ��ȡһ���ֽ�SPI���ص�����
* ����    : ��
* ���    : ��
* ����ֵ  : ��ȡ���ļĴ�������
* ˵��    : ��
*******************************************************************************/
unsigned char SPI_Read_Byte(void)
{
	unsigned char i,rByte=0;
	
	GPIO_ResetBits(W5500_SCK_PORT,W5500_SCK);
	for(i=0;i<8;i++)
	{
		GPIO_SetBits(W5500_SCK_PORT,W5500_SCK);
		rByte<<=1;
		rByte|=GPIO_ReadInputDataBit(W5500_MISO_PORT,W5500_MISO);
		GPIO_ResetBits(W5500_SCK_PORT,W5500_SCK);
	}
	return rByte;
}

/*******************************************************************************
* ������  : SPI_SendByte
* ����    : SPI����һ���ֽ�����
* ����    : dt:�����͵�����
* ���    : ��
* ����ֵ  : ��
* ˵��    : ��
*******************************************************************************/
void SPI_Send_Byte(unsigned char dt)
{
	unsigned char i;
		
	for(i=0;i<8;i++)
	{	
		GPIO_ResetBits(W5500_SCK_PORT,W5500_SCK);
		if((dt<<i)&0x80)
			GPIO_SetBits(W5500_MOSI_PORT,W5500_MOSI);
		else
			GPIO_ResetBits(W5500_MOSI_PORT,W5500_MOSI);
		GPIO_SetBits(W5500_SCK_PORT,W5500_SCK);
	}
	GPIO_ResetBits(W5500_SCK_PORT,W5500_SCK);
}

/*******************************************************************************
* ������  : SPI1_Send_Short
* ����    : SPI1����2���ֽ�����(16λ)
* ����    : dat:�����͵�16λ����
* ���    : ��
* ����ֵ  : ��
* ˵��    : ��
*******************************************************************************/
void SPI_Send_Short(unsigned short dat)
{
	SPI_Send_Byte(dat/256);//д���ݸ�λ
	SPI_Send_Byte(dat);	//д���ݵ�λ
}

/*******************************************************************************
* ������  : Write_W5500_1Byte
* ����    : ͨ��SPI1��ָ����ַ�Ĵ���д1���ֽ�����
* ����    : reg:16λ�Ĵ�����ַ,dat:��д�������
* ���    : ��
* ����ֵ  : ��
* ˵��    : ��
*******************************************************************************/
void Write_W5500_1Byte(unsigned short reg, unsigned char dat)
{
	GPIO_ResetBits(W5500_SCS_PORT, W5500_SCS);//��W5500��SCSΪ�͵�ƽ

	SPI_Send_Short(reg);//ͨ��SPI1д16λ�Ĵ�����ַ
	SPI_Send_Byte(FDM1|RWB_WRITE|COMMON_R);//ͨ��SPI1д�����ֽ�,1���ֽ����ݳ���,д����,ѡ��ͨ�üĴ���
	SPI_Send_Byte(dat);//д1���ֽ�����

	GPIO_SetBits(W5500_SCS_PORT, W5500_SCS); //��W5500��SCSΪ�ߵ�ƽ
}

/*******************************************************************************
* ������  : Write_W5500_2Byte
* ����    : ͨ��SPI1��ָ����ַ�Ĵ���д2���ֽ�����
* ����    : reg:16λ�Ĵ�����ַ,dat:16λ��д�������(2���ֽ�)
* ���    : ��
* ����ֵ  : ��
* ˵��    : ��
*******************************************************************************/
void Write_W5500_2Byte(unsigned short reg, unsigned short dat)
{
	GPIO_ResetBits(W5500_SCS_PORT, W5500_SCS);//��W5500��SCSΪ�͵�ƽ
		
	SPI_Send_Short(reg);//ͨ��SPI1д16λ�Ĵ�����ַ
	SPI_Send_Byte(FDM2|RWB_WRITE|COMMON_R);//ͨ��SPI1д�����ֽ�,2���ֽ����ݳ���,д����,ѡ��ͨ�üĴ���
	SPI_Send_Short(dat);//д16λ����

	GPIO_SetBits(W5500_SCS_PORT, W5500_SCS); //��W5500��SCSΪ�ߵ�ƽ
}

/*******************************************************************************
* ������  : Write_W5500_nByte
* ����    : ͨ��SPI1��ָ����ַ�Ĵ���дn���ֽ�����
* ����    : reg:16λ�Ĵ�����ַ,*dat_ptr:��д�����ݻ�����ָ��,size:��д������ݳ���
* ���    : ��
* ����ֵ  : ��
* ˵��    : ��
*******************************************************************************/
void Write_W5500_nByte(unsigned short reg, unsigned char *dat_ptr, unsigned short size)
{
	unsigned short i;

	GPIO_ResetBits(W5500_SCS_PORT, W5500_SCS);//��W5500��SCSΪ�͵�ƽ	
		
	SPI_Send_Short(reg);//ͨ��SPI1д16λ�Ĵ�����ַ
	SPI_Send_Byte(VDM|RWB_WRITE|COMMON_R);//ͨ��SPI1д�����ֽ�,N���ֽ����ݳ���,д����,ѡ��ͨ�üĴ���

	for(i=0;i<size;i++)//ѭ������������size���ֽ�����д��W5500
	{
		SPI_Send_Byte(*dat_ptr++);//дһ���ֽ�����
	}

	GPIO_SetBits(W5500_SCS_PORT, W5500_SCS); //��W5500��SCSΪ�ߵ�ƽ
}

/*******************************************************************************
* ������  : Write_W5500_SOCK_1Byte
* ����    : ͨ��SPI1��ָ���˿ڼĴ���д1���ֽ�����
* ����    : s:�˿ں�,reg:16λ�Ĵ�����ַ,dat:��д�������
* ���    : ��
* ����ֵ  : ��
* ˵��    : ��
*******************************************************************************/
void Write_W5500_SOCK_1Byte(SOCKET s, unsigned short reg, unsigned char dat)
{
	GPIO_ResetBits(W5500_SCS_PORT, W5500_SCS);//��W5500��SCSΪ�͵�ƽ	
		
	SPI_Send_Short(reg);//ͨ��SPI1д16λ�Ĵ�����ַ
	SPI_Send_Byte(FDM1|RWB_WRITE|(s*0x20+0x08));//ͨ��SPI1д�����ֽ�,1���ֽ����ݳ���,д����,ѡ��˿�s�ļĴ���
	SPI_Send_Byte(dat);//д1���ֽ�����

	GPIO_SetBits(W5500_SCS_PORT, W5500_SCS); //��W5500��SCSΪ�ߵ�ƽ
}

/*******************************************************************************
* ������  : Write_W5500_SOCK_2Byte
* ����    : ͨ��SPI1��ָ���˿ڼĴ���д2���ֽ�����
* ����    : s:�˿ں�,reg:16λ�Ĵ�����ַ,dat:16λ��д�������(2���ֽ�)
* ���    : ��
* ����ֵ  : ��
* ˵��    : ��
*******************************************************************************/
void Write_W5500_SOCK_2Byte(SOCKET s, unsigned short reg, unsigned short dat)
{
	GPIO_ResetBits(W5500_SCS_PORT, W5500_SCS);//��W5500��SCSΪ�͵�ƽ
			
	SPI_Send_Short(reg);//ͨ��SPI1д16λ�Ĵ�����ַ
	SPI_Send_Byte(FDM2|RWB_WRITE|(s*0x20+0x08));//ͨ��SPI1д�����ֽ�,2���ֽ����ݳ���,д����,ѡ��˿�s�ļĴ���
	SPI_Send_Short(dat);//д16λ����

	GPIO_SetBits(W5500_SCS_PORT, W5500_SCS); //��W5500��SCSΪ�ߵ�ƽ
}

/*******************************************************************************
* ������  : Write_W5500_SOCK_4Byte
* ����    : ͨ��SPI1��ָ���˿ڼĴ���д4���ֽ�����
* ����    : s:�˿ں�,reg:16λ�Ĵ�����ַ,*dat_ptr:��д���4���ֽڻ�����ָ��
* ���    : ��
* ����ֵ  : ��
* ˵��    : ��
*******************************************************************************/
void Write_W5500_SOCK_4Byte(SOCKET s, unsigned short reg, unsigned char *dat_ptr)
{
	GPIO_ResetBits(W5500_SCS_PORT, W5500_SCS);//��W5500��SCSΪ�͵�ƽ
			
	SPI_Send_Short(reg);//ͨ��SPI1д16λ�Ĵ�����ַ
	SPI_Send_Byte(FDM4|RWB_WRITE|(s*0x20+0x08));//ͨ��SPI1д�����ֽ�,4���ֽ����ݳ���,д����,ѡ��˿�s�ļĴ���

	SPI_Send_Byte(*dat_ptr++);//д��1���ֽ�����
	SPI_Send_Byte(*dat_ptr++);//д��2���ֽ�����
	SPI_Send_Byte(*dat_ptr++);//д��3���ֽ�����
	SPI_Send_Byte(*dat_ptr++);//д��4���ֽ�����

	GPIO_SetBits(W5500_SCS_PORT, W5500_SCS); //��W5500��SCSΪ�ߵ�ƽ
}

/*******************************************************************************
* ������  : Read_W5500_1Byte
* ����    : ��W5500ָ����ַ�Ĵ�����1���ֽ�����
* ����    : reg:16λ�Ĵ�����ַ
* ���    : ��
* ����ֵ  : ��ȡ���Ĵ�����1���ֽ�����
* ˵��    : ��
*******************************************************************************/
unsigned char Read_W5500_1Byte(unsigned short reg)
{
	unsigned char i;

	GPIO_ResetBits(W5500_SCS_PORT, W5500_SCS);//��W5500��SCSΪ�͵�ƽ
			
	SPI_Send_Short(reg);//ͨ��SPI1д16λ�Ĵ�����ַ
	SPI_Send_Byte(FDM1|RWB_READ|COMMON_R);//ͨ��SPI1д�����ֽ�,1���ֽ����ݳ���,������,ѡ��ͨ�üĴ���

	i=SPI_Read_Byte();
	
	GPIO_SetBits(W5500_SCS_PORT, W5500_SCS);//��W5500��SCSΪ�ߵ�ƽ
	return i;//���ض�ȡ���ļĴ�������
}

/*******************************************************************************
* ������  : Read_W5500_SOCK_1Byte
* ����    : ��W5500ָ���˿ڼĴ�����1���ֽ�����
* ����    : s:�˿ں�,reg:16λ�Ĵ�����ַ
* ���    : ��
* ����ֵ  : ��ȡ���Ĵ�����1���ֽ�����
* ˵��    : ��
*******************************************************************************/
unsigned char Read_W5500_SOCK_1Byte(SOCKET s, unsigned short reg)
{
	unsigned char i;

	GPIO_ResetBits(W5500_SCS_PORT, W5500_SCS);//��W5500��SCSΪ�͵�ƽ
			
	SPI_Send_Short(reg);//ͨ��SPI1д16λ�Ĵ�����ַ
	SPI_Send_Byte(FDM1|RWB_READ|(s*0x20+0x08));//ͨ��SPI1д�����ֽ�,1���ֽ����ݳ���,������,ѡ��˿�s�ļĴ���

	i=SPI_Read_Byte();

	GPIO_SetBits(W5500_SCS_PORT, W5500_SCS);//��W5500��SCSΪ�ߵ�ƽ
	return i;//���ض�ȡ���ļĴ�������
}

/*******************************************************************************
* ������  : Read_W5500_SOCK_2Byte
* ����    : ��W5500ָ���˿ڼĴ�����2���ֽ�����
* ����    : s:�˿ں�,reg:16λ�Ĵ�����ַ
* ���    : ��
* ����ֵ  : ��ȡ���Ĵ�����2���ֽ�����(16λ)
* ˵��    : ��
*******************************************************************************/
unsigned short Read_W5500_SOCK_2Byte(SOCKET s, unsigned short reg)
{
	unsigned short i;

	GPIO_ResetBits(W5500_SCS_PORT, W5500_SCS);//��W5500��SCSΪ�͵�ƽ
			
	SPI_Send_Short(reg);//ͨ��SPI1д16λ�Ĵ�����ַ
	SPI_Send_Byte(FDM2|RWB_READ|(s*0x20+0x08));//ͨ��SPI1д�����ֽ�,2���ֽ����ݳ���,������,ѡ��˿�s�ļĴ���

	i=SPI_Read_Byte();

	i*=256;
	i+=SPI_Read_Byte();//��ȡ��λ����

	GPIO_SetBits(W5500_SCS_PORT, W5500_SCS);//��W5500��SCSΪ�ߵ�ƽ
	return i;//���ض�ȡ���ļĴ�������
}

/*******************************************************************************
* ������  : Read_SOCK_Data_Buffer
* ����    : ��W5500�������ݻ������ж�ȡ����
* ����    : s:�˿ں�,*dat_ptr:���ݱ��滺����ָ��
* ���    : ��
* ����ֵ  : ��ȡ�������ݳ���,rx_size���ֽ�
* ˵��    : ��
*******************************************************************************/
unsigned short Read_SOCK_Data_Buffer(SOCKET s, unsigned char *dat_ptr)
{
	unsigned short rx_size;
	unsigned short offset, offset1;
	unsigned short i;
	unsigned char j;

	rx_size=Read_W5500_SOCK_2Byte(s,Sn_RX_RSR);
	if(rx_size==0) return 0;//û���յ������򷵻�
	if(rx_size>1460) rx_size=1460;

	offset=Read_W5500_SOCK_2Byte(s,Sn_RX_RD);
	offset1=offset;
	offset&=(S_RX_SIZE-1);//����ʵ�ʵ������ַ

	GPIO_ResetBits(W5500_SCS_PORT, W5500_SCS);//��W5500��SCSΪ�͵�ƽ

	SPI_Send_Short(offset);//д16λ��ַ
	SPI_Send_Byte(VDM|RWB_READ|(s*0x20+0x18));//д�����ֽ�,N���ֽ����ݳ���,������,ѡ��˿�s�ļĴ���
	
	if((offset+rx_size)<S_RX_SIZE)//�������ַδ����W5500���ջ������Ĵ���������ַ
	{
		for(i=0;i<rx_size;i++)//ѭ����ȡrx_size���ֽ�����
		{
			// SPI_Send_Byte(0x00);//����һ��������
			j=SPI_Read_Byte();//��ȡ1���ֽ�����
			*dat_ptr=j;//����ȡ�������ݱ��浽���ݱ��滺����
			dat_ptr++;//���ݱ��滺����ָ���ַ����1
		}
	}
	else//�������ַ����W5500���ջ������Ĵ���������ַ
	{
		offset=S_RX_SIZE-offset;
		for(i=0;i<offset;i++)//ѭ����ȡ��ǰoffset���ֽ�����
		{
			j=SPI_Read_Byte();//��ȡ1���ֽ�����
			*dat_ptr=j;//����ȡ�������ݱ��浽���ݱ��滺����
			dat_ptr++;//���ݱ��滺����ָ���ַ����1
		}
		GPIO_SetBits(W5500_SCS_PORT, W5500_SCS); //��W5500��SCSΪ�ߵ�ƽ

		GPIO_ResetBits(W5500_SCS_PORT, W5500_SCS);//��W5500��SCSΪ�͵�ƽ

		SPI_Send_Short(0x00);//д16λ��ַ
		SPI_Send_Byte(VDM|RWB_READ|(s*0x20+0x18));//д�����ֽ�,N���ֽ����ݳ���,������,ѡ��˿�s�ļĴ���
		j=SPI_Read_Byte();

		for(;i<rx_size;i++)//ѭ����ȡ��rx_size-offset���ֽ�����
		{
			j=SPI_Read_Byte();//��ȡ1���ֽ�����
			*dat_ptr=j;//����ȡ�������ݱ��浽���ݱ��滺����
			dat_ptr++;//���ݱ��滺����ָ���ַ����1
		}
	}
	GPIO_SetBits(W5500_SCS_PORT, W5500_SCS); //��W5500��SCSΪ�ߵ�ƽ

	offset1+=rx_size;//����ʵ�������ַ,���´ζ�ȡ���յ������ݵ���ʼ��ַ
	Write_W5500_SOCK_2Byte(s, Sn_RX_RD, offset1);
	Write_W5500_SOCK_1Byte(s, Sn_CR, RECV);//����������������
	return rx_size;//���ؽ��յ����ݵĳ���
}

/*******************************************************************************
* ������  : Write_SOCK_Data_Buffer
* ����    : ������д��W5500�����ݷ��ͻ�����
* ����    : s:�˿ں�,*dat_ptr:���ݱ��滺����ָ��,size:��д�����ݵĳ���
* ���    : ��
* ����ֵ  : ��
* ˵��    : ��
*******************************************************************************/
void Write_SOCK_Data_Buffer(SOCKET s, unsigned char *dat_ptr, unsigned short size)
{
	unsigned short offset,offset1;
	unsigned short i;

	//�����UDPģʽ,�����ڴ�����Ŀ��������IP�Ͷ˿ں�
	if((Read_W5500_SOCK_1Byte(s,Sn_MR)&0x0f) != SOCK_UDP)//���Socket��ʧ��
	{		
		Write_W5500_SOCK_4Byte(s, Sn_DIPR, UDP_DIPR);//����Ŀ������IP  		
		Write_W5500_SOCK_2Byte(s, Sn_DPORTR, UDP_DPORT[0]*256+UDP_DPORT[1]);//����Ŀ�������˿ں�				
	}

	offset=Read_W5500_SOCK_2Byte(s,Sn_TX_WR);
	offset1=offset;
	offset&=(S_TX_SIZE-1);//����ʵ�ʵ������ַ

	GPIO_ResetBits(W5500_SCS_PORT, W5500_SCS);//��W5500��SCSΪ�͵�ƽ

	SPI_Send_Short(offset);//д16λ��ַ
	SPI_Send_Byte(VDM|RWB_WRITE|(s*0x20+0x10));//д�����ֽ�,N���ֽ����ݳ���,д����,ѡ��˿�s�ļĴ���

	if((offset+size)<S_TX_SIZE)//�������ַδ����W5500���ͻ������Ĵ���������ַ
	{
		for(i=0;i<size;i++)//ѭ��д��size���ֽ�����
		{
			SPI_Send_Byte(*dat_ptr++);//д��һ���ֽڵ�����		
		}
	}
	else//�������ַ����W5500���ͻ������Ĵ���������ַ
	{
		offset=S_TX_SIZE-offset;
		for(i=0;i<offset;i++)//ѭ��д��ǰoffset���ֽ�����
		{
			SPI_Send_Byte(*dat_ptr++);//д��һ���ֽڵ�����
		}
		GPIO_SetBits(W5500_SCS_PORT, W5500_SCS); //��W5500��SCSΪ�ߵ�ƽ

		GPIO_ResetBits(W5500_SCS_PORT, W5500_SCS);//��W5500��SCSΪ�͵�ƽ

		SPI_Send_Short(0x00);//д16λ��ַ
		SPI_Send_Byte(VDM|RWB_WRITE|(s*0x20+0x10));//д�����ֽ�,N���ֽ����ݳ���,д����,ѡ��˿�s�ļĴ���

		for(;i<size;i++)//ѭ��д��size-offset���ֽ�����
		{
			SPI_Send_Byte(*dat_ptr++);//д��һ���ֽڵ�����
		}
	}
	GPIO_SetBits(W5500_SCS_PORT, W5500_SCS); //��W5500��SCSΪ�ߵ�ƽ

	offset1+=size;//����ʵ�������ַ,���´�д���������ݵ��������ݻ���������ʼ��ַ
	Write_W5500_SOCK_2Byte(s, Sn_TX_WR, offset1);
	Write_W5500_SOCK_1Byte(s, Sn_CR, SEND);//����������������				
}

/*******************************************************************************
* ������  : W5500_Hardware_Reset
* ����    : Ӳ����λW5500
* ����    : ��
* ���    : ��
* ����ֵ  : ��
* ˵��    : W5500�ĸ�λ���ű��ֵ͵�ƽ����500us����,������ΧW5500
*******************************************************************************/
void W5500_Hardware_Reset(void)
{
	GPIO_ResetBits(W5500_RST_PORT, W5500_RST);//��λ��������
	Delay(200);
	GPIO_SetBits(W5500_RST_PORT, W5500_RST);//��λ��������
	Delay(200);
	while((Read_W5500_1Byte(PHYCFGR)&LINK)==0);//�ȴ���̫���������
}

/*******************************************************************************
* ������  : W5500_Init
* ����    : ��ʼ��W5500�Ĵ�������
* ����    : ��
* ���    : ��
* ����ֵ  : ��
* ˵��    : ��ʹ��W5500֮ǰ���ȶ�W5500��ʼ��
*******************************************************************************/
void W5500_Init(void)
{
	u8 i=0;

	Write_W5500_1Byte(MR, RST);//�����λW5500,��1��Ч,��λ���Զ���0
	Delay(10);//��ʱ10ms,�Լ�����ú���

	//��������(Gateway)��IP��ַ,Gateway_IPΪ4�ֽ�unsigned char����,�Լ����� 
	//ʹ�����ؿ���ʹͨ��ͻ�������ľ��ޣ�ͨ�����ؿ��Է��ʵ��������������Internet
	Write_W5500_nByte(GAR, Gateway_IP, 4);
			
	//������������(MASK)ֵ,SUB_MASKΪ4�ֽ�unsigned char����,�Լ�����
	//��������������������
	Write_W5500_nByte(SUBR,Sub_Mask,4);		
	
	//���������ַ,PHY_ADDRΪ6�ֽ�unsigned char����,�Լ�����,����Ψһ��ʶ�����豸�������ֵַ
	//�õ�ֵַ��Ҫ��IEEE���룬����OUI�Ĺ涨��ǰ3���ֽ�Ϊ���̴��룬�������ֽ�Ϊ��Ʒ���
	//����Լ����������ַ��ע���һ���ֽڱ���Ϊż��
	Write_W5500_nByte(SHAR,Phy_Addr,6);		

	//���ñ�����IP��ַ,IP_ADDRΪ4�ֽ�unsigned char����,�Լ�����
	//ע�⣬����IP�����뱾��IP����ͬһ�����������򱾻����޷��ҵ�����
	Write_W5500_nByte(SIPR,IP_Addr,4);		
	
	//���÷��ͻ������ͽ��ջ������Ĵ�С���ο�W5500�����ֲ�
	for(i=0;i<8;i++)
	{
		Write_W5500_SOCK_1Byte(i,Sn_RXBUF_SIZE, 0x02);//Socket Rx memory size=2k
		Write_W5500_SOCK_1Byte(i,Sn_TXBUF_SIZE, 0x02);//Socket Tx mempry size=2k
	}

	//��������ʱ�䣬Ĭ��Ϊ2000(200ms) 
	//ÿһ��λ��ֵΪ100΢��,��ʼ��ʱֵ��Ϊ2000(0x07D0),����200����
	Write_W5500_2Byte(RTR, 0x07d0);

	//�������Դ�����Ĭ��Ϊ8�� 
	//����ط��Ĵ��������趨ֵ,�������ʱ�ж�(��صĶ˿��жϼĴ����е�Sn_IR ��ʱλ(TIMEOUT)�á�1��)
	Write_W5500_1Byte(RCR,8);
}

/*******************************************************************************
* ������  : Detect_Gateway
* ����    : ������ط�����
* ����    : ��
* ���    : ��
* ����ֵ  : �ɹ�����TRUE(0xFF),ʧ�ܷ���FALSE(0x00)
* ˵��    : ��
*******************************************************************************/
unsigned char Detect_Gateway(void)
{
	unsigned char ip_adde[4];
	ip_adde[0]=IP_Addr[0]+1;
	ip_adde[1]=IP_Addr[1]+1;
	ip_adde[2]=IP_Addr[2]+1;
	ip_adde[3]=IP_Addr[3]+1;

	//������ؼ���ȡ���ص������ַ
	Write_W5500_SOCK_4Byte(0,Sn_DIPR,ip_adde);//��Ŀ�ĵ�ַ�Ĵ���д���뱾��IP��ͬ��IPֵ
	Write_W5500_SOCK_1Byte(0,Sn_MR,MR_TCP);//����socketΪTCPģʽ
	Write_W5500_SOCK_1Byte(0,Sn_CR,OPEN);//��Socket	
	Delay(5);//��ʱ5ms 	
	
	if(Read_W5500_SOCK_1Byte(0,Sn_SR) != SOCK_INIT)//���socket��ʧ��
	{
		Write_W5500_SOCK_1Byte(0,Sn_CR,CLOSE);//�򿪲��ɹ�,�ر�Socket
		return FALSE;//����FALSE(0x00)
	}

	Write_W5500_SOCK_1Byte(0,Sn_CR,CONNECT);//����SocketΪConnectģʽ						

	do
	{
		u8 j=0;
		j=Read_W5500_SOCK_1Byte(0,Sn_IR);//��ȡSocket0�жϱ�־�Ĵ���
		if(j!=0)
		Write_W5500_SOCK_1Byte(0,Sn_IR,j);
		Delay(5);//��ʱ5ms 
		if((j&IR_TIMEOUT) == IR_TIMEOUT)
		{
			return FALSE;	
		}
		else if(Read_W5500_SOCK_1Byte(0,Sn_DHAR) != 0xff)
		{
			Write_W5500_SOCK_1Byte(0,Sn_CR,CLOSE);//�ر�Socket
			return TRUE;							
		}
	}while(1);
}

/*******************************************************************************
* ������  : Socket_Init
* ����    : ָ��Socket(0~7)��ʼ��
* ����    : s:����ʼ���Ķ˿�
* ���    : ��
* ����ֵ  : ��
* ˵��    : ��
*******************************************************************************/
void Socket_Init(SOCKET s)
{
	//���÷�Ƭ���ȣ��ο�W5500�����ֲᣬ��ֵ���Բ��޸�	
	Write_W5500_SOCK_2Byte(0, Sn_MSSR, 1460);//����Ƭ�ֽ���=1460(0x5b4)
	//����ָ���˿�
	switch(s)
	{
		case 0:
			//���ö˿�0�Ķ˿ں�
			Write_W5500_SOCK_2Byte(0, Sn_PORT, S0_Port[0]*256+(S0_Port[1]++));
			//���ö˿�0Ŀ��(Զ��)�˿ں�
			Write_W5500_SOCK_2Byte(0, Sn_DPORTR, S0_DPort[0]*256+S0_DPort[1]);
			//���ö˿�0Ŀ��(Զ��)IP��ַ
			Write_W5500_SOCK_4Byte(0, Sn_DIPR, S0_DIP);			
			
			break;

		case 1:
            //���ö˿�1�Ķ˿ں�
			Write_W5500_SOCK_2Byte(1, Sn_PORT, S1_Port[0]*256+(S1_Port[1]++));
			//���ö˿�1Ŀ��(Զ��)�˿ں�
			Write_W5500_SOCK_2Byte(1, Sn_DPORTR, S1_DPort[0]*256+S1_DPort[1]);
			//���ö˿�1Ŀ��(Զ��)IP��ַ
			Write_W5500_SOCK_4Byte(1, Sn_DIPR, S1_DIP);
			break;

		case 2:
			break;

		case 3:
			break;

		case 4:
			break;

		case 5:
			break;

		case 6:
			break;

		case 7:
			break;

		default:
			break;
	}
}

/*******************************************************************************
* ������  : Socket_Connect
* ����    : ����ָ��Socket(0~7)Ϊ�ͻ�����Զ�̷���������
* ����    : s:���趨�Ķ˿�
* ���    : ��
* ����ֵ  : �ɹ�����TRUE(0xFF),ʧ�ܷ���FALSE(0x00)
* ˵��    : ������Socket�����ڿͻ���ģʽʱ,���øó���,��Զ�̷�������������
*			����������Ӻ���ֳ�ʱ�жϣ��������������ʧ��,��Ҫ���µ��øó�������
*			�ó���ÿ����һ��,�������������һ������
*******************************************************************************/
unsigned char Socket_Connect(SOCKET s)
{
	Write_W5500_SOCK_1Byte(s,Sn_MR,MR_TCP);//����socketΪTCPģʽ
	Write_W5500_SOCK_1Byte(s,Sn_CR,OPEN);//��Socket
	Delay(5);//��ʱ5ms
	if(Read_W5500_SOCK_1Byte(s,Sn_SR)!=SOCK_INIT)//���socket��ʧ��
	{
		Write_W5500_SOCK_1Byte(s,Sn_CR,CLOSE);//�򿪲��ɹ�,�ر�Socket
		return FALSE;//����FALSE(0x00)
	}
	Write_W5500_SOCK_1Byte(s,Sn_CR,CONNECT);//����SocketΪConnectģʽ
	return TRUE;//����TRUE,���óɹ�
}

/*******************************************************************************
* ������  : Socket_Listen
* ����    : ����ָ��Socket(0~7)��Ϊ�������ȴ�Զ������������
* ����    : s:���趨�Ķ˿�
* ���    : ��
* ����ֵ  : �ɹ�����TRUE(0xFF),ʧ�ܷ���FALSE(0x00)
* ˵��    : ������Socket�����ڷ�����ģʽʱ,���øó���,�ȵ�Զ������������
*			�ó���ֻ����һ��,��ʹW5500����Ϊ������ģʽ
*******************************************************************************/
unsigned char Socket_Listen(SOCKET s)
{
	Write_W5500_SOCK_1Byte(s,Sn_MR,MR_TCP);//����socketΪTCPģʽ 
	Write_W5500_SOCK_1Byte(s,Sn_CR,OPEN);//��Socket	
	Delay(5);//��ʱ5ms
	if(Read_W5500_SOCK_1Byte(s,Sn_SR)!=SOCK_INIT)//���socket��ʧ��
	{
		Write_W5500_SOCK_1Byte(s,Sn_CR,CLOSE);//�򿪲��ɹ�,�ر�Socket
		return FALSE;//����FALSE(0x00)
	}	
	Write_W5500_SOCK_1Byte(s,Sn_CR,LISTEN);//����SocketΪ����ģʽ	
	Delay(5);//��ʱ5ms
	if(Read_W5500_SOCK_1Byte(s,Sn_SR)!=SOCK_LISTEN)//���socket����ʧ��
	{
		Write_W5500_SOCK_1Byte(s,Sn_CR,CLOSE);//���ò��ɹ�,�ر�Socket
		return FALSE;//����FALSE(0x00)
	}

	return TRUE;

	//���������Socket�Ĵ򿪺�������������,����Զ�̿ͻ����Ƿ�������������,����Ҫ�ȴ�Socket�жϣ�
	//���ж�Socket�������Ƿ�ɹ����ο�W5500�����ֲ��Socket�ж�״̬
	//�ڷ���������ģʽ����Ҫ����Ŀ��IP��Ŀ�Ķ˿ں�
}

/*******************************************************************************
* ������  : Socket_UDP
* ����    : ����ָ��Socket(0~7)ΪUDPģʽ
* ����    : s:���趨�Ķ˿�
* ���    : ��
* ����ֵ  : �ɹ�����TRUE(0xFF),ʧ�ܷ���FALSE(0x00)
* ˵��    : ���Socket������UDPģʽ,���øó���,��UDPģʽ��,Socketͨ�Ų���Ҫ��������
*			�ó���ֻ����һ�Σ���ʹW5500����ΪUDPģʽ
*******************************************************************************/
unsigned char Socket_UDP(SOCKET s)
{
	Write_W5500_SOCK_1Byte(s,Sn_MR,MR_UDP);//����SocketΪUDPģʽ*/
	Write_W5500_SOCK_1Byte(s,Sn_CR,OPEN);//��Socket*/
	Delay(5);//��ʱ5ms
	if(Read_W5500_SOCK_1Byte(s,Sn_SR)!=SOCK_UDP)//���Socket��ʧ��
	{
		Write_W5500_SOCK_1Byte(s,Sn_CR,CLOSE);//�򿪲��ɹ�,�ر�Socket
		return FALSE;//����FALSE(0x00)
	}
	else
		return TRUE;

	//���������Socket�Ĵ򿪺�UDPģʽ����,������ģʽ��������Ҫ��Զ��������������
	//��ΪSocket����Ҫ��������,�����ڷ�������ǰ����������Ŀ������IP��Ŀ��Socket�Ķ˿ں�
	//���Ŀ������IP��Ŀ��Socket�Ķ˿ں��ǹ̶���,�����й�����û�иı�,��ôҲ��������������
}

/*******************************************************************************
* ������  : W5500_Interrupt_Process
* ����    : W5500�жϴ��������
* ����    : ��
* ���    : ��
* ����ֵ  : ��
* ˵��    : ��
*******************************************************************************/
void W5500_Interrupt_Process(void)
{
	unsigned char i,j;


    
//IntDispose:

//	i=Read_W5500_1Byte(SIR);//��ȡ�˿��жϱ�־�Ĵ���
//    
//	if((i & S0_INT) == S0_INT)//Socket0�¼����� 
//	{
		j=Read_W5500_SOCK_1Byte(0,Sn_IR);//��ȡSocket0�жϱ�־�Ĵ���
		Write_W5500_SOCK_1Byte(0,Sn_IR,j);
		if(j&IR_CON)//��TCPģʽ��,Socket0�ɹ����� 
		{
			S0_State|=S_CONN;//��������״̬0x02,�˿�������ӣ�����������������
             printf("\r\n�ɹ���������֪����������\r\n");
		}
		if(j&IR_DISCON)//��TCPģʽ��Socket�Ͽ����Ӵ���
		{
			Write_W5500_SOCK_1Byte(0,Sn_CR,CLOSE);//�رն˿�,�ȴ����´����� 
			Socket_Init(0);		//ָ��Socket(0~7)��ʼ��,��ʼ���˿�0
			S0_State=0;//��������״̬0x00,�˿�����ʧ��
            printf("\r\n��֪�������ӶϿ�������\r\n");
		}
		if(j&IR_SEND_OK)//Socket0���ݷ������,�����ٴ�����S_tx_process()������������ 
		{
			S0_Data|=S_TRANSMITOK;//�˿ڷ���һ�����ݰ���� 
            //printf("\r\nSocket0���ͳɹ�������\r\n");
		}
		if(j&IR_RECV)//Socket���յ�����,��������S_rx_process()���� 
		{
			S0_Data|=S_RECEIVE;//�˿ڽ��յ�һ�����ݰ�
            //printf("\r\nSocket0���ճɹ�������\r\n");
		}
		if(j&IR_TIMEOUT)//Socket���ӻ����ݴ��䳬ʱ���� 
		{
			Write_W5500_SOCK_1Byte(0,Sn_CR,CLOSE);// �رն˿�,�ȴ����´����� 
			S0_State=0;//��������״̬0x00,�˿�����ʧ��
            printf("\r\nSocket0 timeout!!!\r\n");
		}
//	}
    
    
//    if((i & S1_INT) == S1_INT)//Socket1�¼����� 
//	{
		j=Read_W5500_SOCK_1Byte(1,Sn_IR);//��ȡSocket1�жϱ�־�Ĵ���
		Write_W5500_SOCK_1Byte(1,Sn_IR,j);
		if(j&IR_CON)//��TCPģʽ��,Socket1�ɹ����� 
		{
			S1_State|=S_CONN;//��������״̬0x02,�˿�������ӣ�����������������
             printf("\r\n�ɹ�������OneNet\r\n");
		}
		if(j&IR_DISCON)//��TCPģʽ��Socket�Ͽ����Ӵ���
		{
			Write_W5500_SOCK_1Byte(1,Sn_CR,CLOSE);//�رն˿�,�ȴ����´����� 
			Socket_Init(1);		//ָ��Socket(0~7)��ʼ��,��ʼ���˿�1
			S1_State=0;//��������״̬0x00,�˿�����ʧ��
            printf("\r\nOneNet���ӶϿ�������\r\n");
		}
		if(j&IR_SEND_OK)//Socket1���ݷ������,�����ٴ�����S_tx_process()������������ 
		{
			S1_Data|=S_TRANSMITOK;//�˿ڷ���һ�����ݰ���� 
            //printf("\r\nSocket1���ͳɹ�������\r\n");
		}
		if(j&IR_RECV)//Socket���յ�����,��������S_rx_process()���� 
		{
			S1_Data|=S_RECEIVE;//�˿ڽ��յ�һ�����ݰ�
            //printf("\r\nSocket1���ճɹ�������\r\n");
		}
		if(j&IR_TIMEOUT)//Socket���ӻ����ݴ��䳬ʱ���� 
		{
			Write_W5500_SOCK_1Byte(1,Sn_CR,CLOSE);// �رն˿�,�ȴ����´����� 
			S1_State=0;//��������״̬0x00,�˿�����ʧ��
            printf("\r\nSocket1 timeout!!!\r\n");
		}
//	}

//	if(Read_W5500_1Byte(SIR) != 0) 
//		goto IntDispose;
}


/*******************************************************************************
* ������  : Delay
* ����    : ��ʱ����(ms)
* ����    : d:��ʱϵ������λΪ����
* ���    : ��
* ����    : �� 
* ˵��    : ��ʱ������systick��ʱ��������1����ļ�����ʵ�ֵ�
*******************************************************************************/
void Delay(unsigned int d)
{
	delay_ms(d);
}

/*******************************************************************************
* ������  : System_Initialization
* ����    : ϵͳ��ʼ������
* ����    : ��
* ���    : ��
* ����    : �� 
* ˵��    : ��
*******************************************************************************/
void System_Initialization(void)
{
	delay_init();
    uart_init();
//    timer_init();
	W5500_GPIO_Configuration();	//W5500 GPIO��ʼ������
}

/*******************************************************************************
* ������  : Load_Net_Parameters
* ����    : װ���������
* ����    : ��
* ���    : ��
* ����ֵ  : ��
* ˵��    : ���ء����롢�����ַ������IP��ַ���˿ںš�Ŀ��IP��ַ��Ŀ�Ķ˿ںš��˿ڹ���ģʽ
*******************************************************************************/
void Load_Net_Parameters(void)
{
	Gateway_IP[0] = 192;//�������ز���
	Gateway_IP[1] = 168;
	Gateway_IP[2] = 0;
	Gateway_IP[3] = 1;

	Sub_Mask[0]=255;//������������
	Sub_Mask[1]=255;
	Sub_Mask[2]=255;
	Sub_Mask[3]=0;

	Phy_Addr[0]=0x0c;//���������ַ
	Phy_Addr[1]=0x29;
	Phy_Addr[2]=0xab;
	Phy_Addr[3]=0x7c;
	Phy_Addr[4]=0x00;
	Phy_Addr[5]=0x01;

	IP_Addr[0]=192;//���ر���IP��ַ
	IP_Addr[1]=168;
	IP_Addr[2]=0;
	IP_Addr[3]=2;

	S0_Port[0] = 0x13;//���ض˿�0�Ķ˿ں�5000 
	S0_Port[1] = 0x88;

	S1_Port[0] = 0x13;//���ض˿�0�Ķ˿ں�5000 
	S1_Port[1] = 0x90;

    S0_DIP[0]=116;      //���ض˿�0��Ŀ��IP��ַ
	S0_DIP[1]=62;
	S0_DIP[2]=81;
	S0_DIP[3]=138;

	S0_DPort[0] = 0x00;//���ض˿�0��Ŀ�Ķ˿ں�80
	S0_DPort[1] = 0x50;
    
	S1_DIP[0]=183;      //���ض˿�1��Ŀ��IP��ַ
	S1_DIP[1]=230;
	S1_DIP[2]=40;
	S1_DIP[3]=33;

	S1_DPort[0] = 0x00;//���ض˿�1��Ŀ�Ķ˿ں�80
	S1_DPort[1] = 0x50;

	S0_Mode=TCP_CLIENT;//���ض˿�0�Ĺ���ģʽ,TCP�ͻ���ģʽ
    S1_Mode=TCP_CLIENT;
}

/*******************************************************************************
* ������  : W5500_Initialization
* ����    : W5500��ʼ������
* ����    : ��
* ���    : ��
* ����ֵ  : ��
* ˵��    : ��
*******************************************************************************/
void W5500_Initialization(void)
{
	W5500_Init();		//��ʼ��W5500�Ĵ�������
    if(Detect_Gateway()!=0xff)//������ط�����
        printf("\r\n������ط�����!\r\n");
	Socket_Init(0);		//ָ��Socket(0~7)��ʼ��,��ʼ���˿�0
    Socket_Init(1);
}

/*******************************************************************************
* ������  : W5500_Socket_Set
* ����    : W5500�˿ڳ�ʼ������
* ����    : ��
* ���    : ��
* ����ֵ  : ��
* ˵��    : �ֱ�����4���˿�,���ݶ˿ڹ���ģʽ,���˿�����TCP��������TCP�ͻ��˻�UDPģʽ.
*			�Ӷ˿�״̬�ֽ�Socket_State�����ж϶˿ڵĹ������
*******************************************************************************/
void W5500_Socket_Set(void)
{
//    printf("\r\n����Ƿ�Ͽ�����.....\r\n");
	if(S0_State==0)//�˿�0��ʼ������
	{
		if(S0_Mode==TCP_SERVER)//TCP������ģʽ 
		{
			if(Socket_Listen(0)==TRUE)
				S0_State=S_INIT;
			else
				S0_State=0;
		}
		else if(S0_Mode==TCP_CLIENT)//TCP�ͻ���ģʽ 
		{
			if(Socket_Connect(0)==TRUE)
            {
				S0_State=S_INIT;
                printf("\r\nSocket0��ʼ���ɹ�������\r\n");
            }
			else
            {
				S0_State=0;
                printf("\r\n��������֪����ʧ�ܣ�����\r\n");
            }
		}
		else//UDPģʽ 
		{
			if(Socket_UDP(0)==TRUE)
				S0_State=S_INIT|S_CONN;
			else
				S0_State=0;
		}
	}
//    else
//        printf("\r\n��������δ�Ͽ�.....\r\n");
    
    
    if(S1_State==0)//�˿�1��ʼ������
	{
		if(S1_Mode==TCP_SERVER)//TCP������ģʽ 
		{
			if(Socket_Listen(1)==TRUE)
				S1_State=S_INIT;
			else
				S1_State=0;
		}
		else if(S1_Mode==TCP_CLIENT)//TCP�ͻ���ģʽ 
		{
			if(Socket_Connect(1)==TRUE)
			{
				S1_State=S_INIT;
                printf("\r\nSocket1��ʼ���ɹ�������\r\n");
            }
			else
            {
				S1_State=0;
                printf("\r\n������OneNetʧ�ܣ�����\r\n");
            }
		}
		else//UDPģʽ 
		{
			if(Socket_UDP(1)==TRUE)
				S1_State=S_INIT|S_CONN;
			else
				S1_State=0;
		}
	}
//    else
//        printf("\r\nOneNet����δ�Ͽ�.....\r\n");
}


//������ݵ�״̬
u8 GetDatapointStatus(char* buf,char* datapoint,char* data)
{
    u8 i;
    char *p = strstr(buf,datapoint);

    if(p == NULL)
        return 0;
    p+=strlen(datapoint)+3;
    for(i=0;*(p+i)!='\"';i++)
        *(data+i)=*(p+i);
    *(data+i)='\0';
    return i;
}

/*******************************************************************************
* ������  : Process_Socket_Data
* ����    : W5500���ղ����ͽ��յ�������
* ����    : s:�˿ں�
* ���    : ��
* ����ֵ  : ��
* ˵��    : �������ȵ���S_rx_process()��W5500�Ķ˿ڽ������ݻ�������ȡ����,
*			Ȼ�󽫶�ȡ�����ݴ�Rx_Buffer������Temp_Buffer���������д���
*			������ϣ������ݴ�Temp_Buffer������Tx_Buffer������������S_tx_process()
*			�������ݡ�
*******************************************************************************/
void Process_Socket_Data(SOCKET s)
{
//    memset(Rx_Buffer,0,sizeof(Rx_Buffer));
	Read_SOCK_Data_Buffer(s, Rx_Buffer);
    

    GetDatapointStatus((char*)Rx_Buffer,"code",text_from_internet);
    
    GetDatapointStatus((char*)Rx_Buffer,"last_update",time_from_internet);
    
    GetDatapointStatus((char*)Rx_Buffer,"temperature",temp_from_internet);
 

    
    switch((u8)(*text_from_internet-0x30))
    {
        case 0:
        case 1:
        case 2:
        case 3:text_from_internet = "��";break;
        case 4:text_from_internet = "����";break;
        case 5:
        case 6:text_from_internet = "������";break;
        case 7:
        case 8:text_from_internet = "�󲿷ֶ���";break;
        case 9:text_from_internet = "��";break;
        case 10:text_from_internet = "����";break;
        case 11:text_from_internet = "������";break;
        case 12:text_from_internet = "��������б���";break;
        case 13:text_from_internet = "С��";break;
        case 14:text_from_internet = "����";break;
        case 15:text_from_internet = "����";break;
        case 16:text_from_internet = "����";break;
        case 17:text_from_internet = "����";break;
        case 18:text_from_internet = "�ش���";break;
        case 19:text_from_internet = "����";break;
        case 20:text_from_internet = "���ѩ";break;
        case 21:text_from_internet = "��ѩ";break;
        case 22:text_from_internet = "Сѩ";break;
        case 23:text_from_internet = "��ѩ";break;
        case 24:text_from_internet = "��ѩ";break;
        case 25:text_from_internet = "��ѩ";break;
        case 26:text_from_internet = "����";break;
        case 27:text_from_internet = "��ɳ";break;
        case 28:text_from_internet = "ɳ����";break;
        case 29:text_from_internet = "ǿɳ����";break;
        case 30:text_from_internet = "��";break;
        case 31:text_from_internet = "��";break;
        case 32:text_from_internet = "��";break;
        case 33:text_from_internet = "���";break;
        case 34:text_from_internet = "쫷�";break;
        case 35:text_from_internet = "�ȴ��籩";break;
        case 36:text_from_internet = "�����";break;
        case 37:text_from_internet = "��";break;
        case 38:text_from_internet = "��";break;
        case 99:text_from_internet = "δ֪";break;
        default:text_from_internet = "δ֪";break;
    }

}
