//
//  MenuWindow.m
//  Dolphins
//
//  Created by Synzo on 2022/4/25.
//

#import "View/MenuWindow.h"
#import "View/OverlayView.h"
#import "SCLAlertView/SCLAlertView.h"
#import "GWMProgressHUD/GWMProgressHUD.h"
#import "mahoa.h"
#import "FCUUID/FCUUID.h"

#import "Internet/Reachability.h"
@implementation MenuWindow
INI*config;

const char *optionItemName[] = {" Home", " Esp", " Items", " Aimbot"};
int optionItemCurrent = 0;
//Aimbot body part text
int aimbotIntensity; //cường độ
//const char *aimbotIntensityText[] = {"So Low","Low", "Normal", "High", "So High", "Lock High", "Lock to dead"};
const char *aimbotIntensityText[] = {"So Low","Low", "Normal", "High", "So High"};
//Phần văn bản tự nhắm
const char *aimbotModeText[] = {"Open Scope", "Fire", "Open Scope & Fire", "Auto", "Not Aim"};
//Phần văn bản tự nhắm
const char *aimbotPartsText[] = {"(Auto) Head", "(Auto) Body", "(Auto) Head & Body", "Default Head", "Default Body"};

OverlayView *overlayView;

- (instancetype)initWithFrame:(ModuleControl*)control {
    self.moduleControl = control;
    //Get Documents directory path
    NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    //Initialize file manager
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //Concatenate file path
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"dolphine.ini"];
    //File does not exist
    if(![fileManager fileExistsAtPath:filePath]){
        //Create file
        [fileManager createFileAtPath:filePath contents:[NSData data] attributes:nil];
    }
    //Get ini file data
    config = ini_load((char*)filePath.UTF8String);
    
    return [super init];
}

-(void)setOverlayView:(OverlayView*)ov{
    overlayView = ov;
    //Read config item
    [self readIniConfig];


}




-(void)drawMenuWindow {



    //Đặt kích thước của cửa sổ tiếp theo
    ImGuiIO & io = ImGui::GetIO();

ImFont* font = ImGui::GetFont();
    font->Scale = 35.f / font->FontSize;
            

    ImGui::SetNextWindowSize({1280, 700}, ImGuiCond_FirstUseEver);
//    ImGui::SetNextWindowPos({172, 172}, ImGuiCond_FirstUseEver);
    ImGui::SetNextWindowPos(ImVec2(io.DisplaySize.x * 0.5f, io.DisplaySize.y * 0.5f), 0, ImVec2(0.5f, 0.5f));


static int a = 20;//bo viền menu
static int b = 8;//bo tròn checkbox, button

ImGui::GetStyle().WindowRounding = a;
ImGui::GetStyle().FrameRounding = b;



NSString *ver = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];

char* bonios = (char*) [[NSString stringWithFormat:NSSENCRYPT("TRAXERIOSHACK.GL Ver: %@") ,ver] cStringUsingEncoding:NSUTF8StringEncoding];


//, ImGuiWindowFlags_NoCollapse | ImGuiWindowFlags_NoResize
     if (ImGui::Begin(bonios,&self.moduleControl->menuStatus)) {
        ImGuiContext& g = *GImGui;
        if(g.NavWindow == NULL){
            self.moduleControl->menuStatus = !self.moduleControl->menuStatus;
        }
        //Set next control width
        ImGui::BeginChild("##optionLayout", {calcTextSize("otionlayout") + 200.0f, 0}, false, ImGuiWindowFlags_None);
        for (int i = 0; i < 4; ++i) {
            if (optionItemCurrent != i) {
                ImGui::PushStyleColor(ImGuiCol_Button, ImColor(0, 0, 0, 0).Value);
                ImGui::PushStyleColor(ImGuiCol_ButtonHovered, ImColor(0, 0, 0, 0).Value);
                ImGui::PushStyleColor(ImGuiCol_ButtonActive, ImColor(0, 0, 0, 0).Value);
            }
            bool isClick = ImGui::Button(optionItemName[i]);
            if (optionItemCurrent != i) {
                ImGui::PopStyleColor(3);
            }
            if (isClick) {
                optionItemCurrent = i;
            }
        }
        ImGui::EndChild();
        //Same line
        ImGui::SameLine();
        ImGui::BeginChild("##surfaceLayout", {0, 0}, false, ImGuiWindowFlags_None);
        switch (optionItemCurrent) {
            case 0:
                [self showSystemInfo];
                break;
            case 1:
                [self showPlayerControl];
                break;
            case 2:
                [self showMaterialControl];
                break;
            case 3:
                [self showAimbotControl];
                break;

        }
        ImGui::EndChild();
        
        
        ImGui::End();
    }
}



-(void)showSystemInfo {
    ImGui::BulletColorText(ImColor(97, 167, 217, 255).Value, "FPS Frame Rate");
    if (ImGui::RadioButton("60FPS", &self.moduleControl->fps, 0)) {
        configManager::putInteger(config,"mainSwitch", "fps",self.moduleControl->fps);
        overlayView.preferredFramesPerSecond = 60;
    }
    ImGui::SameLine();
    if (ImGui::RadioButton("90FPS", &self.moduleControl->fps, 1)) {
        configManager::putInteger(config,"mainSwitch", "fps",self.moduleControl->fps);
        overlayView.preferredFramesPerSecond = 90;
    }
    ImGui::SameLine();
    if (ImGui::RadioButton("120FPS", &self.moduleControl->fps, 2)) {
        configManager::putInteger(config,"mainSwitch", "fps",self.moduleControl->fps);
        overlayView.preferredFramesPerSecond = 120;



    }
    
    ImGui::BulletColorText(ImColor(97, 167, 217, 255).Value, "Control Switch");
    
    if (ImGui::Checkbox("Player ESP", &self.moduleControl->mainSwitch.playerStatus)) {
        configManager::putBoolean(config,"mainSwitch", "player", self.moduleControl->mainSwitch.playerStatus);
           }
    ImGui::SameLine();
    if (ImGui::Checkbox("Items ESP", &self.moduleControl->mainSwitch.materialStatus)) {
        configManager::putBoolean(config,"mainSwitch", "material", self.moduleControl->mainSwitch.materialStatus);
        }
    ImGui::SameLine();
    if (ImGui::Checkbox("Aimbot", &self.moduleControl->mainSwitch.aimbotStatus)) {
        configManager::putBoolean(config,"mainSwitch", "aimbot", self.moduleControl->mainSwitch.aimbotStatus);
            }


ImGui::BulletColorText(ImColor(97, 167, 217, 255).Value, "System Notifi");
    
    ImGui::PushStyleVar(ImGuiStyleVar_FramePadding, ImVec2(32.0f, 32.0f));
    ImGui::TextWrapped("%s", "Expired Time: 2024-06-05");
    ImGui::TextWrapped("%s", "Expired End Time: 2033-06-05");
    ImGui::PopStyleVar();
    


ImGui::TextColored(ImColor(125, 165, 62),"Delay frame .  %.3f ms/frame (%.1f FPS)", 500.0f / ImGui::GetIO().Framerate, ImGui::GetIO().Framerate);



    ImGui::Text("Copyright © 2023 @adamputra84. All Rights Reserved.");
    
}





-(void) showPlayerControl {
    ImGui::BulletColorText(ImColor(97, 167, 217, 255).Value, "ESP Control");
    if (ImGui::Checkbox("Handheld Icon", &self.moduleControl->playerSwitch.SCStatus)) {
        configManager::putBoolean(config,"playerSwitch", "playerSwitch_6", self.moduleControl->playerSwitch.SCStatus);
   /* }
    ImGui::SameLine();
    if (ImGui::Checkbox("Handheld Text", &self.moduleControl->playerSwitch.SCWZStatus)) {
        configManager::putBoolean(config,"playerSwitch", "playerSwitch_7", self.moduleControl->playerSwitch.SCWZStatus);*/
    }

    
    if (ImGui::Checkbox("Box", &self.moduleControl->playerSwitch.boxStatus)) {
        configManager::putBoolean(config,"playerSwitch", "playerSwitch_0", self.moduleControl->playerSwitch.boxStatus);
    }
    ImGui::SameLine();
    if (ImGui::Checkbox("Bone", &self.moduleControl->playerSwitch.boneStatus)) {
        configManager::putBoolean(config,"playerSwitch", "playerSwitch_1", self.moduleControl->playerSwitch.boneStatus);
    }
    ImGui::SameLine();
    if (ImGui::Checkbox("Line", &self.moduleControl->playerSwitch.lineStatus)) {
        configManager::putBoolean(config,"playerSwitch", "playerSwitch_2", self.moduleControl->playerSwitch.lineStatus);
    }
    ImGui::SameLine();
    if (ImGui::Checkbox("Info", &self.moduleControl->playerSwitch.infoStatus)) {
        configManager::putBoolean(config,"playerSwitch", "playerSwitch_3", self.moduleControl->playerSwitch.infoStatus);
    }
    
    if (ImGui::Checkbox("Radar", &self.moduleControl->playerSwitch.radarStatus)) {
        configManager::putBoolean(config,"playerSwitch", "playerSwitch_4", self.moduleControl->playerSwitch.radarStatus);
    }
    ImGui::SameLine();
    if (ImGui::Checkbox("Warning Behind", &self.moduleControl->playerSwitch.backStatus)) {
        configManager::putBoolean(config,"playerSwitch", "playerSwitch_5", self.moduleControl->playerSwitch.backStatus);
    }
    
    ImGui::BulletColorText(ImColor(97, 167, 217, 255).Value, "Radar Adjustment");
    
    ImGui::SetNextItemWidth(ImGui::GetWindowContentRegionWidth() - calcTextSize("RadrX") - 32.0f);
    if (ImGui::SliderFloat("Radar X##radarX", &self.moduleControl->playerSwitch.radarCoord.x, 0.0f, ([UIScreen mainScreen].bounds.size.width * [UIScreen mainScreen].nativeScale), "%.0f")) {
        configManager::putFloat(config,"playerSwitch", "radarX", self.moduleControl->playerSwitch.radarCoord.x);
    }
    
    ImGui::SetNextItemWidth(ImGui::GetWindowContentRegionWidth() - calcTextSize("RadarY") - 32.0f);
    if (ImGui::SliderFloat("Radar Y##radarY", &self.moduleControl->playerSwitch.radarCoord.y, 0.0f, ([UIScreen mainScreen].bounds.size.height * [UIScreen mainScreen].nativeScale), "%.0f")) {
        configManager::putFloat(config,"playerSwitch", "radarY", self.moduleControl->playerSwitch.radarCoord.y);
    }
    ImGui::SetNextItemWidth(ImGui::GetWindowContentRegionWidth() - calcTextSize("RadarSize") - 32.0f);
    if (ImGui::SliderFloat("Radar Size##radarSize", &self.moduleControl->playerSwitch.radarSize, 1.0f, 100, "%.0f%%")) {
        configManager::putFloat(config,"playerSwitch", "radarSize", self.moduleControl->playerSwitch.radarSize);
    }
}




-(void) showMaterialControl {
    ImGui::BulletColorText(ImColor(97, 167, 217, 255).Value, "Draw Items");
    
    if (ImGui::Checkbox("Material Icon", &self.moduleControl->playerSwitch.WZStatus)) {
        configManager::putBoolean(config,"playerSwitch", "playerSwitch_8", self.moduleControl->playerSwitch.WZStatus);
    }
    ImGui::SameLine();
    if (ImGui::Checkbox("Material Text", &self.moduleControl->playerSwitch.WZWZStatus)) {
        configManager::putBoolean(config,"playerSwitch", "playerSwitch_9", self.moduleControl->playerSwitch.WZWZStatus);
    }

    ImGui::Separator();
    if (ImGui::Checkbox("Bomb Warning", &self.moduleControl->materialSwitch[Warning])) {
        std::string str = "materialSwitch_" + std::to_string(Warning);
        configManager::putBoolean(config,"materialSwitch", str.c_str(), self.moduleControl->materialSwitch[Warning]);
    }

    ImGui::SameLine();


    if (ImGui::Checkbox("Vehicle", &self.moduleControl->materialSwitch[Vehicle])) {
        std::string str = "materialSwitch_" + std::to_string(Vehicle);
        configManager::putBoolean(config,"materialSwitch", str.c_str(), self.moduleControl->materialSwitch[Vehicle]);
    }
    ImGui::Separator();
    if (ImGui::Checkbox("Airdrop", &self.moduleControl->materialSwitch[Airdrop])) {
        std::string str = "materialSwitch_" + std::to_string(Airdrop);
        configManager::putBoolean(config,"materialSwitch", str.c_str(), self.moduleControl->materialSwitch[Airdrop]);
    }
    ImGui::SameLine();
    if (ImGui::Checkbox("FlareGun", &self.moduleControl->materialSwitch[FlareGun])) {
        std::string str = "materialSwitch_" + std::to_string(FlareGun);
        configManager::putBoolean(config,"materialSwitch", str.c_str(), self.moduleControl->materialSwitch[FlareGun]);
    }
    ImGui::Separator();
    if (ImGui::Checkbox("Sniper", &self.moduleControl->materialSwitch[Sniper])) {
        std::string str = "materialSwitch_" + std::to_string(Sniper);
        configManager::putBoolean(config,"materialSwitch", str.c_str(), self.moduleControl->materialSwitch[Sniper]);
    }
    ImGui::SameLine();
    if (ImGui::Checkbox("Weapon", &self.moduleControl->materialSwitch[Rifle])) {
        std::string str = "materialSwitch_" + std::to_string(Rifle);
        configManager::putBoolean(config,"materialSwitch", str.c_str(), self.moduleControl->materialSwitch[Rifle]);
  
    }
    
    ImGui::Separator();
    if (ImGui::Checkbox("Missile", &self.moduleControl->materialSwitch[Missile])) {
        std::string str = "materialSwitch_" + std::to_string(Missile);
        configManager::putBoolean(config,"materialSwitch", str.c_str(), self.moduleControl->materialSwitch[Missile]);
    }
    
    
    ImGui::SameLine();
    if (ImGui::Checkbox("Armor", &self.moduleControl->materialSwitch[Armor])) {
        std::string str = "materialSwitch_" + std::to_string(Armor);
        configManager::putBoolean(config,"materialSwitch", str.c_str(), self.moduleControl->materialSwitch[Armor]);
    }
    ImGui::Separator();
    if (ImGui::Checkbox("SniperParts", &self.moduleControl->materialSwitch[SniperParts])) {
        std::string str = "materialSwitch_" + std::to_string(SniperParts);
        configManager::putBoolean(config,"materialSwitch", str.c_str(), self.moduleControl->materialSwitch[SniperParts]);
    }
    ImGui::SameLine();
    if (ImGui::Checkbox("RifleParts", &self.moduleControl->materialSwitch[RifleParts])) {
        std::string str = "materialSwitch_" + std::to_string(RifleParts);
        configManager::putBoolean(config,"materialSwitch", str.c_str(), self.moduleControl->materialSwitch[RifleParts]);
    }
    ImGui::Separator();
    if (ImGui::Checkbox("Drug", &self.moduleControl->materialSwitch[Drug])) {
        std::string str = "materialSwitch_" + std::to_string(Drug);
        configManager::putBoolean(config,"materialSwitch", str.c_str(), self.moduleControl->materialSwitch[Drug]);
    }
    ImGui::SameLine();
    if (ImGui::Checkbox("Bullet", &self.moduleControl->materialSwitch[Bullet])) {
        std::string str = "materialSwitch_" + std::to_string(Bullet);
        configManager::putBoolean(config,"materialSwitch", str.c_str(), self.moduleControl->materialSwitch[Bullet]);
    }
    ImGui::Separator();
    if (ImGui::Checkbox("Grip", &self.moduleControl->materialSwitch[Grip])) {
        std::string str = "materialSwitch_" + std::to_string(Grip);
        configManager::putBoolean(config,"materialSwitch", str.c_str(), self.moduleControl->materialSwitch[Grip]);
    }
    ImGui::SameLine();
    if (ImGui::Checkbox("Scope", &self.moduleControl->materialSwitch[Sight])) {
        std::string str = "materialSwitch_" + std::to_string(Sight);
        configManager::putBoolean(config,"materialSwitch", str.c_str(), self.moduleControl->materialSwitch[Sight]);
    }

}

-(void) showAimbotControl {
    ImGui::BulletColorText(ImColor(97, 167, 217, 255).Value, "automatic target");
    

    if (ImGui::Checkbox("aiming range", &self.moduleControl->aimbotController.showAimbotRadius)) {
        configManager::putBoolean(config,"aimbotControl", "showRadius", self.moduleControl->aimbotController.showAimbotRadius);
    }
    ImGui::Separator();
    if (ImGui::Checkbox("Not Knockdown", &self.moduleControl->aimbotController.fallNotAim)) {
        configManager::putBoolean(config,"aimbotControl", "fall", self.moduleControl->aimbotController.fallNotAim);
    }
    ImGui::Separator();
    if (ImGui::Checkbox("Not aim Smoke", &self.moduleControl->aimbotController.smoke)) {
        configManager::putBoolean(config,"aimbotControl", "smoke", self.moduleControl->aimbotController.smoke);
    }


    ImGui::SetNextItemWidth(calcTextSize("AimPower"));
    if (ImGui::Combo("aiming power", &aimbotIntensity, aimbotIntensityText, IM_ARRAYSIZE(aimbotIntensityText))) {
        configManager::putInteger(config,"aimbotControl", "intensity",aimbotIntensity);
        switch (aimbotIntensity) {
            case 0:
                self.moduleControl->aimbotController.aimbotIntensity = 0.1f;
                break;
            case 1:
                self.moduleControl->aimbotController.aimbotIntensity = 0.2f;
                break;
            case 2:
                self.moduleControl->aimbotController.aimbotIntensity = 0.3f;
                break;
            case 3:
                self.moduleControl->aimbotController.aimbotIntensity = 0.4f;
                break;
            case 4:
                self.moduleControl->aimbotController.aimbotIntensity = 0.5f;
                break;
            case 5:
                self.moduleControl->aimbotController.aimbotIntensity = 1.0f;
                break;
            case 6:
                self.moduleControl->aimbotController.aimbotIntensity = 1.2f;
                break;
        }
    }
    

    ImGui::SetNextItemWidth(ImGui::GetWindowContentRegionWidth() / 2 - calcTextSize("Mode Aimbot") - 32.0f);
    if (ImGui::Combo("Mode Aimbot", &self.moduleControl->aimbotController.aimbotMode, aimbotModeText, IM_ARRAYSIZE(aimbotModeText))) {
        configManager::putInteger(config,"aimbotControl", "mode", self.moduleControl->aimbotController.aimbotMode);
    }

    ImGui::SetNextItemWidth(ImGui::GetWindowContentRegionWidth() / 2 - calcTextSize("Aimbot Parts") - 32.0f);
    if (ImGui::Combo("Aimbot Parts", &self.moduleControl->aimbotController.aimbotParts, aimbotPartsText, IM_ARRAYSIZE(aimbotPartsText))) {
        configManager::putBoolean(config,"aimbotControl", "parts", self.moduleControl->aimbotController.aimbotParts);
    }
    
    ImGui::SetNextItemWidth(ImGui::GetWindowContentRegionWidth() - calcTextSize("AimPOV") - 32.0f);
    if (ImGui::SliderFloat("AimPOV", &self.moduleControl->aimbotController.aimbotRadius, 0.0f, ([UIScreen mainScreen].bounds.size.height * [UIScreen mainScreen].nativeScale) / 5, "%.0f")) {
        configManager::putFloat(config,"aimbotControl", "radius", self.moduleControl->aimbotController.aimbotRadius);
    }
    
    ImGui::SetNextItemWidth(ImGui::GetWindowContentRegionWidth() - calcTextSize("Distance") - 32.0f);
    if (ImGui::SliderFloat("Aimbot Distance", &self.moduleControl->aimbotController.distance, 0.0f, 70.0f, "%.0fM")) {
        configManager::putFloat(config,"aimbotControl", "distance", self.moduleControl->aimbotController.distance);


    }
}

-(void)readIniConfig {
    self.moduleControl->fps = configManager::readInteger(config,"mainSwitch", "fps", 0);
    switch(self.moduleControl->fps){
        case 0:
            overlayView.preferredFramesPerSecond = 60;
            break;
        case 1:
            overlayView.preferredFramesPerSecond = 90;
            break;
        case 2:
            overlayView.preferredFramesPerSecond = 120;
            break;
        default:
            overlayView.preferredFramesPerSecond = 60;
            break;
    }
    //Main switch
    self.moduleControl->mainSwitch.playerStatus = configManager::readBoolean(config,"mainSwitch", "player", false);
    self.moduleControl->mainSwitch.materialStatus = configManager::readBoolean(config,"mainSwitch", "material", false);
    self.moduleControl->mainSwitch.aimbotStatus = configManager::readBoolean(config,"mainSwitch", "aimbot", false);
    //Player switch
    for (int i = 0; i < 10; ++i) {
        std::string str = "playerSwitch_" + std::to_string(i);
        *((bool *) &self.moduleControl->playerSwitch + sizeof(bool) * i) = configManager::readBoolean(config,"playerSwitch", str.c_str(), false);
    }
    //Radar coord
    self.moduleControl->playerSwitch.radarSize = configManager::readFloat(config,"playerSwitch", "radarSize", 70);
    self.moduleControl->playerSwitch.radarCoord.x = configManager::readFloat(config,"playerSwitch", "radarX", 500);
    self.moduleControl->playerSwitch.radarCoord.y = configManager::readFloat(config,"playerSwitch", "radarY", 500);
    //Material switch
    for (int i = 0; i < All; ++i) {
        std::string str = "materialSwitch_" + std::to_string(i);
        self.moduleControl->materialSwitch[i] = configManager::readBoolean(config,"materialSwitch", str.c_str(), false);
    }
    //Dont aim at knocked
    self.moduleControl->aimbotController.fallNotAim = configManager::readBoolean(config,"aimbotControl", "fall", false);
    self.moduleControl->aimbotController.showAimbotRadius = configManager::readBoolean(config,"aimbotControl", "showRadius", true);
    self.moduleControl->aimbotController.aimbotRadius = configManager::readFloat(config,"aimbotControl", "radius", 200);
    
    self.moduleControl->aimbotController.smoke = configManager::readBoolean(config,"aimbotControl", "smoke", true);
    
    //Aimbot mode
    self.moduleControl->aimbotController.aimbotMode = configManager::readInteger(config,"aimbotControl", "mode", 3);
    //Aimbot body part
    self.moduleControl->aimbotController.aimbotParts = configManager::readInteger(config,"aimbotControl", "parts", 2);
    //Aimbot intensity
    aimbotIntensity = configManager::readInteger(config,"aimbotControl", "intensity", 2);
    switch (aimbotIntensity) {
        case 0:
            self.moduleControl->aimbotController.aimbotIntensity = 0.1f;
            break;
        case 1:
            self.moduleControl->aimbotController.aimbotIntensity = 0.2f;
            break;
        case 2:
            self.moduleControl->aimbotController.aimbotIntensity = 0.3f;
            break;
        case 3:
            self.moduleControl->aimbotController.aimbotIntensity = 0.4f;
            break;
        case 4:
            self.moduleControl->aimbotController.aimbotIntensity = 0.5f;
            break;
        case 5:
            self.moduleControl->aimbotController.aimbotIntensity = 1.0f;
            break;
        case 6:
            self.moduleControl->aimbotController.aimbotIntensity = 1.2f;
            break;
    }
    //Aimbot distance
    self.moduleControl->aimbotController.distance = configManager::readFloat(config,"aimbotControl", "distance", 70);
}

@end