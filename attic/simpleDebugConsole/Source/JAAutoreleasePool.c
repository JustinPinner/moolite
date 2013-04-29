#include "JAAutoreleasePool.h"
#include "JAPrint.h"

static JAAutoreleasePoolRef PoolForThisThread(void);
static void SetPoolForThisThread(JAAutoreleasePoolRef pool);


struct JAAutoreleasePool
{
	CFMutableArrayRef		objects;
	JAAutoreleasePoolRef	link;
};


static Boolean sInited = FALSE;


JAAutoreleasePoolRef JACreateAutoreleasePool(void)
{
	JAAutoreleasePoolRef		result = NULL;
	
	result = malloc(sizeof *result);
	if (result != NULL)
	{
		result->objects = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
		if (result->objects == NULL)
		{
			free(result);
			result = NULL;
		}
	}
	if (result != NULL)
	{
		result->link = PoolForThisThread();
		SetPoolForThisThread(result);
	}
	
	return result;
}


void JADestroyAutoreleasePool(JAAutoreleasePoolRef pool)
{
	JAAutoreleasePoolRef		current = NULL;
	
	if (pool == NULL)  return;
	
	current = PoolForThisThread();
	if (pool != current)
	{
		JAFPrint(stderr, CFSTR("Attempt to destroy autorelease pool which isn't current. Ignoring."));
		return;
	}
	
	SetPoolForThisThread(pool->link);
	CFRelease(pool->objects);
	free(pool);
}


CFTypeRef JAAutorelease(CFTypeRef object)
{
	JAAutoreleasePoolRef		pool = NULL;
	
	if (object == NULL)  return NULL;
	
	pool = PoolForThisThread();
	if (pool == NULL)
	{
		JAFPrint(stderr, CFSTR("Attempt to autorelease object while no autorelease pool is in effect. The object will be leaked. Object: %@."), object);
		return object;
	}
	
	CFArrayAppendValue(pool->objects, object);
	CFRelease(object);		// The array now owns a reference, which will be released when the array is.
	
	return object;
}



#if JAAUTORELEASEPOOL_THREAD_SAFE

#import <assert.h>
#import <pthread.h>

static void InitJAAutoreleasePool(void) __attribute__((constructor));
static void JAAutoreleasePoolDestructor(void *pool);


static pthread_key_t sCurrentPoolKey;

static void InitJAAutoreleasePool(void)
{
	assert(pthread_key_create(&sCurrentPoolKey, JAAutoreleasePoolDestructor) == 0);
	sInited = TRUE;
}


static void JAAutoreleasePoolDestructor(void *pool)
{
	if (pool != NULL)
	{
		JAFPrint(stderr, CFSTR("A thread was destroyed with an autorelease pool in place! Objects may be leaked."));
	}
}


static JAAutoreleasePoolRef PoolForThisThread(void)
{
	assert(sInited);
	
	return pthread_getspecific(sCurrentPoolKey);
}


static void SetPoolForThisThread(JAAutoreleasePoolRef pool)
{
	assert(sInited);
	
	assert(pthread_setspecific(sCurrentPoolKey, pool) == 0);
}

#else	// !JAAUTORELEASEPOOL_THREAD_SAFE

static JAAutoreleasePoolRef sCurrent = NULL;


static JAAutoreleasePoolRef PoolForThisThread(void)
{
	assert(sInited);
	
	return sCurrent;
}


static void SetPoolForThisThread(JAAutoreleasePoolRef pool)
{
	assert(sInited);
	
	sCurrent = pool;
}

#endif
