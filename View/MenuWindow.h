//
//  MenuWindow.h
//  Dolphins
//
//  Created by XBK on 2022/4/25.
//

#import <UIKit/UIKit.h>

#include "imgui/imgui.h"

#include "module_tools.h"

#include "imgui_tools.h"

#include "ini_rw.h"

@class OverlayView;

NS_ASSUME_NONNULL_BEGIN

@interface MenuWindow : NSObject

@property (nonatomic, assign) ModuleControl *moduleControl;

- (instancetype)initWithFrame:(ModuleControl*)control;

-(void)setOverlayView:(OverlayView*)ov;
//Draw menu window
-(void)drawMenuWindow;
//Show system info page
-(void)showSystemInfo;
//Player function control
-(void) showPlayerControl;
//Material function control
-(void) showMaterialControl;
//Aimbot control
-(void) showAimbotControl;
//Read Ini config
-(void)readIniConfig;

@end

NS_ASSUME_NONNULL_END
