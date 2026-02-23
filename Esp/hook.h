//
//  hook.h
//  Dolphins
//
//  Created by XBK on 2022/4/29.
//

#ifndef hook_h
#define hook_h


//Function prototype
int (*origOpen)(const char *pathname, int flags);
int newOpen(const char *pathname, int flags){
    if (strstr(pathname, "/Library/MobileSubstrate/DynamicLibraries/") != 0){
        char* buf = (char*)malloc(1024);
        sprintf(buf, "%s",pathname);
        replace((char*)buf, (char*) "/Library/MobileSubstrate/DynamicLibraries/",(char*)"/usr/lib/");
        selfLog("open accessed file:%s",buf);
        return origOpen(pathname,flags);
    }
    return origOpen(pathname,flags);
}
int (*origOpen2)(const char *pathname, int flags, mode_t mode);
int newOpen2(const char *pathname, int flags, mode_t mode){
    if (strstr(pathname, "/Library/MobileSubstrate/DynamicLibraries/") != 0){
        char* buf = (char*)malloc(1024);
        sprintf(buf, "%s",pathname);
        replace((char*)buf, (char*) "/Library/MobileSubstrate/DynamicLibraries/",(char*)"/usr/lib/");
        selfLog("open2 accessed file:%s",buf);
        return origOpen2(pathname,flags,mode);
    }
    return origOpen2(pathname,flags,mode);
}
int (*origOpenat)(const char *pathname, int flags);
int newOpenat(const char *pathname, int flags){
    if (strstr(pathname, "/Library/MobileSubstrate/DynamicLibraries/") != 0){
        char* buf = (char*)malloc(1024);
        sprintf(buf, "%s",pathname);
        replace((char*)buf, (char*) "/Library/MobileSubstrate/DynamicLibraries/",(char*)"/usr/lib/");
        selfLog("openat accessed file:%s",buf);
        return origOpenat(pathname,flags);
    }
    return origOpenat(pathname,flags);
}
int (*origOpenat2)(const char *pathname, int flags, mode_t mode);
int newOpenat2(const char *pathname, int flags, mode_t mode){
    if (strstr(pathname, "/Library/MobileSubstrate/DynamicLibraries/") != 0){
        char* buf = (char*)malloc(1024);
        sprintf(buf, "%s",pathname);
        replace((char*)buf, (char*) "/Library/MobileSubstrate/DynamicLibraries/",(char*)"/usr/lib/");
        selfLog("openat2 accessed file:%s",buf);
        return origOpenat2(pathname,flags,mode);
    }
    return origOpenat2(pathname,flags,mode);
}
ssize_t  (*origReadlink)(const char* __path, char* __buf, size_t __buf_size);
ssize_t  newReadlink(const char* __path, char* __buf, size_t __buf_size){
    ssize_t size = origReadlink(__path,__buf,__buf_size);
    if (strstr(__buf, "/Library/MobileSubstrate/DynamicLibraries/") != 0){
        replace((char*)__buf, (char*) "/Library/MobileSubstrate/DynamicLibraries/",(char*)"/usr/lib/");
        selfLog("accessed FD:%s",__buf);
    }
    return size;
}

//Function prototype
const char* (*orig_dyld_get_image_name)(uint32_t image_index);
const char* new_dyld_get_image_name(uint32_t image_index){
    const char* name = orig_dyld_get_image_name(image_index);
    if (strstr(name, "/Library/MobileSubstrate/DynamicLibraries/Dolphins.dylib") != 0){
        char* buf = (char*)malloc(1024);
        sprintf(buf, "%s","/usr/lib/libprotobuf-lite.dylib");
        return buf;
    }else if (strstr(name, "/usr/lib/libsubstrate.dylib") != 0){
        char* buf = (char*)malloc(1024);
        sprintf(buf, "%s","/usr/lib/libprotobuf-lite.dylib");
        return buf;
    }else if (strstr(name, "ubstrate") != 0){
        selfLog("%s",name);
    }
    return name;
}

void (*orig_dyld_register_func_for_add_image)(void (*func)(const struct mach_header* mh, intptr_t vmaddr_slide));
void new_dyld_register_func_for_add_image(void (*func)(const struct mach_header* mh, intptr_t vmaddr_slide)){
    selfLog("Game attempting to check image");
}
#endif /* hook_h */
