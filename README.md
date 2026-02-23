# Dolphins - PUBG Mobile Tweak

A Theos-based tweak for PUBG Mobile with menu overlay and gameplay features.

## Credits

- **Developer**: [Synzo](https://github.com/synzo) (@synzo)

## Supported Games

| Game | Bundle ID |
|------|-----------|
| PUBG Mobile (Global) | com.tencent.ig |
| Battlegrounds Mobile India (BGMI) | com.pubg.imobile |
| PUBG Mobile KR | com.pubg.krmobile |
| PUBG Mobile VN | com.vng.pubgmobile |

## Requirements

### For Building

- **macOS** with Xcode Command Line Tools
- **OR** Windows (WSL2 with Ubuntu)
- **OR** Linux (Ubuntu/Debian)

### For Installation

- Jailbroken iOS device (for .deb)
- TrollStore/Non-JB loader (for .dylib)

## Installation

### Option 1: Pre-built .deb (Jailbroken)

1. Transfer `com.synzo.pubgglobal_0.0.2_iphoneos-arm.deb` to your iOS device
2. Install via Filza or SSH:
   ```bash
   dpkg -i com.synzo.pubgglobal_0.0.2_iphoneos-arm.deb
   ```
3. Respring

### Option 2: Build from Source

#### 1. Install THEOS

```bash
# macOS
git clone --depth 1 https://github.com/theos/theos.git ~/theos
export THEOS=/Users/synzo/theos && ~/theos/bin/update-theos
brew install ldid

# WSL/Linux
# See BUILD.md for detailed instructions
```

#### 2. Clone & Build

```bash
# Clone this repository
git clone <repository-url>
cd dolphins

# Run interactive build
./build.sh

# Select build type:
# [1] JB (Jailbreak) - Creates .deb
# [2] Non-JB - Creates .dylib
```

#### 3. Manual Build Commands

```bash
# JB Build (Jailbreak)
make clean && make

# Non-JB Build
make clean && make NONJB=1

# Create package
make package
```

## Output Files

| Build Type | Output |
|------------|--------|
| JB | `packages/com.synzo.pubgglobal_0.0.2_iphoneos-arm.deb` |
| Non-JB | `.theos/obj/Dolphins.dylib` |

## Project Structure

```
dolphins/
├── BUILD.md              # Detailed build guide
├── build.sh              # Interactive build script
├── Makefile              # Theos makefile
├── control               # Package control file
├── Dolphins.plist        # Bundle filter (game targets)
├── Dolphins.mm           # Main source
├── MenuWindow.mm         # Menu source
├── View/                 # UI components
├── Esp/                  # ESP & offsets
├── imgui/                # ImGui library
├── SCLAlertView/         # Alert views
├── FCUUID/               # UUID generation
├── Internet/             # Network utilities
└── GWMProgressHUD/       # Progress HUD
```

## Troubleshooting

### "ldid: command not found"
```bash
# macOS
brew install ldid

# WSL/Linux
# Build from source: https://github.com/ProcursusTeam/ldid
```

### Build fails
- Make sure THEOS is installed correctly
- Run: `export THEOS=~/theos` before building

### Tweak not loading
- Check if game is supported (see bundle IDs)
- Verify installation succeeded

## License

This project is for educational purposes only. Use at your own risk.

## Support

- For build issues: Create an issue on GitHub
- For game-specific issues: May need updated offsets for new game versions
