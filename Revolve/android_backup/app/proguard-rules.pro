-keep class org.tensorflow.lite.** { *; }
-keep class com.google.android.gms.** { *; }
-keep class com.google.android.gms.maps.** { *; }
-keep class com.google.android.gms.tasks.** { *; }
-keep class com.google.maps.** { *; }
-keep class com.google.firebase.** { *; }
-keep class com.squareup.okhttp.** { *; }
-keep class okhttp3.** { *; }
-keep class okio.** { *; }
-dontwarn org.tensorflow.lite.**
-dontwarn com.google.android.gms.**
-dontwarn com.google.maps.**
-dontwarn okhttp3.**
-dontwarn okio.**

# Keep Google Maps SDK classes
-keep class com.google.android.gms.maps.GoogleMap { *; }
-keep class com.google.android.gms.maps.MapView { *; }
-keep class com.google.android.gms.maps.SupportMapFragment { *; }
-keep class com.google.android.gms.maps.model.** { *; }

# Keep Flutter Google Maps plugin classes
-keep class io.flutter.plugins.googlemaps.** { *; }
-dontwarn io.flutter.plugins.googlemaps.**

# Keep Firebase Storage classes
-keep class com.google.firebase.storage.** { *; }
-keep class com.google.firebase.storage.network.** { *; }

# Keep image loading related classes
-keep class com.bumptech.glide.** { *; }
-keep class com.android.volley.** { *; }
-dontwarn com.bumptech.glide.**