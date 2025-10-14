// lib/widgets/loading_overlay.dart
import 'package:flutter/material.dart';

class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final Color overlayColor;
  final Color progressColor;
  final String? message;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.overlayColor = Colors.black26,
    this.progressColor = Colors.white,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: overlayColor,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                  ),
                  if (message != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Text(
                        message!,
                        style: TextStyle(
                          color: progressColor,
                          fontSize: 16.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
