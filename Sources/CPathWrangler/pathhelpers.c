#include "pathhelpers.h"
#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>
#include <string.h>
#include <paths.h>

inline const char *_Nonnull cpw_tmp_dir_path() {
    if (issetugid() == 0) {
        const char *envPath = getenv("TMPDIR");
        if (envPath != NULL && strlen(envPath) > 0) {
            return envPath;
        }
    }
#ifdef P_tmpdir
    if (strlen(P_tmpdir) > 0) {
        return P_tmpdir;
    }
#endif
    return _PATH_TMP;
}
