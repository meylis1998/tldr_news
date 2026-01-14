# TLDR News

A Flutter app for staying updated with byte-sized tech news from the TLDR newsletter.

## Tech Stack

- **State Management:** flutter_bloc, hydrated_bloc
- **Dependency Injection:** get_it, injectable
- **Networking:** dio, xml, html
- **Navigation:** go_router
- **Storage:** shared_preferences, path_provider
- **UI:** flutter_screenutil, google_fonts, cached_network_image, shimmer

## Architecture

Clean Architecture with feature-based organization.

## Folder Structure

```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── constants/
│   ├── di/
│   ├── error/
│   ├── network/
│   ├── router/
│   ├── storage/
│   ├── theme/
│   └── utils/
├── shared/
│   └── widgets/
└── features/
    ├── feed/
    │   ├── domain/
    │   │   ├── entities/
    │   │   ├── repositories/
    │   │   └── usecases/
    │   ├── data/
    │   │   ├── models/
    │   │   ├── repositories/
    │   │   └── datasources/
    │   └── presentation/
    │       ├── bloc/
    │       ├── pages/
    │       └── widgets/
    ├── article_detail/
    │   └── presentation/
    │       ├── pages/
    │       └── widgets/
    ├── bookmarks/
    │   ├── domain/
    │   │   └── repositories/
    │   ├── data/
    │   │   ├── datasources/
    │   │   └── repositories/
    │   └── presentation/
    │       ├── bloc/
    │       └── pages/
    ├── search/
    │   └── presentation/
    │       ├── bloc/
    │       ├── pages/
    │       └── widgets/
    └── settings/
        └── presentation/
            ├── bloc/
            └── pages/
```

## Getting Started

```bash
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter run
```
