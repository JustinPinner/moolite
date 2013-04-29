/*	JAPrint
	
	Printf-like functions fore CoreFoundation objects, with support for %@
	formatting.
*/

#include <CoreFoundation/CoreFoundation.h>
#include <stdio.h>
#include <stdarg.h>


#define JAPRINT_ENCODING	kCFStringEncodingUTF8


void JAPrint(CFStringRef format, ...);
void JAPrintWithArguments(CFStringRef format, va_list args);

#define JAPrintFlush()  fflush(stdout)

void JAFPrint(FILE *file, CFStringRef format, ...);
void JAFPrintWithArguments(FILE *file, CFStringRef format, va_list args);


#define JAPrintC(format, ...)		JAPrint(CFSTR(format), ## __VA_ARGS__)
#define JAPrintErr(format, ...)		JAFPrint(stderr, format, ## __VA_ARGS__)
#define JAPrintErrC(format, ...)	JAFPrint(stderr, CFSTR(format), ## __VA_ARGS__)
