LIBGCOMPAT_INCLUDE = \
	libgcompat/alias.h
LIBGCOMPAT_SRC = \
	libgcompat/ctype.c		\
	libgcompat/cxx_thread.c		\
	libgcompat/dlfcn.c		\
	libgcompat/error.c		\
	libgcompat/execinfo.c		\
	libgcompat/gnulib.c		\
	libgcompat/grp.c		\
	libgcompat/internal.c		\
	libgcompat/malloc.c		\
	libgcompat/math.c		\
	libgcompat/misc.c		\
	libgcompat/netdb.c		\
	libgcompat/pthread.c		\
	libgcompat/pwd.c		\
	libgcompat/readlink.c		\
	libgcompat/resolv.c		\
	libgcompat/resource.c		\
	libgcompat/setjmp.c		\
	libgcompat/signal.c		\
	libgcompat/socket.c		\
	libgcompat/stdio.c		\
	libgcompat/stdlib.c		\
	libgcompat/string.c		\
	libgcompat/sysctl.c		\
	libgcompat/syslog.c		\
	libgcompat/ucontext.c		\
	libgcompat/unistd.c		\
	libgcompat/utmp.c		\
	libgcompat/version.c		\
	libgcompat/wchar.c
LIBGCOMPAT_OBJ = ${LIBGCOMPAT_SRC:.c=.o}
LIBGCOMPAT_SOVERSION = 0
LIBGCOMPAT_NAME = libgcompat.so.${LIBGCOMPAT_SOVERSION}
LIBGCOMPAT_PATH = /lib/${LIBGCOMPAT_NAME}

LOADER_SRC = \
	loader/loader.c
LOADER_OBJ = ${LOADER_SRC:.c=.o}
LOADER_NAME = ld-linux.so.2
LOADER_PATH = /lib/${LOADER_NAME}

ifdef WITH_LIBUCONTEXT

LIBUCONTEXT_LIBS   = -Wl,--no-as-needed -lucontext
LIBUCONTEXT_CFLAGS = -DWITH_LIBUCONTEXT

endif

all: ${LIBGCOMPAT_NAME} ${LOADER_NAME}

${LIBGCOMPAT_NAME}: ${LIBGCOMPAT_OBJ}
	$(CC) -o ${LIBGCOMPAT_NAME} -Wl,-soname,${LIBGCOMPAT_NAME} \
		-shared ${LIBGCOMPAT_OBJ} ${LIBUCONTEXT_LIBS}

${LIBGCOMPAT_OBJ}: ${LIBGCOMPAT_INCLUDE}

${LOADER_NAME}: ${LOADER_OBJ}
	$(CC) -o ${LOADER_NAME} -fPIE -static ${LOADER_OBJ}

.c.o:
	$(CC) -c -D_BSD_SOURCE -DLIBGCOMPAT=\"${LIBGCOMPAT_PATH}\" \
		-DLINKER=\"${LINKER_PATH}\" -DLOADER=\"${LOADER_NAME}\" \
		-Ilibgcompat ${LIBUCONTEXT_CFLAGS} \
		-fPIC -std=c99 -Wall -Wextra -Wno-frame-address \
		-Wno-unused-parameter ${CFLAGS} ${CPPFLAGS} -o $@ $<

clean:
	rm -f libgcompat/*.o loader/*.o ${LIBGCOMPAT_NAME} ${LOADER_NAME}

format:
	clang-format -i ${LIBGCOMPAT_SRC} ${LOADER_SRC}

install: all
	install -D -m755 ${LIBGCOMPAT_NAME} ${DESTDIR}/${LIBGCOMPAT_PATH}
	install -D -m755 ${LOADER_NAME} ${DESTDIR}/${LOADER_PATH}

.PHONY: all clean format install
