#include "JAPrint.h"


void JAPrint(CFStringRef format, ...)
{
	va_list				args;
	
	va_start(args, format);
	JAPrintWithArguments(format, args);
	va_end(args);
}


void JAPrintWithArguments(CFStringRef format, va_list args)
{
	JAFPrintWithArguments(stdout, format, args);
}


void JAFPrint(FILE *file, CFStringRef format, ...)
{
	va_list				args;
	
	va_start(args, format);
	JAFPrintWithArguments(file, format, args);
	va_end(args);
}


void JAFPrintWithArguments(FILE *file, CFStringRef format, va_list args)
{
	CFStringRef			string = NULL;
	char				*cString = NULL;
	Boolean				freeBuffer = FALSE;
	CFIndex				size;
	
	string = CFStringCreateWithFormatAndArguments(kCFAllocatorDefault, NULL, format, args);
	if (string != NULL)
	{
		cString = (char *)CFStringGetCStringPtr(string, JAPRINT_ENCODING);
		if (cString == NULL)
		{
			size = CFStringGetMaximumSizeForEncoding(CFStringGetLength(string), JAPRINT_ENCODING) + 1;
			cString = malloc(size);
			if (cString != NULL)
			{
				if (CFStringGetCString(string, cString, size, JAPRINT_ENCODING))
				{
					freeBuffer = TRUE;
				}
				else
				{
					free(cString);
					cString = NULL;
				}
			}
			
			if (cString != NULL)
			{
				fputs(cString, file);
			}
			
			if (freeBuffer)  free(cString);
		}
		
		CFRelease(string);
	}
}
