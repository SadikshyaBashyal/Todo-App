# Todo App

A modern todo application built with Flutter that supports multiple platforms including Android, iOS, Web, and Desktop.

## Features

- **Cross-Platform Support**: Works on Android, iOS, Web, and Desktop
- **User Authentication**: Sign up and login with profile photos
- **Image Handling**: 
  - **Web**: Gallery selection with base64 storage
  - **Mobile/Desktop**: Gallery and camera support with file storage
- **Calendar Integration**: View and manage todos with calendar
- **Daily Routine Management**: Track daily tasks and routines
- **Settings & Profile**: User profile management with login streak tracking

## Platform-Specific Features

### Web
- Gallery image selection only (camera not supported)
- Images stored as base64 in local storage
- Responsive design for browser compatibility

### Mobile (Android/iOS)
- Gallery and camera image selection
- File-based image storage
- Native platform permissions handling

### Desktop (Windows/macOS/Linux)
- Gallery and camera image selection
- File-based image storage
- Native desktop integration

## Getting Started

1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Run `flutter run` to start the app

For web: `flutter run -d chrome`
For desktop: `flutter run -d windows` (or macos/linux)

## Dependencies

- `flutter`: Core framework
- `provider`: State management
- `shared_preferences`: Local data storage
- `image_picker`: Cross-platform image selection
- `uuid`: Unique identifier generation
- `intl`: Internationalization support

## Architecture

The app uses a clean architecture with:
- **Screens**: UI components for different app sections
- **Widgets**: Reusable UI components
- **Providers**: State management for todos and user data
- **Helpers**: Utility classes for cross-platform functionality
- **Models**: Data structures for todos and user information

## Image Handling

The app includes a robust `ImageHelper` class that handles:
- Platform detection (web vs mobile/desktop)
- Image encoding/decoding for storage
- Fallback handling for missing images
- Consistent UI across platforms
