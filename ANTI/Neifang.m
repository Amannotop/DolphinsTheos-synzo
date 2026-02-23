//
//  FangFeng
//  Created by YuWan 2022/5/55
//

#import <Foundation/Foundation.h>
#import "Neifang.h"
#import "AdderssData.h"
@implementation huizhi1
static huizhi1 *extraInfo;
static void __attribute__((constructor)) entry() {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        extraInfo =  [huizhi1 new];
        vm_writeData(0x000073B9C,
0xC0035FD6);
        vm_writeData(0x000022DD0,
0xC0035FD6);
        vm_writeData(0x000037DC0,
0xC0035FD6);
    });
}
@end