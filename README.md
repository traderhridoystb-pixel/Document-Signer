# Signer - Document Signer

<p align="center">
  <img src="Signer/Resources/Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png" width="120" alt="Signer App Icon" />
</p>

<p align="center">
  <strong>E-Sign on PDF & Documents</strong><br>
  Sign documents. Anytime. Anywhere.
</p>

---

## Overview

**Signer** is a premium iOS document signing application built entirely with **Swift** and **SwiftUI**. It allows users to electronically sign PDFs and documents directly on their iPhone or iPad with a professional, intuitive experience.

## Features

### Core Signing Features
- **Draw Signatures** - Create hand-drawn signatures with customizable colors and stroke widths
- **Type Signatures** - Generate signatures from text with multiple font styles
- **Add Stamps** - 10+ professional stamp templates (Approved, Rejected, Draft, Confidential, etc.)
- **Text Fields** - Add custom text annotations to any document
- **Date Fields** - Insert formatted date stamps
- **Checkboxes** - Add interactive checkbox marks
- **Initials** - Create and place initials on documents
- **Image Insertion** - Add images to documents

### Document Management
- **Import PDFs** - Import documents from Files, iCloud, or other apps
- **Create Blank Documents** - Start with a blank page for notes or signing
- **Document Organization** - Search, rename, and manage your document library
- **Export & Share** - Share signed documents via email, AirDrop, or any app

### Premium Experience
- **Splash Screen** - Animated, branded launch experience
- **Language Selection** - Auto-detects device language with 20+ language options
- **Onboarding Flow** - 4-screen guided introduction with smooth animations
- **Premium Paywall** - StoreKit 2 integration with Yearly (3-day free trial) and Lifetime plans
- **Dark Mode** - Full dark mode support with adaptive color system

### Settings
- Restore Purchase
- Manage Subscription
- Language Selection
- Privacy Policy
- Terms & Conditions
- Support Contact

## Tech Stack

- **Language**: Swift 5.9+
- **UI Framework**: SwiftUI
- **Minimum iOS**: 17.0
- **PDF Processing**: PDFKit
- **In-App Purchases**: RevenueCat SDK (StoreKit 2 backend)
- **Paywalls**: RevenueCat Paywalls (remote-configurable)
- **Customer Center**: RevenueCat Customer Center (subscription management)
- **Architecture**: MVVM with Observable

## Project Structure

```
Signer/
├── App/
│   └── SignerApp.swift              # App entry point
├── Models/
│   ├── Document.swift               # Document & annotation models
│   └── Signature.swift              # Signature & stamp models
├── Views/
│   ├── Splash/                      # Splash screen
│   ├── Language/                    # Language selection
│   ├── Onboarding/                  # Onboarding flow
│   ├── Paywall/                     # Subscription paywall
│   ├── Home/                        # Main tab view & document list
│   ├── DocumentViewer/              # PDF viewer & annotation
│   ├── Signing/                     # Signature creation & stamps
│   ├── Settings/                    # App settings
│   └── Components/                  # Reusable UI components
├── ViewModels/
│   └── AppFlowViewModel.swift       # App navigation flow
├── Services/
│   ├── RevenueCatManager.swift      # RevenueCat SDK integration
│   ├── StoreKitManager.swift        # Legacy compatibility wrapper
│   ├── DocumentManager.swift        # Document CRUD operations
│   └── LocalizationManager.swift    # Multi-language support
├── Utilities/
│   ├── Theme.swift                  # Design system (colors, typography, spacing)
│   ├── Constants.swift              # App constants & supported languages
│   └── Extensions/
│       └── ViewExtensions.swift     # SwiftUI view modifiers & haptics
└── Resources/
    ├── Assets.xcassets/             # App icon, colors, images
    └── Products.storekit            # StoreKit configuration
```

## Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-username/Signer.git
   ```

2. **Open in Xcode**
   - Open the project in Xcode 15+
   - Select your development team in Signing & Capabilities
   - Set the bundle identifier

3. **Configure RevenueCat**
   - The SDK is pre-configured with a test API key in `RevenueCatManager.swift`
   - Replace `RevenueCatConfig.apiKey` with your production API key
   - Configure your products and entitlements in the [RevenueCat Dashboard](https://app.revenuecat.com)
   - Set up the "Signer Pro" entitlement with your Yearly and Lifetime products
   - Configure a Paywall template in the dashboard for remote paywall support
   - The project includes a `Products.storekit` file for local testing

4. **Build & Run**
   - Select a simulator or device
   - Build and run (Cmd + R)

## App Flow

```
Splash Screen → Language Selection → Onboarding (4 screens) → Paywall → Home
```

## Supported Languages

English, Spanish, French, German, Portuguese, Arabic, Hindi, Bengali, Chinese, Japanese, Korean, Turkish, Russian, Italian, Dutch, Thai, Vietnamese, Indonesian, Malay, Polish

## Design System

The app uses a comprehensive design system defined in `Theme.swift`:
- **Colors**: Primary blue (#2563EB), Accent emerald (#10B981), Premium gradients
- **Typography**: SF Pro Rounded for headings, SF Pro for body text
- **Spacing**: Consistent 4px-based spacing scale
- **Animations**: Spring-based animations with haptic feedback

## Contact

**Support Email**: developer.nasar416@gmail.com

## License

Copyright (c) 2025 Signer. All rights reserved.
