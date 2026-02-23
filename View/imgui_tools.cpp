//
//  ImguiTools.cpp
//  Dolphins
//
//  Created by XBK on 2022/4/25.
//

#include "imgui_tools.h"

void HelpMarker(const char *desc) {
    ImGui::TextColored(ImVec4(1.0f, 0.0f, 0.0f, 1.0f), "(?)");
    if (ImGui::IsItemHovered()) {
        ImGui::BeginTooltip();
        ImGui::PushTextWrapPos(ImGui::GetFontSize() * 35.0f);
        ImGui::TextUnformatted(desc);
        ImGui::PopTextWrapPos();
        ImGui::EndTooltip();
    }
}

float calcTextSize(const char *text, float font_size) {
    ImGuiContext &g = *GImGui;
    
    ImFont *font = g.Font;
    
    ImVec2 text_size;
    if (font_size == 0) {
        text_size = font->CalcTextSizeA(font->FontSize, FLT_MAX, -1.0f, text, NULL, NULL);
    } else {
        text_size = font->CalcTextSizeA(font_size, FLT_MAX, -1.0f, text, NULL, NULL);
    }
    
    text_size.x = IM_FLOOR(text_size.x + 0.99999f);
    
    return text_size.x;
}

void setDarkTheme() {
    ImGuiStyle *style = &ImGui::GetStyle();
    /*
    style->WindowRounding = 12.0f;//窗口圆角
    style->WindowBorderSize = 1.0f;//窗口边框
    style->FramePadding = ImVec2(16.0f, 16.0f);//组件内边距
    style->WindowPadding = ImVec2(16.0f, 16.0f);//窗口内边距
    
    style->ScrollbarSize = 64.0f;//滚动条大小
    style->ScrollbarRounding = 8.0f;//滚动条大小
    style->FrameRounding = 12.0f;
    style->FrameBorderSize = 1.0f;
    style->ItemSpacing = ImVec2(16.0f, 16.0f);
    style->ItemInnerSpacing = ImVec2(16.0f, 16.0f);
    style->GrabMinSize = 72.0f;
    style->GrabRounding = 12.0f;
    
    ImVec4 *colors = style->Colors;
    
    colors[ImGuiCol_Text] = ImColor(255, 165, 0, 255).Value;
    colors[ImGuiCol_TextDisabled] = ImColor(128, 128, 128, 255).Value;
    
    colors[ImGuiCol_WindowBg] = ImColor(100, 100, 100, 255).Value;
    colors[ImGuiCol_ChildBg] = ImColor(100, 100, 100, 255).Value;
    colors[ImGuiCol_PopupBg] = ImColor(90, 90, 90, 255).Value;
    colors[ImGuiCol_Border] = ImColor(80, 80, 80, 255).Value;
    colors[ImGuiCol_BorderShadow] = ImColor(0, 0, 0, 0).Value;
    
    colors[ImGuiCol_FrameBg] = ImColor(90, 90, 90, 255).Value;
    colors[ImGuiCol_FrameBgHovered] = ImColor(90, 90, 90, 255).Value;
    colors[ImGuiCol_FrameBgActive] = ImColor(97, 167, 217, 50).Value;
    
    colors[ImGuiCol_TitleBg] = ImColor(90, 90, 90, 255).Value;
    colors[ImGuiCol_TitleBgActive] = ImColor(90, 90, 90, 255).Value;
    colors[ImGuiCol_TitleBgCollapsed] = ImColor(224, 0, 255, 255).Value;
    colors[ImGuiCol_MenuBarBg] = ImColor(90, 90, 90, 255).Value;
    
    colors[ImGuiCol_ScrollbarBg] = ImColor(90, 90, 90, 255).Value;
    colors[ImGuiCol_ScrollbarGrab] = ImColor(97, 167, 217, 150).Value;
    colors[ImGuiCol_ScrollbarGrabHovered] = ImColor(97, 167, 217, 150).Value;
    colors[ImGuiCol_ScrollbarGrabActive] = ImColor(97, 167, 217, 255).Value;
    
    colors[ImGuiCol_CheckMark] = ImColor(97, 167, 217, 255).Value;
    colors[ImGuiCol_SliderGrab] = ImColor(97, 167, 217, 255).Value;
    colors[ImGuiCol_SliderGrabActive] = ImColor(97, 167, 217, 255).Value;
    
    colors[ImGuiCol_Button] = ImColor(97, 167, 217, 150).Value;
    colors[ImGuiCol_ButtonHovered] = ImColor(97, 167, 217, 150).Value;
    colors[ImGuiCol_ButtonActive] = ImColor(97, 167, 217, 255).Value;
    
    colors[ImGuiCol_Header] = ImColor(100, 100, 100, 255).Value;
    colors[ImGuiCol_HeaderHovered] = ImColor(90, 90, 90, 255).Value;
    colors[ImGuiCol_HeaderActive] = ImColor(90, 90, 90, 255).Value;
    
    colors[ImGuiCol_Separator] = ImColor(80, 80, 80, 255).Value;
    colors[ImGuiCol_SeparatorHovered] = ImColor(224, 0, 255, 255).Value;
    colors[ImGuiCol_SeparatorActive] = ImColor(224, 0, 255, 255).Value;
    
    colors[ImGuiCol_ResizeGrip] = ImColor(97, 167, 217, 150).Value;
    colors[ImGuiCol_ResizeGripHovered] = ImColor(97, 167, 217, 150).Value;
    colors[ImGuiCol_ResizeGripActive] = ImColor(97, 167, 217, 255).Value;
    
    colors[ImGuiCol_Tab] = ImColor(97, 167, 217, 150).Value;
    colors[ImGuiCol_TabHovered] = ImColor(97, 167, 217, 150).Value;
    colors[ImGuiCol_TabActive] = ImColor(100, 100, 100, 255).Value;
    colors[ImGuiCol_TabUnfocused] = ImColor(224, 0, 255, 255).Value;
    colors[ImGuiCol_TabUnfocusedActive] = ImColor(224, 0, 255, 255).Value;
    
    
    colors[ImGuiCol_PlotLines] = ImColor(97, 167, 217, 255).Value;
    colors[ImGuiCol_PlotLinesHovered] = ImColor(97, 167, 217, 150).Value;
    colors[ImGuiCol_PlotHistogram] = ImColor(97, 167, 217, 255).Value;
    colors[ImGuiCol_PlotHistogramHovered] = ImColor(97, 167, 217, 150).Value;
    
    colors[ImGuiCol_TableHeaderBg] = ImColor(90, 90, 90, 255).Value;
    colors[ImGuiCol_TableBorderStrong] = ImColor(70, 70, 70, 150).Value;
    colors[ImGuiCol_TableBorderLight] = ImColor(80, 80, 80, 255).Value;
    colors[ImGuiCol_TableRowBg] = ImColor(90, 90, 90, 150).Value;
    colors[ImGuiCol_TableRowBgAlt] = ImColor(100, 100, 100, 150).Value;
    
    colors[ImGuiCol_TextSelectedBg] = ImColor(224, 0, 255, 255).Value;
    colors[ImGuiCol_DragDropTarget] = ImColor(224, 0, 255, 255).Value;
    
    colors[ImGuiCol_NavHighlight] = ImColor(224, 0, 255, 255).Value;
    colors[ImGuiCol_NavWindowingHighlight] = ImColor(224, 0, 255, 255).Value;
    colors[ImGuiCol_NavWindowingDimBg] = ImColor(224, 0, 255, 255).Value;
    colors[ImGuiCol_ModalWindowDimBg] = ImColor(224, 0, 255, 255).Value;
*/

    style->WindowRounding = 12.0f;//窗口圆角
    style->WindowBorderSize = 1.0f;//窗口边框
    style->FramePadding = ImVec2(16.0f, 16.0f);//组件内边距
    style->WindowPadding = ImVec2(16.0f, 16.0f);//窗口内边距
    
    style->ScrollbarSize = 64.0f;//滚动条大小
    style->ScrollbarRounding = 8.0f;//滚动条大小
    style->FrameRounding = 12.0f;
    style->FrameBorderSize = 1.0f;
    style->ItemSpacing = ImVec2(16.0f, 16.0f);
    style->ItemInnerSpacing = ImVec2(16.0f, 16.0f);
    style->GrabMinSize = 72.0f;
    style->GrabRounding = 12.0f;
        style->WindowTitleAlign = ImVec2(0.5, 0.5);
		style->ButtonTextAlign = ImVec2(0.5,0.5);


    ImVec4 *colors = style->Colors;
/*
		style->Colors[ImGuiCol_Text]                  = ImColor(255, 255, 255, 255);
	    style->Colors[ImGuiCol_WindowBg]              = ImColor(0, 0, 0, 70);




colors[ImGuiCol_Text]                   = ImVec4(0.92f, 0.92f, 0.92f, 1.00f);
    colors[ImGuiCol_TextDisabled]           = ImVec4(0.44f, 0.44f, 0.44f, 1.00f);
    colors[ImGuiCol_WindowBg]               = ImVec4(0.06f, 0.06f, 0.06f, 1.00f);
    colors[ImGuiCol_ChildBg]                = ImVec4(0.00f, 0.00f, 0.00f, 0.00f);
    colors[ImGuiCol_PopupBg]                = ImVec4(0.08f, 0.08f, 0.08f, 0.94f);
    colors[ImGuiCol_Border]                 = ImVec4(0.80f, 0.00f, 0.00f, 1.00f);
    colors[ImGuiCol_BorderShadow]           = ImVec4(0.00f, 0.00f, 0.00f, 0.00f);
    colors[ImGuiCol_FrameBg]                = ImVec4(0.11f, 0.11f, 0.11f, 1.00f);
    colors[ImGuiCol_FrameBgHovered]         = ImVec4(0.80f, 0.00f, 0.00f, 1.00f);
    colors[ImGuiCol_FrameBgActive]          = ImVec4(1.00f, 0.00f, 0.00f, 1.00f);
    colors[ImGuiCol_TitleBg]                = ImVec4(0.80f, 0.00f, 0.00f, 1.00f);
    colors[ImGuiCol_TitleBgActive]          = ImVec4(1.00f, 0.00f, 0.00f, 1.00f);
    colors[ImGuiCol_TitleBgCollapsed]       = ImVec4(0.00f, 0.00f, 0.00f, 0.51f);
    colors[ImGuiCol_MenuBarBg]              = ImVec4(0.11f, 0.11f, 0.11f, 1.00f);
    colors[ImGuiCol_ScrollbarBg]            = ImVec4(0.06f, 0.06f, 0.06f, 0.53f);
    colors[ImGuiCol_ScrollbarGrab]          = ImVec4(0.21f, 0.21f, 0.21f, 1.00f);
    colors[ImGuiCol_ScrollbarGrabHovered]   = ImVec4(0.47f, 0.47f, 0.47f, 1.00f);
    colors[ImGuiCol_ScrollbarGrabActive]    = ImVec4(0.81f, 0.83f, 0.81f, 1.00f);
    colors[ImGuiCol_CheckMark]              = ImVec4(1.00f, 0.00f, 0.00f, 1.00f);
    colors[ImGuiCol_SliderGrab]             = ImVec4(0.80f, 0.00f, 0.00f, 1.00f);
    colors[ImGuiCol_SliderGrabActive]       = ImVec4(1.00f, 0.00f, 0.00f, 1.00f);
    colors[ImGuiCol_Button]                 = ImVec4(0.80f, 0.00f, 0.00f, 1.00f);
    colors[ImGuiCol_ButtonHovered]          = ImVec4(1.00f, 0.00f, 0.00f, 1.00f);
    colors[ImGuiCol_ButtonActive]           = ImVec4(1.00f, 0.00f, 0.00f, 1.00f);
    colors[ImGuiCol_Header]                 = ImVec4(0.80f, 0.00f, 0.00f, 1.00f);
    colors[ImGuiCol_HeaderHovered]          = ImVec4(0.60f, 0.00f, 0.00f, 1.00f);
    colors[ImGuiCol_HeaderActive]           = ImVec4(1.00f, 0.00f, 0.00f, 1.00f);
    colors[ImGuiCol_Separator]              = ImVec4(0.21f, 0.21f, 0.21f, 1.00f);
    colors[ImGuiCol_SeparatorHovered]       = ImVec4(0.60f, 0.00f, 0.00f, 1.00f);
    colors[ImGuiCol_SeparatorActive]        = ImVec4(1.00f, 0.00f, 0.00f, 1.00f);
    colors[ImGuiCol_ResizeGrip]             = ImVec4(0.21f, 0.21f, 0.21f, 1.00f);
    colors[ImGuiCol_ResizeGripHovered]      = ImVec4(0.60f, 0.00f, 0.00f, 1.00f);
    colors[ImGuiCol_ResizeGripActive]       = ImVec4(1.00f, 0.00f, 0.00f, 1.00f);
    colors[ImGuiCol_Tab]                    = ImVec4(0.80f, 0.00f, 0.00f, 1.00f);
    colors[ImGuiCol_TabHovered]             = ImVec4(0.60f, 0.00f, 0.00f, 1.00f);
    colors[ImGuiCol_TabActive]              = ImVec4(1.00f, 0.00f, 0.00f, 1.00f);
    colors[ImGuiCol_TabUnfocused]           = ImVec4(0.10f, 0.10f, 0.10f, 0.97f);
    colors[ImGuiCol_TabUnfocusedActive]     = ImVec4(1.00f, 0.00f, 0.00f, 1.00f);
    colors[ImGuiCol_PlotLines]              = ImVec4(0.61f, 0.61f, 0.61f, 1.00f);
    colors[ImGuiCol_PlotLinesHovered]       = ImVec4(1.00f, 0.00f, 0.00f, 1.00f);
    colors[ImGuiCol_PlotHistogram]          = ImVec4(1.00f, 0.00f, 0.00f, 1.00f);
    colors[ImGuiCol_PlotHistogramHovered]   = ImVec4(1.00f, 0.00f, 0.00f, 1.00f);
    colors[ImGuiCol_TextSelectedBg]         = ImVec4(1.00f, 0.00f, 0.00f, 0.35f);
    colors[ImGuiCol_DragDropTarget]         = ImVec4(1.00f, 1.00f, 0.00f, 0.90f);
    colors[ImGuiCol_NavHighlight]           = ImVec4(1.00f, 0.00f, 0.00f, 1.00f);
    colors[ImGuiCol_NavWindowingHighlight]  = ImVec4(1.00f, 1.00f, 1.00f, 0.70f);
    colors[ImGuiCol_NavWindowingDimBg]      = ImVec4(0.80f, 0.80f, 0.80f, 0.20f);
*/
/*
// Thiết lập màu nền của menu
style->Colors[ImGuiCol_MenuBarBg] = ImVec4(0.2f, 0.2f, 0.4f, 1.0f);

// Thiết lập màu chữ của menu
style->Colors[ImGuiCol_Text] = ImVec4(1.0f, 1.0f, 1.0f, 1.0f);

// Thiết lập màu nền khi di chuột qua menu
//style->Colors[ImGuiCol_MenuBarBgHovered] = ImVec4(0.3f, 0.3f, 0.5f, 1.0f);

// Thiết lập màu nền khi menu được chọn
style->Colors[ImGuiCol_MenuBarBg] = ImVec4(0.4f, 0.4f, 0.6f, 1.0f);
*/
/*

style->Colors[ImGuiCol_WindowBg] = ImVec4(0.1f, 0.1f, 0.1f, 1.0f);
style->Colors[ImGuiCol_FrameBg] = ImVec4(0.2f, 0.2f, 0.2f, 1.0f);
style->Colors[ImGuiCol_Text] = ImVec4(1.0f, 1.0f, 1.0f, 1.0f);
style->Colors[ImGuiCol_Button] = ImVec4(0.5f, 0.5f, 0.5f, 1.0f);
style->Colors[ImGuiCol_ButtonHovered] = ImVec4(0.7f, 0.7f, 0.7f, 1.0f);
style->Colors[ImGuiCol_ButtonActive] = ImVec4(0.9f, 0.9f, 0.9f, 1.0f);
style->Colors[ImGuiCol_Header] = ImVec4(0.2f, 0.2f, 0.2f, 1.0f);
style->Colors[ImGuiCol_HeaderHovered] = ImVec4(0.4f, 0.4f, 0.4f, 1.0f);
style->Colors[ImGuiCol_HeaderActive] = ImVec4(0.6f, 0.6f, 0.6f, 1.0f);
style->Colors[ImGuiCol_CheckMark] = ImVec4(0.8f, 0.8f, 0.8f, 1.0f);
style->Colors[ImGuiCol_SliderGrab] = ImVec4(0.8f, 0.8f, 0.8f, 1.0f);
style->Colors[ImGuiCol_SliderGrabActive] = ImVec4(0.6f, 0.6f, 0.6f, 1.0f);
style->Colors[ImGuiCol_FrameBgHovered] = ImVec4(0.3f, 0.3f, 0.3f, 1.0f);
style->Colors[ImGuiCol_FrameBgActive] = ImVec4(0.4f, 0.4f, 0.4f, 1.0f);
style->Colors[ImGuiCol_PopupBg] = ImVec4(0.1f, 0.1f, 0.1f, 1.0f);
*/
/*

style->Colors[ImGuiCol_WindowBg] = ImVec4(0.2f, 0.2f, 0.2f, 1.0f);

// Thay đổi màu nền của các khung (frames)
style->Colors[ImGuiCol_FrameBg] = ImVec4(0.3f, 0.3f, 0.3f, 1.0f);

// Thay đổi màu chữ
style->Colors[ImGuiCol_Text] = ImVec4(1.0f, 0.8f, 0.4f, 1.0f);

// Thay đổi màu nút
style->Colors[ImGuiCol_Button] = ImVec4(0.4f, 0.6f, 0.8f, 1.0f);
style->Colors[ImGuiCol_ButtonHovered] = ImVec4(0.5f, 0.7f, 0.9f, 1.0f);
style->Colors[ImGuiCol_ButtonActive] = ImVec4(0.3f, 0.5f, 0.7f, 1.0f);

// Thay đổi màu của header
style->Colors[ImGuiCol_Header] = ImVec4(0.4f, 0.4f, 0.4f, 1.0f);
style->Colors[ImGuiCol_HeaderHovered] = ImVec4(0.5f, 0.5f, 0.5f, 1.0f);
style->Colors[ImGuiCol_HeaderActive] = ImVec4(0.6f, 0.6f, 0.6f, 1.0f);

// Thay đổi màu của slider
style->Colors[ImGuiCol_SliderGrab] = ImVec4(0.8f, 0.4f, 0.2f, 1.0f);
style->Colors[ImGuiCol_SliderGrabActive] = ImVec4(0.9f, 0.5f, 0.3f, 1.0f);

// Thay đổi màu của checkbox
style->Colors[ImGuiCol_CheckMark] = ImVec4(0.8f, 0.8f, 0.8f, 1.0f);

// Thay đổi màu nền của popup
style->Colors[ImGuiCol_PopupBg] = ImVec4(0.1f, 0.1f, 0.1f, 1.0f);
*/

ImVec4 mainColor = ImVec4(0.0f, 0.0f, 0.0f, 1.0f);

// Màu nền của cửa sổ
style->Colors[ImGuiCol_WindowBg] = mainColor;

// Màu nền của các khung (frames)
style->Colors[ImGuiCol_FrameBg] = mainColor;

// Màu chữ
style->Colors[ImGuiCol_Text] = ImVec4(1.0f, 1.0f, 1.0f, 1.0f);

// Màu nút
style->Colors[ImGuiCol_Button] = mainColor;
style->Colors[ImGuiCol_ButtonHovered] = ImVec4(0.2f, 0.2f, 0.2f, 1.0f);
style->Colors[ImGuiCol_ButtonActive] = ImVec4(0.4f, 0.4f, 0.4f, 1.0f);

// Màu của header
style->Colors[ImGuiCol_Header] = mainColor;
style->Colors[ImGuiCol_HeaderHovered] = ImVec4(0.2f, 0.2f, 0.2f, 1.0f);
style->Colors[ImGuiCol_HeaderActive] = ImVec4(0.4f, 0.4f, 0.4f, 1.0f);

// Màu của slider
style->Colors[ImGuiCol_SliderGrab] = mainColor;
style->Colors[ImGuiCol_SliderGrabActive] = ImVec4(0.2f, 0.2f, 0.2f, 1.0f);

// Màu của checkbox
style->Colors[ImGuiCol_CheckMark] = ImVec4(1.0f, 1.0f, 1.0f, 1.0f);

// Màu nền của popup
style->Colors[ImGuiCol_PopupBg] = mainColor;
        }

