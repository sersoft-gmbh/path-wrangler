#ifndef STATHELPERS_H
#define STATHELPERS_H

#ifdef __cplusplus
extern "C" {
#endif

#include <stdbool.h>
#include <sys/types.h>

extern inline const bool cpw_mode_is_link(mode_t mode);

#ifdef __cplusplus
}
#endif

#endif /* STATHELPERS_H */
