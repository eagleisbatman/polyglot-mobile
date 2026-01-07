import 'package:flutter/material.dart';
import 'audio_waveform.dart';

/// Unified input bar with mic, camera, and attachment buttons
class ChatInputBar extends StatelessWidget {
  final bool isRecording;
  final bool isProcessing;
  final String recordingDuration;
  final VoidCallback onMicPressed;
  final VoidCallback onCameraPressed;
  final VoidCallback onAttachmentPressed;
  final VoidCallback? onCancelRecording;

  const ChatInputBar({
    super.key,
    required this.isRecording,
    required this.isProcessing,
    this.recordingDuration = '0:00',
    required this.onMicPressed,
    required this.onCameraPressed,
    required this.onAttachmentPressed,
    this.onCancelRecording,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: isRecording ? _buildRecordingState(theme) : _buildIdleState(theme),
    );
  }

  Widget _buildIdleState(ThemeData theme) {
    return Row(
      children: [
        // Attachment button
        _InputButton(
          icon: Icons.attach_file,
          onPressed: onAttachmentPressed,
          tooltip: 'Attach document',
        ),
        const SizedBox(width: 8),
        
        // Camera button
        _InputButton(
          icon: Icons.camera_alt_outlined,
          onPressed: onCameraPressed,
          tooltip: 'Take photo or video',
        ),
        
        const Spacer(),
        
        // Mic button (primary action)
        _MicButton(
          isRecording: false,
          isProcessing: isProcessing,
          onPressed: onMicPressed,
        ),
      ],
    );
  }

  Widget _buildRecordingState(ThemeData theme) {
    return Row(
      children: [
        // Cancel button
        TextButton.icon(
          onPressed: onCancelRecording,
          icon: const Icon(Icons.close, size: 20),
          label: const Text('Cancel'),
          style: TextButton.styleFrom(
            foregroundColor: theme.colorScheme.error,
          ),
        ),
        
        const Spacer(),
        
        // Waveform and duration
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AudioWaveform(
              isActive: true,
              color: theme.colorScheme.primary,
              height: 24,
              barCount: 5,
            ),
            const SizedBox(height: 4),
            Text(
              recordingDuration,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        
        const Spacer(),
        
        // Stop/Send button
        _MicButton(
          isRecording: true,
          isProcessing: false,
          onPressed: onMicPressed,
        ),
      ],
    );
  }
}

class _InputButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;

  const _InputButton({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Tooltip(
      message: tooltip,
      child: Material(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            child: Icon(
              icon,
              size: 22,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

class _MicButton extends StatelessWidget {
  final bool isRecording;
  final bool isProcessing;
  final VoidCallback onPressed;

  const _MicButton({
    required this.isRecording,
    required this.isProcessing,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: isProcessing ? null : onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: isRecording ? 56 : 52,
        height: isRecording ? 56 : 52,
        decoration: BoxDecoration(
          color: isRecording 
              ? theme.colorScheme.error 
              : theme.colorScheme.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: (isRecording 
                  ? theme.colorScheme.error 
                  : theme.colorScheme.primary
              ).withOpacity(0.3),
              blurRadius: isRecording ? 16 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: isProcessing
            ? Padding(
                padding: const EdgeInsets.all(16),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: theme.colorScheme.onPrimary,
                ),
              )
            : Icon(
                isRecording ? Icons.stop : Icons.mic,
                color: theme.colorScheme.onPrimary,
                size: isRecording ? 28 : 24,
              ),
      ),
    );
  }
}

