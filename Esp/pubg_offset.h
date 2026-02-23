//
// Created by Synzo on 2022/1/16.
//
namespace PubgOffset {
    //NetDriver* NetDriver
    //NetConnection* ServerConnection
    //STExtraPlayerController* PlayerController
    int PlayerControllerOffset[3] = {0x38, 0x78, 0x30};
    namespace PlayerControllerParam {
        //STExtraBaseCharacter* STExtraBaseCharacter;
        int SelfOffset = 0x252c;
        //Rotator ControlRotation
        int MouseOffset = 0x428;
        //PlayerCameraManager* PlayerCameraManager
        int CameraManagerOffset = 0x490;
    namespace CameraManagerParam{
            //TViewTarget ViewTarget
            int PovOffset = 0xfd0 + 0x10;
        }
        namespace ControllerFunction {
            int LineOfSightToOffset = 0x750;
// goc 718
        }
    }
    //Level* PersistentLevel
    int ULevelOffset = 0x30;
    namespace ULevelParam {
        //LineBatchComponenet* PersistentLineBatcher
        int ObjectArrayOffset = 0xA0;
        //Member count
        int ObjectCountOffset = 0xA8;
    }

    namespace ObjectParam {
        int ClassIdOffset = 0x18;
        int ClassNameOffset = 0xC;

        namespace PlayerFunction {
            int AddControllerYawInputOffset = 0x828 + 0x8;
            int AddControllerRollInputOffset = 0x820 + 0x8;
            int AddControllerPitchInputOffset = 0x830 + 0x8;
        }
        //uint64 CurrentStates;
        int StatusOffset = 0xf30;
        //int TeamID
        int TeamOffset = 0x8f0;
        //FString PlayerName
        int NameOffset = 0x8a8;
        //bool bIsAI
        int RobotOffset = 0x9a1;
        //float Health
        int HpOffset = 0xD58;
        int MoveCoordOffset = 0xB0;
        int DeadOffset = 0xD74;
        //SkeletalMeshComponent* Mesh;
        int MeshOffset = 0x458;
        namespace MeshParam{
            //Character* CharacterOwner;
            int HumanOffset = 0x1b0;
            //StaticMesh* StaticMesh;
            int BonesOffset = 0x810;
        }
        //bool bIsWeaponFiring
        int OpenFireOffset = 0x15c0;
        //bool bIsGunADS
        int OpenTheSightOffset = 0xfe9;
        int WeaponOneOffset = 0x2630+0x20;
// struct FAnimStatusKeyList LastUpdateStatusKeyList;
// struct ASTExtraWeapon* EquipWeapon;
        namespace WeaponParam{
            int MasterOffset = 0xB0;


//enum class EShootWeaponShootMode ShootMode;
            int ShootModeOffset = 0xeb0;
//struct UShootWeaponEntity* ShootWeaponEntityComp;
            int WeaponAttrOffset = 0xFd8;
            namespace WeaponAttrParam{
// float BulletFireSpeed;
                int BulletSpeedOffset = 0x4f0;
//	float RecoilKickADS
                int RecoilOffset = 0xc50;
            }
        }
        //struct TArray<struct FPickUpItemData> PickUpDataList;
        int GoodsListOffset = 0x858;
        namespace GoodsListParam {
            int DataBase = 0x38;
        }
        //SceneComponent* RootComponent;
        int CoordOffset = 0x1b0;
        namespace CoordParam {
            int HeightOffset = 0x17c;


//struct AStairsActor* TargetStairsActor; // Offset: 0x210 // Size: 0x08
            int CoordOffset = 0x1c0;
        }
    }
}
