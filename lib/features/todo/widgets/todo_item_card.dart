import 'dart:io';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:life_hub/core/constants/app_colors.dart';
import 'package:life_hub/data/models/todo_model.dart';
import 'package:intl/intl.dart';

class TodoItemCard extends StatefulWidget {
  final TodoModel todo;
  final VoidCallback? onDone;
  final VoidCallback? onSkip;
  final VoidCallback? onRestore;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;

  const TodoItemCard({
    super.key,
    required this.todo,
    this.onDone,
    this.onSkip,
    this.onRestore,
    this.onDelete,
    this.onEdit,
  });

  @override
  State<TodoItemCard> createState() => _TodoItemCardState();
}

class _TodoItemCardState extends State<TodoItemCard> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _showFullImage = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      }
    });

    _audioPlayer.onDurationChanged.listen((duration) {
      if (mounted) {
        setState(() {
          _duration = duration;
        });
      }
    });

    _audioPlayer.onPositionChanged.listen((position) {
      if (mounted) {
        setState(() {
          _position = position;
        });
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.1),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        widget.todo.content,
                        style: TextStyle(
                          color: AppColors.getTextColor(context),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          decoration: widget.todo.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    _buildPriorityBadge(widget.todo.priority),
                  ],
                ),
                if (widget.todo.endTime != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: AppColors.getSubtitleColor(context),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Due: ${DateFormat('MMM dd, yyyy hh:mm a').format(widget.todo.endTime!)}',
                        style: TextStyle(
                          color: AppColors.getSubtitleColor(context),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
                if (widget.todo.imagePath != null) ...[
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _showFullImage = !_showFullImage;
                      });
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(widget.todo.imagePath!),
                        height: _showFullImage ? null : 150,
                        width: double.infinity,
                        fit: _showFullImage ? BoxFit.contain : BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 150,
                            color: Colors.grey.withOpacity(0.2),
                            child: const Center(
                              child: Icon(Icons.broken_image, size: 40),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
                if (widget.todo.voicePath != null) ...[
                  const SizedBox(height: 12),
                  _buildAudioPlayer(context, isDark),
                ],
              ],
            ),
          ),
          _buildActions(context, isDark),
        ],
      ),
    );
  }

  Widget _buildPriorityBadge(String priority) {
    Color color;
    switch (priority) {
      case 'high':
        color = AppColors.highPriority;
        break;
      case 'medium':
        color = AppColors.mediumPriority;
        break;
      default:
        color = AppColors.lowPriority;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        priority.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildAudioPlayer(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.purpleGradientStart.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: _togglePlayPause,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: AppColors.purpleGradientStart,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Voice Recording',
                      style: TextStyle(
                        color: AppColors.getTextColor(context),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_formatDuration(_position)} / ${_formatDuration(_duration)}',
                      style: TextStyle(
                        color: AppColors.getSubtitleColor(context),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_duration.inSeconds > 0) ...[
            const SizedBox(height: 8),
            SliderTheme(
              data: SliderThemeData(
                trackHeight: 2,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
              ),
              child: Slider(
                value: _position.inSeconds.toDouble(),
                max: _duration.inSeconds.toDouble(),
                activeColor: AppColors.purpleGradientStart,
                inactiveColor: AppColors.purpleGradientStart.withOpacity(0.3),
                onChanged: (value) async {
                  await _audioPlayer.seek(Duration(seconds: value.toInt()));
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  Future<void> _togglePlayPause() async {
    if (widget.todo.voicePath == null) return;

    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.play(DeviceFileSource(widget.todo.voicePath!));
      }
    } catch (e) {
      print('Error playing audio: $e');
    }
  }

  Widget _buildActions(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (widget.onEdit != null && widget.onDone != null) ...[
            _buildActionButton(
              label: 'Edit',
              color: AppColors.purpleGradientStart,
              onTap: widget.onEdit,
            ),
            const SizedBox(width: 20),
          ],
          if (widget.onDone != null) ...[
            _buildActionButton(
              label: 'Done',
              color: AppColors.completed,
              onTap: widget.onDone,
            ),
            const SizedBox(width: 20),
          ],
          if (widget.onSkip != null) ...[
            _buildActionButton(
              label: 'Skip',
              color: AppColors.mediumPriority,
              onTap: widget.onSkip,
            ),
            const SizedBox(width: 20),
          ],
          if (widget.onRestore != null) ...[
            _buildActionButton(
              label: 'Restore',
              color: AppColors.pending,
              onTap: widget.onRestore,
            ),
            const SizedBox(width: 20),
          ],
          if (widget.onDelete != null) ...[
            _buildActionButton(
              label: 'Delete',
              color: AppColors.highPriority,
              onTap: widget.onDelete,
            ),
            const SizedBox(width: 10),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}