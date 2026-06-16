# 1. Vosk / JNA (Reconocimiento de voz)
-keep class com.sun.jna.* { *; }
-keepclassmembers class * extends com.sun.jna.* { public *; }

# 2. Regla absoluta para parchar todos los canales de Pigeon y Plugins de Flutter
-keep class io.flutter.plugins.** { *; }
-keep class dev.flutter.** { *; }

# 3. Silenciar advertencias de clases de escritorio no usadas en Android
-dontwarn java.awt.Component
-dontwarn java.awt.GraphicsEnvironment
-dontwarn java.awt.HeadlessException
-dontwarn java.awt.Window