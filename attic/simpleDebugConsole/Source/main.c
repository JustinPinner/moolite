#include <CoreFoundation/CoreFoundation.h>
#include "JAPrint.h"
#include "JAAutoreleasePool.h"
#include "OOConsoleConnection.h"
#include "OODebugTCPConsoleProtocol.h"

#include <stdio.h>
#include <stdlib.h>
#include <sys/socket.h>
#include <sys/select.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <unistd.h>
#include <fcntl.h>


static int						sClientSocket = -1;
static OOConsoleConnectionRef	sConnection = NULL;
static Boolean					sQuit = FALSE;


static int SetUpServerSocket(in_port_t port);
static void RunServerLoop(int serverSocket);

static void RejectConnection(int connectionFD);

static void HandleInput(void);
static void HandleIncomingData(void);

static CFStringRef ErrnoDesc(void);


static void ConnectionSendData(void *cbInfo, const void *bytes, size_t length);
static void ConnectionConsoleOutput(void *cbInfo, CFStringRef text, CFStringRef colorKey, CFRange *emphasisRanges, uint32_t emphasisRangeCount);
static void ConnectionConnectionEstablished(void *cbInfo, CFStringRef ooliteVersion);
static void ConnectionClose(void *cbInfo, Boolean closedRemotely, CFStringRef message);
static void ConnectionError(void *cbInfo, CFStringRef message);


int main (int argc, char *argv[])
{
	int						serverSocket = -1;
	JAAutoreleasePoolRef	pool = NULL;
	in_port_t				serverPort = kOOTCPConsolePort;
	OOConsoleConnectionCallbacks callbacks =
	{
		ConnectionSendData,
		ConnectionConsoleOutput,
		NULL,
		NULL,
		NULL,
		ConnectionConnectionEstablished,
		ConnectionClose,
		ConnectionError,
		NULL
	};
	
	pool = JACreateAutoreleasePool();
	
	// Create protocol decoder
	sConnection = OOConsoleConnectionCreate(CFSTR("simpleDebugConsole"), &callbacks, NULL);
	if (sConnection == NULL)
	{
		JAPrintErrC("* Could not create connection object.\n");
		return EXIT_FAILURE;
	}
	
	if (argc > 1)
	{
		serverPort = atoi(argv[1]);
		if (serverPort < 1)
		{
			JAPrintErrC("* Invalid port (%i).\n", (int)serverPort);
			return EXIT_FAILURE;
		}
	}
	
	serverSocket = SetUpServerSocket(serverPort);
	if (serverSocket == -1)  return EXIT_FAILURE;
	
	JADestroyAutoreleasePool(pool);
	pool = JACreateAutoreleasePool();
	
	JAPrintC("- Waiting for connection.\n");
	RunServerLoop(serverSocket);
	
	OOConsoleConnectionDestroy(sConnection);
	
	return 0;
}


static int SetUpServerSocket(in_port_t port)
{
	int						sock = -1;
	
	// Create socket.
	sock = socket(AF_INET, SOCK_STREAM, 0);
	if (sock == -1)
	{
		JAPrintErrC("* Could not create server socket (%@).\n", ErrnoDesc());
		return -1;
	}
	
	// Allow local address reuse.
	int yes = 1;
	if (setsockopt(sock, SOL_SOCKET, SO_REUSEADDR, &yes, sizeof(int)) == -1)
	{
		JAPrintErrC("* Could not configure server socket (%@).\n", ErrnoDesc());
		return -1;
	}
	
	// Bind to listen on specified port.
	struct sockaddr_in serverAddress =
	{
		sin_len: 0,
		sin_family: AF_INET,
		sin_addr: { s_addr: INADDR_ANY },
		sin_port: htons(port),
		sin_zero: { 0,0,0,0,0,0,0,0 }
	};
	if (bind(sock, (struct sockaddr *)&serverAddress, sizeof serverAddress) == -1)
	{
		JAPrintErrC("* Could not bind server socket (%@).\n", ErrnoDesc());
		return -1;
	}
	
	// Listen, allowing one connection at a time.
	if (listen(sock, 1) == -1)
	{
		JAPrintErrC("* Could not listen on server socket (%@).\n", ErrnoDesc());
		return -1;
	}
	
	return sock;
}


static void RunServerLoop(int serverSocket)
{
	JAAutoreleasePoolRef	pool = NULL;
	fd_set					masterSet, tempSet;
	struct sockaddr_in		clientAddress;
	socklen_t				addressLength;
	int						newFD;
	int						maxFD;
	
	// Set up file descriptor set for select()
	FD_ZERO(&masterSet);
	FD_SET(serverSocket, &masterSet);
	FD_SET(0 /* stdin */, &masterSet);
	maxFD = 0;
	if (serverSocket > maxFD)  maxFD = serverSocket;
	
	// Run select() loop
	do
	{
		JADestroyAutoreleasePool(pool);
		pool = JACreateAutoreleasePool();
		
		FD_COPY(&masterSet, &tempSet);
		if (select(maxFD + 1, &tempSet, NULL, NULL, NULL) == -1)
		{
			if (errno != EINTR)  JAPrintErrC("* select() failed (%@)!", ErrnoDesc());
			continue;
		}
		
		// If we got a message on the server socket:
		if(FD_ISSET(serverSocket, &tempSet))
		{
			addressLength = sizeof clientAddress;			
			newFD = accept(serverSocket, (struct sockaddr *)&clientAddress, &addressLength);
			if (newFD == -1)
			{
				JAPrintErrC("* Client connection failed, error in accept() (%@).\n", ErrnoDesc());
			}
			else
			{
				if (sClientSocket == -1)
				{
					// No client connected yet.
					sClientSocket = newFD;
					fcntl(sClientSocket, F_SETFL, O_NONBLOCK);
					FD_SET(sClientSocket, &masterSet);
					
					// Specify the host, if not localhost.
					if (clientAddress.sin_family == AF_INET)
					{
						if (clientAddress.sin_addr.s_addr != INADDR_LOOPBACK)
						{
							JAPrintC("- Client connected from %s.\n", inet_ntoa(clientAddress.sin_addr));
						}
						else  JAPrintC("- Client connected locally.\n");
					}
					else  JAPrintC("- Client connected.\n");
					
					JAPrintFlush();
					if (sClientSocket > maxFD)  maxFD = sClientSocket;
				}
				else
				{
					// We already have one client, and don't deal with more.
					RejectConnection(newFD);
					JAPrintC("* Rejected attempted connection by second client.\n");
				}
			}
		}
		if (FD_ISSET(0, &tempSet))
		{
			HandleInput();
		}
		if (sClientSocket != -1 && FD_ISSET(sClientSocket, &tempSet))
		{
			HandleIncomingData();
		}
	} while (!sQuit);
	
	JADestroyAutoreleasePool(pool);
}


static void RejectConnection(int connectionFD)
{
	// TODO: send reject packet
	close(connectionFD);
}


static void HandleInput(void)
{
	CFMutableDataRef		data = NULL;
	int						input;
	UInt8					byte;
	CFStringRef				string = NULL;
	
	data = CFDataCreateMutable(kCFAllocatorDefault, 0);
	if (data == NULL)  return;
	
	for (;;)
	{
		input = getchar();
		if (input == '\n' || input == EOF)  break;
		byte = input;
		CFDataAppendBytes(data, &byte, 1);
	}
	
	string = CFStringCreateFromExternalRepresentation(kCFAllocatorDefault, data, kCFStringEncodingUTF8);
	CFRelease(data);
	if (string != NULL)
	{
		OOConsoleConnectionPerformCommand(sConnection, string);
	}
	else
	{
		JAPrintErrC("* Could not interpret input as UTF-8.\n");
	}
}


static void HandleIncomingData(void)
{
	enum { kBufferSize = 16 << 10 };
	
	ssize_t					length;
	unsigned char			buffer[kBufferSize];
	
	while (length = recv(sClientSocket, buffer, kBufferSize, 0), length > 0)
	{
		if (sQuit)  return;
		OOConsoleConnectionReceiveBytes(sConnection, buffer, length);
	}
	if (length == -1 && errno != EAGAIN)
	{
		JAPrintC("*** Connection broken (%@).\n\n", ErrnoDesc());
		sQuit = TRUE;
	}
	if (length == 0)
	{
		JAPrintC("*** Connection closed by remote.\n\n");
		sQuit = TRUE;
	}
}


static void ConnectionSendData(void *cbInfo, const void *bytes, size_t length)
{
	ssize_t					sent;
	
	
	fcntl(sClientSocket, F_SETFL, 0);
	
	while (length > 0)
	{
		if (sQuit)  break;
		sent = send(sClientSocket, bytes, length, 0);
		if (sent == -1)
		{
			JAPrintErrC("*** Connection broken (%@).\n", ErrnoDesc());
			sQuit = TRUE;
		}
		bytes += sent;
		length -= sent;
	}
	
	fcntl(sClientSocket, F_SETFL, O_NONBLOCK);
}


static void ConnectionConsoleOutput(void *cbInfo, CFStringRef text, CFStringRef colorKey, CFRange *emphasisRanges, uint32_t emphasisRangeCount)
{
	JAPrintC("  %@\n", text);
	JAPrintFlush();
}


static void ConnectionConnectionEstablished(void *cbInfo, CFStringRef ooliteVersion)
{
	JAPrintC("- Connection established to Oolite %@.\n\n", ooliteVersion);
}


static void ConnectionClose(void *cbInfo, Boolean closedRemotely, CFStringRef message)
{
	JAPrintC("- Connection closed: %@\n\n", message ? message : CFSTR("no reason given."));
	sQuit = TRUE;
}


static void ConnectionError(void *cbInfo, CFStringRef message)
{
	JAPrintErrC("* %@\n", message);
}


static CFStringRef ErrnoDesc(void)
{
	int						error;
	
	error = errno;
	
	switch (error)
	{
		case 0:
			return CFSTR("no error");
			
		case EPROTONOSUPPORT:
			return CFSTR("protocol is not supported in this domain");
			
		case EMFILE:
			return CFSTR("file descriptor table is full");
			
		case ENFILE:
			return CFSTR("system file table is full");
			
		case EACCES:
			return CFSTR("permission denied");
			
		case ENOBUFS:
			return CFSTR("insufficient buffer space available");
			
		case ENOMEM:
			return CFSTR("out of memory");
			
		case EBADF:
			return CFSTR("bad file descriptor");
			
		case ENOTSOCK:
			return CFSTR("not a socket");
			
		case ENOPROTOOPT:
			return CFSTR("unknown option for protocol level");
			
		case EFAULT:
			return CFSTR("out-of-bounds pointer");
			
		case EDOM:
			return CFSTR("out-of-bounds value");
			
		case EADDRNOTAVAIL:
			return CFSTR("address is not available");
			
		case EADDRINUSE:
			return CFSTR("address is in use");
			
		case EINVAL:
			return CFSTR("invalid argument");
			
		case EOPNOTSUPP:
			return CFSTR("operation not supported");
			
		case EINTR:
			return CFSTR("interrupted");
			
		case EHOSTUNREACH:
			return CFSTR("host unreachable");
			
		case EPIPE:
			return CFSTR("broken pipe");
			
		case ECONNRESET:
			return CFSTR("connection reset by peer");
	}
	
	return CFFMTSTR("unknown errno %i", error);
}
