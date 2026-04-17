# How to Run CityPulse App on Mobile Device

## Prerequisites

1. **Flutter SDK** - Make sure Flutter is installed and configured
   - Check: `flutter doctor`
   - Install from: https://flutter.dev/docs/get-started/install

2. **Android Studio** (for Android) or **Xcode** (for iOS)
   - Android Studio: https://developer.android.com/studio
   - Xcode: Available on Mac App Store (macOS only)

3. **Mobile Device** - Physical device or emulator/simulator

## For Android Devices

### Option 1: Physical Android Device

1. **Enable Developer Options on your Android device:**
   - Go to Settings → About Phone
   - Tap "Build Number" 7 times
   - Go back to Settings → Developer Options
   - Enable "USB Debugging"

2. **Connect your device:**
   - Connect your Android device to your computer via USB
   - Allow USB debugging when prompted on your device

3. **Check if device is detected:**
   ```bash
   flutter devices
   ```
   You should see your device listed

4. **Run the app:**
   ```bash
   flutter run
   ```
   Or specify the device:
   ```bash
   flutter run -d <device-id>
   ```

### Option 2: Android Emulator

1. **Create an Android Virtual Device (AVD):**
   - Open Android Studio
   - Go to Tools → Device Manager
   - Click "Create Device"
   - Select a device (e.g., Pixel 5)
   - Select a system image (e.g., Android 13)
   - Finish the setup

2. **Start the emulator:**
   - Launch the emulator from Android Studio
   - Or run: `flutter emulators --launch <emulator-id>`

3. **Run the app:**
   ```bash
   flutter run
   ```

## For iOS Devices (macOS only)

### Option 1: Physical iOS Device

1. **Connect your iPhone/iPad:**
   - Connect your iOS device to your Mac via USB
   - Trust the computer when prompted

2. **Configure Xcode:**
   - Open `ios/Runner.xcworkspace` in Xcode
   - Select your device from the device dropdown
   - Go to Signing & Capabilities
   - Select your Team (Apple Developer account)
   - Xcode will automatically manage signing

3. **Check if device is detected:**
   ```bash
   flutter devices
   ```

4. **Run the app:**
   ```bash
   flutter run
   ```

### Option 2: iOS Simulator

1. **Open Simulator:**
   ```bash
   open -a Simulator
   ```
   Or from Xcode: Xcode → Open Developer Tool → Simulator

2. **Select a device:**
   - File → Open Simulator → Choose a device (e.g., iPhone 14)

3. **Run the app:**
   ```bash
   flutter run
   ```

## Important Notes

### Permissions Required

The app requires the following permissions:

**Android:**
- ✅ Location permissions (already configured in AndroidManifest.xml)
- ✅ Internet permission (already configured)
- ✅ Camera permission (for taking photos)
- ✅ Storage permission (for accessing photos)

**iOS:**
- Location permissions need to be added to Info.plist
- Camera and Photo Library permissions need to be added

### Firebase Configuration

Make sure you have:
- ✅ `google-services.json` in `android/app/` (for Android)
- ✅ Firebase configured in `ios/Runner/` (for iOS)
- ✅ Firebase project set up with Authentication, Firestore, and Storage enabled

### Google Maps API Key

- The app uses Google Maps, so make sure your API key is valid
- For Android: Already configured in `AndroidManifest.xml`
- For iOS: Need to add to `Info.plist` if not already done

## Troubleshooting

### Device Not Detected

1. **Android:**
   - Check USB debugging is enabled
   - Try different USB cable/port
   - Run: `adb devices` to check ADB connection
   - Restart ADB: `adb kill-server && adb start-server`

2. **iOS:**
   - Trust the computer on your device
   - Check Xcode is properly configured
   - Make sure device is unlocked

### Build Errors

1. **Clean and rebuild:**
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

2. **Check Flutter doctor:**
   ```bash
   flutter doctor -v
   ```
   Fix any issues shown

### Location Not Working

- Make sure location permissions are granted on the device
- For Android: Check app permissions in device Settings
- For iOS: Check Info.plist has location permission descriptions

### Camera/Photos Not Working

- Grant camera and photo library permissions when prompted
- Check device settings if permissions were denied

## Quick Commands

```bash
# Check connected devices
flutter devices

# Run on specific device
flutter run -d <device-id>

# Run in release mode (faster, no hot reload)
flutter run --release

# Build APK for Android
flutter build apk

# Build IPA for iOS (requires macOS and Xcode)
flutter build ios
```

## Next Steps

Once the app is running:
1. Sign up or log in
2. Grant location permissions when prompted
3. Grant camera permissions when reporting issues
4. Start reporting issues!

