import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_screen.dart'; // Import login screen

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  MapboxMapController? mapController;
  // Initial camera position (e.g., Fallujah center)
  // Coordinates for Fallujah: approx 33.35° N, 43.78° E
  final CameraPosition _initialCameraPosition = const CameraPosition(
    target: LatLng(33.35, 43.78),
    zoom: 12.0,
  );

  void _onMapCreated(MapboxMapController controller) {
    mapController = controller;
    // You can add markers, lines, etc. here or later
  }

  Future<void> _signOut() async {
    try {
      await Supabase.instance.client.auth.signOut();
      if (mounted) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Error signing out'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ));
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('يلا رايد - الرئيسية'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
            tooltip: 'تسجيل الخروج',
          )
        ],
      ),
      body: MapboxMap(
        accessToken: dotenv.env['MAPBOX_ACCESS_TOKEN']!,
        initialCameraPosition: _initialCameraPosition,
        onMapCreated: _onMapCreated,
        styleString: MapboxStyles.MAPBOX_STREETS, // Or use a custom style
        // Add other map configurations as needed
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement ride request logic/navigation
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ride request feature coming soon!')),
          );
        },
        tooltip: 'طلب رحلة',
        child: const Icon(Icons.local_taxi),
      ), 
    );
  }
}

