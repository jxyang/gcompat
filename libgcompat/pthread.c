#define _GNU_SOURCE
#include <errno.h>   /* errno */
#include <fcntl.h>   /* O_CLOEXEC, O_RDONLY */
#include <pthread.h> /* pthread_atfork */
#include <sched.h>   /* sched_yield, CPU_ALLOC, CPU_FREE */
#include <unistd.h>  /* open, read */

#include "alias.h" /* weak_alias */

/**
 * Underlying function for pthread_cleanup_push.
 */
void __pthread_register_cancel(void *buf)
{
}

/**
 * Underlying function for pthread_cleanup_push.
 */
void __pthread_unregister_cancel(void *buf)
{
}

/**
 * Register fork handlers.
 *
 * LSB 5.0: LSB-Core-generic/baselib---register-atfork.html
 */
int __register_atfork(void (*prepare)(void), void (*parent)(void),
                      void (*child)(void), void *__dso_handle)
{
	return pthread_atfork(prepare, parent, child);
}
weak_alias(__register_atfork, register_atfork);

/**
 * Get the name of a thread.
 */
int pthread_getname_np(pthread_t thread, char *name, size_t len)
{
	int fd = open("/proc/thread-self/comm", O_RDONLY | O_CLOEXEC);
	ssize_t n;

	if (fd < 0)
		return errno;
	n = read(fd, name, len);
	if (n < 0)
		return errno;
	/* If the trailing newline was not read, the buffer was too small. */
	if (n == 0 || name[n - 1] != '\n')
		return ERANGE;
	name[n - 1] = '\0';

	return 0;
}

/**
 * Yield this thread.
 */
int pthread_yield(void)
{
	return sched_yield();
}

/**
 * Allocate a large enough CPU set
 */
cpu_set_t *__sched_cpualloc(size_t __count)
{
	return CPU_ALLOC(__count);
}

/**
 * Free a CPU set allocated by __sched_cpualloc
 */
void __sched_cpufree(cpu_set_t *__set)
{
	return CPU_FREE(__set);
}
