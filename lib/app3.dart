import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Login',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Name Field
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),

              // Username Field
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your username';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),

              // Phone Number Field
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),

              // Password Field
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true, // Hide password text
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),

              // Login Button
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    // Perform login
                    String username = _usernameController.text;
                    String password = _passwordController.text;
                    String phone = _phoneController.text;
                    String name = _nameController.text;

                    // Logic for login (authentication)
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Logging in with $name, $username, $phone'),
                    ));

                    // Navigate to the next screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AppSelectionScreen(phone)),
                    );
                  }
                },
                child: Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AppSelectionScreen extends StatefulWidget {
  final String phone;

  AppSelectionScreen(this.phone);

  @override
  _AppSelectionScreenState createState() => _AppSelectionScreenState();
}

class _AppSelectionScreenState extends State<AppSelectionScreen> {
  String? _selectedApp;
  final _timeController = TextEditingController();
  int _streakDays = 0;  // To store the current streak count
  late FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;

  // Simulating app options as a list
  final List<String> _availableApps = [
    'Facebook',
    'Instagram',
    'Twitter',
    'WhatsApp',
    'Spotify',
  ];

  @override
  void initState() {
    super.initState();
    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    // Initialize notifications
    var android = AndroidInitializationSettings('app_icon');
    var settings = InitializationSettings(android: android);
    _flutterLocalNotificationsPlugin.initialize(settings);
  }

  void _sendNotification(String phone) async {
    var androidDetails = AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      channelDescription: 'channel_description',
      importance: Importance.high,
      priority: Priority.high,
    );
    var platformDetails = NotificationDetails(android: androidDetails);
    
    await _flutterLocalNotificationsPlugin.show(
      0,
      'Streak Broken',
      'Your streak has been broken! We will notify $phone.',
      platformDetails,
    );
  }

  void _checkAndUpdateStreak() {
    if (_streakDays == 0) {
      // Send notification if streak is broken
      _sendNotification(widget.phone);
    } else {
      setState(() {
        _streakDays++;  // Increment streak if task is done
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Select App and Set Time')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // App Selection
            DropdownButtonFormField<String>(
              value: _selectedApp,
              decoration: InputDecoration(
                labelText: 'Select App',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _selectedApp = value;
                });
              },
              items: _availableApps.map((app) {
                return DropdownMenuItem<String>(
                  value: app,
                  child: Text(app),
                );
              }).toList(),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select an app';
                }
                return null;
              },
            ),
            SizedBox(height: 20),

            // Time Input
            TextFormField(
              controller: _timeController,
              decoration: InputDecoration(
                labelText: 'Enter Time (in minutes)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter time';
                }
                
                if (int.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            SizedBox(height: 20),

            // Submit Button
            ElevatedButton(
              onPressed: () {
                if (_selectedApp != null && _timeController.text.isNotEmpty) {
                  _checkAndUpdateStreak();  // Update streak based on the action
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Selected app: $_selectedApp, Time: ${_timeController.text} minutes'),
                  ));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Please complete the form!'),
                  ));
                }
              },
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}