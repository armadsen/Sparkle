#include "SULog.h"

static BOOL SULoggingEnabled = NO;

void SUEnableLogging(BOOL flag)
{
	SULoggingEnabled = flag;
}

void SULog(NSString* format, ...)
{
	if (!SULoggingEnabled) { return; }
	va_list ap;
	va_start(ap, format);
	NSString *theStr = [[[NSString alloc] initWithFormat: format arguments: ap] autorelease];
	NSLog(@"%@", theStr);
}
