#!/bin/bash

# Script to completely fix the plugin issue by doing a full app restart

echo "🔧 Fixing plugin issue - Complete app restart required"
echo "=================================================="
echo ""

# Step 1: Stop any running Flutter processes
echo "Step 1: Stopping any running Flutter processes..."
pkill -f "flutter_tools" 2>/dev/null || true
echo "✓ Stopped"
echo ""

# Step 2: Clean build cache
echo "Step 2: Cleaning build cache..."
flutter clean
echo "✓ Build cache cleaned"
echo ""

# Step 3: Uninstall app from connected Android device/emulator
echo "Step 3: Uninstalling app from Android device/emulator..."
adb uninstall com.example.quote_vault 2>/dev/null && echo "✓ App uninstalled from Android" || echo "⚠ No Android device found or app not installed"
echo ""

# Step 4: Reinstall dependencies
echo "Step 4: Reinstalling dependencies..."
flutter pub get
echo "✓ Dependencies reinstalled"
echo ""

# Step 5: Ready to run
echo "=================================================="
echo "✅ Setup complete!"
echo ""
echo "Next step: Run the app with a FULL BUILD (not hot reload)"
echo "Command: flutter run"
echo ""
echo "⚠️  IMPORTANT: After the app starts, do NOT use hot reload"
echo "   for plugin changes. Always stop and restart the app."
echo "=================================================="
