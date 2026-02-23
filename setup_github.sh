#!/bin/bash

echo "================================"
echo "  Dolphins GitHub Setup"
echo "================================"
echo ""
echo "This script will:"
echo "  1. Initialize git"
echo "  2. Add all files"
echo "  3. Create initial commit"
echo "  4. Help you push to GitHub"
echo ""

read -p "Enter your GitHub repository URL: " repo_url

if [ -z "$repo_url" ]; then
    echo "Error: Please enter a repository URL"
    exit 1
fi

echo ""
echo "Initializing git..."
git init
git add .
git commit -m "Initial commit - Dolphins Tweak"

echo ""
echo "Adding remote..."
git remote add origin $repo_url

echo ""
echo "To push to GitHub, run:"
echo "  git branch -M main"
echo "  git push -u origin main"
echo ""
echo "After pushing:"
echo "  1. Go to GitHub → Actions"
echo "  2. Click 'Build Dolphins'"
echo "  3. Click 'Run workflow'"
echo "  4. Download your .deb or .dylib"
echo ""
