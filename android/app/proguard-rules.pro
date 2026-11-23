# =========================================================================
# Valora - ProGuard & R8 Obfuscation & Security Hardening Rules
# =========================================================================

# --- General Shrinking & Optimization ---
-optimizationpasses 5
-dontusemixedcaseclassnames
-dontskipnonpubliclibraryclasses
-verbose

# --- Flutter Engine & Embedding Preservation ---
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# --- Strip Debugging Logs & Symbols in Production ---
-assumenosideeffects class android.util.Log {
    public static boolean isLoggable(java.lang.String, int);
    public static int v(...);
    public static int d(...);
    public static int i(...);
}

# --- Flutter Local Notifications Plugin Preservation ---
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-keepclassmembers class com.dexterous.flutterlocalnotifications.** { *; }

# --- Sqflite / SQLite Engine Preservation ---
-keep class com.tekartik.sqflite.** { *; }
-keepclassmembers class com.tekartik.sqflite.** { *; }

# --- Firebase Core & Auth Preservation (if configured) ---
-keep class com.google.firebase.** { *; }
-keep class io.flutter.plugins.firebase.** { *; }
-dontwarn com.google.firebase.**

# --- SharedPreferences Preservation ---
-keep class io.flutter.plugins.sharedpreferences.** { *; }

# --- Desugaring Core Library ---
-dontwarn java.lang.invoke.**
-dontwarn java.time.**

# --- Keep Native Methods & Enums ---
-keepclasseswithmembernames class * {
    native <methods>;
}

-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}
