# Scan2PDF

A fast, lightweight mobile app that allows users to scan documents using their camera, auto-enhance and crop images, convert them into PDF, and share/export easily.

**"Scan -> Clean -> Convert -> Share in seconds"**

## Features

### Core Features
- **Camera Scan**: Capture documents using camera with flash toggle and multi-page scan support
- **Auto Crop & Enhance**: Image filters (B&W, Grayscale, Color Enhance, High Contrast), brightness/contrast adjustment, rotation
- **PDF Creation**: Convert scanned images to PDF with page size options (A4, Letter, Legal), drag & reorder pages
- **Export & Share**: Share PDFs via WhatsApp, Email, Drive, or print directly
- **Document Manager**: List, search, rename, and delete saved PDFs

### Premium Features
- No advertisements
- No watermark on PDFs
- Advanced image filters
- Password-protected PDFs
- High-quality export
- Unlimited scans

## Tech Stack

- **Framework**: Flutter (Dart)
- **State Management**: Provider
- **PDF Generation**: `pdf` package
- **Image Processing**: `image` package
- **Camera**: `image_picker`
- **Sharing**: `share_plus`
- **PDF Preview**: `printing`
- **Storage**: `shared_preferences` + local file system

## Project Structure

```
lib/
  main.dart                    # App entry point
  app.dart                     # App widget with routing
  models/
    document.dart              # ScannedDocument model
    scan_page.dart             # ScanPage model
  providers/
    app_state_provider.dart    # App state (PIN lock, nav)
    document_provider.dart     # Document management
    premium_provider.dart      # Premium/freemium state
  screens/
    splash_screen.dart         # Animated splash screen
    home_screen.dart           # Home with quick actions & recent docs
    camera_screen.dart         # Camera/gallery capture
    crop_edit_screen.dart      # Image editing & filters
    pdf_preview_screen.dart    # PDF preview & save
    document_list_screen.dart  # Document manager
    share_screen.dart          # Share/export/print
    profile_screen.dart        # Profile, premium, settings
    pin_lock_screen.dart       # PIN lock screen
  services/
    image_processing_service.dart  # Image filters & transforms
    pdf_service.dart               # PDF generation
    share_service.dart             # File sharing
    storage_service.dart           # Local file storage
  theme/
    app_theme.dart             # Material 3 theme
  utils/
    constants.dart             # App constants
  widgets/
    ad_banner.dart             # Ad banner placeholder
    document_card.dart         # Document list item
    premium_badge.dart         # Premium badge widget
```

## Getting Started

### Prerequisites
- Flutter SDK (3.11+)
- Android Studio / Xcode

### Setup
```bash
flutter pub get
flutter run
```

### Build
```bash
# Android APK
flutter build apk --release

# iOS
flutter build ios --release
```

## Monetization

### Free Tier
- All core scanning features
- Basic filters
- Ads enabled
- Watermark on PDFs

### Premium Pricing
- Monthly: ₹99/month
- Yearly: ₹499/year (Best Value)
- Lifetime: ₹799 one-time

## App Screens

1. **Splash Screen** - Animated brand intro
2. **Home Screen** - Quick actions + recent documents
3. **Camera Screen** - Capture/import images
4. **Crop/Edit Screen** - Filters, brightness, contrast, rotation
5. **PDF Preview Screen** - Reorder pages, set options, save
6. **Document List Screen** - Search, rename, delete documents
7. **Share Screen** - PDF preview, share, print
8. **Profile Screen** - Premium upgrade, stats, PIN lock, settings

## Future Roadmap

- OCR (text extraction)
- AI auto-summary
- Digital signature
- Cloud sync & backup
- Google AdMob integration
- In-app purchase integration
