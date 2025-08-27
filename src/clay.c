#define CLAY_IMPLEMENTATION
#include "clay/clay.h"
#include <string.h>

Clay_Context* context;

Clay_String Clay__InternString(Clay_String string) {
    if (context->dynamicStringData.length + string.length > context->dynamicStringData.capacity)
    {
        return CLAY_STRING("OOM");
    }

    char *chars = (char *)(context->dynamicStringData.internalArray + context->dynamicStringData.length);
    memcpy(chars, string.chars, string.length);
    context->dynamicStringData.length += string.length;
    return CLAY__INIT(Clay_String) { .length = string.length, .chars = chars };
}
