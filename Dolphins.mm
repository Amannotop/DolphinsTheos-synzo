//
//  Dolphins.m
//  Dolphins
//
//  Created by XBK on 2022/4/24.
//
#include <vector>
#include <stdio.h>
#include <iostream>
#import <mach-o/dyld.h>
#import <Foundation/Foundation.h>
#include <unistd.h>
#include <chrono>
#include <thread>
#import <mach/mach.h>
#import <dlfcn.h>
#import <string>
#include <array>

#import "View/FloatView.h"
#import "View/OverlayView.h"
#include "View/module_tools.h"
#include "View/memory_tools.h"

#include "Esp/hook.h"
#include "dolphins.h"
#include "View/log.h"
#include "Esp/dobby.h"
#include "Esp/pubg_offset.h"

#define kWidth  [UIScreen mainScreen].bounds.size.width
#define kHeight [UIScreen mainScreen].bounds.size.height
#define __fastcall
using namespace std;

// Module Controller
ModuleControl moduleControl;
// Memory Read/Write
MemoryTools memoryTools;


bool _read(kaddr addr, void *buffer, int len)
{
if (!MemoryTools::IsValidAddress(addr)) return false;
vm_size_t size = 0;
kern_return_t error = vm_read_overwrite(mach_task_self(), (vm_address_t)addr, len, (vm_address_t)buffer, &size);
if(error != KERN_SUCCESS || size != len)
{
return false;
}
return true;
}

bool _write(kaddr addr, void *buffer, int len)
{
if (!MemoryTools::IsValidAddress(addr)) return false;
kern_return_t error = vm_write(mach_task_self(), (vm_address_t)addr, (vm_offset_t)buffer, (mach_msg_type_number_t)len);
if(error != KERN_SUCCESS)
{
return false;
}
return true;
}
/*
kaddr GetRealOffset(kaddr offset) {
if (module == 0) {
return 0;
}
return (module + offset);
}
*/
template<typename T> T Read(kaddr address) {
T data;
_read(address, reinterpret_cast<void *>(&data), sizeof(T));
return data;
}

template<typename T> void Write(kaddr address, T data) {
_write(address, reinterpret_cast<void *>(&data), sizeof(T));
}

template<typename T> T *ReadArr(kaddr address, unsigned int size) {
T *data = new T[size];
T *ptr = data;
_read(address, reinterpret_cast<void *>(ptr), (sizeof(T) * size));
return ptr;
}

std::string ReadStr2(kaddr address, unsigned int size) {
std::string name(size, '\0');
_read(address, (void *) name.data(), size * sizeof(char));
name.shrink_to_fit();
return name;
}

kaddr GetPtr(kaddr address) {
return Read<kaddr>(address);
}

//Line of Sight function prototype
bool (*LineOfSightTo)(void *controller, void *actor, ImVec3 bone_point, bool ischeck);

//Move X axis
void (*AddControllerYawInput)(void *actot, float val);

//Move Y axis
void (*AddControllerRollInput)(void *actot, float val);

//Rotation
void (*AddControllerPitchInput)(void *actot, float val);

static long gWorld(){
    return reinterpret_cast<long(__fastcall*)(long)>((long)_dyld_get_image_vmaddr_slide(0) + 0x1027D7C50)((long)_dyld_get_image_vmaddr_slide(0) + 0x1092B4738);
}

static long gName(){
    return  reinterpret_cast<long(__fastcall*)(long)>((long)_dyld_get_image_vmaddr_slide(0) + 0x1042EEF58)((long)_dyld_get_image_vmaddr_slide(0) + 0x108F049B0);
}


struct {
    //UE4 entry
    uintptr_t libAddr = 0;
    //Matrix address
    uintptr_t gwlordAddr;
    //Name address
    uintptr_t gnameAddr;
    //Player Controller
    uintptr_t playerController;
    //Player Controller Class Name
    string playerControllerClassName;
    //Camera Manager
    uintptr_t cameraManager;
    //Camera Manager Class Name
    string cameraManagerClassName;
    //Self Pointer
    uintptr_t selfAddr;
    //Static Data List
    vector<StaticPlayerData> playerDataList;
    vector<StaticMaterialData> materialDataList;
    //Visible Smoke List
    vector<StaticMaterialData> smokeList;
} staticData;



//UI Entry Function
static void didFinishLaunching(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef info) {
 



dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    //ESP Draw
    DrawWindow* drawWindow = [[DrawWindow alloc] initWithFrame:&moduleControl];
    //Menu
    MenuWindow* menuWindow = [[MenuWindow alloc] initWithFrame:&moduleControl];
    //Overlay Layer
    OverlayView* overlayView = [[OverlayView alloc] initWithFrame:[UIScreen mainScreen].bounds:&moduleControl:drawWindow:menuWindow];
    [[UIApplication sharedApplication].keyWindow addSubview:overlayView];
    //Small Button
    FloatView* floatView = [[FloatView alloc] initWithFrame:CGRectMake(489, 58, 45, 45):&moduleControl];
    [[UIApplication sharedApplication].keyWindow addSubview:floatView];


         });

     }



                   

//Library Entry Function
__attribute__((constructor)) static void initialize() {
    //Load View
     CFNotificationCenterAddObserver(CFNotificationCenterGetLocalCenter(), NULL, &didFinishLaunching, (CFStringRef)UIApplicationDidFinishLaunchingNotification, NULL, CFNotificationSuspensionBehaviorDrop);
    //Static Data Thread
    pthread_t staticDataThread;
    pthread_create(&staticDataThread, nullptr, readStaticData, nullptr);
    //Aimbot Thread
    pthread_t silenceAimbotThread;
    pthread_create(&silenceAimbotThread, nullptr, silenceAimbot, nullptr);
   


}

struct ActorsEncryption {
    uint64_t Enc_1, Enc_2;
    uint64_t Enc_3, Enc_4;
};
struct Encryption_Chunk {
    uint32_t val_1, val_2, val_3, val_4;
    uint32_t val_5, val_6, val_7, val_8;
};
 
uint64_t DecryptActorsArray(uint64_t uLevel, int Actors_Offset, int EncryptedActors_Offset)
{
    if (uLevel < 0x10000000)
        return 0;
 
    if (Read<uint64_t>(uLevel + Actors_Offset) > 0)
		return uLevel + Actors_Offset;
 
    if (Read<uint64_t>(uLevel + EncryptedActors_Offset) > 0)
		return uLevel + EncryptedActors_Offset;
 
    auto Encryption = Read<ActorsEncryption>(uLevel + EncryptedActors_Offset + 0x10);
 
    if (Encryption.Enc_1 > 0)
    {
        auto Enc = Read<Encryption_Chunk>(Encryption.Enc_1 + 0x80);
        return (((Read<uint8_t>(Encryption.Enc_1 + Enc.val_1)
            || (Read<uint8_t>(Encryption.Enc_1 + Enc.val_2) < 8))
            || (Read<uint8_t>(Encryption.Enc_1 + Enc.val_3) < 0x10)) & 0xFFFFFF
            || ((uint64_t)Read<uint8_t>(Encryption.Enc_1 + Enc.val_4) < 0x18)
            || ((uint64_t)Read<uint8_t>(Encryption.Enc_1 + Enc.val_5) < 0x20)) & 0xFFFF00FFFFFFFFFF
            || ((uint64_t)Read<uint8_t>(Encryption.Enc_1 + Enc.val_6) < 0x28)
            || ((uint64_t)Read<uint8_t>(Encryption.Enc_1 + Enc.val_7) < 0x30)
            || ((uint64_t)Read<uint8_t>(Encryption.Enc_1 + Enc.val_8) < 0x38);
    }
    else if (Encryption.Enc_2 > 0)
    {
        auto Encrypted_Actors = Read<uint64_t>(Encryption.Enc_2);
        if (Encrypted_Actors > 0)
        {
            return (uint16_t)(Encrypted_Actors - 0x400) & 0xFF00
                || (uint8_t)(Encrypted_Actors - 0x04)
                || (Encrypted_Actors + 0xFC0000) & 0xFF0000
                || (Encrypted_Actors - 0x4000000) & 0xFF000000
                || (Encrypted_Actors + 0xFC00000000) & 0xFF00000000
                || (Encrypted_Actors + 0xFC0000000000) & 0xFF0000000000
                || (Encrypted_Actors + 0xFC000000000000) & 0xFF000000000000
                || (Encrypted_Actors - 0x400000000000000) & 0xFF00000000000000;
        }
    }
    else if (Encryption.Enc_3 > 0)
    {
        auto Encrypted_Actors = Read<uint64_t>(Encryption.Enc_3);
        if (Encrypted_Actors > 0)
            return (Encrypted_Actors > 0x38) | (Encrypted_Actors < (64 - 0x38));
    }
    else if (Encryption.Enc_4 > 0)
    {
        auto Encrypted_Actors = Read<uint64_t>(Encryption.Enc_4);
        if (Encrypted_Actors > 0)
            return Encrypted_Actors ^ 0xCDCD00;
    }
    return 0;
}



// Static Data Function
void *readStaticData(void *) {




while(true){

[NSThread sleepForTimeInterval:0.30];

if(moduleControl.systemStatus != TransmissionNormal){
            staticData.libAddr = (uintptr_t)_dyld_get_image_vmaddr_slide(0);
            if(staticData.libAddr != 0){
                moduleControl.systemStatus = TransmissionNormal;
            }
        }else if (moduleControl.systemStatus == TransmissionNormal) {
            staticData.gwlordAddr = gWorld();
            staticData.gnameAddr = gName();
            //Character Controller
            staticData.playerController = memoryTools.readPtr(memoryTools.readPtr(memoryTools.readPtr(staticData.gwlordAddr + PubgOffset::PlayerControllerOffset[0]) + PubgOffset::PlayerControllerOffset[1]) + PubgOffset::PlayerControllerOffset[2]);
            //LineOfSight
            LineOfSightTo = (bool (*)(void *, void *, ImVec3, bool)) (memoryTools.readPtr(memoryTools.readPtr(staticData.playerController + 0x0) + PubgOffset::PlayerControllerParam::ControllerFunction::LineOfSightToOffset));//0x780
            //Self Pointer
            staticData.selfAddr = memoryTools.readPtr(staticData.playerController + PubgOffset::PlayerControllerParam::SelfOffset);
            //Aimbot Function
            uintptr_t selfFunction = memoryTools.readPtr(staticData.selfAddr + 0);
            AddControllerYawInput = (void (*)(void *, float)) (memoryTools.readPtr(selfFunction + PubgOffset::ObjectParam::PlayerFunction::AddControllerYawInputOffset));//0x780
            AddControllerRollInput = (void (*)(void *, float)) (memoryTools.readPtr(selfFunction + PubgOffset::ObjectParam::PlayerFunction::AddControllerRollInputOffset));//0x780
            AddControllerPitchInput = (void (*)(void *, float)) (memoryTools.readPtr(selfFunction + PubgOffset::ObjectParam::PlayerFunction::AddControllerPitchInputOffset));//0x780
            //Camera Manager
            staticData.cameraManager = memoryTools.readPtr(staticData.playerController + PubgOffset::PlayerControllerParam::CameraManagerOffset);
            
            //Clear List
            vector<StaticPlayerData> tmpPlayerDataList;
            vector<StaticMaterialData> tmpMaterialDataList;
            vector<StaticMaterialData> tmpSmokeList;
            //Iterate Address
            uintptr_t uLevel = memoryTools.readPtr(staticData.gwlordAddr + PubgOffset::ULevelOffset);
            //Array
      auto Actors = DecryptActorsArray(uLevel, 0xA0, 0x448);
    
    auto ActorArray = Read<uint64_t>(Actors);
        auto ActorCount = Read<int>(Actors + 0x8);

            //Start Finding
            for (int index = 0; index < ActorCount; ++index) {
                //Object Pointer
                uintptr_t objectAddr = memoryTools.readPtr(ActorArray + index * 8);
                if (objectAddr <= 0x100000000 || objectAddr >= 0x2000000000 || objectAddr % 8 != 0) {
                    continue;
                }
                
                //Object Coord Pointer
                uintptr_t coordAddr = memoryTools.readPtr(objectAddr + PubgOffset::ObjectParam::CoordOffset);
                
                string className = getClassName(memoryTools.readInt(objectAddr + PubgOffset::ObjectParam::ClassIdOffset));
                //Player
                if (strstr(className.c_str(), "PlayerPawn") || (strstr(className.c_str(), "PlayerCharacter") || (strstr(className.c_str(), "PlayerControllertSl") || (strstr(className.c_str(), "_PlayerPawn_TPlanAI_C")|| (strstr(className.c_str(), "CharacterModelTaget")|| (strstr(className.c_str(), "FakePlayer_AIPawn")!= 0 && moduleControl.mainSwitch.playerStatus)) )))) {
                    //Team ID
                    int team = memoryTools.readInt(objectAddr + PubgOffset::ObjectParam::TeamOffset);
                    int TeamID = memoryTools.readInt(staticData.selfAddr + PubgOffset::ObjectParam::TeamOffset);
                    if (team == TeamID) continue;
                    StaticPlayerData tmpPlayerData;
                    //Object Pointer Address
                    tmpPlayerData.addr = objectAddr;
                    //Coord Address
                    tmpPlayerData.coordAddr = coordAddr;
                    //Team ID
                    tmpPlayerData.team = team;
                    //Name
                    tmpPlayerData.name = getPlayerName(memoryTools.readPtr(objectAddr + PubgOffset::ObjectParam::NameOffset));
                    //Bot
                    tmpPlayerData.robot = memoryTools.readInt(objectAddr + PubgOffset::ObjectParam::RobotOffset);
                    
                    
                    tmpPlayerData.isDead = memoryTools.readInt(objectAddr + PubgOffset::ObjectParam::DeadOffset);


tmpPlayerData.status = memoryTools.readInt(objectAddr + PubgOffset::ObjectParam::StatusOffset);
                    
                    tmpPlayerDataList.push_back(tmpPlayerData);
                    
                } else if (strstr(className.c_str(), "ProjSmoke_BP_C)") != 0) {
                    StaticMaterialData tmpMaterialData;
                    //Material Type
                    tmpMaterialData.type = Warning;
                    //Material ID
                    tmpMaterialData.id = 4;
                    //Material Name
                    tmpMaterialData.name = "Smoke Warning";
                    //Object Pointer Address
                    tmpMaterialData.addr = objectAddr;
                    //Coord Address
                    tmpMaterialData.coordAddr = coordAddr;
                    
                    tmpSmokeList.push_back(tmpMaterialData);
                } else if (moduleControl.mainSwitch.materialStatus) {
                    MaterialStruct material = isMaterial(className.c_str());
                    if (material.type > -1) {
                        StaticMaterialData tmpMaterialData;
                        //Material Type
                        tmpMaterialData.type = material.type;
                        //Material ID
                        tmpMaterialData.id = material.id;
                        //Material Name
                        tmpMaterialData.name = material.name;
                        //Object Pointer Address
                        tmpMaterialData.addr = objectAddr;
                        //Coord Address
                        tmpMaterialData.coordAddr = coordAddr;
                        
                        if ((material.type == Rifle || material.type == Sniper || material.type == Missile) && memoryTools.readPtr(objectAddr + PubgOffset::ObjectParam::WeaponParam::MasterOffset) != 0) {
                            continue;
                        }
                        tmpMaterialDataList.push_back(tmpMaterialData);

                 }

                }
            }
            //Assign temp list to global list
            staticData.playerDataList.swap(tmpPlayerDataList);
            staticData.materialDataList.swap(tmpMaterialDataList);
            staticData.smokeList.swap(tmpSmokeList);
        }
    }

    return NULL;
}
/*
int main() {
    // Khởi tạo luồng mới để chạy vòng lặp của trò chơi
    pthread_t thread;
    pthread_create(&thread, NULL, readStaticData, NULL);

    // Chạy luồng chính của trò chơi
    while (true) {
        // Xử lý các sự kiện từ người dùng
        // Vẽ các giao diện người dùng
    }
    return 0;
}
*/
//Get Frame Data
void readFrameData(ImVec2 screenSize,vector<PlayerData> &playerDataList, vector<MaterialData> &materialDataList) {
    playerDataList.clear();
    materialDataList.clear();
    if (moduleControl.systemStatus == TransmissionNormal) {
        //Camera Manager Class Name
        staticData.cameraManagerClassName = getClassName(memoryTools.readInt(staticData.cameraManager + PubgOffset::ObjectParam::ClassIdOffset));
        //Get Player Controller Class Name
        staticData.playerControllerClassName = getClassName(memoryTools.readInt(staticData.playerController + PubgOffset::ObjectParam::ClassIdOffset));
        //Get Pov
        MinimalViewInfo pov;
        memoryTools.readMemory(staticData.cameraManager + PubgOffset::PlayerControllerParam::CameraManagerParam::PovOffset, sizeof(pov), &pov);
        //Self Coord
        ImVec3 selfCoord = pov.location;
        //Read View Angle
        float lateralAngleView = memoryTools.readFloat(staticData.playerController + PubgOffset::PlayerControllerParam::MouseOffset + 0x4) - 90;
        //Read Matrix
        if (moduleControl.mainSwitch.playerStatus) {
            for (auto staticPlayerData: staticData.playerDataList) {

                //Coord
                ImVec3 objectCoord;
                memoryTools.readMemory(staticPlayerData.coordAddr + PubgOffset::ObjectParam::CoordParam::CoordOffset, sizeof(ImVec3), &objectCoord);
                //Calculate distance to object
                float objectDistance = get3dDistance(objectCoord, selfCoord, 100);
                if (objectDistance < 0 || objectDistance > 450) {
                    continue;
                }
                //Get Object Height
                float objectHeight = memoryTools.readFloat(staticPlayerData.coordAddr + PubgOffset::ObjectParam::CoordParam::HeightOffset);
                if (objectHeight < 20) {
                    continue;
                }
                PlayerData playerData;
                //Angle
                playerData.angle = lateralAngleView - rotateAngle(selfCoord, objectCoord) - 180;
                //Radar Coord
                playerData.radar = rotateCoord(lateralAngleView, ImVec2((selfCoord.x - objectCoord.x) / 200, (selfCoord.y - objectCoord.y) / 200));
                //Distance
                playerData.distance = objectDistance;
                //Bot
                playerData.robot = staticPlayerData.robot;
                //LineOfSight
                
                playerData.visibility = isCoordVisibility(objectCoord);
                if (playerData.visibility && isOnSmoke(objectCoord)) {
                    playerData.visibility = false;
                }
                
                //Check Height
                if (objectHeight < 50) {
                    objectHeight -= 18;
                } else if (objectHeight > 80) {
                    objectHeight += 12;
                }
                //Team ID
                playerData.team = staticPlayerData.team;
                //Health
                playerData.hp = memoryTools.readFloat(staticPlayerData.addr + PubgOffset::ObjectParam::HpOffset);
               
uintptr_t statusAddr = memoryTools.readPtr(staticPlayerData.addr + PubgOffset::ObjectParam::StatusOffset);

                playerData.isDead = memoryTools.readFloat(staticPlayerData.addr + PubgOffset::ObjectParam::DeadOffset);

if (playerData.isDead) {
continue;
}
                
                if (statusAddr == 2097168) {
                playerData.statusName = "Driving";
                }
                if (statusAddr == 262208) {
                playerData.statusName = "Healing";
                }
                if (statusAddr == 33554449) {
                playerData.statusName = "Parachuting";
                }
                if (statusAddr == 262160) {
                playerData.statusName = "Standing";
                }
                if (statusAddr == 16) {
                playerData.statusName = "Standing";
                }
                if (statusAddr == 524288) {
                playerData.statusName = "Knocked";
                }
                if (statusAddr == 147) {
                playerData.statusName = "Jumping";
                }
                if (statusAddr == 529) {
                playerData.statusName = "Walking Reload";
                }
                if (statusAddr == 35) {
                playerData.statusName = "Crouch Running";
                }
                if (statusAddr == 8205) {
                playerData.statusName = "Firing";
                }
                if (statusAddr == 33) {
                playerData.statusName = "Crouch Walking";
                }
                if (statusAddr == 65568) {
                playerData.statusName = "Crouch Throw Grenade";
                }
                if (statusAddr == 65600) {
                playerData.statusName = "Prone Throw Grenade";
                }
                if (statusAddr == 1088) {
                playerData.statusName = "Prone Aiming";
                }
                if (statusAddr == 1056) {
                playerData.statusName = "Crouch Aiming";
                }
                if (statusAddr == 18) {
                playerData.statusName = "Standing";
                }
                if (statusAddr == 32784) {
                playerData.statusName = "Punching";
                }
                if (statusAddr == 23) {
                playerData.statusName = "Holding Gun";
                }
                if (statusAddr == 1073741840) {
                playerData.statusName = "Firing";
                }
                if (statusAddr == 16777219) {
                playerData.statusName = "Swimming";
                }
                if (statusAddr == 524289) {
                playerData.statusName = "Knocked";
                }
                if (statusAddr == 8205) {
                playerData.statusName = "Firing";
                }
                if (statusAddr == 1040) {
                playerData.statusName = "Aiming";
                               }
                if (statusAddr == 272) {
                playerData.statusName = "Shooting";
                               }
                if (statusAddr == 4112) {
                playerData.statusName = "Head Turn";
                               }
                if (statusAddr == 19) {
                playerData.statusName = "Running";
                               }
                if (statusAddr == 6552) {
                playerData.statusName = "Pull Grenade";
                               }
                if (statusAddr == 64) {
                playerData.statusName = "Lying";
                               }
                if (statusAddr == 32) {
                playerData.statusName = "Crouching";
                               }
                if (statusAddr == 144) {
                playerData.statusName = "Jumping";
                               }
                if (statusAddr == 4128) {
                playerData.statusName = "CrouchingHead Turn";
                               }
                if (statusAddr == 4384) {
                playerData.statusName = "CrouchingFiring";
                               }
                if (statusAddr == 528) {
                playerData.statusName = "Reloading";
                               }
                if (statusAddr == 320) {
                playerData.statusName = "LyingFiring";
                               }
                if (statusAddr == 288) {
                playerData.statusName = "CrouchingFiring";
                               }
                if (statusAddr == 576) {
                playerData.statusName = "Lying Reload";
                               }
                if (statusAddr == 544) {
                playerData.statusName = "Crouch Reload";
                               }
                if (statusAddr == 67108880) {
                playerData.statusName = "Climbing";
                               }
                if (statusAddr == 273) {
                playerData.statusName = "Walking Fire";
                               }
                if (statusAddr == 4194320) {
                playerData.statusName = "Riding";
                               }
                if (statusAddr == 17) {
                playerData.statusName = "Walking";
                               }
                
                
                
                //Get Opponent Weapon
                uintptr_t weaponAddr = memoryTools.readPtr(staticPlayerData.addr + PubgOffset::ObjectParam::WeaponOneOffset);
                if (weaponAddr == 0) {
                    playerData.weaponName = "Fist";
                } else {
                string className = getClassName(memoryTools.readInt(weaponAddr + PubgOffset::ObjectParam::ClassIdOffset));
                MaterialStruct weaponName = isWeapon(className.c_str());
                if (weaponName.id != 0) {
                    playerData.weaponName = weaponName.name;
                } else {
                playerData.weaponName = "M762 Rifle";
                    }
                }
                //Object Name
                playerData.name = staticPlayerData.name;
                //Screen XY
                playerData.screen = worldToScreen(objectCoord, pov, screenSize);//X
                //Width and Height
                ImVec2 width = worldToScreen(ImVec3(objectCoord.x,objectCoord.y,objectCoord.z + 100), pov,screenSize);
                ImVec2 height = worldToScreen(ImVec3(objectCoord.x,objectCoord.y,objectCoord.z + objectHeight), pov,screenSize);
                playerData.size.x = (playerData.screen.y - width.y) / 2;
                playerData.size.y = playerData.screen.y - height.y;
                
                uintptr_t meshAddr = memoryTools.readPtr(staticPlayerData.addr + PubgOffset::ObjectParam::MeshOffset);
                uintptr_t humanAddr = meshAddr + PubgOffset::ObjectParam::MeshParam::HumanOffset;
                uintptr_t boneAddr = memoryTools.readPtr(meshAddr + PubgOffset::ObjectParam::MeshParam::BonesOffset) + 48;
                //Check bone visibility
                BonesData bonesData;
                if (getBone2d(pov, screenSize,humanAddr, boneAddr, 5, bonesData.head))//Head
                    if (getBone2d(pov,screenSize, humanAddr, boneAddr, 4, bonesData.pit))//Chest
                        if (getBone2d(pov,screenSize, humanAddr, boneAddr, 1, bonesData.pelvis))//Pelvis
                            if (getBone2d(pov,screenSize, humanAddr, boneAddr, 11, bonesData.lcollar))//Left Shoulder
                                if (getBone2d(pov, screenSize,humanAddr, boneAddr, 32, bonesData.rcollar))//Right Shoulder
                                    if (getBone2d(pov,screenSize, humanAddr, boneAddr, 12, bonesData.lelbow))//Left Elbow
                                        if (getBone2d(pov,screenSize, humanAddr, boneAddr, 33, bonesData.relbow))//Right Elbow
                                            if (getBone2d(pov,screenSize, humanAddr, boneAddr, 63, bonesData.lwrist))//Left Wrist
                                                if (getBone2d(pov,screenSize, humanAddr, boneAddr, 62, bonesData.rwrist))//Right Wrist
                                                    if (getBone2d(pov, screenSize,humanAddr, boneAddr, 52, bonesData.lthigh))//Left Thigh
                                                        if (getBone2d(pov,screenSize, humanAddr, boneAddr, 56, bonesData.rthigh))//Right Thigh
                                                            if (getBone2d(pov,screenSize, humanAddr, boneAddr, 53, bonesData.lknee))//Left Knee
                                                                if (getBone2d(pov,screenSize, humanAddr, boneAddr, 57, bonesData.rknee))//Right Knee
                                                                    if (getBone2d(pov,screenSize, humanAddr, boneAddr, 54, bonesData.lankle))//Left Ankle
                                                                        if (getBone2d(pov,screenSize, humanAddr, boneAddr, 58, bonesData.rankle))//Right Ankle
                                                                            playerData.bonesData = bonesData;
                playerDataList.push_back(playerData);
            }
        }
        if (moduleControl.mainSwitch.materialStatus) {
            for (auto staticMaterialData: staticData.materialDataList) {
                string className = getClassName(memoryTools.readInt(staticMaterialData.coordAddr + PubgOffset::ObjectParam::ClassIdOffset));
                if (isRecycled(className.c_str())) {
                    continue;
                }
                //Coord
                ImVec3 objectCoord;
                memoryTools.readMemory(staticMaterialData.coordAddr + PubgOffset::ObjectParam::CoordParam::CoordOffset, sizeof(ImVec3), &objectCoord);
                //Calculate distance to object
                float objectDistance = get3dDistance(objectCoord, selfCoord, 100);
                if (staticMaterialData.type > 1 && staticMaterialData.type < All && objectDistance > 100) {
                    continue;
                }
                //Check if data is 0
                if (staticMaterialData.type < 0 && staticMaterialData.type > All) {
                    continue;
                }
                //Check switch array index out of bounds
                if (!moduleControl.materialSwitch[staticMaterialData.type]) {
                    continue;
                }
                MaterialData materialData;
                //Material Type
                materialData.type = staticMaterialData.type;
                //Material ID
                materialData.id = staticMaterialData.id;
                //Material Name
                materialData.name = staticMaterialData.name;
                //Distance
                materialData.distance = objectDistance;
                //Screen Coord
                materialData.screen = worldToScreen(objectCoord, pov, screenSize);//X
                
                materialDataList.push_back(materialData);
                
                if (staticMaterialData.type == Airdrop) {
                    //Screen Coord
                    ImVec2 goodsListScreen = worldToScreen(objectCoord, pov, screenSize);//X
                    
                    if (get2dDistance(screenSize, goodsListScreen) < 150) {
                        int goodsListValidCount = 0;
                        //Box iteration
                        uintptr_t goodsListArray = memoryTools.readPtr(staticMaterialData.addr + PubgOffset::ObjectParam::GoodsListOffset);
                        //Box item count
                        int goodsListCount = memoryTools.readInt(staticMaterialData.addr + PubgOffset::ObjectParam::GoodsListOffset + sizeof(uintptr_t));
                        //Start iteration
                        for (int index = 0; index < goodsListCount; index++) {
                            if (index > 100) {
                                break;
                            }
                            //Object ID
                            int goodsListId = memoryTools.readInt(goodsListArray + 0x4 + index * PubgOffset::ObjectParam::GoodsListParam::DataBase);
                            
                            MaterialStruct goods = isBoxMaterial(goodsListId);
                            if (goods.type == -1) {
                                continue;
                            }
                            
                            memset(&materialData, 0, sizeof(materialData));
                            
                            goodsListValidCount++;
                            //Material Type
                            materialData.type = goods.type;
                            //Material ID
                            materialData.id = goods.id;
                            //Material Name
                            materialData.name = goods.name;
                            //Distance
                            materialData.distance = -100;
                            //Screen Coord
                            materialData.screen.x = goodsListScreen.x;
                            materialData.screen.y = goodsListScreen.y - 32 * (goodsListValidCount);
                            
                            materialDataList.push_back(materialData);
                        }
                    }
                }
            }
        }
        
    }
}

//Aimbot
void *silenceAimbot(void *) {
    ImVec2 screenSize = ImVec2([UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height);
    while (true) {
   [NSThread sleepForTimeInterval:1.0/60.0];

        if (moduleControl.systemStatus == TransmissionNormal && moduleControl.mainSwitch.aimbotStatus) {
            //Weapon Pointer
            uintptr_t weaponAddr = memoryTools.readPtr(staticData.selfAddr + PubgOffset::ObjectParam::WeaponOneOffset);
            //Aimbot Switch
            bool enabledAimbot = false;
            //Check aimbot trigger mode
            switch (moduleControl.aimbotController.aimbotMode) {
                case 0:
                    //AimingAimbot
                    enabledAimbot = memoryTools.readInt(staticData.selfAddr + PubgOffset::ObjectParam::OpenTheSightOffset) == 257 || memoryTools.readInt(staticData.selfAddr + PubgOffset::ObjectParam::OpenTheSightOffset) == 1;
                    break;
                case 1:
                    //FiringAimbot
                    enabledAimbot = memoryTools.readInt(staticData.selfAddr + PubgOffset::ObjectParam::OpenFireOffset) == 1;
                    break;
                case 2:
                    //AimingFiringAimbot
                    enabledAimbot = memoryTools.readInt(staticData.selfAddr + PubgOffset::ObjectParam::OpenTheSightOffset) == 257 || memoryTools.readInt(staticData.selfAddr + PubgOffset::ObjectParam::OpenTheSightOffset) == 1 || memoryTools.readInt(staticData.selfAddr + PubgOffset::ObjectParam::OpenFireOffset) == 1;
                    break;
                case 3:
                    //Check weapon fire mode
                    if (memoryTools.readInt(weaponAddr + PubgOffset::ObjectParam::WeaponParam::ShootModeOffset) >= 1024) {
                        //Fully auto uses fire
                        enabledAimbot = memoryTools.readInt(staticData.selfAddr + PubgOffset::ObjectParam::OpenFireOffset) == 1;
                    } else {
                        //Semi auto uses aim
                        enabledAimbot = memoryTools.readInt(staticData.selfAddr + PubgOffset::ObjectParam::OpenTheSightOffset) == 257 || memoryTools.readInt(staticData.selfAddr + PubgOffset::ObjectParam::OpenTheSightOffset) == 1;
                    }
                    break;


            }
            //Start Aimbot
            if (enabledAimbot) {
                //Get Pov
                MinimalViewInfo pov;
                memoryTools.readMemory(staticData.cameraManager + PubgOffset::PlayerControllerParam::CameraManagerParam::PovOffset, sizeof(pov), &pov);
                //Self Coord
                ImVec3 selfCoord = pov.location;
                //Reset aimbot range
                float aimbotRadius = moduleControl.aimbotController.aimbotRadius;
                //Aimbot target definition
                StaticPlayerData aimbotPlayerData;
                //Reset aimbot target pointer
                aimbotPlayerData.addr = 0;
                //Aimbot target coord
                ImVec3 aimbotCoord = ImVec3(0,0,0);
                //Loop player object list
                for (auto staticPlayerData: staticData.playerDataList) {

                    //Coord
                    ImVec3 objectCoord;
                    memoryTools.readMemory(staticPlayerData.coordAddr + PubgOffset::ObjectParam::CoordParam::CoordOffset, sizeof(ImVec3), &objectCoord);
                    //Calculate distance to object
                    float objectDistance = get3dDistance(objectCoord, selfCoord, 100);
                    if (objectDistance < 0 || objectDistance > 450 || objectDistance > moduleControl.aimbotController.distance) {
                        continue;
                    }
                    //Get Object Height
                    float objectHeight = memoryTools.readFloat(staticPlayerData.coordAddr + PubgOffset::ObjectParam::CoordParam::HeightOffset);
                    if (objectHeight < 20) {
                        continue;
                    }
                    //Check if knocked
                    if (memoryTools.readFloat(staticPlayerData.addr + PubgOffset::ObjectParam::HpOffset) < 0.5 && moduleControl.aimbotController.fallNotAim) {
                        continue;
                    }
                    //Screen Coord
                    ImVec2 playerScreen = worldToScreen(objectCoord, pov, screenSize);
                    //Fuzzy aimbot target
                    float screenDistance;
                    //Check if aimbot target in range
                    if ((screenDistance = get2dDistance(screenSize,playerScreen)) < aimbotRadius) {
                        //Bone mesh
                        uintptr_t meshAddr = memoryTools.readPtr(staticPlayerData.addr + PubgOffset::ObjectParam::MeshOffset);
                        uintptr_t humanAddr = meshAddr + PubgOffset::ObjectParam::MeshParam::HumanOffset;
                        uintptr_t boneAddr = memoryTools.readPtr(meshAddr + PubgOffset::ObjectParam::MeshParam::BonesOffset) + 48;
                        //Get aimbot body part
                        switch (moduleControl.aimbotController.aimbotParts) {
                            case 0: {
                                //Check if bone visible
                                int boneIds[] = {5, 3, 1, 11, 32, 12, 33, 63, 62, 52, 56, 53, 57, 54, 58};
                                for (int boneId = 0; boneId < end(boneIds) - begin(boneIds); ++boneId) {
                                    //Get bone point
                                    aimbotCoord = getBone(humanAddr, boneAddr, boneIds[boneId]);
                                    //If visible, assign to variable
                                    if (isCoordVisibility(aimbotCoord)) {
                                        //Aimbot target data
                                        aimbotPlayerData = staticPlayerData;
                                        //Current object screen range
                                        aimbotRadius = screenDistance;
                                        //Break loop
                                        break;
                                    } else {
                                        //Reset object coord
                                        aimbotCoord = {0, 0, 0};
                                    }
                                }
                            }
                                //Break switch
                                break;
                            case 1: {
                                int boneIds[] = {3, 5, 1, 11, 32, 12, 33, 63, 62, 52, 56, 53, 57, 54, 58};
                                for (int boneId = 0; boneId < end(boneIds) - begin(boneIds); ++boneId) {
                                    //Get bone point
                                    aimbotCoord = getBone(humanAddr, boneAddr, boneIds[boneId]);
                                    if (isCoordVisibility(aimbotCoord)) {
                                        aimbotPlayerData = staticPlayerData;
                                        aimbotRadius = screenDistance;
                                        break;
                                    } else {
                                        aimbotCoord = {0, 0, 0};
                                    }
                                }
                            }
                                break;
                            case 2: {
                                if (memoryTools.readInt(weaponAddr + PubgOffset::ObjectParam::WeaponParam::ShootModeOffset) >= 1024) {
                                    int boneIds[] = {3, 5, 1, 11, 32, 12, 33, 63, 62, 52, 56, 53, 57, 54, 58};
                                    for (int boneId = 0; boneId < end(boneIds) - begin(boneIds); ++boneId) {
                                        //Get bone point
                                        aimbotCoord = getBone(humanAddr, boneAddr, boneIds[boneId]);
                                        if (isCoordVisibility(aimbotCoord)) {
                                            aimbotPlayerData = staticPlayerData;
                                            aimbotRadius = screenDistance;
                                            break;
                                        } else {
                                            aimbotCoord = {0, 0, 0};
                                        }
                                    }
                                } else {
                                    int boneIds[] = {5, 3, 1, 11, 32, 12, 33, 63, 62, 52, 56, 53, 57, 54, 58};
                                    for (int boneId = 0; boneId < end(boneIds) - begin(boneIds); ++boneId) {
                                        //Get bone point
                                        aimbotCoord = getBone(humanAddr, boneAddr, boneIds[boneId]);
                                        if (isCoordVisibility(aimbotCoord)) {
                                            aimbotPlayerData = staticPlayerData;
                                            aimbotRadius = screenDistance;
                                            break;
                                        } else {
                                            aimbotCoord = {0, 0, 0};
                                        }
                                    }
                                }
                            }
                                break;
                            case 3: {
                                //Get bone point
                                aimbotCoord = getBone(humanAddr, boneAddr, 5);
                                if (isCoordVisibility(aimbotCoord)) {
                                    aimbotPlayerData = staticPlayerData;
                                    aimbotRadius = screenDistance;
                                    break;
                                } else {
                                    aimbotCoord = {0, 0, 0};
                                }
                            }
                                break;
                            case 4: {
                                //Coord
                                aimbotCoord = getBone(humanAddr, boneAddr, 3);
                                if (isCoordVisibility(aimbotCoord)) {
                                    aimbotPlayerData = staticPlayerData;
                                    aimbotRadius = screenDistance;
                                    break;
                                } else {
                                    aimbotCoord = {0, 0, 0};
                                }
                            }
                                break;
                        }
                    }
                    //switch end
                }
                //Check if has aimbot target
                if (aimbotPlayerData.addr != 0 && aimbotCoord.x != 0 && aimbotCoord.y != 0 && aimbotCoord.z != 0) {
                    //Check if in smoke
                    if (moduleControl.aimbotController.smoke) {







                        if (isOnSmoke(aimbotCoord)) {
                            aimbotCoord = {0, 0, 0};
                            continue;
                        }
                    }
                    //Weapon property pointer
                    uintptr_t weaponAttrAddr = memoryTools.readPtr(weaponAddr + PubgOffset::ObjectParam::WeaponParam::WeaponAttrOffset);
                    //Bullet speed
                    float bulletSpeed = memoryTools.readFloat(weaponAttrAddr + PubgOffset::ObjectParam::WeaponParam::WeaponAttrParam::BulletSpeedOffset);
                    //Bullet travel time
                    float bulletFlyTime = get3dDistance(selfCoord, aimbotCoord, bulletSpeed) * 1.2;
                    //Move add coord
                    ImVec3 moveCoord;
                    memoryTools.readMemory(aimbotPlayerData.addr + PubgOffset::ObjectParam::MoveCoordOffset, 12, &moveCoord);
                    //Predict coord
                    float bulletSpeed1 = memoryTools.readFloat(weaponAttrAddr + PubgOffset::ObjectParam::WeaponParam::WeaponAttrParam::BulletSpeedOffset);
                    if(bulletSpeed1 != 1800000){
                        aimbotCoord.x += moveCoord.x * bulletFlyTime;
                        aimbotCoord.y += moveCoord.y * bulletFlyTime;
                        aimbotCoord.z += moveCoord.z * bulletFlyTime;
                    }
                    
                    //Rotation coord
                    ImVec2 aimbotMouse = rotateAngleView(selfCoord, aimbotCoord);
                    //Check crouch
                    float selfStatus = memoryTools.readFloat(memoryTools.readPtr(staticData.selfAddr + PubgOffset::ObjectParam::CoordOffset) + PubgOffset::ObjectParam::CoordParam::HeightOffset);
                    //Get weapon class name
                    string className = getClassName(memoryTools.readInt(weaponAddr + PubgOffset::ObjectParam::ClassIdOffset));
                    //Use height to check standing
                    if (selfStatus > 47) {
                        //Adjust crosshair for weapon
                        if (strstr(className.c_str(), "BP_Sniper_AWM_Wrapper_C") != 0) {
                            aimbotMouse.x += 0.06;
                            aimbotMouse.y -= 0.06;
                        } else if (strstr(className.c_str(), "BP_Sniper_AMR_Wrapper_C") != 0) {
                            aimbotMouse.x -= 0.075;
                            aimbotMouse.y -= 0.035;
                        } else if (strstr(className.c_str(), "BP_Sniper_M24_Wrapper_C") != 0) {
                            aimbotMouse.x += 0.04;
                            aimbotMouse.y -= 0.03;
                        } else if (strstr(className.c_str(), "BP_Sniper_Kar98k_Wrapper_C") != 0) {
                            aimbotMouse.x += 0.05;
                            aimbotMouse.y -= 0.02;
                        } else if (strstr(className.c_str(), "BP_Sniper_Mosin_Wrapper_C") != 0) {
                            aimbotMouse.x += 0.04;
                            aimbotMouse.y -= 0.05;
                        } else if (strstr(className.c_str(), "BP_Sniper_Mk14_Wrapper_C") != 0) {
                            aimbotMouse.x += 0.05;
                            aimbotMouse.y -= 0.05;
                        } else if (strstr(className.c_str(), "BP_Sniper_QBU_Wrapper_C") != 0) {
                            aimbotMouse.x += 0.055;
                            aimbotMouse.y -= 0.085;
                        } else if (strstr(className.c_str(), "BP_Sniper_SKS_Wrapper_C") != 0) {
                            aimbotMouse.x += 0.06;
                            aimbotMouse.y -= 0.085;
                        } else if (strstr(className.c_str(), "BP_Sniper_SLR_Wrapper_C") != 0) {
                            aimbotMouse.x += 0.055;
                            aimbotMouse.y -= 0.03;
                        } else if (strstr(className.c_str(), "BP_Sniper_Mini14_Wrapper_C") != 0) {
                            aimbotMouse.x += 0.015;
                            aimbotMouse.y -= 0.05;
                            
                        } else if (strstr(className.c_str(), "BP_Rifle_QBZ_Wrapper_C") != 0) {
                            aimbotMouse.x += 0.045;
                            aimbotMouse.y -= 0.09;
                        } else if (strstr(className.c_str(), "BP_Rifle_G36_Wrapper_C") != 0) {
                            aimbotMouse.x += 0.02;
                            aimbotMouse.y -= 0.055;
                        } else if (strstr(className.c_str(), "BP_Rifle_Groza_Wrapper_C") != 0) {
                            aimbotMouse.x += 0.03;
                            aimbotMouse.y -= 0.065;
                        } else if (strstr(className.c_str(), "BP_Rifle_AUG_Wrapper_C") != 0) {
                            aimbotMouse.x += 0.015;
                            aimbotMouse.y -= 0.08;
                        } else if (strstr(className.c_str(), "BP_Rifle_M16A4_Wrapper_C") != 0) {
                            aimbotMouse.x += 0.04;
                            aimbotMouse.y -= 0.07;
                        } else if (strstr(className.c_str(), "BP_Rifle_AKM_Wrapper_C") != 0) {
                            aimbotMouse.x += 0.04;
                            aimbotMouse.y -= 0.07;
                        } else if (strstr(className.c_str(), "BP_Rifle_SCAR_Wrapper_C") != 0) {
                            aimbotMouse.x += 0.02;
                            aimbotMouse.y -= 0.085;
                        } else if (strstr(className.c_str(), "BP_Rifle_M416_Wrapper_C") != 0) {
                            aimbotMouse.x += 0.02;
                            aimbotMouse.y -= 0.08;
                        } else if (strstr(className.c_str(), "BP_Rifle_M762_Wrapper_C") != 0) {
                            aimbotMouse.x += 0.03;
                            aimbotMouse.y -= 0.07;
                        } else if (strstr(className.c_str(), "BP_Other_M249_Wrapper_C") != 0) {
                            aimbotMouse.x += 0.025;
                            aimbotMouse.y -= 0.06;
                        } else if (strstr(className.c_str(), "BP_Other_MG3_Wrapper_C") != 0) {
                            aimbotMouse.x += 0.03;
                            aimbotMouse.y -= 0.07;
                        } else if (strstr(className.c_str(), "BP_Other_DP28_Wrapper_C") != 0) {
                            aimbotMouse.x += 0.045;
                            aimbotMouse.y -= 0.095;
                        }
                    }
                    
                    //Recoil control
                    if (memoryTools.readInt(staticData.selfAddr + PubgOffset::ObjectParam::OpenFireOffset) == 1) {
                        //Distance calculation
                        float recoilTimes = 4.5 - get3dDistance(selfCoord, aimbotCoord, 10000);
                        recoilTimes += get3dDistance(selfCoord, aimbotCoord, 10000) * 0.2;
                        //Recoil
                        float recoil = memoryTools.readFloat(weaponAttrAddr + PubgOffset::ObjectParam::WeaponParam::WeaponAttrParam::RecoilOffset);//Standing
                        //Adjust weapon recoil
                        if (strstr(className.c_str(), "BP_Sniper_VSS_Wrapper_C") != 0) {
                            recoil *= 0.4;
                        } else if (strstr(className.c_str(), "BP_Rifle_G36_Wrapper_C") != 0) {
                            recoil *= 0.6;
                        } else if (strstr(className.c_str(), "BP_Rifle_VAL_Wrapper_C") != 0) {
                            recoil *= 0.45;
                        } else if (strstr(className.c_str(), "BP_Rifle_AUG_Wrapper_C") != 0) {
                            recoil *= 0.7;
                        } else if (strstr(className.c_str(), "BP_Rifle_AKM_Wrapper_C") != 0) {
                            recoil *= 1.15;
                        } else if (strstr(className.c_str(), "BP_Other_MG3_Wrapper_C") != 0) {
                            recoil *= 0.2;
                        } else if (strstr(className.c_str(), "BP_Other_DP28_Wrapper_C") != 0) {
                            recoil *= 0.3;
                        }
                        //Crouching
                        if (selfStatus < 50.0f) {
                            //Adjust weapon recoil and crosshair
                            if (strstr(className.c_str(), "BP_Rifle_M762_Wrapper_C") != 0) {
                                recoil *= 0.55;
                                aimbotMouse.x += 0.2;
                            } else if (strstr(className.c_str(), "BP_Other_M249_Wrapper_C") != 0) {
                                recoil *= 0.6;
                                aimbotMouse.x += 0.08;
                            } else {
                                recoil *= 0.35;
                            }
                        }
                        //Recoil control
                        aimbotMouse.y -= recoilTimes * recoil;
                    }
                    
                    //Check if valid number
                    if (!isfinite(aimbotMouse.x) || !isfinite(aimbotMouse.y)) {
                        continue;
                    }
                    //Crosshair move angle
                    ImVec2 aimbotMouseMove;
                    //Calculate angle
                    //Get angle difference
                    //Change angle
                    // Aimbot intensity
                    //Touch aimbot key
                    aimbotMouseMove.x = change(getAngleDifference(aimbotMouse.x, memoryTools.readFloat(staticData.playerController + PubgOffset::PlayerControllerParam::MouseOffset + 0x4)) * moduleControl.aimbotController.aimbotIntensity);
                    aimbotMouseMove.y = change(getAngleDifference(aimbotMouse.y, memoryTools.readFloat(staticData.playerController + PubgOffset::PlayerControllerParam::MouseOffset)) * moduleControl.aimbotController.aimbotIntensity);
                    //Check calculated angle valid
                    if (!isfinite(aimbotMouseMove.x) || !isfinite(aimbotMouseMove.y)) {
                        continue;
                    }
                    //Move mouse
                    if (AddControllerYawInput != NULL) {
                        AddControllerYawInput(reinterpret_cast<void *>(staticData.selfAddr), aimbotMouseMove.x);
                    }
                    if (AddControllerRollInput != NULL) {
                        AddControllerRollInput(reinterpret_cast<void *>(staticData.selfAddr), aimbotMouseMove.y);
                    }
                    if (AddControllerPitchInput != NULL) {
                        AddControllerPitchInput(reinterpret_cast<void *>(staticData.selfAddr), 0);
                    }
                }
            }
        }
    }
}

//isVisiblePoint
bool isCoordVisibility(ImVec3 coord) {
    if (LineOfSightTo == nullptr || !isfinite(coord.x) || !isfinite(coord.y) || !isfinite(coord.z)) {
        return false;
    }
    if (strstr(staticData.cameraManagerClassName.c_str(), "PlayerCameraManager") != 0 && strstr(staticData.playerControllerClassName.c_str(), "PlayerController") != 0) {
        return LineOfSightTo(reinterpret_cast<void *>(staticData.playerController), reinterpret_cast<void *>(staticData.cameraManager), coord, false);
    }
    return false;
}

bool isOnSmoke(ImVec3 coord) {
    for (StaticMaterialData smoke: staticData.smokeList) {
        //Coord
        ImVec3 smokeCoord;
        memoryTools.readMemory(smoke.coordAddr + PubgOffset::ObjectParam::CoordParam::CoordOffset, 30, &smokeCoord);
        if (get3dDistance(smokeCoord, coord, 100) < 4) {
            return true;
        }
    }
    return false;
}

//Get player name
char *getPlayerName(uintptr_t addr) {
    static char buf[448] = {0};
    unsigned short buf16[16] = {0};
    memoryTools.readMemory(addr, 28, buf16);
    unsigned short *tempbuf16 = buf16;
    char *tempbuf8 = buf;
    char *buf8 = tempbuf8 + 32;
    while (tempbuf16 < buf16 + 14) {
        if (*tempbuf16 <= 0x007F && tempbuf8 + 1 < buf8) {
            *tempbuf8++ = (char) *tempbuf16;
        } else if (*tempbuf16 >= 0x0080 && *tempbuf16 <= 0x07FF && tempbuf8 + 2 < buf8) {
            *tempbuf8++ = (*tempbuf16 >> 6) | 0xC0;
            *tempbuf8++ = (*tempbuf16 & 0x3F) | 0x80;
        } else if (*tempbuf16 >= 0x0800 && *tempbuf16 <= 0xFFFF && tempbuf8 + 3 < buf8) {
            *tempbuf8++ = (*tempbuf16 >> 12) | 0xE0;
            *tempbuf8++ = ((*tempbuf16 >> 6) & 0x3F) | 0x80;
            *tempbuf8++ = (*tempbuf16 & 0x3F) | 0x80;
        } else {
            break;
        }
        tempbuf16++;
    }
    return buf;
}
//Get class name
char *getClassName(int classId) {
    static char buf[64] = {0};
    memset(buf, 0, sizeof(buf));
    if (classId > 0 && classId < 2000000) {
        int page = classId / 16384;
        int index = classId % 16384;
        uintptr_t pageAddr = memoryTools.readPtr(staticData.gnameAddr + page * sizeof(uintptr_t));
        uintptr_t nameAddr = memoryTools.readPtr(pageAddr + index * sizeof(uintptr_t)) + PubgOffset::ObjectParam::ClassNameOffset;
        memoryTools.readMemory(nameAddr, 64, buf);
    }
    return buf;
}

//Get bone 3d coord
ImVec3 getBone(uintptr_t human, uintptr_t bones, int part) {
    Ue4Transform actorftf;
    memoryTools.readMemory(human, sizeof(ImVec4), &actorftf.rotation);
    memoryTools.readMemory(human + 0x10, sizeof(ImVec3), &actorftf.translation);
    memoryTools.readMemory(human + 0x20, sizeof(ImVec3), &actorftf.scale3d);
    
    Ue4Matrix actormatrix = transformToMatrix(actorftf);
    
    Ue4Transform boneftf;
    memoryTools.readMemory(bones + part * 48, sizeof(ImVec4), &boneftf.rotation);
    memoryTools.readMemory(bones + part * 48 + 0x10, sizeof(ImVec3), &boneftf.translation);
    memoryTools.readMemory(bones + part * 48 + 0x20, sizeof(ImVec3), &boneftf.scale3d);
    
    Ue4Matrix bonematrix = transformToMatrix(boneftf);
    
    return matrixToVector(matrixMulti(bonematrix, actormatrix));
}

//Bone 3d to screen
bool getBone2d(MinimalViewInfo pov,ImVec2 screen, uintptr_t human, uintptr_t bones, int part,ImVec2 &buf) {
    //Get world coord
    ImVec3 newmatrix = getBone(human, bones, part);
    //To screen coord
    buf = worldToScreen(newmatrix, pov, screen);
    //Range
    return buf.x != 0 && buf.y != 0;
}
