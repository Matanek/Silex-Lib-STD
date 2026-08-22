#include <errno.h>
#include <fcntl.h>
#include <poll.h>
#include <stdint.h>
#include <netinet/in.h>
#include <sys/socket.h>
#include <sys/time.h>
#include <unistd.h>

static int set_timeout(int descriptor, int option, int64_t milliseconds) {
    if (milliseconds < 0) return 1;
    struct timeval value;
    value.tv_sec = milliseconds / 1000;
    value.tv_usec = (milliseconds % 1000) * 1000;
    return setsockopt(descriptor, SOL_SOCKET, option, &value, sizeof(value)) == 0;
}

int64_t silex_tcp_connect_bounded(
    const void *address,
    uint32_t address_length,
    int64_t connect_timeout,
    int64_t read_timeout,
    int64_t write_timeout
) {
    const struct sockaddr *socket_address = address;
    int descriptor = socket(socket_address->sa_family, SOCK_STREAM, IPPROTO_TCP);
    if (descriptor < 0) return -1;

    if (connect_timeout >= 0) {
        int flags = fcntl(descriptor, F_GETFL, 0);
        if (flags < 0 || fcntl(descriptor, F_SETFL, flags | O_NONBLOCK) != 0) goto failure;
        int status = connect(descriptor, socket_address, (socklen_t)address_length);
        if (status != 0 && errno != EINPROGRESS) goto failure;
        if (status != 0) {
            struct pollfd candidate = { .fd = descriptor, .events = POLLOUT, .revents = 0 };
            if (poll(&candidate, 1, (int)connect_timeout) != 1) goto failure;
            int socket_error = 0;
            socklen_t error_length = sizeof(socket_error);
            if (getsockopt(descriptor, SOL_SOCKET, SO_ERROR, &socket_error, &error_length) != 0 || socket_error != 0) {
                goto failure;
            }
        }
        if (fcntl(descriptor, F_SETFL, flags) != 0) goto failure;
    } else if (connect(descriptor, socket_address, (socklen_t)address_length) != 0) {
        goto failure;
    }

    if (!set_timeout(descriptor, SO_RCVTIMEO, read_timeout) ||
        !set_timeout(descriptor, SO_SNDTIMEO, write_timeout)) goto failure;
    return descriptor;

failure:
    close(descriptor);
    return -1;
}
