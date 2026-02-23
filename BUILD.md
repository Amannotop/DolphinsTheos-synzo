# Dolphins - Theos Tweak Build Guide

## Credits

- **Developer**: [Synzo](https://github.com/synzo) (@synzo)

## Where Can I Build This?

You can build Theos projects on:

| Platform | Requirements |
|----------|--------------|
| **macOS** | Xcode Command Line Tools |
| **Windows (WSL)** | Ubuntu on WSL2, Xcode SDK files |
| **Linux** | Ubuntu/Debian, clang toolchain |

**No.** You cannot build directly on iOS. You must build on macOS/WSL/Linux, then transfer the `.deb` package to your iOS device.

---

## Fixes Applied

1. **Set THEOS path** to `/Users/synzo/theos`
2. **Renamed** `MenuWindow.m` to `MenuWindow.mm` (C++ compilation needed for imgui)
3. **Installed** `ldid` for code signing

---

## Build on macOS

### Prerequisites

1. Install Xcode Command Line Tools:
   ```bash
   xcode-select --install
   ```

2. Install Homebrew:
   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```

### Install THEOS & Build

```bash
# Install THEOS
git clone --depth 1 https://github.com/theos/theos.git ~/theos

# Update THEOS
export THEOS=/Users/synzo/theos && ~/theos/bin/update-theos

# Install ldid (code signing)
brew install ldid

# Run interactive build script (Recommended)
./build.sh

# Or manually select build type:
# JB Build: make clean && make
# Non-JB Build: make clean && make NONJB=1

# Create .deb package
make package
```

---

## Build on Windows (WSL)

### Prerequisites

1. Install **WSL2** (Windows Subsystem for Linux):
   ```powershell
   wsl --install -d Ubuntu
   ```

2. Install required packages:
   ```bash
   sudo apt update && sudo apt install -y git curl wget clang cmake unzip
   ```

### Install THEOS

```bash
# Clone THEOS
git clone --depth 1 https://github.com/theos/theos.git ~/theos

# Update THEOS
export THEOS=~/theos && ~/theos/bin/update-theos
```

### Download Xcode SDK

Theos needs iOS SDK headers. Download from:

**Option A:** Use `sdk-gen` script:
```bash
cd ~/theos/bin
./sdk-gen
```

**Option B:** Manual download:
```bash
# Download Xcode SDK extract (Mac or from releases)
# Place extracted SDK files in ~/theos/sdks/
```

### Install ldid

WSL needs a custom ldid build:

```bash
# Install dependencies
sudo apt install -y libplist-dev libssl-dev

# Build ldid
git clone https://github.com/ProcursusTeam/ldid.git
cd ldid
git submodule update --init
make
sudo cp ldid /usr/local/bin/
```

### Build

```bash
# Set THEOS environment
export THEOS=~/theos

# Run interactive build script
./build.sh

# Or manually select build type:
# JB Build: make clean && make
# Non-JB Build: make clean && make NONJB=1

# Create package
make package
```

---

## Build on Linux (Ubuntu/Debian)

```bash
# Install dependencies
sudo apt update
sudo apt install -y git curl wget clang cmake unzip libplist-dev libssl-dev

# Clone THEOS
git clone --depth 1 https://github.com/theos/theos.git ~/theos

# Update THEOS
export THEOS=~/theos && ~/theos/bin/update-theos

# Install ldid (from Procursus)
sudo apt install -y libplist-dev libssl-dev
git clone https://github.com/ProcursusTeam/ldid.git
cd ldid
git submodule update --init
make
sudo cp ldid /usr/local/bin/

# Build
./build.sh

# Or manually:
# JB Build: make clean && make
# Non-JB Build: make clean && make NONJB=1
make package
```

---

## Output

- **Dylib**: `.theos/obj/Dolphins.dylib`
- **Package**: `packages/com.synzo.pubgglobal_0.0.2_iphoneos-arm.deb`

---

## Install on iOS Device

### Prerequisites

1. A jailbroken iOS device
2. Cydia/Sileo/Zebra package manager installed
3. OpenSSH installed (or use Filza File Manager)

### Method 1: Using Filza (Easiest)

1. Transfer the `.deb` file to your iOS device (via AirDrop, iCloud, etc.)
2. Open **Filza File Manager** on your iOS device
3. Navigate to where you saved the `.deb` file
4. Tap on the `.deb` file
5. Tap **Install** (top right corner)
6. Wait for installation to complete
7. **Respring** or reboot your device

### Method 2: Using SSH

1. Transfer the `.deb` file to your iOS device:
   ```bash
   scp packages/com.synzo.pubgglobal_0.0.2_iphoneos-arm.deb root@<your-iphone-ip>:/var/mobile/
   ```

2. SSH into your device:
   ```bash
   ssh root@<your-iphone-ip>
   # Default password: alpine
   ```

3. Install the package:
   ```bash
   dpkg -i com.synzo.pubgglobal_0.0.2_iphoneos-arm.deb
   ```

4. If you get dependency errors, fix with:
   ```bash
   apt-get install -f
   ```

5. Respring:
   ```bash
   killall -9 SpringBoard
   ```

### Method 3: Using Sileo/TrollStore

1. Upload the `.deb` to a repository (e.g., GitHub Releases)
2. Add the URL in Sileo
3. Install from Sileo

---

## Troubleshooting

### "ldid: command not found"
- **macOS**: `brew install ldid`
- **WSL/Linux**: Build from source (see above)

### "File does not exist"
- Make sure you're in the project directory
- Check that THEOS path is set correctly in Makefile

### "No SDK found" (WSL/Linux)
- Run `~/theos/bin/sdk-gen` to download Xcode SDK
- Or manually place SDK files in `~/theos/sdks/`

### Package installation fails
- Make sure you have Substrate (Cydia) installed
- Try: `apt-get update && apt-get install -f`

### Tweak not loading
- Check if it's enabled in Substrate/Cydia
- Try a different jailbreak (unc0ver, checkra1n, etc.)
- Check syslog for crash reports

### Default SSH Credentials
- **Username**: `root`
- **Password**: `alpine`

---

## Notes

- Supports **all PUBG Mobile versions**: Global, KR, VNG, TW, BGMI, etc.
- Package: `com.synzo.pubgglobal`
- Requires a jailbroken device
- Build target: **arm64** (iPhone 5s and newer)

---

## License

This project is provided as-is for educational purposes. Use at your own risk.

---

## Credits

- **Developer**: [Synzo](https://github.com/synzo) (@synzo)
- **THEOS**: [@theos](https://github.com/theos)
