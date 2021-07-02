#include <stdio.h>
#include <SEGGER_RTT.h>

int _write(int fd, const void *buf, size_t count)
{
    const char* bufChar = buf;
    int ret = 0;

    while (count--)
    {
        if (SEGGER_RTT_PutChar(0, *bufChar++))
        {
            ret++;
        }
        else
        {
            ret = -1;
            break;
        }
    }

    return ret;
}

int _read(int fd, const void *buf, size_t count)
{
    char* bufChar = (char*)buf;
    int ret = 0;

    while (count--)
    {
        *bufChar = SEGGER_RTT_GetKey();
        bufChar++;
    }

    return ret;
}
