//
//  log.cpp
//  Dolphins
//
//  Created by XBK on 2022/4/26.
//

#include "log.h"

void selfLog(const char* format, ...) {
    va_list argList;
    va_start(argList, format);
    NSString *text = [[NSString alloc] initWithFormat:[NSString stringWithUTF8String:format] arguments:argList];
    va_end(argList);
    NSLog(@"[%s] %@", "Dolphins", text);
}

char* replace(char *s1, char *s2, char *s3) {
    char *p, *from, *to, *begin = s1;
    int c1, c2, c3, c;         //String length and count
    c2 = strlen(s2);
    c3 = (s3 != NULL) ? strlen(s3) : 0;
    if (c2 == 0) return s1;     //Note to exit
    while (true)             //Replace all occurrences
    {
        c1 = strlen(begin);
        p = strstr(begin, s2); //Occurrence position
        if (p == NULL)         //Not found
            return s1;
        if (c2 > c3)           //String move forward
        {
            from = p + c2;
            to = p + c3;
            c = c1 - c2 + begin - p + 1;
            while (c--)
                *to++ = *from++;
        }
        else if (c2 < c3)      //String move backward
        {
            from = begin + c1;
            to = from - c2 + c3;
            c = from - p - c2 + 1;
            while (c--)
                *to-- = *from--;
        }
        if (c3)              //Complete replace
        {
            from = s3, to = p, c = c3;
            while (c--)
                *to++ = *from++;
        }
        begin = p + c3;         //New search position
    }
}
