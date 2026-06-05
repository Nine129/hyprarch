/*
 * hyprland-dispatch-compat.c
 * LD_PRELOAD wrapper that translates old-format Waybar dispatch commands
 * to Hyprland v0.55+ Lua dispatch format.
 *
 * Hooks connect() to detect Hyprland socket connections,
 * and write()/send()/(sendmsg) to translate dispatch commands.
 *
 * Compile:
 *   gcc -shared -fPIC -o hyprland-dispatch-compat.so hyprland-dispatch-compat.c -ldl
 *
 * Use:
 *   LD_PRELOAD=/path/to/hyprland-dispatch-compat.so waybar
 */
#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <dlfcn.h>
#include <sys/socket.h>
#include <sys/un.h>
#include <sys/uio.h>

/* Saved original functions */
static int    (*real_connect)(int, const struct sockaddr*, socklen_t) = NULL;
static ssize_t (*real_write)(int, const void*, size_t) = NULL;
static ssize_t (*real_send)(int, const void*, size_t, int) = NULL;
static ssize_t (*real_sendmsg)(int, const struct msghdr*, int) = NULL;
static ssize_t (*real_sendto)(int, const void*, size_t, int, const struct sockaddr*, socklen_t) = NULL;

/* Bitmask of FDs that are connected to the Hyprland command socket */
#define MAX_FDS 4096
static char hyprland_fds[MAX_FDS / 8];

static inline void set_hyprland_fd(int fd) {
    if (fd >= 0 && fd < MAX_FDS) hyprland_fds[fd / 8] |= (1 << (fd % 8));
}

static inline int is_hyprland_fd(int fd) {
    if (fd >= 0 && fd < MAX_FDS) return (hyprland_fds[fd / 8] >> (fd % 8)) & 1;
    return 0;
}

/* Check if a sockaddr is a Hyprland command socket */
static int is_hyprland_socket_addr(const struct sockaddr *addr, socklen_t addrlen) {
    if (!addr || addr->sa_family != AF_UNIX || addrlen < sizeof(sa_family_t))
        return 0;

    const struct sockaddr_un *un = (const struct sockaddr_un*)addr;
    char path[sizeof(un->sun_path) + 1] = {0};
    size_t pathlen = addrlen - sizeof(sa_family_t);
    if (pathlen > sizeof(un->sun_path)) pathlen = sizeof(un->sun_path);
    memcpy(path, un->sun_path, pathlen);

    return (strstr(path, "/hypr/") && strstr(path, "/.socket.sock"));
}

/*
 * Translate old dispatch commands to new Lua format.
 * Returns malloc'd string or NULL if no translation needed.
 * Caller must free() the result.
 */
static char* translate_dispatch(const char *data, size_t count, size_t *new_len) {
    /* Skip leading whitespace */
    while (count > 0 && (*data == ' ' || *data == '\t' || *data == '\n')) {
        data++;
        count--;
    }
    if (count == 0) return NULL;

    /* Must start with "dispatch " */
    const char prefix[] = "dispatch ";
    size_t plen = sizeof(prefix) - 1;
    if (count < plen || strncmp(data, prefix, plen) != 0) return NULL;

    const char *cmd = data + plen;
    size_t cmd_len = count - plen;

    /* Strip trailing whitespace/newlines */
    while (cmd_len > 0 && (cmd[cmd_len-1] == ' ' || cmd[cmd_len-1] == '\t' || cmd[cmd_len-1] == '\n' || cmd[cmd_len-1] == '\r'))
        cmd_len--;

    if (cmd_len == 0) return NULL;

    char *result = NULL;
    size_t needed;

    /* ── dispatch workspace ARGS ── */
    if (strncmp(cmd, "workspace ", 10) == 0) {
        const char *arg = cmd + 10;
        size_t arg_len = cmd_len - 10;

        /* Strip "name:" prefix */
        if (strncmp(arg, "name:", 5) == 0) { arg += 5; arg_len -= 5; }

        /* Relative selectors: e+1, e-1, m+1, m-1, r+1, r-1, etc */
        if ((arg_len >= 2 && arg[0] >= 'a' && arg[0] <= 'z' && (arg[1] == '+' || arg[1] == '-'))) {
            needed = 64 + arg_len; result = malloc(needed);
            if (result) *new_len = snprintf(result, needed, "dispatch hl.dsp.focus({workspace=\"%.*s\"})\n", (int)arg_len, arg);
        }
        /* Named: "previous", "empty", "name" */
        else if (arg_len > 0 && (arg[0] < '0' || arg[0] > '9')) {
            needed = 64 + arg_len; result = malloc(needed);
            if (result) *new_len = snprintf(result, needed, "dispatch hl.dsp.focus({workspace=\"%.*s\"})\n", (int)arg_len, arg);
        }
        /* Numeric ID */
        else {
            needed = 64 + arg_len; result = malloc(needed);
            if (result) *new_len = snprintf(result, needed, "dispatch hl.dsp.focus({workspace=%.*s})\n", (int)arg_len, arg);
        }
    }
    /* ── dispatch focusworkspaceoncurrentmonitor ARGS ── */
    else if (strncmp(cmd, "focusworkspaceoncurrentmonitor ", 31) == 0) {
        const char *arg = cmd + 31;
        size_t arg_len = cmd_len - 31;
        if (strncmp(arg, "name:", 5) == 0) { arg += 5; arg_len -= 5; }
        needed = 64 + arg_len; result = malloc(needed);
        if (result) *new_len = snprintf(result, needed, "dispatch hl.dsp.focus({workspace=%.*s})\n", (int)arg_len, arg);
    }
    /* ── dispatch togglespecialworkspace [NAME] ── */
    else if (strncmp(cmd, "togglespecialworkspace", 22) == 0) {
        if (cmd_len == 22) {
            result = strdup("dispatch hl.dsp.workspace.toggle_special(\"\")\n");
            if (result) *new_len = strlen(result);
        } else if (cmd[22] == ' ') {
            const char *arg = cmd + 23;
            size_t arg_len = cmd_len - 23;
            needed = 64 + arg_len; result = malloc(needed);
            if (result) *new_len = snprintf(result, needed, "dispatch hl.dsp.workspace.toggle_special(\"%.*s\")\n", (int)arg_len, arg);
        }
    }

    return result;
}

/* ── Hook: connect() → detect Hyprland socket ── */
int connect(int sockfd, const struct sockaddr *addr, socklen_t addrlen) {
    if (!real_connect) {
        real_connect = (int (*)(int, const struct sockaddr*, socklen_t))dlsym(RTLD_NEXT, "connect");
        if (!real_connect) return -1;
    }

    int ret = real_connect(sockfd, addr, addrlen);

    if (ret == 0 && is_hyprland_socket_addr(addr, addrlen)) {
        set_hyprland_fd(sockfd);
    }

    return ret;
}

/* ── Intercept writes to Hyprland socket ── */

/* Process a buffer: translate if it's a dispatch command to the Hyprland socket.
   Calls writer(fd, buf, count, flags) — for write(), flags is ignored. */
static ssize_t process_write(int fd, const void *buf, size_t count,
                              ssize_t (*writer)(int, const void*, size_t, int),
                              int flags) {
    if (buf && count > 0 && is_hyprland_fd(fd)) {
        size_t new_len = 0;
        char *translated = translate_dispatch(buf, count, &new_len);
        if (translated) {
            ssize_t result = writer(fd, translated, new_len, flags);
            free(translated);
            return result;
        }
    }
    return writer(fd, buf, count, flags);
}

ssize_t write(int fd, const void *buf, size_t count) {
    if (!real_write) {
        real_write = (ssize_t (*)(int, const void*, size_t))dlsym(RTLD_NEXT, "write");
        if (!real_write) return -1;
    }
    if (buf && count > 0 && is_hyprland_fd(fd)) {
        size_t new_len = 0;
        char *translated = translate_dispatch(buf, count, &new_len);
        if (translated) {
            ssize_t result = real_write(fd, translated, new_len);
            free(translated);
            return result;
        }
    }
    return real_write(fd, buf, count);
}

ssize_t send(int sockfd, const void *buf, size_t len, int flags) {
    if (!real_send) {
        real_send = (ssize_t (*)(int, const void*, size_t, int))dlsym(RTLD_NEXT, "send");
        if (!real_send) return -1;
    }
    return process_write(sockfd, buf, len, real_send, flags);
}

ssize_t sendto(int sockfd, const void *buf, size_t len, int flags,
               const struct sockaddr *dest_addr, socklen_t addrlen) {
    if (!real_sendto) {
        real_sendto = (ssize_t (*)(int, const void*, size_t, int,
                                   const struct sockaddr*, socklen_t))dlsym(RTLD_NEXT, "sendto");
        if (!real_sendto) return -1;
    }
    return process_write(sockfd, buf, len,
        (ssize_t (*)(int, const void*, size_t, int))real_sendto, flags);
}

ssize_t sendmsg(int sockfd, const struct msghdr *msg, int flags) {
    if (!real_sendmsg) {
        real_sendmsg = (ssize_t (*)(int, const struct msghdr*, int))dlsym(RTLD_NEXT, "sendmsg");
        if (!real_sendmsg) return -1;
    }
    if (msg && msg->msg_iov && msg->msg_iovlen > 0 && is_hyprland_fd(sockfd)) {
        /* Handle single-iov messages */
        if (msg->msg_iovlen == 1) {
            struct iovec *iov = msg->msg_iov;
            if (iov[0].iov_base && iov[0].iov_len > 0) {
                size_t new_len = 0;
                char *translated = translate_dispatch(iov[0].iov_base, iov[0].iov_len, &new_len);
                if (translated) {
                    struct msghdr new_msg = *msg;
                    struct iovec new_iov = { translated, new_len };
                    new_msg.msg_iov = &new_iov;
                    new_msg.msg_iovlen = 1;
                    ssize_t result = real_sendmsg(sockfd, &new_msg, flags);
                    free(translated);
                    return result;
                }
            }
        }
    }
    return real_sendmsg(sockfd, msg, flags);
}
