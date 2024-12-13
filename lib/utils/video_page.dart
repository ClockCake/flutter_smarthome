import 'package:flutter/material.dart';
import 'package:flutter_smarthome/network/api_manager.dart';
import 'package:video_player/video_player.dart';

class VideoPage extends StatefulWidget {
  final String videoId;
  const VideoPage({Key? key, required this.videoId}) : super(key: key);

  @override
  State<VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  VideoPlayerController? _controller;
  bool _initialized = false;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _getVideoUrl();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _getVideoUrl() async {
    try {
      final apiManager = ApiManager();
      final response = await apiManager.get(
        "/api/home/video",
        queryParameters: {"id": widget.videoId},
      );
      if (response != null && response['resourceInfo'] != null && mounted) {
        final String videoUrl = response['resourceInfo'];
        _controller = VideoPlayerController.network(videoUrl)
          ..initialize().then((_) {
            setState(() {
              _initialized = true;
            });
            _controller?.setLooping(true);
            _controller?.play();
          }).catchError((error) {
            print('视频初始化失败: $error');
            setState(() {
              _error = true;
            });
          });
      } else {
        setState(() {
          _error = true;
        });
      }
    } catch (e) {
      print('获取视频 URL 失败: $e');
      setState(() {
        _error = true;
      });
    }
  }

  Widget _buildPlayer() {
    if (_error) {
      return const Center(child: Text('视频加载失败'));
    }
    if (_initialized && _controller != null) {
      return AspectRatio(
        aspectRatio: _controller!.value.aspectRatio,
        child: VideoPlayer(_controller!),
      );
    }
    return const Center(child: CircularProgressIndicator());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text('视频播放', style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(child: _buildPlayer()),
          if (_initialized && _controller != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(
                    _controller!.value.isPlaying ? Icons.pause : Icons.play_arrow
                  ),
                  onPressed: () {
                    setState(() {
                      _controller!.value.isPlaying 
                        ? _controller!.pause() 
                        : _controller!.play();
                    });
                  },
                ),
              ],
            ),
        ],
      ),
    );
  }
}