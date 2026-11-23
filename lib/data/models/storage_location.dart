import 'package:flutter/material.dart';
import 'package:valora/l10n/generated/app_localizations.dart';

enum StorageLocation {
  refrigerator,
  freezer,
  pantry,
  other;

  String get displayName {
    switch (this) {
      case StorageLocation.refrigerator:
        return 'Geladeira';
      case StorageLocation.freezer:
        return 'Congelador';
      case StorageLocation.pantry:
        return 'Despensa';
      case StorageLocation.other:
        return 'Outro';
    }
  }

  String localizedName(AppLocalizations l10n) {
    switch (this) {
      case StorageLocation.refrigerator:
        return l10n.locRefrigerator;
      case StorageLocation.freezer:
        return l10n.locFreezer;
      case StorageLocation.pantry:
        return l10n.locPantry;
      case StorageLocation.other:
        return l10n.locOther;
    }
  }

  IconData get icon {
    switch (this) {
      case StorageLocation.refrigerator:
        return Icons.kitchen_rounded;
      case StorageLocation.freezer:
        return Icons.ac_unit_rounded;
      case StorageLocation.pantry:
        return Icons.shelves;
      case StorageLocation.other:
        return Icons.place_outlined;
    }
  }

  static StorageLocation fromString(String value) {
    return StorageLocation.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => StorageLocation.other,
    );
  }
}
