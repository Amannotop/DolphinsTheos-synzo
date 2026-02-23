//
//  ImguiTools.h
//  Dolphins
//
//  Created by XBK on 2022/4/24.
//

#ifndef ImguiTools_h
#define ImguiTools_h
#include "imgui/imgui_internal.h"

#define IM_FLOOR(_VAL)                  ((float)(int)(_VAL))

//Tip text
void HelpMarker(const char *desc);
//Set Imgui style
void setDarkTheme();
//Get text width
float calcTextSize(const char *text, float font_size = 0);

#endif /* ImguiTools_h */
