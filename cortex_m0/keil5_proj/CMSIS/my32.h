#ifndef __MY32_H
#define __MY32_H

#ifdef __cplusplus
 extern "C" {
#endif 

	 
#define __STM32F0XX_STDPERIPH_VERSION_MAIN   (0x01) /*!< [31:24] main version */
#define __STM32F0XX_STDPERIPH_VERSION_SUB1   (0x00) /*!< [23:16] sub1 version */
#define __STM32F0XX_STDPERIPH_VERSION_SUB2   (0x00) /*!< [15:8]  sub2 version */
#define __STM32F0XX_STDPERIPH_VERSION_RC     (0x00) /*!< [7:0]  release candidate */ 
#define __STM32F0XX_STDPERIPH_VERSION        ((__STM32F0XX_STDPERIPH_VERSION_MAIN << 24)\
                                             |(__STM32F0XX_STDPERIPH_VERSION_SUB1 << 16)\
                                             |(__STM32F0XX_STDPERIPH_VERSION_SUB2 << 8)\
                                             |(__STM32F0XX_STDPERIPH_VERSION_RC))


/** @addtogroup Configuration_section_for_CMSIS
  * @{
  */

/**
 * @brief STM32F0xx Interrupt Number Definition, according to the selected device 
 *        in @ref Library_configuration_section 
 */
#define __CM0_REV                 0 /*!< Core Revision r0p0                            */
#define __MPU_PRESENT             0 /*!< STM32F0xx do not provide MPU                  */
#define __NVIC_PRIO_BITS          2 /*!< STM32F0xx uses 2 Bits for the Priority Levels */
#define __Vendor_SysTickConfig    0 /*!< Set to 1 if different SysTick Config is used  */	 

//中断通道
typedef enum IRQn
{
/******  Cortex-M3 Processor Exceptions Numbers ***************************************************/
  NonMaskableInt_IRQn         = -14,    /*!< 2 Non Maskable Interrupt                             */
  MemoryManagement_IRQn       = -12,    /*!< 4 Cortex-M3 Memory Management Interrupt              */
  BusFault_IRQn               = -11,    /*!< 5 Cortex-M3 Bus Fault Interrupt                      */
  UsageFault_IRQn             = -10,    /*!< 6 Cortex-M3 Usage Fault Interrupt                    */
  SVCall_IRQn                 = -5,     /*!< 11 Cortex-M3 SV Call Interrupt                       */
  DebugMonitor_IRQn           = -4,     /*!< 12 Cortex-M3 Debug Monitor Interrupt                 */
  PendSV_IRQn                 = -2,     /*!< 14 Cortex-M3 Pend SV Interrupt                       */
  SysTick_IRQn                = -1,     /*!< 15 Cortex-M3 System Tick Interrupt                   */

/******  STM32 specific Interrupt Numbers *********************************************************/
  UART_IRQn                   = 0,
  TIM_IRQn                    = 1,
  SPI_IRQn                    = 2,
  EXTI0_IRQn                  = 3,
  EXTI1_IRQn                  = 4,
  EXTI2_IRQn                  = 5,
  EXTI3_IRQn                  = 6
} IRQn_Type;

	 
	 	 
#include "core_cm0.h"
//#include "system_cm0.h"
#include <stdint.h>


//类型别名定义
typedef int32_t  s32;
typedef int16_t s16;
typedef int8_t  s8;

typedef const int32_t sc32;   /*!< Read Only */
typedef const int16_t sc16;   /*!< Read Only */
typedef const int8_t sc8;     /*!< Read Only */

typedef __IO int32_t  vs32;
typedef __IO int16_t  vs16;
typedef __IO int8_t   vs8;

typedef __I int32_t vsc32;    /*!< Read Only */
typedef __I int16_t vsc16;    /*!< Read Only */
typedef __I int8_t vsc8;      /*!< Read Only */

typedef uint32_t  u32;
typedef uint16_t u16;
typedef uint8_t  u8;

typedef const uint32_t uc32;  /*!< Read Only */
typedef const uint16_t uc16;  /*!< Read Only */
typedef const uint8_t uc8;    /*!< Read Only */

typedef __IO uint32_t  vu32;
typedef __IO uint16_t vu16;
typedef __IO uint8_t  vu8;

typedef __I uint32_t vuc32;   /*!< Read Only */
typedef __I uint16_t vuc16;   /*!< Read Only */
typedef __I uint8_t vuc8;     /*!< Read Only */


//状态枚举
typedef enum 
{
	RESET = 0, 
	SET = !RESET
} 
FlagStatus, ITStatus;

typedef enum 
{
	DISABLE = 0, 
	ENABLE = !DISABLE
} FunctionalState;

typedef enum 
{
	ERROR = 0, 
	SUCCESS = !ERROR
} ErrorStatus;


//uart寄存器
typedef struct 
{
	volatile unsigned long SR;
	volatile unsigned long DR;
	volatile unsigned long BRR;
	volatile unsigned long CR;
} UART_TypeDef;

//timer寄存器
typedef struct 
{
	volatile unsigned long SR;
	volatile unsigned long PSC;
	volatile unsigned long ARR;
	volatile unsigned long CR;
} TIMER_TypeDef;

//spi寄存器
typedef struct 
{
	volatile unsigned long SR;
	volatile unsigned long DR;
	volatile unsigned long PSC;
	volatile unsigned long CR;
} SPI_TypeDef;

//gpio寄存器
typedef struct 
{
	volatile unsigned long MR;
	volatile unsigned long DR;
} GPIO_TypeDef;


//外设模块基地址
#define Gpio       ((GPIO_TypeDef  *)0x40000000)
#define	Uart  	   ((UART_TypeDef  *)0x40100000)
#define	Timer  	   ((TIMER_TypeDef *)0x40200000)
#define	Spi  	   ((SPI_TypeDef   *)0x40300000)
//#define Led	       *(volatile unsigned long *)0x40400000

	
#include "cm0_conf.h"

#ifdef __cplusplus
 extern "C" }
#endif 

#endif
