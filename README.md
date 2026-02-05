# Kiku (ReHear) - Minimal Language-Learning Audio Player

A clean, distraction-free Flutter audio player designed specifically for language learning with A-B loop functionality.

## Features

✅ **Dropbox Integration**: Paste any Dropbox MP3 link and play instantly  
✅ **A-B Loop Playback**: Set two markers (A and B) to repeat specific sections  
✅ **Playback Speed Control**: 0.5x, 0.75x, 1.0x, 1.25x, 1.5x  
✅ **Quick Skip**: ±5 second forward/backward buttons  
✅ **Waveform Visualization**: Visual representation of audio with loop highlighting  
✅ **Dark Mode Support**: Automatically adapts to system theme  

## Getting Started

### Prerequisites

- Flutter SDK 3.0.0 or higher
- Dart 3.0.0 or higher

### Installation

1. Clone the repository:
```bash
git clone <your-repo-url>
cd ReHear
```

2. Get dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

## How to Use

### Loading Audio

1. Get a Dropbox shared link to an MP3 file
2. Paste the link in the "SOURCE" input field
3. Press the link icon or Enter to load the audio

**Note**: The app automatically converts Dropbox sharing links (`dl=0`) to direct download links (`raw=1`).

### A-B Loop Feature

The A-B loop allows you to repeat specific sections of audio - perfect for language learning:

1. **Set Point A**: Tap on the timeline where you want the loop to start
2. **Set Point B**: Tap again where you want the loop to end
3. **Loop Active**: The audio will automatically jump back to A when it reaches B
4. **Reset Loop**: Tap on the timeline again to set new points

You can also **drag the markers** to fine-tune the loop positions.

### Playback Controls

- **Play/Pause**: Large center button
- **Skip Backward**: -5s button (left)
- **Skip Forward**: +5s button (right)
- **Speed Control**: Tap any speed button at the bottom (0.5x to 1.5x)

## Technical Details

### Dependencies

- **just_audio** (^0.9.36): Audio playback engine
- **http** (^1.1.0): HTTP requests for fetching audio

### Architecture

- Single-screen app using `StatefulWidget`
- Audio lifecycle managed with `just_audio` package
- Real-time position tracking via streams
- A-B loop implemented with position monitoring

### Key Implementation Notes

**Dropbox URL Conversion**:
```dart
// Converts: https://www.dropbox.com/s/xxx/file.mp3?dl=0
// To:       https://www.dropbox.com/s/xxx/file.mp3?raw=1
```

**A-B Loop Logic**:
```dart
// Continuously monitors position and seeks back when B is reached
if (_position >= _pointB) {
  _audioPlayer.seek(_pointA);
}
```

## Project Structure

```
lib/
  └── main.dart           # Complete app implementation
pubspec.yaml             # Dependencies
README.md               # This file
```

## Constraints & Design Decisions

- **No backend**: Everything runs locally
- **No authentication**: Open access
- **No history/playlist**: Focus on single audio file
- **No multiple screens**: Single-page experience
- **Material 3**: Modern, clean UI design
- **System theme**: Respects user's dark/light mode preference

## Future Enhancements (Not Implemented)

These features are intentionally excluded to maintain simplicity:
- ❌ User profiles
- ❌ Audio history
- ❌ Playlists
- ❌ Note-taking
- ❌ Analytics
- ❌ Cloud sync

## License

This project is created for educational purposes.
