# Valora

> **Waste less. Live better.**  
> *Não deixe comida boa ir para o lixo.*

[![Flutter](https://img.shields.io/badge/Flutter-3.44+-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.12+-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Hack Club Cider](https://img.shields.io/badge/Hack%20Club-Cider%20Challenge-ec3750)](https://cider.hackclub.dev)

Valora is an open-source, offline-first food inventory and expiry tracking application built with Flutter. It helps households organize their pantry, identify foods before they spoil, log consumption and disposal, and observe transparent progress toward eliminating food waste.

---

## 🍃 Product Principles

1. **Useful before impressive**: Fast data entry, intuitive filters, zero unnecessary steps.
2. **Minimalist, calm and trustworthy**: Restrained sage green palette, warm natural surfaces, and clear visual hierarchy without distracting clutter.
3. **Offline-first**: All data is stored in a local SQLite database on your device. Works completely offline with zero network dependencies.
4. **Zero mandatory accounts or cloud dependencies**: No registration, no telemetry, no third-party tracking.
5. **Zero fabricated claims**: Valora never displays fake environmental metrics, simulated carbon offsets, or imaginary savings. All statistics reflect recorded user activity only.
6. **Every element is interactive**: Every button, chip, filter, dialog, and setting triggers a concrete behavior.

---

## 📱 The Six Required Screens

### 1. Home (`HomeScreen`)
- **Branding & Greeting**: Locale-aware greeting (*Bom dia / Good morning*) and Valora identity.
- **Dynamic Inventory Summary**: Real-time counts of active items, items requiring attention, and items expiring soon.
- **Priority Preview**: Compact cards for foods that are expired, expiring today, or expiring soon.
- **Prominent Add Food Action**: Quick entry point to log new purchases.
- **Empty State**: Reassuring and instructive onboarding state when the pantry is empty.

### 2. Pantry (`PantryScreen`)
- **Complete Inventory List**: Real-time list of all active items with quantity, unit, category, and expiry status.
- **Instant Search**: Case-insensitive, whitespace-trimmed text search by food name.
- **Category Filter**: Horizontal chips to filter by Fruits, Vegetables, Dairy, Meat & Fish, Bakery, Pantry Staples, Frozen Foods, Drinks, or Other.
- **Status Filter**: Filter by All, Expired, Expiring Today, Expiring Soon, Fresh, or Unknown.
- **Sorting Options**: Earliest expiry first, latest expiry first, alphabetical (A–Z), and reverse (Z–A).
- **Interactive Actions**: Quick consume, quick discard, edit details, and delete with confirmation.

### 3. Add / Edit Food (`AddEditFoodScreen`)
- **Required Fields**: Name, Expiry Date (or toggle for explicitly unknown expiry), Quantity (> 0), Unit, and Category.
- **Optional Fields**: Purchase Price (≥ 0), Storage Location (Refrigerator, Freezer, Pantry, Other), Purchase Date, and Notes.
- **Safety**: Unsaved changes confirmation dialog if leaving a modified form, duplicate-submission protection, and domain-layer validation.

### 4. Expiry Center (`ExpiryCenterScreen`)
- **Mutually Exclusive Grouping**:
  - **Expired**: Items with expiry date prior to today.
  - **Expiring Today**: Items expiring on the current calendar day (never marked expired merely because the clock is past midnight).
  - **Expiring Soon**: Items expiring within the configurable warning threshold (default: 3 days).
  - **Good for Later**: Items beyond the warning threshold.
  - **Unknown Expiry**: Items with no expiry date (never falsely marked safe or expired).
- **Direct Actions**: Consume, discard, edit, or delete items directly from the group.
- **Peaceful Empty State**: Calming confirmation when no items need attention.

### 5. My Impact (`ImpactScreen`)
- **Genuine Recorded Metrics**:
  - *Recorded items consumed*
  - *Recorded items discarded*
  - *Estimated value consumed* (calculated proportionally from recorded purchase prices)
  - *Estimated value discarded* (calculated proportionally from recorded purchase prices)
  - *Consumption rate* (% of consumed actions out of total actions)
- **Transparent Methodology**: Explanatory disclaimer explaining calculation boundaries.
- **Activity Log**: Chronological audit trail of consumption and disposal actions with timestamps and quantities.

### 6. Settings (`SettingsScreen`)
- **Language Selection**: Full switching between Brazilian Portuguese (`pt_BR`) and English (`en`), with system default support.
- **Local Notifications**: Toggle for daily expiry reminders with contextual permission requests.
- **Warning Threshold**: Configurable threshold (1 to 14 days) used across Home, Pantry, and Expiry Center.
- **Theme Selection**: Light mode, Dark mode, or System default.
- **Data Management System (Central de Gerenciamento de Dados)**:
  - **1. Armazenamento Local (SQLite & SharedPreferences)**:
    - ACID-compliant SQLite relational database (`valora_inventory.db`) with foreign keys and performance indexes (`idx_food_items_status`, `idx_food_activities_timestamp`, `idx_food_activities_food_id`).
    - Diagnostics & Maintenance: Database size, table metrics, and database optimization (`VACUUM` & `ANALYZE`).
    - Full backup export and atomic validated import via JSON format.
  - **2. Banco em Nuvem & Sincronização (Cloud Database & Sync)**:
    - `CloudSyncService`: Synchronizes local inventory state and audit trails with cloud databases (Firebase Cloud Firestore / snapshot engine).
    - Tracks synchronization timestamps, status indicators (Synced, Syncing, Offline), and allows cloud restore.
  - **3. APIs e Serviços Conectados (Open Food Facts REST API)**:
    - `OpenFoodFactsApiService`: Live REST API integration with Open Food Facts (`world.openfoodfacts.org`) to search over 3 million products with automatic category, unit, storage, and shelf-life inference.
    - Integrated directly into `AddEditFoodScreen` via `ApiFoodSearchSheet` and `DataManagementScreen` live API explorer with offline fallback.
- **About & Privacy**: Information about Valora, local storage guarantees, and the MIT license.


---

## 🏗 Architecture & Data Model

Valora follows clean layered architecture:

```
lib/
├── core/
│   ├── theme/          # AppColors, AppTypography, AppTheme (Light & Dark)
│   ├── utils/          # CurrencyFormatter, UiFeedback
│   └── widgets/        # AppButton, AppCard, AppTextField, ExpiryBadge, CategoryChip, ConfirmationDialog
├── data/
│   ├── local/          # FoodRepository, SqliteFoodRepository (ACID SQLite)
│   ├── models/         # FoodItem, FoodActivity, FoodCategory, FoodUnit, ExpiryStatus, StorageLocation
│   └── services/       # NotificationService, PreferencesService
├── l10n/
│   ├── app_en.arb      # English translations
│   ├── app_pt.arb      # Brazilian Portuguese translations
│   └── generated/      # Type-safe AppLocalizations
├── presentation/
│   ├── navigation/     # MainNavigationScreen (IndexedStack)
│   └── screens/        # home, pantry, food_form, expiry, impact, settings
└── state/              # PantryProvider, ImpactProvider, SettingsProvider
```

### Local Database Schema (SQLite)

- **`food_items`**: `id` (UUID PRIMARY KEY), `name`, `category`, `initial_quantity`, `consumed_quantity`, `discarded_quantity`, `unit`, `expiry_date`, `purchase_price`, `storage_location`, `purchase_date`, `notes`, `created_at`, `updated_at`, `status`.
- **`food_activities`**: `id` (UUID PRIMARY KEY), `food_item_id` (FOREIGN KEY), `food_name`, `category`, `quantity`, `unit`, `type` (`consumed` / `discarded`), `timestamp`, `estimated_value`, `notes`.

---

## 🌐 Internationalization (i18n)

Valora is 100% translated into:
- 🇧🇷 **Portuguese (pt_BR)**
- 🇺🇸 **English (en)**

All labels, buttons, forms, dialogs, empty states, plurals, and dates are dynamically localized.

---

## 🧪 Automated Testing

Valora includes comprehensive automated test suites covering domain logic, persistence, and UI workflows:

| Test Suite | File | Tests | Status |
|---|---|---|---|
| Domain Expiry Logic | `test/domain_expiry_test.dart` | 6 | ✅ PASS |
| Domain Lifecycle & Quantities | `test/domain_food_lifecycle_test.dart` | 10 | ✅ PASS |
| SQLite Persistence & Transactions | `test/persistence_sqlite_test.dart` | 9 | ✅ PASS |
| UI & Screens Integration | `test/widget_test.dart` | 4 | ✅ PASS |
| Functional Foundation & Normalization | `test/session2_functional_foundation_test.dart` | 16 | ✅ PASS |
| Expiry Center & Impact Audit Trail | `test/session3_advanced_integration_test.dart` | 15 | ✅ PASS |
| Settings, Notifications & Release Readiness | `test/session4_settings_notifications_release_test.dart` | 18 | ✅ PASS |
| **Total** | | **78** | **100% PASS** |

### Running Tests & Static Analysis

```bash
# Run static analysis
flutter analyze

# Run all automated tests
flutter test

# Run code generator for localization (if modified)
flutter gen-l10n
```

---

## 🚀 Running the App

### Web / Chrome
```bash
flutter run -d chrome
```

### Windows Desktop
```bash
flutter run -d windows
```

### iOS (macOS required)
```bash
flutter run -d ios
```

---

## 🍎 iOS & Cider Submission Guide

For the **Hack Club Cider Challenge** ([https://cider.hackclub.dev/](https://cider.hackclub.dev/)):

1. **Verify Hackatime**: Ensure you have logged at least 40 development hours with Hackatime.
2. **Submit Demo**: Submit your demo via [Hack Club Demo Form](https://forms.hackclub.com/t/jALEZHqGE2us) to get TestFlight support.
3. **Submit PR**: Open a PR to `hackclub/cider-website` adding a folder under `submissions/valora`.
4. **Grant & App Store**: Claim your $100 grant for Apple Developer Membership and publish Valora to the App Store!

---

## 📚 Technical Documentation & Architecture

For in-depth details on the software architecture, SQLite schema, offline-first design patterns, and contribution guidelines, see:

- [ARCHITECTURE.md](file:///c:/valora/ARCHITECTURE.md) — Comprehensive technical architecture, entity-relationship diagrams, SQLite transaction safety, and expiry status rules.
- [CONTRIBUTING.md](file:///c:/valora/CONTRIBUTING.md) — Development setup, static analysis rules, testing guidelines, and pull request workflow.

---

## 📄 License

Valora is licensed under the [MIT License](LICENSE).

