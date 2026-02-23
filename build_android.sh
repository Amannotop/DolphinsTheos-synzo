#!/bin/bash

echo "================================"
echo "  Dolphins Android Build"
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
        export THEOS=$PREFIX/opt/theos
        make clean
        make
        echo ""
        echo "================================"
        echo "Build complete!"
        echo "Output: .theos/pkg/*.deb"
        echo "================================"
        ;;
    2)
        echo "Building Non-JB version..."
        export THEOS=$PREFIX/opt/theos
        make clean
        make NONJB=1
        echo ""
        echo "================================"
        echo "Build complete!"
        echo "Output: .theos/obj/*.dylib"
        echo "================================"
        ;;
    *)
        echo "Invalid choice!"
        exit 1
        ;;
esac
