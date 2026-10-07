/*
 * chello.c -- CADzilla program, zcc (z88dk C) toolchain
 *
 * Compiled on the host by z88dk's zcc, then copied onto the CP/M disk and run
 * (cadzilla-build-zcc skill):
 *   tools/z88dk/zccbuild.sh software/chello      -> build/CHELLO.COM
 *   A0>R CHELLO.COM                          (hb0 HOSTDIR = build/)
 *   A0>CHELLO
 *
 * The target CPU (8080) is machine.toml's cpu0 block: it is both the emulated
 * CPU and the C library zcc links (-clib=8080, 8085 or default for the Z80).
 * CPUID.Z88 is an assembly module, linked in beside this file.
 *
 * The program prints the CPU it was built for and the one it is running on;
 * the two should always match.
 */
#include <stdio.h>

/* zcc defines one of these, from the C library it was given */
#if defined(__Z80)
#define BUILT "Z80"
#elif defined(__8085)
#define BUILT "8085"
#else
#define BUILT "8080"
#endif

extern int cpuid(void);         /* CPUID.Z88: 0 = 8080, 1 = 8085, 2 = Z80 */

static char *cpus[] = { "8080", "8085", "Z80" };

int main(void)
{
    printf("Welcome to CADzilla: chello!\n");
    printf("Built for %s, running on %s\n", BUILT, cpus[cpuid()]);
    return 0;
}
