#include "OOConsoleConnection.h"
#include "OOTCPStreamDecoder.h"
#include "OODebugTCPConsoleProtocol.h"
#include "JAAutoreleasePool.h"

#include <stdlib.h>


#define LOG_PACKETS		0


#if LOG_PACKETS
static void LogPacket(CFStringRef label, CFDictionaryRef packet);
#else
#define LogPacket(label, packet) do {} while (0)
#endif


typedef enum
{
	kStateWaitingForConnection,
	kStateConnected,
	kStateClosing,
	kStateDisconnected
} OOConsoleConnectionState;


struct OOConsoleConnection
{
	OOTCPStreamDecoderRef			decoder;
	
	OOConsoleConnectionCallbacks	cb;
	void							*cbInfo;
	
	uint8_t							vFormat, vMajor, vMinor, noteUnknownPackets;
	
	CFStringRef						consoleIdentityString;
	CFMutableDictionaryRef			configuration;
	OOConsoleConnectionState		state;
};


static void Error(OOConsoleConnectionRef connection, OOALStringRef format, ...);

static void SendWithOneParameter(OOConsoleConnectionRef connection, CFStringRef packetType, CFStringRef paramKey, CFPropertyListRef paramValue);
// static void SendWithDictionary(OOConsoleConnectionRef connection, CFStringRef packetType, CFDictionaryRef parameters);
static void SendPacketDictionary(OOConsoleConnectionRef connection, CFDictionaryRef packet);

static OOConsoleRGBColor GetSpecificColor(OOConsoleConnectionRef connection, CFStringRef colorKey);

static void DecoderPacket(void *cbInfo, OOALStringRef packetType, OOALDictionaryRef packet);
static void DecoderError(void *cbInfo, OOALStringRef errorDesc);

static void HandleRequestConnectionPacket(OOConsoleConnectionRef connection, CFDictionaryRef packet);
static void HandleCloseConnectionPacket(OOConsoleConnectionRef connection, CFDictionaryRef packet);
static void HandleConsoleOutputPacket(OOConsoleConnectionRef connection, CFDictionaryRef packet);
static void HandleClearConsolePacket(OOConsoleConnectionRef connection, CFDictionaryRef packet);
static void HandleShowConsolePacket(OOConsoleConnectionRef connection, CFDictionaryRef packet);
static void HandleNoteConfigurationPacket(OOConsoleConnectionRef connection, CFDictionaryRef packet);
static void HandleNoteConfigurationChangePacket(OOConsoleConnectionRef connection, CFDictionaryRef packet);
static void HandlePingPacket(OOConsoleConnectionRef connection, CFDictionaryRef packet);
static void HandlePongPacket(OOConsoleConnectionRef connection, CFDictionaryRef packet);

static void RejectConnection(OOConsoleConnectionRef connection, CFStringRef message);


OOConsoleConnectionRef OOConsoleConnectionCreate(CFStringRef consoleIdentityString, OOConsoleConnectionCallbacks *callbacks, void *cbInfo)
{
	OOConsoleConnectionRef		result = NULL;
	
	// Sanity check: we need at least SendData and ConsoleOutput callbacks to be meaningful.
	if (callbacks == NULL || callbacks->SendData == NULL || callbacks->ConsoleOutput == NULL)  return NULL;
	
	result = malloc(sizeof *result);
	if (result == NULL)  return result;
	
	result->decoder = OOTCPStreamDecoderCreate(DecoderPacket, DecoderError, NULL, result);
	if (result->decoder == NULL)
	{
		free(result);
		return NULL;
	}
	
	result->cb = *callbacks;
	result->cbInfo = cbInfo;
	result->consoleIdentityString = consoleIdentityString ? CFRetain(consoleIdentityString) : NULL;
	result->state = kStateWaitingForConnection;
	
	return result;
}


void OOConsoleConnectionDestroy(OOConsoleConnectionRef connection)
{
	if (connection == NULL)  return;
	
	if (connection->state == kStateConnected)  OOConsoleConnectionClose(connection, CFSTR("Server-side connection object destroyed while open."));
	
	if (connection->cb.Finalize != NULL)  connection->cb.Finalize(connection->cbInfo);
	if (connection->consoleIdentityString != NULL)  CFRelease(connection->consoleIdentityString);
	if (connection->configuration != NULL)  CFRelease(connection->configuration);
	
	free(connection);
}


void OOConsoleConnectionClose(OOConsoleConnectionRef connection, CFStringRef message)
{
	if (connection != NULL && connection->state == kStateConnected)
	{
		SendWithOneParameter(connection, kOOTCPPacket_CloseConnection, kOOTCPMessage, message);
		connection->state = kStateDisconnected;
	}
}


Boolean OOConsoleConnectionIsOpen(OOConsoleConnectionRef connection)
{
	return connection != NULL && connection->state == kStateConnected;
}


void OOConsoleConnectionReceiveData(OOConsoleConnectionRef connection, CFDataRef data)
{
	if (connection == NULL || data == NULL || connection->state == kStateDisconnected)  return;
	
	OOConsoleConnectionReceiveBytes(connection, OOALDataGetBytePtr(data), OOALDataGetLength(data));
}

void OOConsoleConnectionReceiveBytes(OOConsoleConnectionRef connection, const void *bytes, size_t length)
{
	if (connection == NULL)  return;
	
	OOTCPStreamDecoderReceiveBytes(connection->decoder, bytes, length);
}


void OOConsoleConnectionPerformCommand(OOConsoleConnectionRef connection, CFStringRef command)
{
	if (connection == NULL || command == NULL)  return;
	
	if (connection->state != kStateConnected)
	{
		Error(connection, CFSTR("Attempt to send command to console when not connected."));
		return;
	}
	
	SendWithOneParameter(connection, kOOTCPPacket_PerformCommand, kOOTCPMessage, command);
}


CFPropertyListRef OOConsoleConnectionGetConfiguration(OOConsoleConnectionRef connection, CFStringRef key)
{
	if (!OOConsoleConnectionIsOpen(connection) || connection->configuration == NULL || key == NULL)  return NULL;
	
	return CFDictionaryGetValue(connection->configuration, key);
}


void OOConsoleConnectionSetConfiguration(OOConsoleConnectionRef connection, CFStringRef key, CFPropertyListRef value)
{
	CFDictionaryRef					changed = NULL;
	CFArrayRef						removed = NULL;
	
	if (!OOConsoleConnectionIsOpen(connection) || key == NULL)  return;
	
	if (value != NULL)
	{
		changed = CFDictionaryCreate(kCFAllocatorDefault, (const void **)&key, (const void **)&value, 1, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
		SendWithOneParameter(connection, kOOTCPPacket_NoteConfigurationChange, kOOTCPConfiguration, changed);
		CFRelease(changed);
	}
	else
	{
		removed = CFArrayCreate(kCFAllocatorDefault, (const void **)&key, 1, &kCFTypeArrayCallBacks);
		SendWithOneParameter(connection, kOOTCPPacket_NoteConfigurationChange, kOOTCPRemovedConfigurationKeys, removed);
		CFRelease(changed);
	}
}


OOConsoleRGBColor OOConsoleConnectionGetForegroundColor(OOConsoleConnectionRef connection, CFStringRef colorKey)
{
	OOConsoleRGBColor				color;
	
	color = GetSpecificColor(connection, CFFMTSTR("-foreground-color", colorKey));
	if (color.r < -1)  color = GetSpecificColor(connection, CFFMTSTR("-foreground-colour", colorKey));
	if (color.r < -1)  color = GetSpecificColor(connection, CFSTR("general-foreground-color"));
	if (color.r < -1)  color = GetSpecificColor(connection, CFSTR("general-foreground-colour"));
	if (color.r < -1)
	{
		color.r = color.g = color.b = 0.0f;
	}
	
	return color;
}


OOConsoleRGBColor OOConsoleConnectionGetBackgroundColor(OOConsoleConnectionRef connection, CFStringRef colorKey)
{
	OOConsoleRGBColor				color;
	
	color = GetSpecificColor(connection, CFFMTSTR("-background-color", colorKey));
	if (color.r < -1)  color = GetSpecificColor(connection, CFFMTSTR("-background-colour", colorKey));
	if (color.r < -1)  color = GetSpecificColor(connection, CFSTR("general-background-color"));
	if (color.r < -1)  color = GetSpecificColor(connection, CFSTR("general-background-colour"));
	if (color.r < -1)
	{
		color.r = color.g = color.b = 1.0f;
	}
	
	return color;
}


static void Error(OOConsoleConnectionRef connection, OOALStringRef format, ...)
{
	va_list							args;
	CFStringRef						string = NULL;
	
	if (connection == NULL || connection->cb.Error == NULL || format == NULL)  return;
	
	va_start(args, format);
	string = CFStringCreateWithFormatAndArguments(kCFAllocatorDefault, NULL, format, args);
	va_end(args);
	
	if (string != NULL)
	{
		connection->cb.Error(connection->cbInfo, string);
		CFRelease(string);
	}
}


static void SendWithOneParameter(OOConsoleConnectionRef connection, CFStringRef packetType, CFStringRef paramKey, CFPropertyListRef paramValue)
{
	CFDictionaryRef					packet = NULL;
	const void						*keys[2] = { kOOTCPPacketType, paramKey };
	const void						*values[2] = { packetType, paramValue };
	
	if (connection == NULL || packetType == NULL)  return;
	
	packet = CFDictionaryCreate(kCFAllocatorDefault, keys, values, (paramKey != NULL && paramValue != NULL) ? 2 : 1, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
	if (packet != NULL)
	{
		SendPacketDictionary(connection, packet);
		CFRelease(packet);
	}
}

/*
static void SendWithDictionary(OOConsoleConnectionRef connection, CFStringRef packetType, CFDictionaryRef parameters)
{
	CFMutableDictionaryRef			packet = NULL;
	
	if (connection == NULL || packetType == NULL)  return;
	if (parameters != NULL)
	{
		packet = CFDictionaryCreateMutableCopy(kCFAllocatorDefault, CFDictionaryGetCount(parameters) + 1, parameters);
		if (packet != NULL)
		{
			SendPacketDictionary(connection, packet);
			CFRelease(packet);
		}
	}
	else
	{
		SendWithOneParameter(connection, packetType, NULL, NULL);
	}
}*/


static void SendPacketDictionary(OOConsoleConnectionRef connection, CFDictionaryRef packet)
{
	CFDataRef						packetData = NULL;
	uint32_t						length;
	uint8_t							header[4];
	
	if (connection == NULL || packet == NULL)  return;
	
	packetData = CFPropertyListCreateXMLData(kCFAllocatorDefault, packet);
	if (packetData != NULL)
	{
		LogPacket(CFSTR("OUT"), packet);
		
		length = CFDataGetLength(packetData);
		if (length != 0)
		{
			header[0] = (length & 0xFF000000) >> 24;
			header[1] = (length & 0x00FF0000) >> 16;
			header[2] = (length & 0x0000FF00) >> 8;
			header[3] = length & 0x000000FF;
			
			connection->cb.SendData(connection->cbInfo, header, 4);
			connection->cb.SendData(connection->cbInfo, CFDataGetBytePtr(packetData), length);
		}
		CFRelease(packetData);
	}
}


static OOConsoleRGBColor GetSpecificColor(OOConsoleConnectionRef connection, CFStringRef colorKey)
{
	OOConsoleRGBColor				color = { -2.0f, 0.0f, 0.0f };
	CFArrayRef						components = NULL;
	CFNumberRef						r = NULL;
	CFNumberRef						g = NULL;
	CFNumberRef						b = NULL;
	
	components = OOConsoleConnectionGetConfiguration(connection, colorKey);
	if (components != NULL && CFGetTypeID(components) == CFArrayGetTypeID() && CFArrayGetCount(components) >= 3)
	{
		r = CFArrayGetValueAtIndex(components, 0);
		g = CFArrayGetValueAtIndex(components, 1);
		b = CFArrayGetValueAtIndex(components, 2);
		if (CFGetTypeID(r) == CFNumberGetTypeID() &&
			CFGetTypeID(g) == CFNumberGetTypeID() &&
			CFGetTypeID(b) == CFNumberGetTypeID())
		{
			CFNumberGetValue(r, kCFNumberFloatType, &color.r);
			CFNumberGetValue(g, kCFNumberFloatType, &color.g);
			CFNumberGetValue(b, kCFNumberFloatType, &color.b);
			
			color.r = fminf(fmaxf(color.r, 0.0f), 1.0f);
			color.g = fminf(fmaxf(color.g, 0.0f), 1.0f);
			color.b = fminf(fmaxf(color.b, 0.0f), 1.0f);
		}
	}
	
	return color;
}


static void DecoderPacket(void *cbInfo, OOALStringRef packetType, OOALDictionaryRef packet)
{
	OOConsoleConnectionRef			connection = cbInfo;
	
	if (connection == NULL)  return;
	
	LogPacket(CFSTR("IN"), packet);
	
#define PACKET_CASE(x) else if (CFEqual(packetType, kOOTCPPacket_##x))  { Handle##x##Packet(connection, packet); }
	if (0)  {}
	PACKET_CASE(RequestConnection)
	PACKET_CASE(CloseConnection)
	PACKET_CASE(ConsoleOutput)
	PACKET_CASE(ClearConsole)
	PACKET_CASE(ShowConsole)
	PACKET_CASE(NoteConfiguration)
	PACKET_CASE(NoteConfigurationChange)
	PACKET_CASE(Ping)
	PACKET_CASE(Pong)
	else
	{
		if (connection->noteUnknownPackets)  Error(connection, CFSTR("Unhandled packet type %@."), packetType);
	}
}


static void DecoderError(void *cbInfo, OOALStringRef errorDesc)
{
	OOConsoleConnectionRef			connection = cbInfo;
	
	if (connection != NULL && connection->cb.Error != NULL)
	{
		connection->cb.Error(connection->cbInfo, errorDesc);
	}
}


static void HandleRequestConnectionPacket(OOConsoleConnectionRef connection, CFDictionaryRef packet)
{
	CFNumberRef						protocolVersionCF = NULL;
	uint32_t						protocolVersion;
	
	if (connection->state == kStateWaitingForConnection)
	{
		// Get protocol verison.
		protocolVersionCF = CFDictionaryGetValue(packet, kOOTCPProtocolVersion);
		if (protocolVersionCF == NULL || CFGetTypeID(protocolVersionCF) != CFNumberGetTypeID())
		{
			RejectConnection(connection, CFSTR("Protocol error: invalid Request Connection packet (no protocol version)."));
		}
		else
		{
			CFNumberGetValue(protocolVersionCF, kCFNumberSInt32Type, &protocolVersion);
			connection->vFormat = OOTCP_VERSION_FORMAT(protocolVersion);
			connection->vMajor = OOTCP_VERSION_MAJOR(protocolVersion);
			connection->vMinor = OOTCP_VERSION_MINOR(protocolVersion);
			
			// We currently support protocol version 1:1.x
			if (connection->vFormat != kOOTCPProtocolVersionPListFormat || connection->vMajor != 1)
			{
				RejectConnection(connection, CFFMTSTR("Unsupported protocol version: %u:%u.%u.", connection->vFormat, connection->vMajor, connection->vMinor));
			}
			else
			{
				// Approve connection.
				connection->noteUnknownPackets = connection->vMinor <= 0;
				connection->state = kStateConnected;
				
				SendWithOneParameter(connection, kOOTCPPacket_ApproveConnection, kOOTCPConsoleIdentity, connection->consoleIdentityString);
				if (connection->consoleIdentityString != NULL)
				{
					CFRelease(connection->consoleIdentityString);
					connection->consoleIdentityString = NULL;
				}
				
				if (connection->cb.ConnectionEstablished != NULL)  connection->cb.ConnectionEstablished(connection->cbInfo, CFDictionaryGetValue(packet, kOOTCPOoliteVersion));
			}
		}
	}
	else
	{
		Error(connection, CFSTR("Protocol error: got Request Connection packet while not waiting for connection, ignoring."));
	}
}


static void HandleCloseConnectionPacket(OOConsoleConnectionRef connection, CFDictionaryRef packet)
{
	CFStringRef						message = NULL;
	
	if (!OOConsoleConnectionIsOpen(connection))  return;
	
	connection->state = kStateClosing;
	message = CFDictionaryGetValue(packet, kOOTCPMessage);
	if (connection->cb.Close != NULL)  connection->cb.Close(connection->cbInfo, TRUE, message);
	connection->state = kStateDisconnected;
	
	if (connection->configuration != NULL)
	{
		CFRelease(connection->configuration);
		connection->configuration = NULL;
	}
}


static void HandleConsoleOutputPacket(OOConsoleConnectionRef connection, CFDictionaryRef packet)
{
	CFStringRef						message = NULL;
	CFStringRef						colorKey = NULL;
	
	if (!OOConsoleConnectionIsOpen(connection))  return;
	
	message = CFDictionaryGetValue(packet, kOOTCPMessage);
	if (message == NULL)
	{
		Error(connection, CFSTR("Protocol error: Console Output packet with no message."));
		return;
	}
	
	colorKey = CFDictionaryGetValue(packet, kOOTCPColorKey);
	if (colorKey == NULL)  colorKey = CFSTR("general");
	
	// TODO: handle emphasis ranges.
	
	connection->cb.ConsoleOutput(connection->cbInfo, message, colorKey, NULL, 0);
}


static void HandleClearConsolePacket(OOConsoleConnectionRef connection, CFDictionaryRef packet)
{
	if (!OOConsoleConnectionIsOpen(connection))  return;
	
	if (connection->cb.ClearConsole)  connection->cb.ClearConsole(connection->cbInfo);
}


static void HandleShowConsolePacket(OOConsoleConnectionRef connection, CFDictionaryRef packet)
{
	if (!OOConsoleConnectionIsOpen(connection))  return;
	
	if (connection->cb.ShowConsole)  connection->cb.ShowConsole(connection->cbInfo);
}


static void HandleNoteConfigurationPacket(OOConsoleConnectionRef connection, CFDictionaryRef packet)
{
	if (connection->configuration != NULL)  CFDictionaryRemoveAllValues(connection->configuration);
	HandleNoteConfigurationChangePacket(connection, packet);
}


static void HandleNoteConfigurationChangePacket(OOConsoleConnectionRef connection, CFDictionaryRef packet)
{
	CFDictionaryRef					set = NULL;
	CFArrayRef						remove = NULL;
	CFIndex							i, count;
	const void						**keys = NULL;
	const void						**values = NULL;
	CFTypeRef						key = NULL;
	CFMutableArrayRef				changed = NULL;
	
	if (connection->configuration == NULL)  connection->configuration = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
	if (connection->configuration == NULL)  return;
	
	changed = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
	if (changed == NULL)  return;
	
	// Set the keys in kOOTCPConfiguration, assuming it's a dictionary.
	set = CFDictionaryGetValue(packet, kOOTCPConfiguration);
	if (set != NULL && CFGetTypeID(set) == CFDictionaryGetTypeID())
	{
		count = CFDictionaryGetCount(set);
		if (count > 0)
		{
			// Get all the keys...
			keys = malloc(sizeof *keys * count);
			values = malloc(sizeof *values * count);
			if (keys != NULL && values != NULL)
			{
				CFDictionaryGetKeysAndValues(set, keys, values);
				
				// ..and set them in configuration.
				for (i = 0; i != count; ++i)
				{
					key = keys[i];
					if (CFGetTypeID(key) == CFArrayGetTypeID())
					{
						CFDictionarySetValue(connection->configuration, key, values[i]);
						CFArrayAppendValue(changed, key);
					}
				}
			}
			free(keys);
			free(values);
		}
	}
	
	remove = CFDictionaryGetValue(packet, kOOTCPRemovedConfigurationKeys);
	if (remove != NULL && CFGetTypeID(set) == CFArrayGetTypeID())
	{
		count = CFArrayGetCount(remove);
		for (i = 0; i != count; ++i)
		{
			key = CFArrayGetValueAtIndex(remove, i);
			if (CFGetTypeID(key) == CFArrayGetTypeID())
			{
				CFDictionaryRemoveValue(connection->configuration, key);
				CFArrayAppendValue(changed, key);
			}
		}
	}
	
	if (connection->cb.ConfigurationChanged != NULL && CFArrayGetCount(changed) != 0)
	{
		connection->cb.ConfigurationChanged(connection->cbInfo, changed);
	}
	CFRelease(changed);
}


static void HandlePingPacket(OOConsoleConnectionRef connection, CFDictionaryRef packet)
{
	CFStringRef						message = NULL;
	
	message = CFDictionaryGetValue(packet, kOOTCPMessage);
	SendWithOneParameter(connection, kOOTCPPacket_Pong, kOOTCPMessage, message);
}


static void HandlePongPacket(OOConsoleConnectionRef connection, CFDictionaryRef packet)
{
	// Ignore; we don't send pings so shouldn't get any pongs.
}


static void RejectConnection(OOConsoleConnectionRef connection, CFStringRef message)
{
	connection->state = kStateClosing;
	SendWithOneParameter(connection, kOOTCPPacket_RejectConnection, kOOTCPMessage, message);
	if (connection->cb.Close != NULL)  connection->cb.Close(connection->cbInfo, FALSE, message);
	connection->state = kStateDisconnected;
	
	if (connection->configuration != NULL)
	{
		CFRelease(connection->configuration);
		connection->configuration = NULL;
	}
}


#if LOG_PACKETS
#include "JAPrint.h"

static void LogPacket(CFStringRef label, CFDictionaryRef packet)
{
	static Boolean			triedToOpen = FALSE;
	static FILE				*file = NULL;
	CFDataRef				data = NULL;
	
	if (!triedToOpen)
	{
		triedToOpen = TRUE;
		file = fopen("traffic log.txt", "w");
	}
	if (file == NULL)  return;
	
	data = CFPropertyListCreateXMLData(kCFAllocatorDefault, packet);
	
	JAFPrint(file, CFSTR("* %@:\n"), label);
	fwrite(CFDataGetBytePtr(data), CFDataGetLength(data), 1, file);
	JAFPrint(file, CFSTR("\n\n"));
}
#endif
