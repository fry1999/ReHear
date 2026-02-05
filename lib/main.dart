import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:async';

void main() {
  runApp(const KikuApp());
}

class KikuApp extends StatelessWidget {
  const KikuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kiku',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      home: const AudioPlayerScreen(),
    );
  }
}

class AudioPlayerScreen extends StatefulWidget {
  const AudioPlayerScreen({super.key});

  @override
  State<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen> {
  final TextEditingController _urlController = TextEditingController();
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  // Playback state
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _isPlaying = false;
  double _speed = 1.0;
  
  // A-B Loop state
  Duration? _pointA;
  Duration? _pointB;
  
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<Duration?>? _durationSubscription;
  StreamSubscription<PlayerState>? _playerStateSubscription;

  @override
  void initState() {
    super.initState();
    _initAudioPlayer();
  }

  void _initAudioPlayer() {
    // Listen to position changes
    _positionSubscription = _audioPlayer.positionStream.listen((position) {
      setState(() {
        _position = position;
      });
      
      // A-B Loop logic: When position reaches or exceeds point B, jump back to point A
      if (_pointA != null && _pointB != null) {
        if (_position >= _pointB!) {
          _audioPlayer.seek(_pointA!);
        }
      }
    });

    // Listen to duration changes
    _durationSubscription = _audioPlayer.durationStream.listen((duration) {
      setState(() {
        _duration = duration ?? Duration.zero;
      });
    });

    // Listen to player state changes
    _playerStateSubscription = _audioPlayer.playerStateStream.listen((state) {
      setState(() {
        _isPlaying = state.playing;
      });
    });
  }

  /// Converts Dropbox shared link to direct playable URL
  /// Changes dl=0 to raw=1 or dl=1 (both work for direct access)
  String _convertDropboxUrl(String url) {
    if (url.contains('dropbox.com')) {
      // Replace dl=0 with raw=1 for direct download
      return url.replaceAll('dl=0', 'raw=1').replaceAll('dl=1', 'raw=1');
    }
    return url;
  }

  Future<void> _loadAudio() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      _showSnackBar('Please enter a Dropbox link');
      return;
    }

    try {
      final directUrl = _convertDropboxUrl(url);
      await _audioPlayer.setUrl(directUrl);
      _showSnackBar('Audio loaded successfully');
      
      // Reset A-B points when loading new audio
      setState(() {
        _pointA = null;
        _pointB = null;
      });
    } catch (e) {
      _showSnackBar('Error loading audio: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  Future<void> _togglePlayPause() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play();
    }
  }

  Future<void> _skipBackward() async {
    final newPosition = _position - const Duration(seconds: 5);
    await _audioPlayer.seek(newPosition < Duration.zero ? Duration.zero : newPosition);
  }

  Future<void> _skipForward() async {
    final newPosition = _position + const Duration(seconds: 5);
    await _audioPlayer.seek(newPosition > _duration ? _duration : newPosition);
  }

  Future<void> _setSpeed(double speed) async {
    await _audioPlayer.setSpeed(speed);
    setState(() {
      _speed = speed;
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _playerStateSubscription?.cancel();
    _audioPlayer.dispose();
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // SOURCE section
                Text(
                  'SOURCE',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                
                // URL Input field
                TextField(
                  controller: _urlController,
                  decoration: InputDecoration(
                    hintText: 'Paste Dropbox Link...',
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.link, color: colorScheme.primary),
                      onPressed: _loadAudio,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                  ),
                  onSubmitted: (_) => _loadAudio(),
                ),
                
                const SizedBox(height: 48),
                
                // Time display
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _formatDuration(_position),
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        ' / ',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w300,
                          color: colorScheme.onSurface.withValues(alpha: 0.3),
                        ),
                      ),
                      Text(
                        _formatDuration(_duration),
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w300,
                          color: colorScheme.onSurface.withValues(alpha: 0.3),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Waveform visualization with A-B markers
                _buildWaveformWithMarkers(colorScheme),
                
                const SizedBox(height: 48),
                
                // Playback controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Backward button
                    _buildControlButton(
                      icon: Icons.replay_5,
                      label: '-5s',
                      onPressed: _skipBackward,
                      colorScheme: colorScheme,
                    ),
                    
                    const SizedBox(width: 32),
                    
                    // Play/Pause button
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.primary.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: Icon(
                          _isPlaying ? Icons.pause : Icons.play_arrow,
                          size: 40,
                          color: Colors.white,
                        ),
                        onPressed: _togglePlayPause,
                      ),
                    ),
                    
                    const SizedBox(width: 32),
                    
                    // Forward button
                    _buildControlButton(
                      icon: Icons.forward_5,
                      label: '+5s',
                      onPressed: _skipForward,
                      colorScheme: colorScheme,
                    ),
                  ],
                ),
                
                const SizedBox(height: 48),
                
                // Playback speed section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'PLAYBACK SPEED',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface.withValues(alpha: 0.5),
                        letterSpacing: 1.2,
                      ),
                    ),
                    Text(
                      'Active: ${_speed}x',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Speed buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSpeedButton(0.5, colorScheme),
                    _buildSpeedButton(0.75, colorScheme),
                    _buildSpeedButton(1.0, colorScheme),
                    _buildSpeedButton(1.25, colorScheme),
                    _buildSpeedButton(1.5, colorScheme),
                  ],
                ),
                
                const SizedBox(height: 64),
                
                // Footer
                Center(
                  child: Text(
                    'PRECISION AUDIO',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface.withValues(alpha: 0.2),
                      letterSpacing: 2.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required ColorScheme colorScheme,
  }) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(icon, size: 28),
            color: colorScheme.onSurface.withValues(alpha: 0.7),
            onPressed: onPressed,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildSpeedButton(double speed, ColorScheme colorScheme) {
    final isActive = (_speed - speed).abs() < 0.01;
    
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Material(
          color: isActive ? colorScheme.primary : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: () => _setSpeed(speed),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              alignment: Alignment.center,
              child: Text(
                '${speed}x',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isActive ? Colors.white : colorScheme.onSurface,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWaveformWithMarkers(ColorScheme colorScheme) {
    return Column(
      children: [
        // Waveform bars
        SizedBox(
          height: 120,
          child: _buildWaveform(colorScheme),
        ),
        
        const SizedBox(height: 8),
        
        // A-B Marker timeline
        SizedBox(
          height: 60,
          child: _buildABMarkerTimeline(colorScheme),
        ),
      ],
    );
  }

  Widget _buildWaveform(ColorScheme colorScheme) {
    // Generate simple waveform bars (decorative)
    final bars = List.generate(24, (index) {
      // Create varied heights for visual interest
      final heights = [0.3, 0.4, 0.6, 0.8, 0.5, 0.9, 0.7, 0.4, 0.95, 0.6, 0.5, 0.75, 
                      0.8, 0.65, 0.4, 0.55, 0.7, 0.45, 0.6, 0.5, 0.4, 0.5, 0.6, 0.45];
      return heights[index];
    });

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(bars.length, (index) {
        final progress = _duration.inMilliseconds > 0
            ? index / bars.length
            : 0.0;
        final currentProgress = _duration.inMilliseconds > 0
            ? _position.inMilliseconds / _duration.inMilliseconds
            : 0.0;
        
        // Highlight bars within A-B range
        final barProgress = index / bars.length;
        bool isInABRange = false;
        if (_pointA != null && _pointB != null && _duration.inMilliseconds > 0) {
          final aProgress = _pointA!.inMilliseconds / _duration.inMilliseconds;
          final bProgress = _pointB!.inMilliseconds / _duration.inMilliseconds;
          isInABRange = barProgress >= aProgress && barProgress <= bProgress;
        }
        
        final isPassed = progress <= currentProgress;
        
        return Expanded(
          child: Container(
            height: 120 * bars[index],
            margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: isInABRange
                    ? colorScheme.primary.withValues(alpha: 0.7)
                    : isPassed
                        ? colorScheme.primary.withValues(alpha: 0.4)
                        : colorScheme.onSurface.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(2),
              ),
          ),
        );
      }),
    );
  }

  Widget _buildABMarkerTimeline(ColorScheme colorScheme) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        
        // Calculate positions for A and B markers
        double? aPosition;
        double? bPosition;
        
        if (_duration.inMilliseconds > 0) {
          if (_pointA != null) {
            aPosition = (width - 40) * (_pointA!.inMilliseconds / _duration.inMilliseconds);
          }
          if (_pointB != null) {
            bPosition = (width - 40) * (_pointB!.inMilliseconds / _duration.inMilliseconds);
          }
        }
        
        return GestureDetector(
          onTapDown: (details) {
            // Set A and B points by tapping on the timeline
            if (_duration.inMilliseconds == 0) return;
            
            final tapPosition = details.localPosition.dx;
            final progress = (tapPosition - 20) / (width - 40);
            final tappedTime = Duration(
              milliseconds: (progress * _duration.inMilliseconds).round(),
            );
            
            setState(() {
              if (_pointA == null) {
                _pointA = tappedTime;
              } else if (_pointB == null) {
                _pointB = tappedTime;
                // Ensure A is before B
                if (_pointA!.inMilliseconds > _pointB!.inMilliseconds) {
                  final temp = _pointA;
                  _pointA = _pointB;
                  _pointB = temp;
                }
              } else {
                // Reset and start over
                _pointA = tappedTime;
                _pointB = null;
              }
            });
          },
          child: Stack(
            children: [
              // Timeline track
              Positioned(
                left: 20,
                right: 20,
                top: 25,
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: colorScheme.onSurface.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
              ),
              
              // Active section between A and B
              if (aPosition != null && bPosition != null)
                Positioned(
                  left: 20 + aPosition,
                  top: 25,
                  child: Container(
                    width: bPosition - aPosition,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              
              // Current position indicator
              if (_duration.inMilliseconds > 0)
                Positioned(
                  left: 20 + (width - 40) * (_position.inMilliseconds / _duration.inMilliseconds),
                  top: 20,
                  child: Container(
                    width: 2,
                    height: 14,
                    color: colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                ),
              
              // Marker A
              if (aPosition != null)
                Positioned(
                  left: 20 + aPosition - 16,
                  top: 9,
                  child: GestureDetector(
                    onPanUpdate: (details) {
                      if (_duration.inMilliseconds == 0) return;
                      setState(() {
                        final newPosition = (aPosition! + details.delta.dx).clamp(0.0, width - 40);
                        _pointA = Duration(
                          milliseconds: (newPosition / (width - 40) * _duration.inMilliseconds).round(),
                        );
                      });
                    },
                    child: Column(
                      children: [
                        Text(
                          'A',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: colorScheme.primary, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatDuration(_pointA!),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              
              // Marker B
              if (bPosition != null)
                Positioned(
                  left: 20 + bPosition - 16,
                  top: 9,
                  child: GestureDetector(
                    onPanUpdate: (details) {
                      if (_duration.inMilliseconds == 0) return;
                      setState(() {
                        final newPosition = (bPosition! + details.delta.dx).clamp(0.0, width - 40);
                        _pointB = Duration(
                          milliseconds: (newPosition / (width - 40) * _duration.inMilliseconds).round(),
                        );
                      });
                    },
                    child: Column(
                      children: [
                        Text(
                          'B',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: colorScheme.primary, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatDuration(_pointB!),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
