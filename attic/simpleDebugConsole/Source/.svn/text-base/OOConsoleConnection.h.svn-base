/*	OOConsoleConnection.h
	
	Psuedo-object to handle communication with Oolite.
	
	This object does not deal with networking. It merely converts between data
	streams and the high-level representation of a connection.
*/

#ifndef INCLUDED_OOConsoleConnection_h
#define INCLUDED_OOConsoleConnection_h

#include <CoreFoundation/CoreFoundation.h>

typedef struct OOConsoleConnection *OOConsoleConnectionRef;


typedef struct
{
	float				r, g, b;
} OOConsoleRGBColor;


// Callbacks.
typedef void (*OOConsoleConnectionSendDataCallback)(void *cbInfo, const void *bytes, size_t length);
typedef void (*OOConsoleConnectionConsoleOutputCallback)(void *cbInfo, CFStringRef text, CFStringRef colorKey, CFRange *emphasisRanges, uint32_t emphasisRangeCount);
typedef void (*OOConsoleConnectionClearConsoleCallback)(void *cbInfo);
typedef void (*OOConsoleConnectionShowConsoleCallback)(void *cbInfo);
typedef void (*OOConsoleConnectionConfigurationChangedCallback)(void *cbInfo, CFArrayRef configurationKeys);
typedef void (*OOConsoleConnectionConnectionEstablishedCallback)(void *cbInfo, CFStringRef ooliteVersion);
typedef void (*OOConsoleConnectionCloseCallback)(void *cbInfo, Boolean closedRemotely, CFStringRef message);
typedef void (*OOConsoleConnectionErrorCallback)(void *cbInfo, CFStringRef message);
typedef void (*OOConsoleConnectionFinalizeCallback)(void *cbInfo);

typedef struct
{
	OOConsoleConnectionSendDataCallback					SendData;
	OOConsoleConnectionConsoleOutputCallback			ConsoleOutput;
	OOConsoleConnectionClearConsoleCallback				ClearConsole;
	OOConsoleConnectionShowConsoleCallback				ShowConsole;
	OOConsoleConnectionConfigurationChangedCallback		ConfigurationChanged;
	OOConsoleConnectionConnectionEstablishedCallback	ConnectionEstablished;
	OOConsoleConnectionCloseCallback					Close;
	OOConsoleConnectionErrorCallback					Error;
	OOConsoleConnectionFinalizeCallback					Finalize;
} OOConsoleConnectionCallbacks;


OOConsoleConnectionRef OOConsoleConnectionCreate(CFStringRef consoleIdentityString, OOConsoleConnectionCallbacks *callbacks, void *cbInfo);
void OOConsoleConnectionDestroy(OOConsoleConnectionRef connection);	// Will close the connection if open (and thus may call SendData callback).
void OOConsoleConnectionClose(OOConsoleConnectionRef connection, CFStringRef message);

Boolean OOConsoleConnectionIsOpen(OOConsoleConnectionRef connection);

void OOConsoleConnectionReceiveData(OOConsoleConnectionRef connection, CFDataRef data);
void OOConsoleConnectionReceiveBytes(OOConsoleConnectionRef connection, const void *bytes, size_t length);

void OOConsoleConnectionPerformCommand(OOConsoleConnectionRef connection, CFStringRef command);

CFPropertyListRef OOConsoleConnectionGetConfiguration(OOConsoleConnectionRef connection, CFStringRef key);
void OOConsoleConnectionSetConfiguration(OOConsoleConnectionRef connection, CFStringRef key, CFPropertyListRef value);

OOConsoleRGBColor OOConsoleConnectionGetForegroundColor(OOConsoleConnectionRef connection, CFStringRef colorKey);
OOConsoleRGBColor OOConsoleConnectionGetBackgroundColor(OOConsoleConnectionRef connection, CFStringRef colorKey);

#endif /* INCLUDED_OOConsoleConnection_h */
