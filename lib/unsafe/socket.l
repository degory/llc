
namespace IO is
    class Socket extends FileStream is
        const int 
	    SOCK_STREAM = 1,
	    SOCK_DGRAM = 2,

	    AF_UNIX = 1,
	    AF_INET = 2;

        native int socket( int family, int type, int protocol );
	native int connect( int handle, 
	
	
   
    si
si