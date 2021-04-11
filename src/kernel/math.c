#include "math.h"

uint_64 power(int mantissa, uint base) {
    uint_64 result = mantissa;

    if (base == 0)
        return 1;

    base--;
    while (base--)
        result *= mantissa;
    return result;
}
