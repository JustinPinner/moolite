#import <stdint.h>

#define OOINLINE static inline


#ifdef __GNUC__
OOINLINE uint32_t OORoundUpToPowerOf2(uint32_t value)
{
	return 0x80000000 >> (__builtin_clz(value - 1) - 1);
}
#elif OO_PPC && defined(__MWERKS__)
OOINLINE uint32_t OORoundUpToPowerOf2(uint32_t value)
{
	return 0x80000000 >> (__cntlzw(value - 1) - 1);
}
#else
OOINLINE uint32_t OORoundUpToPowerOf2(uint32_t value)
{
	value -= 1;
	value |= (value >> 1);
	value |= (value >> 2);
	value |= (value >> 4);
	value |= (value >> 8);
	value |= (value >> 16);
	return value + 1;
}
#endif
