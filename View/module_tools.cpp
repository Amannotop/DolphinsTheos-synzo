//
//  module_tools.c
//  Dolphins
//
//  Created by XBK on 2022/4/25.
//

#include "module_tools.h"
#include <math.h>

#pragma mark - 坐标系转换
ImVec3 matrixToVector(Ue4Matrix matrix) {
    return ImVec3(matrix[3][0], matrix[3][1], matrix[3][2]);
}

Ue4Matrix matrixMulti(Ue4Matrix m1, Ue4Matrix m2) {
    Ue4Matrix matrix = Ue4Matrix();
    for (int i = 0; i < 4; i++) {
        for (int j = 0; j < 4; j++) {
            for (int k = 0; k < 4; k++) {
                matrix[i][j] += m1[i][k] * m2[k][j];
            }
        }
    }
    return matrix;
}

Ue4Matrix transformToMatrix(Ue4Transform transform) {
    Ue4Matrix matrix;
    
    matrix[3][0] = transform.translation.x;
    matrix[3][1] = transform.translation.y;
    matrix[3][2] = transform.translation.z;
    
    float x2 = transform.rotation.x + transform.rotation.x;
    float y2 = transform.rotation.y + transform.rotation.y;
    float z2 = transform.rotation.z + transform.rotation.z;
    
    float xx2 = transform.rotation.x * x2;
    float yy2 = transform.rotation.y * y2;
    float zz2 = transform.rotation.z * z2;
    
    matrix[0][0] = (1.0f - (yy2 + zz2)) * transform.scale3d.x;
    matrix[1][1] = (1.0f - (xx2 + zz2)) * transform.scale3d.y;
    matrix[2][2] = (1.0f - (xx2 + yy2)) * transform.scale3d.z;
    
    float yz2 = transform.rotation.y * z2;
    float wx2 = transform.rotation.w * x2;
    matrix[2][1] = (yz2 - wx2) * transform.scale3d.z;
    matrix[1][2] = (yz2 + wx2) * transform.scale3d.y;
    
    float xy2 = transform.rotation.x * y2;
    float wz2 = transform.rotation.w * z2;
    matrix[1][0] = (xy2 - wz2) * transform.scale3d.y;
    matrix[0][1] = (xy2 + wz2) * transform.scale3d.x;
    
    float xz2 = transform.rotation.x * z2;
    float wy2 = transform.rotation.w * y2;
    matrix[2][0] = (xz2 + wy2) * transform.scale3d.z;
    matrix[0][2] = (xz2 - wy2) * transform.scale3d.x;
    
    matrix[0][3] = 0;
    matrix[1][3] = 0;
    matrix[2][3] = 0;
    matrix[3][3] = 1;
    
    return matrix;
}

Ue4Matrix rotatorToMatrix(Ue4Rotator rotation) {
    float radPitch = rotation.pitch * ((float) M_PI / 180.0f);
    float radYaw = rotation.yaw * ((float) M_PI / 180.0f);
    float radRoll = rotation.roll * ((float) M_PI / 180.0f);
    
    float SP = sinf(radPitch);
    float CP = cosf(radPitch);
    float SY = sinf(radYaw);
    float CY = cosf(radYaw);
    float SR = sinf(radRoll);
    float CR = cosf(radRoll);
    
    Ue4Matrix matrix;
    
    matrix[0][0] = (CP * CY);
    matrix[0][1] = (CP * SY);
    matrix[0][2] = (SP);
    matrix[0][3] = 0;
    
    matrix[1][0] = (SR * SP * CY - CR * SY);
    matrix[1][1] = (SR * SP * SY + CR * CY);
    matrix[1][2] = (-SR * CP);
    matrix[1][3] = 0;
    
    matrix[2][0] = (-(CR * SP * CY + SR * SY));
    matrix[2][1] = (CY * SR - CR * SP * SY);
    matrix[2][2] = (CR * CP);
    matrix[2][3] = 0;
    
    matrix[3][0] = 0;
    matrix[3][1] = 0;
    matrix[3][2] = 0;
    matrix[3][3] = 1;
    
    return matrix;
}

ImVec2 worldToScreen(ImVec3 worldLocation, MinimalViewInfo camViewInfo, ImVec2 screenCenter) {
    Ue4Matrix tempMatrix = rotatorToMatrix(camViewInfo.rotation);
    
    ImVec3 vAxisX(tempMatrix[0][0], tempMatrix[0][1], tempMatrix[0][2]);
    ImVec3 vAxisY(tempMatrix[1][0], tempMatrix[1][1], tempMatrix[1][2]);
    ImVec3 vAxisZ(tempMatrix[2][0], tempMatrix[2][1], tempMatrix[2][2]);
    
    ImVec3 vDelta = worldLocation - camViewInfo.location;
    
    ImVec3 vTransformed(ImVec3::Dot(vDelta, vAxisY), ImVec3::Dot(vDelta, vAxisZ), ImVec3::Dot(vDelta, vAxisX));
    
    if (vTransformed.z < 1.0f) {
        vTransformed.z = 1.0f;
    }
    ImVec2 screenCoord;
    screenCoord.x = (screenCenter.x + vTransformed.x * (screenCenter.x / tanf(camViewInfo.fov * ((float) M_PI / 360.0f))) / vTransformed.z);
    screenCoord.y = (screenCenter.y - vTransformed.y * (screenCenter.x / tanf(camViewInfo.fov * ((float) M_PI / 360.0f))) / vTransformed.z);
    return screenCoord;
}
//雷达
float getAngleDifference(float angle1, float angle2) {
    float diff = fmod(angle2 - angle1 + 180, 360) - 180;
    return diff < -180 ? diff + 360 : diff;
}

float change(float num) {
    if (num < 0) {
        return abs(num);
    } else if (num > 0) {
        return num - num * 2;
    }
    return num;
}

float get2dDistance(ImVec2 self, ImVec2 object) {
    float osx = self.x - object.x;
    float osy = self.y - object.y;
    
    return sqrt(osx * osx + osy * osy);
}

float get3dDistance(ImVec3 self, ImVec3 object, float divice) {
    ImVec3 xyz;
    xyz.x = self.x - object.x;
    xyz.y = self.y - object.y;
    xyz.z = self.z - object.z;
    return sqrt(pow(xyz.x, 2) + pow(xyz.y, 2) + pow(xyz.z, 2)) / divice;
}

ImVec2 rotateCoord(float angle, ImVec2 coord) {
    float s = sin(angle * M_PI / 180);
    float c = cos(angle * M_PI / 180);
    
    return {coord.x * c + coord.y * s, -coord.x * s + coord.y * c};
}

float rotateAngle(ImVec3 selfCoord, ImVec3 targetCoord) {
    float osx = targetCoord.x - selfCoord.x;
    float osy = targetCoord.y - selfCoord.y;
    return (float) (atan2(osy, osx) * 180 / M_PI);
}

ImVec2 rotateAngleView(ImVec3 selfCoord, ImVec3 targetCoord) {
    
    float osx = targetCoord.x - selfCoord.x;
    float osy = targetCoord.y - selfCoord.y;
    float osz = targetCoord.z - selfCoord.z;
    
    return {(float) (atan2(osy, osx) * 180 / M_PI), (float) (atan2(osz, sqrt(osx * osx + osy * osy)) * 180 / M_PI)};
}

bool isRecycled(const char *name) {
    return strstr(name, "ecycled") != 0;
}
//手持武器
MaterialStruct isWeapon(const char *name) {
    if (strstr(name, "Sniper_QBU") != 0) {
        return {Sniper, 0, "[Sniper Gun]QBU" };
    } else if (strstr(name, "Sniper_SLR") != 0) {
        return {Sniper, 1, "[sniper gun]SLR"};
    } else if (strstr(name, "Sniper_SKS") != 0) {
        return {Sniper, 2, "[Sniper Gun]SKS"};
    } else if (strstr(name, "Sniper_Mini14") != 0) {
        return {Sniper, 3, "[Sniper Gun]Mini14"};
    } else if (strstr(name, "Sniper_M24") != 0) {
        return {Sniper, 4, "[Sniper Gun] M24"};
    } else if (strstr(name, "Sniper_Kar98k") != 0) {
        return {Sniper, 5, "[sniper gun]Kar98k"};
    } else if (strstr(name, "Sniper_AWM") != 0) {
        return {Sniper, 6, "[Sniper Gun]AWM"};
    } else if (strstr(name, "WEP_Mk14") != 0) {
        return {Sniper, 7, "[Sniper Rifle] Mk14"};
    } else if (strstr(name, "Sniper_Mosin") != 0) {
        return {Sniper, 8, "[Sniper Rifle] Mosin Nagant"};
    } else if (strstr(name, "Sniper_MK12") != 0) {
        return {Sniper, 9, "[Sniper Rifle] MK12"};
    } else if (strstr(name, "Sniper_AMR") != 0) {
        return {Sniper, 10, "[Sniper Gun] AMR"};
    } else if (strstr(name, "Sniper_VSS") != 0) {
        return {Sniper, 10, "[Sniper Gun]VSS"};
    
    } else if (strstr(name, "Rifle_M762") != 0) {
        return {Rifle, 0, "[Rifle]M762"};
    } else if (strstr(name, "Rifle_SCAR") != 0) {
        return {Rifle, 1, "[Rifle]SCAR-L"};
    } else if (strstr(name, "Rifle_M416") != 0) {
        return {Rifle, 2, "[Rifle]M416"};
    } else if (strstr(name, "Rifle_M16A4") != 0) {
        return {Rifle, 3, "[Rifle]M16A4"};
    } else if (strstr(name, "Rifle_Mk47") != 0) {
        return {Rifle, 4, "[Rifle]Mk47"};
    } else if (strstr(name, "Rifle_G36") != 0) {
        return {Rifle, 5, "[Rifle]G36C"};
    } else if (strstr(name, "Rifle_QBZ") != 0) {
        return {Rifle, 6, "[Rifle]QBZ"};
    } else if (strstr(name, "Rifle_Groza") != 0) {
        return {Rifle, 7, "[Rifle]Groza"};
    } else if (strstr(name, "Rifle_AUG") != 0) {
        return {Rifle, 8, "[Rifle]AUG"};
    } else if (strstr(name, "Rifle_AKM") != 0) {
        return {Rifle, 9, "[Rifle]AKM"};
        
    } else if (strstr(name, "Other_DP28") != 0) {
        return {Rifle, 10, "[Machine Gun] Big Pan Chicken"};
    } else if (strstr(name, "Other_M249") != 0) {
        return {Rifle, 11, "[Machine Gun] Big Pineapple"};
    } else if (strstr(name, "Other_MG3") != 0) {
        return {Rifle, 12, "[Machine Gun] MG3"};
        
    } else if (strstr(name, "Grenade_Shoulei_Weapon_C") != 0) {
        return {Missile, 0, "[Throwing Object] Grenade"};
    } else if (strstr(name, "Grenade_Smoke_Weapon_C") != 0) {
        return {Missile, 1, "[Throwing Object] Smoke Bomb"};
    } else if (strstr(name, "Grenade_Burn_Weapon_C") != 0) {
        return {Missile, 2, "[Throwing Object] Molotov cocktail"};
    
    } else if (strstr(name, "WEP_Pan") != 0) {
        return {WEP, 0, "[Melee] Pan"};
    } else if (strstr(name, "WEP_Sickle") != 0) {
        return {WEP, 1, "[Melee] Scythe"};
    } else if (strstr(name, "WEP_Machere_") != 0) {
        return {WEP, 2, "[Melee] Machete"};
    } else if (strstr(name, "WEP_Cowbar") != 0) {
        return {WEP, 3, "[Melee] Crowbar"};
    
    } else if (strstr(name, "MachineGun_MP5K") != 0) {
        return {MachineGun, 0, "[submachine gun] MP5K"};
    } else if (strstr(name, "MachineGun_P90") != 0) {
        return {MachineGun, 1, "[submachine gun] P90"};
    } else if (strstr(name, "MachineGun_TommyGun") != 0) {
        return {MachineGun, 2, "[Submachine Gun]TommyGun"};
    } else if (strstr(name, "MachineGun_UMP9") != 0) {
        return {MachineGun, 3, "[submachine gun]UMP9"};
    } else if (strstr(name, "MachineGun_Uzi") != 0) {
        return {MachineGun, 4, "[submachine gun]Uzi"};
    } else if (strstr(name, "MachineGun_Vector") != 0) {
        return {MachineGun, 5, "[Submachine Gun]Vector"};
    } else if (strstr(name, "MachineGun_Bison") != 0) {
        return {MachineGun, 6, "[Submachine Gun] Bison"};
    
    } else if (strstr(name, "ShotGun_S686") != 0) {
        return {ShotGun, 0, "[Shotgun]S686"};
    } else if (strstr(name, "ShotGun_S1897") != 0) {
        return {ShotGun, 1, "[Shotgun]S1897"};
    } else if (strstr(name, "ShotGun_S12K") != 0) {
        return {ShotGun, 2, "[Shotgun]S12K"};
    } else if (strstr(name, "ShotGun_DBS") != 0) {
        return {ShotGun, 3, "[Shotgun]DBS"};
    } else if (strstr(name, "ShotGun_SawedOff") != 0) {
        return {ShotGun, 4, "[Shotgun]SawedOff"};
    
    
    } else if (strstr(name, "Pistol_P92") != 0) {
        return {Pistol, 0, "[Pistol]P92"};
    } else if (strstr(name, "Pistol_P1911") != 0) {
        return {Pistol, 1, "[Pistol]P1911"};
    } else if (strstr(name, "Pistol_R1895") != 0) {
        return {Pistol, 2, "[Pistol]R1895"};
    } else if (strstr(name, "Pistol_P18C") != 0) {
        return {Pistol, 3, "[Pistol]P18C"};
    } else if (strstr(name, "Pistol_R45") != 0) {
        return {Pistol, 4, "[Pistol]R45"};
    }
    
    return {-1, -1, "NULL"};
}
//地面显示
MaterialStruct isMaterial(const char *name) {
     if (strstr(name, "Motorcycle_") != 0) {
         return {Vehicle, 0, "motorcycle"};
     } else if (strstr(name, "MotorcycleCart") != 0) {
         return {Vehicle, 1, "Tricycle"};
     } else if (strstr(name, "Scooter") != 0) {
         return {Vehicle, 2, "Little Sheep"};// Little Sheep Vehicle
     } else if (strstr(name, "Buggy") != 0) {
         return {Vehicle, 3, "Boom"};// Boom
     } else if (strstr(name, "Mirado") != 0) {
         return {Vehicle, 4, "Sports Car"};// Maserati
     } else if (strstr(name, "Dacia") != 0) {
         return {Vehicle, 5, "Sedan"};//Sedan
// } else if (strstr(name, "PickUp") != 0 && strstr(name, "Armor") == 0 && strstr(name, "List") == 0 && strstr(name, "Helmet") == 0 && strstr(name, "Bag") == 0) {
// return {Vehicle, 6, "Pickup Truck"};// Pickup Truck
     } else if (strstr(name, "UAZ") != 0) {
         return {Vehicle, 7, "Jeep"};// Jeep
     } else if (strstr(name, "PG117") != 0) {
         return {Vehicle, 8, "big boat"};//speedboat
     } else if (strstr(name, "AquaRail") != 0) {
         return {Vehicle, 9, "motorboat"};// motorboat
     } else if (strstr(name, "MiniBus") != 0) {
         return {Vehicle, 10, "Baby Bus"};// van
     } else if (strstr(name, "BRDM") != 0) {
         return {Vehicle, 11, "Armored Vehicle"};// Amphibious armored vehicle
     } else if (strstr(name, "LadaNiva") != 0) {
         return {Vehicle, 12, "Jeep"}; // Radaniva
     } else if (strstr(name, "Snowbike") != 0) {
         return {Vehicle, 13, "Snowmobile"};// light snowmobile
     } else if (strstr(name, "Snowmobile") != 0) {
         return {Vehicle, 14, "Snowmobile"}; // heavy snowmobile
     } else if (strstr(name, "Rony") != 0) {
         return {Vehicle, 15, "Pickup"};// small truck
     } else if (strstr(name, "CoupeRB_1") != 0) {
         return {Vehicle, 16, "CoupeRB"};// small truck
        
     } else if (strstr(name, "PickUpList") != 0) {
         return {Airdrop, 0, "[box]"};
     } else if (strstr(name, "AirDropList") != 0) {
         return {Airdrop, 1, "[Airdrop]"};
// } else if (strstr(name, "DeadInventoryBox") != 0) {
// return {Airdrop, 2, "Box"};
// } else if (strstr(name, "AirDropBox") != 0) {
// return {Airdrop, 3, "Airdrop"};
        
     } else if (strstr(name, "Pistol_Flaregun") != 0) {
         return {FlareGun, 0, "FlareGun"};
        
     } else if (strstr(name, "BP_Sniper_QBU_Wrapper_C") != 0) {
         return {Sniper, 0, "QBU"};
     } else if (strstr(name, "BP_Sniper_SLR_Wrapper_C") != 0) {
         return {Sniper, 1, "SLR"};
     } else if (strstr(name, "BP_Sniper_SKS_Wrapper_C") != 0) {
         return {Sniper, 2, "SKS"};
     } else if (strstr(name, "BP_Sniper_Mini14_Wrapper_C") != 0) {
         return {Sniper, 3, "Mini14"};
     } else if (strstr(name, "BP_Sniper_M24_Wrapper_C") != 0) {
         return {Sniper, 4, "M24"};
     } else if (strstr(name, "BP_Sniper_Kar98kv") != 0) {
         return {Sniper, 5, "Kar98k"};
} else if (strstr(name, "BP_Sniper_AWM_Wrapper_C") != 0) {
         return {Sniper, 6, "AWM"};
     } else if (strstr(name, "BP_Sniper_Mk14_Wrapper_C") != 0) {
         return {Sniper, 7, "Mk14"};
     } else if (strstr(name, "BP_Sniper_Mosin_Wrapper_C") != 0) {
         return {Sniper, 8, "Mosin Nagant"};
     } else if (strstr(name, "BP_Sniper_MK12_Wrapper_C") != 0) {
         return {Sniper, 9, "MK12"};
     } else if (strstr(name, "BP_Sniper_AMR_Wrapper_C") != 0) {
         return {Sniper, 10, "AMR"};
        
     } else if (strstr(name, "BP_Rifle_M762_Wrapper_C") != 0) {
         return {Rifle, 0, "M762"};
     } else if (strstr(name, "BP_Rifle_SCAR_Wrapper_C") != 0) {
         return {Rifle, 1, "SCAR-L"};
     } else if (strstr(name, "BP_Rifle_M416_Wrapper_C") != 0) {
         return {Rifle, 2, "M416"};
     } else if (strstr(name, "BP_Rifle_M16A4_Wrapper_C") != 0) {
         return {Rifle, 3, "M16A4"};
     } else if (strstr(name, "BP_Rifle_Mk47_Wrapper_C") != 0) {
         return {Rifle, 4, "Mk47"};
     } else if (strstr(name, "BP_Rifle_G36_Wrapper_C") != 0) {
         return {Rifle, 5, "G36C"};
     } else if (strstr(name, "BP_Rifle_QBZ_Wrapper_C") != 0) {
         return {Rifle, 6, "QBZ"};
     } else if (strstr(name, "BP_Rifle_Groza_Wrapper_C") != 0) {
         return {Rifle, 7, "Groza"};
     } else if (strstr(name, "BP_Rifle_AUG_Wrapper_C") != 0) {
         return {Rifle, 8, "AUG"};
     } else if (strstr(name, "BP_Rifle_AKM_Wrapper_C") != 0) {
         return {Rifle, 9, "AKM"};
     } else if (strstr(name, "BP_Other_DP28_Wrapper_C") != 0) {
         return {Rifle, 10, "Big Pan Chicken"};
     } else if (strstr(name, "BP_Other_M249_Wrapper_C") != 0) {
         return {Rifle, 11, "Big Pineapple"};
     } else if (strstr(name, "BP_Other_MG3_Wrapper_C") != 0) {
         return {Rifle, 12, "MG3"};
        
     } else if (strstr(name, "Grenade_Shoulei_Weapon_") != 0) {
         return {Missile, 0, "Grenade"};
     } else if (strstr(name, "Grenade_Smoke_Weapon_") != 0) {
         return {Missile, 1, "Smoke Bomb"};
     } else if (strstr(name, "Grenade_Burn_Weapon_") != 0) {
         return {Missile, 2, "Molot"};
        
// } else if (strstr(name, "Armor_Lv2") != 0) {
// return {Armor, 0, "[Armor] Second Class Armor"};
     } else if (strstr(name, "Armor_Lv3") != 0) {
         return { Armor, 1, "Level 3"};
// } else if (strstr(name, "Bag_Lv2") != 0) {
// return {Armor, 2, "[Backpack] Secondary Pack"};
     } else if (strstr(name, "Bag_Lv3") != 0) {
         return {Armor, 3, "Level 3"};
// } else if (strstr(name, "Helmet_Lv2") != 0) {
// return {Armor, 4, "[Armor] Second Level Head"};
     } else if (strstr(name, "Helmet_Lv3") != 0) {
         return {Armor, 5, "Third level head"};
        
     } else if (strstr(name, "QT_Sniper") != 0) {
         return {SniperParts, 0, "cheek support"};
     } else if (strstr(name, "ZDD_Sniper") != 0) {
         return {SniperParts, 1, "SniperParts"};
} else if (strstr(name, "Sniper_FlashHider") != 0) {
         return {SniperParts, 2, "flame hider"};
     } else if (strstr(name, "Sniper_Compensator") != 0) {
         return {SniperParts, 3, "SniperParts"};
     } else if (strstr(name, "Sniper_Suppressor") != 0) {
         return {SniperParts, 4, "SniperParts"};
     } else if (strstr(name, "Sniper_EQ") != 0) {
         return {SniperParts, 5, "Quick expansion"};
     } else if (strstr(name, "Sniper_E") != 0) {
         return {SniperParts, 6, "Expansion"};
        
     } else if (strstr(name, "QT_A") != 0) {
         return {RifleParts, 0, "Tactical Rifle Stock"};
     } else if (strstr(name, "Large_FlashHider") != 0) {
         return {RifleParts, 1, "flame hider"};
     } else if (strstr(name, "Large_Compensator") != 0) {
         return {RifleParts, 2, "RifleParts"};
     } else if (strstr(name, "Large_Suppressor") != 0) {
         return {RifleParts, 3, "Muffler"};
     } else if (strstr(name, "Large_EQ") != 0) {
         return {RifleParts, 4, "Rapid expansion"};
     } else if (strstr(name, "Large_E") != 0) {
         return {RifleParts, 5, "Expansion"};
        
     } else if (strstr(name, "Pills") != 0) {
         return {Drug, 0, "Painkiller"};
     } else if (strstr(name, "Injection") != 0) {
         return {Drug, 1, "Adrenaline"};
     } else if (strstr(name, "Drink") != 0) {
         return {Drug, 2, "Drink"};
     } else if (strstr(name, "Firstaid") != 0) {
         return {Drug, 3, "First Aid Kit"};
     } else if (strstr(name, "FirstAidbox") != 0) {
         return {Drug, 4, "Medical Kit"};
     } else if (strstr(name, "GasCanBattery_Destructible_") != 0) {
         return {Drug, 5, "Oil Barrel"};
    
     } else if (strstr(name, "Ammo_556mm") != 0) {
         return {Bullet, 0, "5.56mm"};
     } else if (strstr(name, "Ammo_762mm") != 0) {
         return {Bullet, 1, "7.62mm"};
     } else if (strstr(name, "Ammo_300Magnum") != 0) {
         return {Bullet, 2, "Magnum"};
     } else if (strstr(name, "Ammo_50BMG") != 0) {
         return {Bullet, 3, "Magnum"};
        
     } else if (strstr(name, "WB_ThumbGrip") != 0) {
         return {Grip, 0, "Thumb Grip"};
     } else if (strstr(name, "WB_LightGrip") != 0) {
         return {Grip, 1, "Light Grip"};
     } else if (strstr(name, "WB_Vertical") != 0) {
         return {Grip, 2, "Vertical Grip"};
     } else if (strstr(name, "WB_Angled") != 0) {
         return {Grip, 3, "Right angle front grip"};
     } else if (strstr(name, "WB_HalfGrip") != 0) {
         return {Grip, 4, "Half Grip"};
     } else if (strstr(name, "WB_Lasersight") != 0) {
         return {Grip, 5, "Laser Grip"};
        
     } else if (strstr(name, "MZJ_HD") != 0) {
         return {Sight, 0, "red dot"};
     } else if (strstr(name, "MZJ_QX") != 0) {
         return {Sight, 1, "hologram"};
     } else if (strstr(name, "MZJ_3X") != 0) {
         return {Sight, 2, "3X"};
     } else if (strstr(name, "MZJ_4X") != 0) {
         return {Sight, 3, "4X"};
} else if (strstr(name, "MZJ_6X") != 0) {
         return {Sight, 4, "6X"};
     } else if (strstr(name, "MZJ_8X") != 0) {
         return {Sight, 5, "8X"};
     } else if (strstr(name, "Large_EQ") != 0) {
         return {Sight, 6, "Rapid expansion"};
     } else if (strstr(name, "Large_E") != 0) {
         return {Sight, 7, "Expansion"};
    
     } else if (strstr(name, "ProjFire__") != 0) {
         return {Warning, 0, "[Warning] Flash"};
     } else if (strstr(name, "ProjBurn_") != 0) {
         return {Warning, 1, "[Warning] Molotov cocktail"};
     } else if (strstr(name, "ProjSmoke_") != 0) {
         return {Warning, 2, "[Warning] smoke bomb"};
     } else if (strstr(name, "ProjGrenade_") != 0) {
         return {Warning, 3, "[Warning] be careful with grenades"};
     } else if (strstr(name, "AirAttackBomb") != 0) {
         return {Warning, 4, "[Bombing Warning] Watch out for the bombing zone"};
     } else if (strstr(name, "ExplosionEffect_Grenade_") != 0) {
         return {Warning, 5, "[Warning] grenade explosion"};
     } else if (strstr(name, "ExplosionEffect_Smoke_") != 0) {
         return {Warning, 6, "[Warning] smoke and smoke"};
     } else if (strstr(name, "ExplosionEffect_Fire_") != 0) {
         return {Warning, 7, "[Warning] smoke and smoke"};
     }
     return {-1, -1, "NULL"};
}
// inside the box
//盒子内
MaterialStruct isBoxMaterial(int box_goods_id) {
    if (box_goods_id == 601006) {
        return {Drug, 4, "[Medicine] Medical Box"};
    } else if (box_goods_id == 601005) {
        return {Drug, 3, "[Medicine] first aid package"};
    } else if (box_goods_id == 601001) {
        return {Drug, 2, "[medicine] drink"};
    } else if (box_goods_id == 601002) {
        return {Drug, 1,"[Medicine] adrenaline"};
    } else if (box_goods_id == 601003) {
        return {Drug, 0, "[Medicine] Pain relieving medicine"};
        
    } else if (box_goods_id == 503002) {
        return {Armor, 0, "[Defense] Tier 2 A"};
    } else if (box_goods_id == 503003) {
        return {Armor, 1, "[Defense] Level 3 A"};
    } else if (box_goods_id == 501002) {
        return {Armor, 2, "[Bag] second -level package"};
    } else if (box_goods_id == 501006) {
        return {Armor, 3, "[Bag] three -level package"};
    } else if (box_goods_id == 502002) {
        return {Armor, 4, "[Head] second -level head"};
    } else if (box_goods_id == 502003) {
        return {Armor, 5, "[Head] three -level head"};
        
    } else if (box_goods_id == 105001) {
        return {Sniper, 0,"[Q] QBU"};
    } else if (box_goods_id == 103009) {
        return {Sniper, 1,"[S] SLR"};
    } else if (box_goods_id == 103004) {
        return {Sniper, 2,"[S] SKS"};
    } else if (box_goods_id == 103006) {
        return {Sniper, 3, "[Sni] MINI14"};
    } else if (box_goods_id == 103002) {
        return {Sniper, 4,"[M] m24"};
    } else if (box_goods_id == 103001) {
        return {Sniper, 5, "[K] Kar98k"};
    } else if (box_goods_id == 103003) {
        return {Sniper, 6, "[A] AWM"};
    } else if (box_goods_id == 103002) {
        return {Sniper, 7,"[MK] mk14"};
    } else if (box_goods_id == 103011) {
        return {Sniper, 9,"[Spicy] Mosinnan Gan"};
    } else if (box_goods_id == 103100) {
        return {Sniper, 10,"[1] mk12"};
    } else if (box_goods_id == 103012) {
        return {Sniper, 11,"[A] AMR"};
        
    } else if (box_goods_id == 101008) {
        return {Rifle, 0,"[Gun] M762"};
    } else if (box_goods_id == 101003) {
        return {Rifle, 1, "[Gun] Scar-L"};
    } else if (box_goods_id == 101004) {
        return {Rifle, 2,"[Gun] M416"};
    } else if (box_goods_id == 101002) {
        return {Rifle, 3, "[Gun] M16A4"};
    } else if (box_goods_id == 101009) {
        return {Rifle, 4,"[Gun] mk47"};
    } else if (box_goods_id == 101010) {
        return {Rifle, 5,"[Gun] G36C"};
    } else if (box_goods_id == 101007) {
        return {Rifle, 6,"[Gun] QBZ"};
    } else if (box_goods_id == 101005) {
        return {Rifle, 7, "[Gun] Groza"};
    } else if (box_goods_id == 101006) {
        return {Rifle, 8,"[Gun] AUG"};
    } else if (box_goods_id == 101001) {
        return {Rifle, 9,"[Gun] AKM"};
        
    } else if (box_goods_id == 105002) {
        return {Rifle, 10,"[Machine] Big plate chicken"};
    } else if (box_goods_id == 105001) {
return {Rifle, 11,"[Machine] big pineapple"};
    } else if (box_goods_id == 105010) {
        return {Rifle, 12,"[Machine] MG3"};
        
    } else if (box_goods_id == 303001) {
        return {Bullet, 0, "[Bullet] 5.56mm"};
    } else if (box_goods_id == 302001) {
        return {Bullet, 1, "[Bullet] 7.62mm"};
    } else if (box_goods_id == 306001) {
        return {Bullet, 2,"[Blade] Magnum"};
    } else if (box_goods_id == 308001) {
        return {Bullet, 4, "[Bullet] signal bullet"};
        
    } else if (box_goods_id == 203001) {
        return {Sight, 0, "[Mirror] Red Dot"};
    } else if (box_goods_id == 203002) {
        return {Sight, 1, "[Mirror] Plutonus"};
    } else if (box_goods_id == 203014) {
        return {Sight, 2, "[mirror] 3x"};
    } else if (box_goods_id == 203004) {
        return {Sight, 3, "[Mirror] 4X"};
    } else if (box_goods_id == 203015) {
        return {Sight, 4, "[mirror] 6x"};
    } else if (box_goods_id == 203005) {
        return {Sight, 5, "[mirror] 8x"};
        
    } else if (box_goods_id == 205003) {
        return {SniperParts, 0, "[Sniper accessories] Cheek cheeks"};
    } else if (box_goods_id == 204014) {
        return {SniperParts, 1, "[Sniper accessories] Bullet bag"};
    } else if (box_goods_id == 204010) {
        return {SniperParts, 1, "[Sniper accessories] Bullet bag"};
    } else if (box_goods_id == 201005) {
        return {SniperParts, 2, "[Sniper accessories] flames"};
    } else if (box_goods_id == 201003) {
        return {SniperParts, 3, "[Sniper] muzzle compensation"};
    } else if (box_goods_id == 201007) {
        return {SniperParts, 4, "[Sniper Accessories] Calculator"};
    } else if (box_goods_id == 204009) {
        return {SniperParts, 5, "[Sniper] Fast expansion"};
    } else if (box_goods_id == 204007) {
        return {SniperParts, 6,"[Sniper accessories] Expansion"};
        
    } else if (box_goods_id == 202004) {
        return {Grip, 0,"[Hold] thumb grip"};
    }/*else if (box_goods_id == 000000) {
      return {Grip, 1, "[Holding] Light grip"};
      }*/ else if (box_goods_id == 202001) {
          return {Grip, 2,"[Holding] Vertical grip"};
      }/*else if (box_goods_id == 000000) {
        return {Grip, 3, "[Holding] Straight corner front handle"};
        }*/else if (box_goods_id == 202005) {
            return {Grip, 4, "[Holding] Half -style grip"};
            
        } else if (box_goods_id == 205002) {
            return {RifleParts, 0, "[Accessories] Tactical Gun Tart"};
        } else if (box_goods_id == 201010) {
            return {RifleParts, 1,"[Accessories] The flames of the flames"};
        } else if (box_goods_id == 201009) {
            return {RifleParts, 2, "[Accessories] muzzle compensation"};
        } else if (box_goods_id == 201011) {
            return {RifleParts, 3,"[Accessories] Calculator"};
        } else if (box_goods_id == 204013) {
            return {RifleParts, 4, "[Accessories] Fast expansion"};
} else if (box_goods_id == 204011) {
            return {RifleParts, 5,"[Accessories] Expansion"};
            
        } else if (box_goods_id == 602004) {
            return {Missile, 0, "[vote] grenade"};
        } else if (box_goods_id == 602002) {
            return {Missile, 1, "[Vote] Smoke bomb"};
        } else if (box_goods_id == 602003) {
            return {Missile, 2, "[Vote] Burning bottle"};
        }
    return {-1, -1, "[unknown]"};
}