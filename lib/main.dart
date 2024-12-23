import 'package:flutter/material.dart';

void main() => runApp(const CombinedApp());

class CombinedApp extends StatelessWidget {
  const CombinedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: const CombinedExample(),
    );
  }
}

class CombinedExample extends StatefulWidget {
  const CombinedExample({super.key});

  @override
  State<CombinedExample> createState() => _CombinedExampleState();
}

class _CombinedExampleState extends State<CombinedExample> {
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const SizedBox(width: 8),
            const Text(
              '(EBbus logo) EBbus Demo Home Page',
              style: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
              ),
            )
          ],
        ),
        backgroundColor: const Color.fromARGB(255, 58, 173, 183),
      ),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        indicatorColor: Colors.amber,
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Badge(child: Icon(Icons.notifications_sharp)),
            label: 'Notifications',
          ),
          NavigationDestination(
            icon: Icon(Icons.pin_drop), // Location pin icon
            label: 'Location Tracking', // New name
          ),
          NavigationDestination(
            icon: Icon(Icons.account_circle), // Profile icon
            label: 'Profile', // Label for the profile
          ),
        ],
      ),
      body: <Widget>[
        /// Home page
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Your one-stop location tracking app',
                style: TextStyle(
                  fontSize: 18.0, // Larger font size for main text
                  fontWeight: FontWeight.bold, // Make it bold if needed
                ),
              ),
              SizedBox(height: 8.0), // Add some spacing between the texts
              Text(
                'Created by P.E.A.R',
                style: TextStyle(
                  fontSize: 12.0, // Smaller font size for the tagline
                  color:
                      Colors.grey, // Optional: Make it grey for a subtle look
                ),
              ),
            ],
          ),
        ),

        /// Notifications page
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              Card(
                child: ListTile(
                  leading: Icon(Icons.notifications_sharp),
                  title: Text('Notification 1'),
                  subtitle: Text('This is a notification'),
                ),
              ),
              Card(
                child: ListTile(
                  leading: Icon(Icons.notifications_sharp),
                  title: Text('Notification 2'),
                  subtitle: Text('This is a notification'),
                ),
              ),
            ],
          ),
        ),

        /// Location Tracking page (new)
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.location_on, // Location pin icon
                size: 80,
                color: theme.colorScheme.primary,
              ),
              SizedBox(height: 16),
              Text(
                'Track your location here',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Stay updated with your current location.',
                style: TextStyle(
                  fontSize: 14.0,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),

        /// Profile page (new)
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.account_circle, // Profile icon
                size: 80,
                color: theme.colorScheme.primary,
              ),
              SizedBox(height: 16),
              Text(
                'Your Profile',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Manage your account and settings here.',
                style: TextStyle(
                  fontSize: 14.0,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ][currentPageIndex],
    );
  }
}
