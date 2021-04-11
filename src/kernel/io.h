#pragma once

#include "types.h"

/* I/O Ports */
void outb(ushort port, uchar val);
uchar inb(ushort port);