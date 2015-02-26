/**************************************************************************
*
*   Filename:           issu_validate_asserts.h
*
*   Author:             Jeremy Rand
*   Created:            Thu Jan 19 15:15:48 EST 2012
*
*   Description:        Macros for validating the layout of structures used
*                       for ISSU.
*
*
***************************************************************************
*
*                 Source Control System Information
*
*   $Id: issu_validate_asserts.h,v 1.10 2013/04/13 20:02:00 jasmets Exp $
*
***************************************************************************
*
*              Copyright (c) 2012-2013 Alcatel-Lucent
*
**************************************************************************/

#ifndef _ISSU_VALIDATE_ASSERTS_H_
#define _ISSU_VALIDATE_ASSERTS_H_


#include <vxWorks.h>
#include "common/compileAssert.h"
#include "common/gen/timos_build_type_beta.h"
#include "common/gen/timos_feature_missu_compile_checks.h"

#ifdef GCC_ABI_64
#include "common/issu_validate_blacklist.h"
#endif

#define ISSU_VALIDATE(s)

#if !TIMOS_FEATURE(MISSU_COMPILE_CHECKS)
#ifndef NO_ISSU_VALIDATE_ASSERTS
#define NO_ISSU_VALIDATE_ASSERTS
#endif
#endif

#ifndef NO_ISSU_VALIDATE_ASSERTS
#ifndef ISSU_DUMP_COMPILE
#if !TIMOS_BUILD_TYPE(BETA)

#define ISSU_VALIDATE_STRUCT_SIZE(name, s, sz) \
    STATIC_ASSERT((sizeof(s) == sz), "ISSU Validation Error: Type " #s " is not exactly " #sz " bytes in size");

#define ISSU_VALIDATE_MEMBER_OFFSET(name, s, mname, m, off) \
    STATIC_ASSERT((OFFSET(s, m) == off), "ISSU Validation Error: Member " #m " within type " #s " is not exactly at byte offset " #off);

#define ISSU_VALIDATE_MEMBER_SIZE(name, s, mname, m, sz) \
    STATIC_ASSERT((MEMBER_SIZE(s, m) == sz), "ISSU Validation Error: Member " #m " within type " #s " is not exactly " #sz " bytes in size");

#define ISSU_VALIDATE_ENUM_VALUE(e, val) \
    STATIC_ASSERT(((unsigned int)e == (unsigned int)val), "ISSU Validation Error: Enum " #e " is not exactly " #val);

#define ISSU_VALIDATE_ENUM_VALUE_CAST(e, name, val) \
    STATIC_ASSERT((e == ((name)val)), "ISSU Validation Error: Enum " #e " is not exactly " #val);

#define ISSU_VALIDATE_ENUM_VALUE_DIFF(e1, e2, diff) \
    STATIC_ASSERT((e1 == (e2 + diff)), "ISSU Validation Error: Enum " #e1 " is not exactly " #diff " different from " #e2);

#undef ISSU_VALIDATE
#define ISSU_VALIDATE(s) ISSU_VALIDATE_##s##_TYPE

#endif // !TIMOS_BUILD_TYPE(BETA)
#endif // ISSU_DUMP_COMPILE
#endif // NO_ISSU_VALIDATE_ASSERTS

#endif /* _ISSU_VALIDATE_ASSERTS_H_ */
