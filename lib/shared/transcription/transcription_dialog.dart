import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_recipes/providers/models/recipes/recipe_provider.dart';
import 'package:flutter_recipes/providers/models/user/user_provider.dart';
import 'package:flutter_recipes/services/business/ad_service.dart';
import 'package:flutter_recipes/services/firebase/cloud_functions_service.dart';
import 'package:flutter_recipes/services/firebase/firestore_service.dart';
import 'package:flutter_recipes/services/business/recipe_service.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';

class TranscriptionDialog extends StatefulWidget {
  @override
  _TranscriptionDialogState createState() => _TranscriptionDialogState();
}

class _TranscriptionDialogState extends State<TranscriptionDialog>
    with SingleTickerProviderStateMixin {
  bool _isRecording = false;
  bool _isTranscribing = false; // New state variable
  String _transcription = '';
  Timer? _timer;
  final record = AudioRecorder();
  late Stream<List<int>> stream;
  late AnimationController _animationController;
  final player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    try {
      if (await record.hasPermission()) {
        // Get the temporary directory
        Directory tempDir = await getTemporaryDirectory();
        String tempPath = '${tempDir.path}/audio.m4a';

        // Create the audio file
        File file = File(tempPath);
        await file.create();

        // Start recording
        await record.start(
          const RecordConfig(),
          path: tempPath,
        );

        bool isRecording = await record.isRecording();
        setState(() {
          _isRecording = isRecording;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error starting recording: $e')),
      );
    }
  }

  Future<void> _stopRecording() async {
    try {
      _timer?.cancel();
      await record.stop();

      setState(() {
        _isRecording = false;
        _isTranscribing = true; // Set transcribing to true when recording stops
      });

      // Get the temporary directory
      Directory tempDir = await getTemporaryDirectory();
      String tempPath = '${tempDir.path}/audio.m4a';

      // Read the tempPath file and convert to base64 audio bytes
      final file = File(tempPath);
      final bytes = await file.readAsBytes();
      final base64Audio = base64Encode(bytes);

      // Print the first 10 bytes
      print(base64Audio.substring(0, 10));

      _transcription = await transcribeAudio(base64Audio);
      setState(() {
        _isTranscribing =
            false; // Set transcribing to false when transcription is done
      });

      // If transcription is not empty, perform the send action
      if (_transcription.isNotEmpty) {
        RecipeService recipeService = RecipeService(
          firestoreService: FirestoreService(),
          userProvider: Provider.of<UserProvider>(context, listen: false),
          adService: Provider.of<AdService>(context, listen: false),
          recipeProvider: Provider.of<RecipeProvider>(context, listen: false),
        );
        recipeService.extractRecipeFromText(_transcription);
        Navigator.of(context).pop(); // Add this line
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error stopping recording: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Image.asset('assets/emojis/smiling-dog-wearing-chefs-hat.png'),
            Text(
              'You can speak your recipe aloud as if you were telling a friend.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Center(
              child: _isTranscribing
                  ? CircularProgressIndicator()
                  : _transcription.isEmpty
                      ? IconTheme(
                          data: IconThemeData(
                            size: 60,
                          ),
                          child: IconButton(
                            icon: _isRecording
                                ? const Icon(Icons.stop, color: Colors.red)
                                : Icon(Icons.mic,
                                    color:
                                        Theme.of(context).colorScheme.primary),
                            onPressed:
                                _isRecording ? _stopRecording : _startRecording,
                          ),
                        )
                      : Container(),
            ),
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
