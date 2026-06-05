import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase not initialized in background handler');
  }
  debugPrint("Handling a background message: ${message.messageId}");
}

class PushNotificationService {
  FirebaseMessaging? _messaging;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin = FlutterLocalNotificationsPlugin();
  
  bool _initialized = false;

  PushNotificationService() {
    try {
      _messaging = FirebaseMessaging.instance;
    } catch (e) {
      debugPrint('Firebase messaging not available yet.');
    }
  }

  Future<void> initialize() async {
    if (_initialized) return;
    
    // 1. Initialize Local Notifications (for foreground & scheduled reminders)
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
            requestAlertPermission: true,
            requestBadgePermission: true,
            requestSoundPermission: true);
    
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );
    
    await _localNotificationsPlugin.initialize(initializationSettings);

    // 2. Initialize Firebase Messaging (if available)
    if (_messaging != null) {
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      NotificationSettings settings = await _messaging!.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      debugPrint('User granted permission: ${settings.authorizationStatus}');

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('Got a message whilst in the foreground!');
        debugPrint('Message data: ${message.data}');

        if (message.notification != null) {
          _showLocalNotification(
            message.notification!.title ?? 'Finance AI',
            message.notification!.body ?? '',
          );
        }
      });
    }

    _initialized = true;
  }

  Future<String?> getToken() async {
    if (_messaging == null) return null;
    return await _messaging!.getToken();
  }

  // Helper to show a local notification immediately (or from FCM)
  Future<void> _showLocalNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'finance_ai_reminders', // channel id
      'Reminders', // channel name
      channelDescription: 'Scheduled reminders for investments and bills',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    
    await _localNotificationsPlugin.show(
      DateTime.now().millisecond,
      title,
      body,
      platformChannelSpecifics,
    );
  }

  // Simulate scheduling a local push notification for a Portfolio reminder
  Future<void> scheduleReminder(String title, String body, DateTime scheduledDate) async {
    // In a real app, you'd use zonedSchedule with timezone. 
    // For now, we will just show it immediately for demonstration or push it to the server.
    debugPrint('Scheduled Reminder for $scheduledDate: $title - $body');
    // await _showLocalNotification(title, body); // For testing immediately
  }
}
