import 'package:flutter/material.dart';
import 'package:frontend/presentation/pages/MainUserPage.dart';
import 'package:frontend/presentation/pages/profile/tasker_profile.dart';
import 'package:frontend/presentation/pages/tasker/MainTaskerPage.dart';
import 'package:frontend/presentation/pages/tasker/certification_page.dart';
import 'package:frontend/presentation/pages/tasker/earning_page.dart';
import 'package:frontend/presentation/pages/tasker/job_requests_page.dart';
import 'package:frontend/presentation/pages/tasker/ratingsPage.dart';
import 'package:frontend/presentation/pages/tasker/schedule_page.dart';
import 'package:frontend/presentation/pages/tasker/taskerBookingsPage.dart';
import 'package:frontend/presentation/pages/tasker/taskerChatList.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart' as notif;
import 'package:frontend/presentation/pages/auth/Tasker_singup.dart';
import 'package:frontend/presentation/pages/chat/chat_page.dart';
import 'package:frontend/presentation/pages/chat/chatsList.dart';
import 'package:frontend/presentation/pages/tasker/taskerHomePage.dart';
import 'package:frontend/presentation/pages/auth/login.dart';
import 'package:frontend/presentation/pages/auth/otpVerification.dart';
import 'package:frontend/presentation/pages/auth/signup.dart';
import 'package:frontend/presentation/pages/RoleSelection.dart';
import 'package:frontend/presentation/pages/getStarted.dart';
import 'package:frontend/presentation/pages/homePage.dart';
import 'package:frontend/presentation/pages/profile/edit_profile_page.dart';
import 'package:frontend/presentation/pages/profile/profile_page.dart';
import 'package:frontend/presentation/pages/tasker/tasker_details.dart';
import 'package:frontend/presentation/pages/booking/confirmBooking.dart';
import 'package:frontend/presentation/pages/notification/notification_page.dart';
import 'package:frontend/presentation/pages/tasker/tasker_chat_page.dart';
import 'package:frontend/presentation/pages/tasker/tasker_certificate.dart' hide CertificationPage;
import 'package:frontend/presentation/pages/tasker/professional_info.dart';

final notif.FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    notif.FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('📩 Handling a background message: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await FirebaseMessaging.instance.requestPermission();

  const notif.AndroidInitializationSettings initializationSettingsAndroid =
      notif.AndroidInitializationSettings('@mipmap/ic_launcher');

  const notif.InitializationSettings initializationSettings = notif.InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        notif.NotificationDetails(
          android: notif.AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            importance: notif.Importance.max,
            priority: notif.Priority.high, // ✅ FIXED HERE
          ),
        ),
      );
    }
  });

  final prefs = await SharedPreferences.getInstance();
  final accessToken = prefs.getString('accessToken');
  final refreshToken = prefs.getString('refreshToken');
  final userId = prefs.getString('userId');

  String initialRoute = '/';

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
        'taskerChatsList': (context) => const TaskerChatsListPage(),
        'taskerChatDetails': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map;
          return TaskerChatPage(
            taskerId: args['taskerId'],
            userId: args['otherUserId'],
            userName: args['otherUserName'],
            userAvatar: args['otherUserAvatar'],
          );
        },
        'certificationPage': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map;
          return CertificationPage(
            certifications: args['certifications'],
            taskerName: args['taskerName'],
          );
        },
        'taskerProfile': (context) => TaskerProfilePage(),
        'taskerBookingsPage': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map;
          return TaskerBookingsPage(
            taskerId: args['taskerId'],
            taskerName: args['taskerName'],
          );
        },
        'taskerRatingsPage': (context) => const RatingsPage(),
        'mainTaskerPage': (context) => const MainTaskerPage(),
        'mainUserPage': (context) => const MainUserPage(),
        'schedulePage': (context) => const SchedulePage(),
        'earningsPage': (context) => const EarningsPage(),
        'taskerCertificate': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map;
          return TaskerCertificationPage(
            certifications: args['certifications'],
            taskerName: args['taskerName'],
            taskerId: args['taskerId'],
          );
        },
        'professionalInfo': (context) => const ProfessionalProfilePage(),

      },
    );
  }
}