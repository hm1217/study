#ifndef	__GPIO_H
#define	__GPIO_H

#include "cm0_gpio.h"

#define Led gpio->DR

void gpio_init(void);

#endif
