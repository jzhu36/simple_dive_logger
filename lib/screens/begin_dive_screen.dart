import 'package:flutter/material.dart';
// TODO: Re-enable location services later
// import 'package:geolocator/geolocator.dart';
// import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';
import '../models/dive.dart';
import '../services/database_service.dart';

class BeginDiveScreen extends StatefulWidget {
  const BeginDiveScreen({super.key});

  @override
  State<BeginDiveScreen> createState() => _BeginDiveScreenState();
}

class _BeginDiveScreenState extends State<BeginDiveScreen> {
  bool _isLoading = false;
  String _currentTime = '';
  String _currentDate = '';
  String _locationDisplay = 'Location (to be implemented)';
  // TODO: Re-enable location services later
  // Position? _currentPosition;
  // String? _country;
  // String? _diveSiteName;

  @override
  void initState() {
    super.initState();
    _updateTime();
    // Start dive immediately when screen opens
    _startDive();
  }

  void _updateTime() {
    final now = DateTime.now();
    setState(() {
      _currentTime = DateFormat('HH:mm').format(now);
      _currentDate = DateFormat('yyyy-MM-dd').format(now);
    });
  }

  // TODO: Re-enable location services later
  /*
  /// Check and request location permissions
  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location services are disabled. Please enable location services.'),
          ),
        );
      }
      return false;
    }

    // Check location permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location permission denied'),
            ),
          );
        }
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location permissions are permanently denied. Please enable in settings.'),
          ),
        );
      }
      return false;
    }

    return true;
  }

  /// Get current GPS location
  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
      _locationDisplay = 'Getting location...';
    });

    try {
      final hasPermission = await _handleLocationPermission();
      if (!hasPermission) {
        setState(() {
          _locationDisplay = 'Location permission denied';
          _isLoading = false;
        });
        return;
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      setState(() {
        _currentPosition = position;
      });

      // Try to get place name from coordinates (reverse geocoding)
      try {
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          setState(() {
            _country = place.country ?? '';
            // Use locality (city) or subLocality as dive site name
            _diveSiteName = place.locality ?? place.subLocality ?? '';

            // Create display string
            if (_diveSiteName != null && _diveSiteName!.isNotEmpty) {
              if (_country != null && _country!.isNotEmpty) {
                _locationDisplay = '$_diveSiteName, $_country';
              } else {
                _locationDisplay = _diveSiteName!;
              }
            } else if (_country != null && _country!.isNotEmpty) {
              _locationDisplay = _country!;
            } else {
              _locationDisplay = '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
            }
          });
        } else {
          setState(() {
            _locationDisplay = '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
          });
        }
      } catch (e) {
        // Geocoding failed, use coordinates
        setState(() {
          _locationDisplay = '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
        });
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _locationDisplay = 'Failed to get location: ${e.toString()}';
        _isLoading = false;
      });
    }
  }
  */

  /// Start dive and save to database
  Future<void> _startDive() async {
    // TODO: Re-enable location services later
    // Get current location first
    // await _getCurrentLocation();

    // Update time to current moment
    _updateTime();

    setState(() {
      _isLoading = true;
    });

    try {
      // Create new dive with in_progress status
      final now = DateTime.now();
      final dive = Dive(
        date: _currentDate,
        time: _currentTime,
        // TODO: Re-enable location services later
        // country: _country,
        // diveSiteName: _diveSiteName,
        // latitude: _currentPosition?.latitude,
        // longitude: _currentPosition?.longitude,
        maxDepth: 0.0, // Placeholder, will be updated when dive ends
        duration: 0, // Placeholder, will be updated when dive ends
        status: 'in_progress',
        createdAt: now.toIso8601String(),
        updatedAt: now.toIso8601String(),
      );

      // Save to database
      await DatabaseService.instance.insertDive(dive);

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dive started successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error starting dive: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Begin Dive'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: GestureDetector(
        onTap: () {
          // Tap anywhere to return
          Navigator.of(context).pop();
        },
        child: Container(
          color: Colors.blue[50],
          child: Center(
            child: _buildDiveStartedView(),
          ),
        ),
      ),
    );
  }

  /// Build the view shown after dive is started
  Widget _buildDiveStartedView() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.check_circle,
            size: 80,
            color: Colors.green,
          ),
          const SizedBox(height: 32),
          Text(
            'Dive Started!',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.blue[900],
            ),
          ),
          const SizedBox(height: 24),
          _buildInfoCard('Time', _currentTime),
          const SizedBox(height: 12),
          _buildInfoCard('Date', _currentDate),
          const SizedBox(height: 12),
          _buildInfoCard('Location', _locationDisplay),
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange, width: 2),
            ),
            child: const Text(
              'Click "End Dive" when finished!\n\nTap anywhere to return',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build info card widget
  Widget _buildInfoCard(String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

}
