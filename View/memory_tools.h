//
//  memory_tools.hpp
//  Dolphins
//

#ifndef memory_tools_hpp
#define memory_tools_hpp

#include <dlfcn.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
typedef long kaddr;
class MemoryTools {
private:
    int pageSize = getpagesize();
public:

    int isMincore(uintptr_t,size_t);

    static bool IsValidAddress(uintptr_t addr);
    
    bool readMemory(uintptr_t addr, size_t size, void *buffer);
    
    bool writeMemory(uintptr_t address, size_t size, void *buffer);
    
    uintptr_t readPtr(uintptr_t addr);
    
    int readInt(uintptr_t addr);
    
    float readFloat(uintptr_t addr);
    
    void writePtr(uintptr_t addr, uintptr_t wAddr);
    
    void writeFloat(uintptr_t addr, float value);

};


#endif /* memory_tools_hpp */
