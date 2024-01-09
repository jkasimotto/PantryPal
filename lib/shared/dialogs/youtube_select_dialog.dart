// lib/screens/home_screen/youtube_select_dialog.dart
import 'package:flutter/material.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class YoutubeSelectDialog extends StatefulWidget {
  final Function(String) onUrlSelected;

  const YoutubeSelectDialog({Key? key, required this.onUrlSelected})
      : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _YoutubeSelectDialogState createState() => _YoutubeSelectDialogState();
}

class _YoutubeSelectDialogState extends State<YoutubeSelectDialog> {
  final _controller = TextEditingController();
  String? _thumbnailUrl;
  String? _videoTitle;
  bool isYoutubeUrl = false;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Enter URL'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            decoration: const InputDecoration(
              hintText: 'YouTube URL',
            ),
            onChanged: (value) async {
              isYoutubeUrl =
                  value.contains('youtube') || value.contains('youtu.be');

              setState(() {
                _thumbnailUrl = null;
                _videoTitle = null;
              });

              if (isYoutubeUrl) {
                setState(() {
                  isLoading = true;
                });

                var yt = YoutubeExplode();
                var video = await yt.videos.get(value);

                setState(() {
                  _thumbnailUrl = video.thumbnails.highResUrl;
                  _videoTitle = video.title;
                  isLoading = false;
                });
              }
            },
          ),
          if (isLoading) const CircularProgressIndicator(),
          if (_thumbnailUrl != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Image.network(_thumbnailUrl!),
            ),
          if (_videoTitle != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(_videoTitle!),
            ),
        ],
      ),
      actions: [
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        if (_thumbnailUrl != null)
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              widget.onUrlSelected(_controller.text);
              Navigator.of(context).pop();
            },
          ),
      ],
    );
  }
}
