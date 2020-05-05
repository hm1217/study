; 栈配置

Stack_Size      EQU     0x00000800

                AREA    STACK, NOINIT, READWRITE, ALIGN=3
Stack_Mem       SPACE   Stack_Size
__initial_sp


; 堆配置

Heap_Size       EQU     0x00000200

                AREA    HEAP, NOINIT, READWRITE, ALIGN=3
__heap_base
Heap_Mem        SPACE   Heap_Size
__heap_limit

                PRESERVE8
                THUMB


; 复位时，内核中断向量表映射到地址0
                AREA    RESET, DATA, READONLY
                EXPORT  __Vectors
                EXPORT  __Vectors_End
                EXPORT  __Vectors_Size


__Vectors       DCD     __initial_sp                   ; Top of Stack
                DCD     Reset_Handler                  ; Reset Handler
                DCD     NMI_Handler                    ; NMI Handler
                DCD     HardFault_Handler              ; Hard Fault Handler
                DCD     MemManage_Handler              ; MemManage Handler
                DCD     BusFault_Handler           	   ; Bus Fault Handler
                DCD     UsageFault_Handler        	   ; Usage Fault Handler
                DCD     0                              ; Reserved
                DCD     0                              ; Reserved
                DCD     0                              ; Reserved
                DCD     0                              ; Reserved
                DCD     SVC_Handler                    ; SVCall Handler
                DCD     DebugMon_Handler               ; Debug Monitor Handler
                DCD     0                              ; Reserved
                DCD     PendSV_Handler             	   ; PendSV Handler
                DCD     SysTick_Handler                ; SysTick Handler

                ; External Interrupts
                DCD     UART_IRQHandler
                DCD     TIM_IRQHandler
                DCD     SPI_IRQHandler
                DCD     EXTI0_IRQHandler
                DCD     EXTI1_IRQHandler
                DCD     EXTI2_IRQHandler
                DCD     EXTI3_IRQHandler
                DCD     0
                DCD     0
                DCD     0
                DCD     0
                DCD     0
                DCD     0
                DCD     0
                DCD     0
__Vectors_End
__Vectors_Size  EQU  __Vectors_End - __Vectors


                AREA    |.text|, CODE, READONLY

; 复位中断函数

Reset_Handler   PROC
                EXPORT  Reset_Handler
				IMPORT  __main
				 
				LDR		R0, =__main
				BX		R0

				ENDP
					 
				ALIGN

NMI_Handler     PROC
                EXPORT  NMI_Handler                [WEAK]
                B       .
                ENDP
HardFault_Handler\
                PROC
                EXPORT  HardFault_Handler          [WEAK]
                B       .
                ENDP
MemManage_Handler\
                PROC
                EXPORT  MemManage_Handler          [WEAK]
                B       .
                ENDP
BusFault_Handler\
                PROC
                EXPORT  BusFault_Handler           [WEAK]
                B       .
                ENDP
UsageFault_Handler\
                PROC
                EXPORT  UsageFault_Handler         [WEAK]
                B       .
                ENDP
SVC_Handler     PROC
                EXPORT  SVC_Handler                [WEAK]
                B       .
                ENDP
DebugMon_Handler\
                PROC
                EXPORT  DebugMon_Handler           [WEAK]
                B       .
                ENDP
PendSV_Handler  PROC
                EXPORT  PendSV_Handler             [WEAK]
                B       .
                ENDP
SysTick_Handler PROC
                EXPORT  SysTick_Handler            [WEAK]
                B       .
                ENDP

Default_Handler PROC	
				EXPORT  UART_IRQHandler            [WEAK]
                EXPORT  TIM_IRQHandler             [WEAK]
                EXPORT  SPI_IRQHandler             [WEAK]
                
UART_IRQHandler
TIM_IRQHandler
SPI_IRQHandler
EXTI0_IRQHandler
EXTI1_IRQHandler
EXTI2_IRQHandler
EXTI3_IRQHandler


                B       .
                ENDP

                ALIGN					


; 用户堆栈初始化
                IF      :DEF:__MICROLIB           
                
                EXPORT  __initial_sp
                EXPORT  __heap_base
                EXPORT  __heap_limit
                
                ELSE
                
                IMPORT  __use_two_region_memory
                EXPORT  __user_initial_stackheap
                 
__user_initial_stackheap

                LDR     R0, =  Heap_Mem
                LDR     R1, =(Stack_Mem + Stack_Size)
                LDR     R2, = (Heap_Mem +  Heap_Size)
                LDR     R3, = Stack_Mem
                BX      LR

                ALIGN

                ENDIF
				 
				 
				END


