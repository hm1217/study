
#include "my32.h"
#include "delay.h"
#include "uart.h"
#include "timer.h"

unsigned int W5500_Send_Delay_Counter = 0;

int main()
{
    delay_init();
    timer_init();
    uart_init();
    
    printf("hello world!\r\n");

    while(1)
    {
        if(W5500_Send_Delay_Counter==10)
        {
            printf("hello world!\r\n");
            W5500_Send_Delay_Counter = 0;
        }
//        Gpio->DR = 0x40;
//        delay_ms(1000);
//        Gpio->DR = 0x40;
//        delay_ms(1000);
    }
    
}

