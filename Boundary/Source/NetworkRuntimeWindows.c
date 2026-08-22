#include <stdint.h>
#include <winsock2.h>
#include <ws2tcpip.h>

static int set_timeout(SOCKET descriptor, int option, int64_t milliseconds) {
    if (milliseconds < 0) return 1;
    DWORD value = (DWORD)milliseconds;
    return setsockopt(descriptor, SOL_SOCKET, option, (const char *)&value, sizeof(value)) == 0;
}

int64_t silex_tcp_connect_bounded(
    const void *address,
    uint32_t address_length,
    int64_t connect_timeout,
    int64_t read_timeout,
    int64_t write_timeout
) {
    const struct sockaddr *socket_address = address;
    SOCKET descriptor = socket(socket_address->sa_family, SOCK_STREAM, IPPROTO_TCP);
    if (descriptor == INVALID_SOCKET) return -1;

    if (connect_timeout >= 0) {
        u_long nonblocking = 1;
        if (ioctlsocket(descriptor, FIONBIO, &nonblocking) != 0) goto failure;
        int status = connect(descriptor, socket_address, (int)address_length);
        if (status != 0 && WSAGetLastError() != WSAEWOULDBLOCK) goto failure;
        if (status != 0) {
            WSAPOLLFD candidate = { .fd = descriptor, .events = POLLWRNORM, .revents = 0 };
            if (WSAPoll(&candidate, 1, (int)connect_timeout) != 1) goto failure;
            int socket_error = 0;
            int error_length = sizeof(socket_error);
            if (getsockopt(descriptor, SOL_SOCKET, SO_ERROR, (char *)&socket_error, &error_length) != 0 || socket_error != 0) {
                goto failure;
            }
        }
        nonblocking = 0;
        if (ioctlsocket(descriptor, FIONBIO, &nonblocking) != 0) goto failure;
    } else if (connect(descriptor, socket_address, (int)address_length) != 0) {
        goto failure;
    }

    if (!set_timeout(descriptor, SO_RCVTIMEO, read_timeout) ||
        !set_timeout(descriptor, SO_SNDTIMEO, write_timeout)) goto failure;
    return (int64_t)descriptor;

failure:
    closesocket(descriptor);
    return -1;
}
