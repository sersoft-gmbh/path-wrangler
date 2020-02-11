#include "stathelpers.h"
#include <sys/stat.h>

inline const bool cpw_mode_is_link(mode_t mode) {
    return S_ISLNK(mode) != 0;
}
