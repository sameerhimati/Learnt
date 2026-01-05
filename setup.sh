#!/bin/bash

# Learnt Project Setup Script
# Run this after copying the project files to your machine

set -e

echo "🎓 Setting up Learnt project..."

# Check for Xcode
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ Xcode is not installed. Please install Xcode from the App Store."
    exit 1
fi

echo "✅ Xcode found"

# Check Xcode version
XCODE_VERSION=$(xcodebuild -version | head -1 | awk '{print $2}')
echo "   Version: $XCODE_VERSION"

# Create Xcode project if it doesn't exist
if [ ! -d "Learnt.xcodeproj" ]; then
    echo ""
    echo "📱 No Xcode project found."
    echo "   Please create a new iOS App project in Xcode with these settings:"
    echo ""
    echo "   Product Name: Learnt"
    echo "   Team: (Your Apple Developer account)"
    echo "   Organization Identifier: com.itamih"
    echo "   Bundle Identifier: com.itamih.Learnt"
    echo "   Interface: SwiftUI"
    echo "   Language: Swift"
    echo "   Storage: SwiftData"
    echo "   ✅ Include Tests"
    echo ""
    echo "   Save the project in this directory."
    echo ""
    read -p "Press Enter after creating the project..."
fi

# Initialize git if not already
if [ ! -d ".git" ]; then
    echo ""
    echo "📦 Initializing git repository..."
    git init
    git add .
    git commit -m "Initial commit: Project setup with Claude Code configuration"
    echo "✅ Git repository initialized"
fi

# Check for SwiftLint (optional but recommended)
if command -v swiftlint &> /dev/null; then
    echo "✅ SwiftLint found"
else
    echo "⚠️  SwiftLint not found (optional)"
    echo "   Install with: brew install swiftlint"
fi

echo ""
echo "🎉 Setup complete!"
echo ""
echo "Next steps:"
echo "1. Open Learnt.xcodeproj in Xcode"
echo "2. Set your Development Team in Signing & Capabilities"
echo "3. Build and run (Cmd+R) to verify setup"
echo "4. Start Claude Code: cd $(pwd) && claude"
echo ""
echo "Use /feature to start building features!"
