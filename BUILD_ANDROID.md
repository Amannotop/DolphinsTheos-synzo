# Dolphins Build Guide

## Option 1: Build with GitHub (Recommended for Android)

### Step 1: Upload to GitHub
1. Create a GitHub account
2. Create a new repository
3. Upload all files to the repository

### Step 2: Build on Android
1. Open the repository on GitHub in browser
2. Go to **Actions** tab
3. Click **Build Dolphins**
4. Click **Run workflow** → **Run workflow**

### Step 3: Download
- **JB (.deb)**: Click the build → Artifacts → Dolphins-jb.deb
- **Non-JB (.dylib)**: Click the build → Artifacts → Dolphins-nonjb.dylib

---

## Option 2: Build with Termux (Direct on Android)

```bash
# Install Termux from F-Droid
pkg update && pkg install git make clang wget curl unzip

# Clone Theos
git clone --recursive https://github.com/theos/theos.git $PREFIX/opt/theos

# Set path
export THEOS=$PREFIX/opt/theos
export PATH=$THEOS/bin:$PATH

# Clone your project
cd ~/DolphinTheos-synzo  # or wherever you put the code

# Build JB (deb)
make

# Build Non-JB (dylib)
make NONJB=1
```
