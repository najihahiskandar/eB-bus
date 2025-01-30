import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:location/location.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(const EbBusApp());
}

class EbBusApp extends StatelessWidget {
  const EbBusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ebBus',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0C203B)),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    const HomeScreen(),
    const ScheduleScreen(),
    const AlertsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.schedule), label: 'Schedule'),
          BottomNavigationBarItem(
              icon: Icon(Icons.notifications), label: 'Alerts'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        selectedItemColor: const Color(0xFF0C203B),
        unselectedItemColor: Colors.blueGrey,
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isMapExpanded = false;
  final TextEditingController _searchController = TextEditingController();
  LatLng? _currentLocation;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    final Location location = Location();
    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    locationData = await location.getLocation();
    setState(() {
      _currentLocation =
          LatLng(locationData.latitude!, locationData.longitude!);
    });
  }

  void _onMapCreated(GoogleMapController controller) {}

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _isMapExpanded = !_isMapExpanded;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _isMapExpanded
                ? MediaQuery.of(context).size.height
                : MediaQuery.of(context).size.height * 0.6,
            color: Colors.grey[200],
            child: _currentLocation != null
                ? GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: _currentLocation!,
                      zoom: 15,
                    ),
                    onMapCreated: _onMapCreated,
                    markers: {
                      Marker(
                        markerId: const MarkerId('current_location'),
                        position: _currentLocation!,
                      )
                    },
                  )
                : const Center(child: CircularProgressIndicator()),
          ),
        ),
        // Search Bar at the top
        Positioned(
          top: 30,
          left: 16,
          right: 16,
          child: TextField(
            controller: _searchController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Search Destination...',
              hintStyle: const TextStyle(color: Colors.white),
              prefixIcon: const Icon(Icons.search, color: Colors.white),
              filled: true,
              fillColor: const Color(0xFF0C203B),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (value) {
              if (['multimedia university', 'mmu', 'cyberlake', 'dpulze']
                  .contains(value.toLowerCase())) {
                FocusScope.of(context).unfocus();
                _showDestinationSelection(context);
              }
            },
          ),
        ),
        if (!_isMapExpanded)
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.4,
              decoration: BoxDecoration(
                color: const Color(0xFF0C203B),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: ListView(
                children: [
                  Row(
                    children: const [
                      SizedBox(width: 12),
                      Icon(Icons.location_on, color: Colors.red, size: 32),
                      SizedBox(width: 5),
                      Text(
                        'Closest Stop',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  _buildBusStop(
                      'MMU (500m)', 'Bus arrives in 10 minutes', Colors.red),
                  _buildBusStop('Cyberlake (1.3km)', 'Bus arrives in 5 minutes',
                      Colors.green),
                  _buildBusStop('DPulze (3km)', 'Bus arrives in 3 minutes',
                      Colors.orange),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBusStop(String title, String subtitle, Color iconColor) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.grey, blurRadius: 5, offset: Offset(0, 3))
        ],
      ),
      child: ListTile(
        leading: Icon(Icons.location_on, color: iconColor),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Icon(Icons.directions_bus, color: iconColor),
      ),
    );
  }

  void _showDestinationSelection(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: Color(0xFF0C203B),
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Choose Starting Point',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const SizedBox(height: 10),
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                child: TextField(
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'Choose Starting Point',
                    prefixIcon:
                        const Icon(Icons.location_on, color: Colors.red),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Choose Destination',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const SizedBox(height: 10),
              TextField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Choose Destination',
                  prefixIcon: const Icon(Icons.location_on, color: Colors.blue),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Confirm'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  String? _selectedStop;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Schedule')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Choose Starting Point'),
            DropdownButton(
              isExpanded: true,
              value: _selectedStop ?? 'Stop 1',
              items: const [
                DropdownMenuItem(value: 'Stop 1', child: Text('MMU (500m)')),
                DropdownMenuItem(
                    value: 'Stop 2', child: Text('Cyberlake (1.3km)')),
                DropdownMenuItem(value: 'Stop 3', child: Text('DPulze (3km)')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedStop = value;
                });
              },
              hint: const Text('Select a stop'),
            ),
            const SizedBox(height: 20),
            const Text('Schedule:'),
            Expanded(
              child: ListView(
                children: const [
                  ListTile(
                    title: Text('08:00 AM'),
                    trailing: Text('Bus 1'),
                  ),
                  ListTile(
                    title: Text('09:00 AM'),
                    trailing: Text('Bus 1'),
                  ),
                  ListTile(
                    title: Text('01:00 PM'),
                    trailing: Text('Bus 3'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Alerts')),
      body: ListView(
        children: const [
          ListTile(
            leading: Icon(Icons.warning, color: Colors.red),
            title: Text('Oh no! You missed the bus'),
            subtitle: Text('20 minutes ago'),
          ),
          ListTile(
            leading: Icon(Icons.notifications, color: Colors.blue),
            title: Text('Reminder set for your bus on 16th Jan, Mon.'),
            subtitle: Text('2 days ago'),
          ),
          ListTile(
            leading: Icon(Icons.directions_bus, color: Colors.green),
            title: Text('Bus 2 is 1km away from you'),
            subtitle: Text('4 days ago'),
          ),
        ],
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: const Center(
        child: Text('Profile Content'),
      ),
    );
  }
}
