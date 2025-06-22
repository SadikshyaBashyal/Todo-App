import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

class ImageHelper {
  /// Converts image data to a format suitable for storage based on platform
  static String encodeImageForStorage(dynamic imageData) {
    if (kIsWeb) {
      if (imageData is Uint8List) {
        return 'data:image/jpeg;base64,${base64Encode(imageData)}';
      }
    } else {
      if (imageData is File) {
        return imageData.path;
      }
    }
    return '';
  }

  /// Decodes stored image data and returns a widget
  static Widget buildImageWidget(String storedImageData, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Widget? fallbackWidget,
  }) {
    if (storedImageData.isEmpty) {
      return fallbackWidget ?? const Icon(
        Icons.person,
        size: 40,
        color: Colors.white,
      );
    }

    if (kIsWeb) {
      // Handle web image (base64)
      if (storedImageData.startsWith('data:image')) {
        try {
          final base64Data = storedImageData.split(',')[1];
          final bytes = base64Decode(base64Data);
          return Image.memory(
            bytes,
            fit: fit,
            width: width,
            height: height,
          );
        } catch (e) {
          return fallbackWidget ?? const Icon(
            Icons.person,
            size: 40,
            color: Colors.white,
          );
        }
      }
    } else {
      // Handle mobile/desktop image (file path)
      try {
        return Image.file(
          File(storedImageData),
          fit: fit,
          width: width,
          height: height,
        );
      } catch (e) {
        return fallbackWidget ?? const Icon(
          Icons.person,
          size: 40,
          color: Colors.white,
        );
      }
    }

    return fallbackWidget ?? const Icon(
      Icons.person,
      size: 40,
      color: Colors.white,
    );
  }

  /// Checks if the current platform supports camera
  static bool supportsCamera() {
    return !kIsWeb;
  }

  /// Gets appropriate text for image picker based on platform
  static String getImagePickerText(bool hasImage) {
    if (kIsWeb) {
      return hasImage ? 'Photo selected' : 'Tap to add photo (Gallery only)';
    } else {
      return hasImage ? 'Photo selected' : 'Tap to add photo (Gallery/Camera)';
    }
  }
} 