# Dolphins - PUBG Mobile Tweak

A Theos-based tweak for PUBG Mobile with menu overlay and gameplay features.

## Download Ready-made Files

**No need to build! Download directly:**

| Version | File | Download |
|---------|------|----------|
| Jailbreak | .deb | [Download from GitHub Actions](./actions/workflows/build.yml) |
| Non-Jailbreak | .dylib | [Download from GitHub Actions](./actions/workflows/build.yml) |

**How to download:**
1. Go to [Actions](./actions/workflows/build.yml)
2. Click on a successful workflow run
3. Download from **Artifacts**

---

## How to Build (For Developers)

Want to modify the code and build yourself? Follow these simple steps:

### Method 1: Build on Phone (Easiest!)

1. **Open this page on your phone browser**
   - Go to: https://github.com/Amannotop/DolphinsTheos-synzo

2. **Run the build**
   - Tap on **Actions** tab
   - Tap on **Build Dolphins**
   - Tap **Run workflow** → **Run workflow**

3. **Download your file**
   - Wait for build to finish (~3-5 minutes)
   - Scroll down to **Artifacts**
   - Tap to download:
     - **Dolphins-jb.deb** (for jailbroken iPhone)
     - **Dolphins-nonjb.dylib** (for non-jailbroken iPhone)

### Method 2: Build on PC/Mac

```bash
# Clone the repo
git clone https://github.com/Amannotop/DolphinsTheos-synzo.git
cd DolphinsTheos-synzo

# Install Theos
git clone --recursive https://github.com/theos/theos.git ./theos

# Build (Jailbreak version)
export THEOS=$PWD/theos
make clean
make package

# OR Build (Non-JB version)
make clean
make NONJB=1
```

---

## How to Install

### For Jailbroken iPhone:
1. Transfer `.deb` file to your iPhone
2. Use Filza or SSH to install:
   ```bash
   dpkg -i Dolphins-jb.deb
   ```
3. Respring

### For Non-Jailbroken iPhone:
1. Install using TrollStore or your preferred non-jb loader
2. Transfer `.dylib` to `/Library/MobileSubstrate/DynamicLibraries/`
3. Create `.plist` file in same folder

---

## How to Update the Code

Want to modify something and rebuild?

1. **On GitHub website:**
   - Go to the file you want to edit
   - Click the pencil icon (edit)
   - Make changes
   - Click **Commit changes**

2. **Or on your PC:**
   ```bash
   # Clone, edit, push
   git clone https://github.com/Amannotop/DolphinsTheos-synzo.git
   # ... make your edits ...
   git add .
   git commit -m "your changes"
   git push
   ```

3. **Build again:**
   - Go to Actions → Run workflow → Download new file

---

## Supported Games

| Game | Bundle ID |
|------|-----------|
| PUBG Mobile (Global) | com.tencent.ig |
| Battlegrounds Mobile India (BGMI) | com.pubg.imobile |
| PUBG Mobile KR | com.pubg.krmobile |
| PUBG Mobile VN | com.vng.pubgmobile |

---

## Credits

- **Developer**: [Synzo](https://github.com/synzo) (@synzo)

---

## Important Notes

- This is for educational purposes only
- Use at your own risk
- May need updated offsets for new game versions
