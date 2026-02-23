#!/bin/bash

# Dolphins Build Script
# Build fixes by Synzo (@synzo)

echo "================================"
echo "  Dolphins Build Script"
echo "================================"
echo ""
echo "Select build type:"
echo "  [1] JB (Jailbreak) - Creates .deb package"
echo "  [2] Non-JB (Non-Jailbreak) - Creates .dylib"
echo ""
read -p "Enter choice [1-2]: " choice

case $choice in
    1)
        echo "Building JB version..."
        rm -rf .theos/obj .theos/pkg
        make
        echo ""
        echo "================================"
        echo "Build complete!"
        echo "Output: packages/com.synzo.pubgglobal_0.0.2_iphoneos-arm.deb"
        echo "================================"
        ;;
    2)
        echo "Building Non-JB version..."
        rm -rf .theos/obj .theos/pkg
        make NONJB=1
        echo ""
        echo "================================"
        echo "Build complete!"
        echo "Output: .theos/obj/Dolphins.dylib"
        echo "================================"
        ;;
    *)
        echo "Invalid choice!"
        exit 1
        ;;
esac
