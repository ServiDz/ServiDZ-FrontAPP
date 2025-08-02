import 'package:flutter/material.dart';
import 'package:frontend/presentation/pages/tasker/job_requests_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:frontend/presentation/pages/auth/Tasker_singup.dart';
import 'package:frontend/presentation/pages/chat/chat_page.dart';
import 'package:frontend/presentation/pages/chat/chatsList.dart';
import 'package:frontend/presentation/pages/taskerHomePage.dart';
import 'package:frontend/presentation/pages/auth/login.dart';
import 'package:frontend/presentation/pages/auth/otpVerification.dart';
import 'package:frontend/presentation/pages/auth/signup.dart';
import 'package:frontend/presentation/pages/RoleSelection.dart';
import 'package:frontend/presentation/pages/getStarted.dart';
import 'package:frontend/presentation/pages/homePage.dart';
import 'package:frontend/presentation/pages/profile/edit_profile_page.dart';
import 'package:frontend/presentation/pages/profile/profile_page.dart';
import 'package:frontend/presentation/pages/tasker_details.dart';
import 'package:frontend/presentation/pages/booking/confirmBooking.dart';
import 'package:frontend/presentation/pages/notification/notification_page.dart';

// Initialize local notifications
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('📩 Handling a background message: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Initialize Firebase
  await Firebase.initializeApp();

  // ✅ Firebase Messaging background handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // ✅ Ask permission (especially for iOS)
  await FirebaseMessaging.instance.requestPermission();

  // ✅ Initialize local notifications
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // ✅ Handle foreground messages
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
      );
    }
  });

  final prefs = await SharedPreferences.getInstance();
  final accessToken = prefs.getString('accessToken');
  final refreshToken = prefs.getString('refreshToken');
  final userId = prefs.getString('userId');

  String initialRoute = '/'; // default route

  runApp(MyApp(initialRoute: initialRoute));
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(),
      initialRoute: initialRoute,
      routes: {
        '/': (context) => GetStartedPage(),
        'roleSelection': (context) => const RoleSelectionPage(),
        'login': (context) => const LoginPage(),
        'signup': (context) => const SignupPage(),
        'otpVerification': (context) => const OtpVerificationPage(),
        'homepage': (context) => HomePage(),
        'taskerDetails': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map;
          return TaskerPage(taskerId: args['id']);
        },
        'profile': (context) => ProfilePage(),
        'editProfile': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map;
          return EditProfilePage(user: args['user']);
        },
        'chatsList': (context) => ChatsListPage(),
        'chatDetails': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map;
          return ChatPage(
            otherUserId: args['otherUserId'],
            otherUserName: args['otherUserName'],
            otherUserAvatar: args['otherUserAvatar'],
            userId: args['userId'],
          );
        },
        'bookingConfirmed': (context) => const BookingConfirmedPage(),
        'notification': (context) => const NotificationPage(),
        'taskerRegister': (context) => const TaskerRegisterPage(),
        'taskerHomePage': (context) => const TaskerHomePage(),
        'jobRequests': (context) => const JobRequestsPage(),
      },
    );
  }
}
