#include "pathhelpers.h"
#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>
#include <string.h>
#include <paths.h>
#include <errno.h>

#if defined(__has_include)
#if __has_include(<sys/auxv.h>)
#include <sys/auxv.h>
#endif /* __has_include(<sys/auxv.h>) */
#endif /* defined(__has_include) */

#ifndef HAVE_ISSETUGID
#if defined(__DARWIN_C_LEVEL) && defined(__DARWIN_C_FULL) && __DARWIN_C_LEVEL >= __DARWIN_C_FULL
#define HAVE_ISSETUGID
#endif /* defined(__DARWIN_C_LEVEL) && defined(__DARWIN_C_FULL) && __DARWIN_C_LEVEL >= __DARWIN_C_FULL */
#endif /* HAVE_ISSETUGID */

#ifndef HAVE_SECURE_GETENV
#ifdef __USE_GNU
#define HAVE_SECURE_GETENV
#endif /* __USE_GNU */
#endif /* HAVE_SECURE_GETENV */

// Adaption from https://gist.github.com/nicowilliams/4daf74a3a0c86848d3cbd9d0cdb5e26e
#ifndef HAVE_SECURE_GETENV
char * secure_getenv(const char *name) {
#ifdef HAVE_ISSETUGID
    if (issetugid() != 0) {
        return NULL;
    }
#elif defined(_SYS_AUXV_H)
#ifdef AT_SECURE
    if (getauxval(AT_SECURE)) {
        return NULL;
    }
#elif defined(AT_RUID) && defined(AT_EUID) && defined(AT_RGID) && defined(AT_EGID)
    uid_t ruid, euid;
    gid_t rgid, egid;

    errno = 0;
    if ((ruid = getauxval(AT_RUID)) == 0 && errno == ENOENT) {
        return NULL;
    }
    errno = 0;
    if ((euid = getauxval(AT_EUID)) == 0 && errno == ENOENT) {
        return NULL;
    }
    errno = 0;
    if ((rgid = getauxval(AT_RGID)) == 0 && errno == ENOENT) {
        return NULL;
    }
    errno = 0;
    if ((egid = getauxval(AT_EGID)) == 0 && errno == ENOENT) {
        return NULL;
    }
    errno = 0;
    if (ruid != euid || rgid != egid) {
        return NULL;
    }
#else /* defined(AT_RUID) && defined(AT_EUID) && defined(AT_RGID) && defined(AT_EGID) */
    if (getuid() != geteuid() || getgid() != getegid()) {
        return NULL;
    }
#endif /* AT_SECURE */
#else /* defined(_SYS_AUXV_H) */
    if (getuid() != geteuid() || getgid() != getegid()) {
        return NULL;
    }
#endif /* HAVE_ISSETUGID */
    return getenv(name);
}
#endif /* HAVE_SECURE_GETENV */

inline char *_Nonnull cpw_tmp_dir_path() {
    char *envPath = secure_getenv("TMPDIR");
    if (envPath != NULL && strlen(envPath) > 0) {
        return envPath;
    }

#ifdef P_tmpdir
    if (strlen(P_tmpdir) > 0) {
        return P_tmpdir;
    }
#endif /* P_tmpdir */

#ifdef _PATH_TMP
    if (strlen(_PATH_TMP) > 0) {
        return _PATH_TMP;
    }
#endif /* _PATH_TMP */

#if !defined(P_tmpdir) && !defined(_PATH_TMP)
#warning Missing TMP dir defines. Using '/tmp'
    return "/tmp";
#endif /* !defined(P_tmpdir) && !defined(_PATH_TMP) */
}
