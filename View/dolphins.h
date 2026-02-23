//
//  Dolphins.h
//  Dolphins
//
//  Created by XBK on 2022/4/24.
//
#include "imgui/imgui.h"

//Static data thread
void *readStaticData(void *);

//Get frame data
void readFrameData(ImVec2 screenSize,std::vector<PlayerData> &playerDataList, std::vector<MaterialData> &materialDataList);

//Aimbot
void *silenceAimbot(void *);
    
//Line of Sight
bool isCoordVisibility(ImVec3 coord);
//In smoke
bool isOnSmoke(ImVec3 coord);

//Get player name
char* getPlayerName(uintptr_t addr);

//Get object type name
char* getClassName(int classId);
char* statusName(int statusId);
//Get bone coord
ImVec3 getBone(uintptr_t human, uintptr_t bones, int part);

//Get bone screen coord
bool getBone2d(MinimalViewInfo pov,ImVec2 screen, uintptr_t human, uintptr_t bones, int part,ImVec2 &buf);
