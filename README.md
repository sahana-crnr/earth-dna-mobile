# EarthDNA Mobile 👟🌍

[![Flutter CI/CD](https://github.com/sahana-crnr/earth-dna-mobile/actions/workflows/main.yml/badge.svg)](https://github.com/sahana-crnr/earth-dna-mobile/actions/workflows/main.yml)
[![Live Demo](https://img.shields.io/badge/Live%20Demo-GitHub%20Pages-22c55e?style=flat&logo=flutter)](https://sahana-crnr.github.io/earth-dna-mobile/)

**EarthDNA Mobile** is an AI-powered sustainable footwear lifecycle mobile application built with Flutter. It guides users through an intuitive 4-angle shoe scanning workflow to generate a verified **ShoeDNA Profile**, estimate resale/recycling value, and connect pairs with sustainable circular pathways.

---

## 🌐 Live Web Demo

You can try the live demo directly in your browser:
👉 **[Launch EarthDNA Mobile Demo](https://sahana-crnr.github.io/earth-dna-mobile/)**

> **Tip for evaluators:** For the best mobile experience on desktop, open Developer Tools (`F12` or `Cmd+Option+I`) and toggle Device Mode to **iPhone 14 / Pixel 7**.

---

## ✨ Key Features

- **4-Angle Guided Camera Flow**:
  - Step-by-step viewfinder instructions: *Top*, *Right*, *Left*, and *Sole/Bottom*.
  - Real-time confirmation feedback and dynamic badge counters.
  - Full-bleed thumbnail review slots with tap-to-retake support.
- **Shoe Completion & Exit Modals**:
  - Modal sheets with 2x2 multi-angle review, session finish, and save & exit flows.
- **My Shoes Collection Dashboard**:
  - Empty state with tailored brand empty graphics and CTAs.
  - Active shoe collection metrics: total pairs scanned and potential resale value.
  - Shoe condition badges (*C1 Like New*, *C2 Lightly Worn*, *C3 Heavily Worn*, *C4/C5 Recycle*).
- **ShoeDNA Profile**:
  - Detailed model specs, sustainability score, brand verification, and marketplace actions (Resell, Donate, Recycle).
- **Offline / Standalone Fallbacks**:
  - Seamless mock catalog and session fallback so client demos never fail due to network or backend latency.

---

## 🛠️ Architecture & Tech Stack

- **Framework**: Flutter (Dart 3.x, Channel `stable`)
- **State Management**: `Provider` (reactive `ScanProvider`, `ShoesProvider`, `AuthProvider`)
- **UI Design System**: Figma-spec typography (`Instrument Sans`), custom color tokens, elevation models, and custom SVG assets
- **Networking**: Dio-based REST client with interceptors and offline preview fallback
- **CI/CD**: GitHub Actions (automated code quality linter, widget testing, and GitHub Pages release deployment)

---

## 🚀 Running Locally

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (`>= 3.24.0` / Dart `^3.13.7`)
- Chrome or Edge for Web / Android Studio for Emulator

### Setup & Launch
```bash
# 1. Clone repository
git clone https://github.com/sahana-crnr/earth-dna-mobile.git
cd earth-dna-mobile

# 2. Install dependencies
flutter pub get

# 3. Run on Chrome (Web)
flutter run -d chrome

# 4. Run on connected mobile device or emulator
flutter run
```

### Running Tests & Code Quality
```bash
# Run static analysis
flutter analyze

# Run unit & widget test suite
flutter test
```
