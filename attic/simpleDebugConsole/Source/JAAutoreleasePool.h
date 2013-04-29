/*	JAAutoreleasePool
	
	Emulate NSAutoreleasePool behaviour for Core Foundation objects, making
	reference counting somewhat bearable.
	
	This maintains a stack of autorelease pools per thread. Note that a
	JAAutoreleasePool is not itself a CF object.
*/

#include <CoreFoundation/CoreFoundation.h>


typedef struct JAAutoreleasePool *JAAutoreleasePoolRef;


JAAutoreleasePoolRef JACreateAutoreleasePool(void);
void JADestroyAutoreleasePool(JAAutoreleasePoolRef pool);

// As a convenience, returns the ojbect it was passed.
CFTypeRef JAAutorelease(CFTypeRef object);


#ifndef JAAUTORELEASEPOOL_THREAD_SAFE
#ifdef THREAD_SAFE
#define JAAUTORELEASEPOOL_THREAD_SAFE THREAD_SAFE
#else
#define JAAUTORELEASEPOOL_THREAD_SAFE 1
#endif
#endif


#define CFFMTSTR(format, ...)  JAAutorelease(CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR(format), ## __VA_ARGS__))

