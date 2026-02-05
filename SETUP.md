# Setup & Testing Guide

## Quick Start

### 1. Run the App

```bash
# For iOS Simulator
flutter run -d ios

# For Android Emulator
flutter run -d android

# For connected device
flutter devices  # List available devices
flutter run      # Run on default device
```

### 2. Testing with Sample Audio

To test the app, you'll need a Dropbox MP3 link. Here's how to get one:

#### Option A: Use Your Own MP3
1. Upload an MP3 file to Dropbox
2. Right-click the file → Share → Create link
3. Copy the link (it will look like: `https://www.dropbox.com/s/xxxxx/audio.mp3?dl=0`)
4. Paste it in the app

#### Option B: Test with Sample Links
You can use any publicly shared Dropbox MP3 link for testing.

**The app will automatically convert:**
- `https://www.dropbox.com/s/xxxxx/file.mp3?dl=0`
- **To:** `https://www.dropbox.com/s/xxxxx/file.mp3?raw=1`

### 3. Testing A-B Loop Feature

1. Load an audio file
2. Press play to start playback
3. **Tap on the timeline** where you want loop point A
4. **Tap again** where you want loop point B
5. The audio will automatically loop between A and B
6. **Drag the markers** to adjust the loop points
7. **Tap the timeline again** to reset and set new loop points

## Features to Test

### ✅ Audio Loading
- [ ] Paste Dropbox link
- [ ] Press link icon or Enter to load
- [ ] Audio loads successfully
- [ ] Duration displays correctly

### ✅ Playback Controls
- [ ] Play/Pause button works
- [ ] -5s backward button works
- [ ] +5s forward button works
- [ ] Time updates during playback

### ✅ A-B Loop
- [ ] Tap to set point A
- [ ] Tap to set point B
- [ ] Audio loops from B back to A
- [ ] Drag markers to adjust positions
- [ ] Timeline highlights loop section
- [ ] Reset by tapping new points

### ✅ Playback Speed
- [ ] 0.5x speed works
- [ ] 0.75x speed works
- [ ] 1.0x speed works (default)
- [ ] 1.25x speed works
- [ ] 1.5x speed works
- [ ] Active speed indicator updates

### ✅ Dark Mode
- [ ] Switches when system theme changes
- [ ] All UI elements visible in both modes

## Troubleshooting

### Audio Won't Load
- Make sure the link is from Dropbox
- Ensure the file is an MP3
- Check internet connection
- Try regenerating the Dropbox share link

### Build Issues
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

### Platform-Specific Setup

#### Android
✅ **Already configured!** The `android/app/src/main/AndroidManifest.xml` includes:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

This is **required** for release builds to stream audio from Dropbox.

#### iOS
If building for iOS, ensure `ios/Runner/Info.plist` has App Transport Security:
```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

## Development Tips

### Hot Reload
- Press `r` in terminal for hot reload
- Press `R` for hot restart
- Press `q` to quit

### Debug Mode
- Look for debug banner in top-right
- Check console for error messages
- Use Flutter DevTools for debugging

### Performance
- Release builds are much faster than debug builds
- Test with release build:
  ```bash
  flutter run --release
  ```

## Known Limitations

1. **Dropbox Only**: Currently only supports Dropbox links
2. **MP3 Only**: Other audio formats may not work
3. **No Offline**: Requires internet to stream audio
4. **Single File**: Can only play one file at a time

## Next Steps

After testing, you can:
1. Build for production: `flutter build apk` or `flutter build ios`
2. Customize colors in `lib/main.dart`
3. Add more playback speeds if needed
4. Extend to support other cloud storage providers

## Publishing to Google Play Store

### 5. Build App Bundle for Release

```bash
flutter build appbundle --release
```

This creates an optimized `.aab` file at:
```
build/app/outputs/bundle/release/app-release.aab
```

### 6. Upload to Google Play Console

1. Go to [Google Play Console](https://play.google.com/console)
2. Select your app or create a new one
3. Navigate to **Production** → **Create new release**
4. Upload the `app-release.aab` file
5. Fill in release notes and details
6. Submit for review

**Note:** You need a Google Play Developer account ($25 one-time fee) to publish apps.
