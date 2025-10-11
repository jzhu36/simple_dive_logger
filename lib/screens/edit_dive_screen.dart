import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/dive.dart';
import '../services/database_service.dart';

class EditDiveScreen extends StatefulWidget {
  final Dive? dive; // If provided, edit this dive. If null, show dive picker.

  const EditDiveScreen({super.key, this.dive});

  @override
  State<EditDiveScreen> createState() => _EditDiveScreenState();
}

class _EditDiveScreenState extends State<EditDiveScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _showingPicker = false;

  Dive? _selectedDive;
  List<Dive> _allDives = [];

  // Form controllers
  late TextEditingController _dateController;
  late TextEditingController _timeController;
  late TextEditingController _countryController;
  late TextEditingController _diveSiteNameController;
  late TextEditingController _latitudeController;
  late TextEditingController _longitudeController;
  late TextEditingController _maxDepthController;
  late TextEditingController _durationController;
  late TextEditingController _waterTemperatureController;
  late TextEditingController _notesController;

  String _visibility = 'good';
  String _status = 'completed';

  @override
  void initState() {
    super.initState();

    // Initialize controllers
    _dateController = TextEditingController();
    _timeController = TextEditingController();
    _countryController = TextEditingController();
    _diveSiteNameController = TextEditingController();
    _latitudeController = TextEditingController();
    _longitudeController = TextEditingController();
    _maxDepthController = TextEditingController();
    _durationController = TextEditingController();
    _waterTemperatureController = TextEditingController();
    _notesController = TextEditingController();

    if (widget.dive != null) {
      // Dive provided from End Dive screen - load it directly
      _selectedDive = widget.dive;
      _loadDiveData();
    } else {
      // No dive provided - show picker
      _showingPicker = true;
      _loadAllDives();
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    _timeController.dispose();
    _countryController.dispose();
    _diveSiteNameController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _maxDepthController.dispose();
    _durationController.dispose();
    _waterTemperatureController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  /// Load all dives (both completed and in-progress) for picker
  Future<void> _loadAllDives() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final db = DatabaseService.instance;
      final dbInstance = await db.database;

      // Get all dives regardless of status
      final result = await dbInstance.query(
        'dives',
        orderBy: 'date DESC, time DESC',
      );

      final allDives = result.map((map) => Dive.fromMap(map)).toList();

      setState(() {
        _allDives = allDives;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading dives: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Load dive data into form fields
  void _loadDiveData() {
    if (_selectedDive == null) return;

    final dive = _selectedDive!;

    _dateController.text = dive.date;
    _timeController.text = dive.time;
    _countryController.text = dive.country ?? '';
    _diveSiteNameController.text = dive.diveSiteName ?? '';
    _latitudeController.text = dive.latitude?.toString() ?? '';
    _longitudeController.text = dive.longitude?.toString() ?? '';
    _maxDepthController.text = dive.maxDepth.toString();
    _durationController.text = dive.duration.toString();
    _waterTemperatureController.text = dive.waterTemperature?.toString() ?? '';
    _notesController.text = dive.notes ?? '';

    _visibility = dive.visibility ?? 'good';
    _status = dive.status;
  }

  /// Save dive changes
  Future<void> _saveDive() async {
    if (_selectedDive == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a dive to edit'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Create updated dive object
      final updatedDive = _selectedDive!.copyWith(
        date: _dateController.text,
        time: _timeController.text,
        country: _countryController.text.isEmpty ? null : _countryController.text,
        diveSiteName: _diveSiteNameController.text.isEmpty ? null : _diveSiteNameController.text,
        latitude: _latitudeController.text.isEmpty ? null : double.tryParse(_latitudeController.text),
        longitude: _longitudeController.text.isEmpty ? null : double.tryParse(_longitudeController.text),
        maxDepth: double.parse(_maxDepthController.text),
        duration: int.parse(_durationController.text),
        waterTemperature: _waterTemperatureController.text.isEmpty ? null : double.tryParse(_waterTemperatureController.text),
        visibility: _visibility.isEmpty ? null : _visibility,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        status: 'completed', // Always set to completed when saving
        updatedAt: DateTime.now().toIso8601String(),
      );

      // Save to database
      await DatabaseService.instance.updateDive(updatedDive);

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dive saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate back to home
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving dive: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Select a dive from the picker
  void _selectDive(Dive dive) {
    setState(() {
      _selectedDive = dive;
      _showingPicker = false;
      _loadDiveData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Dive'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _showingPicker
              ? _buildDivePicker()
              : _buildEditForm(),
    );
  }

  /// Build dive picker (when no dive is pre-selected)
  Widget _buildDivePicker() {
    if (_allDives.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.info_outline,
                size: 80,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 24),
              Text(
                'No Dives Found',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'You don\'t have any dives yet.\nStart a new dive first!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  'Go Back',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Select Dive to Edit',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blue[900],
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _allDives.length,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemBuilder: (context, index) {
              final dive = _allDives[index];
              return _buildDivePickerCard(dive);
            },
          ),
        ),
      ],
    );
  }

  /// Build dive picker card
  Widget _buildDivePickerCard(Dive dive) {
    return GestureDetector(
      onTap: () => _selectDive(dive),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.2),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${dive.date} at ${dive.time}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: dive.status == 'completed' ? Colors.green[100] : Colors.orange[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    dive.status == 'completed' ? 'Completed' : 'In Progress',
                    style: TextStyle(
                      fontSize: 12,
                      color: dive.status == 'completed' ? Colors.green[900] : Colors.orange[900],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            if (dive.country != null || dive.diveSiteName != null) ...[
              const SizedBox(height: 8),
              Text(
                dive.getLocationDisplay(),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              'Depth: ${dive.maxDepth}m • Duration: ${dive.duration} min',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build edit form
  Widget _buildEditForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Date and Time
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _dateController,
                    decoration: const InputDecoration(
                      labelText: 'Date *',
                      hintText: 'YYYY-MM-DD',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _timeController,
                    decoration: const InputDecoration(
                      labelText: 'Time *',
                      hintText: 'HH:MM',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Country
            TextFormField(
              controller: _countryController,
              decoration: const InputDecoration(
                labelText: 'Country',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Dive Site Name
            TextFormField(
              controller: _diveSiteNameController,
              decoration: const InputDecoration(
                labelText: 'Dive Site Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // GPS Coordinates
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _latitudeController,
                    decoration: const InputDecoration(
                      labelText: 'Latitude',
                      hintText: '-90 to 90',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*')),
                    ],
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final lat = double.tryParse(value);
                        if (lat == null || lat < -90 || lat > 90) {
                          return 'Invalid';
                        }
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _longitudeController,
                    decoration: const InputDecoration(
                      labelText: 'Longitude',
                      hintText: '-180 to 180',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*')),
                    ],
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final lon = double.tryParse(value);
                        if (lon == null || lon < -180 || lon > 180) {
                          return 'Invalid';
                        }
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Max Depth and Duration
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _maxDepthController,
                    decoration: const InputDecoration(
                      labelText: 'Max Depth (m) *',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      final depth = double.tryParse(value);
                      if (depth == null || depth < 0 || depth > 300) {
                        return '0-300';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _durationController,
                    decoration: const InputDecoration(
                      labelText: 'Duration (min) *',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      final duration = int.tryParse(value);
                      if (duration == null || duration < 0 || duration > 999) {
                        return '0-999';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Water Temperature
            TextFormField(
              controller: _waterTemperatureController,
              decoration: const InputDecoration(
                labelText: 'Water Temperature (°C)',
                hintText: '-2 to 40',
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*')),
              ],
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final temp = double.tryParse(value);
                  if (temp == null || temp < -2 || temp > 40) {
                    return 'Must be -2 to 40';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Visibility
            DropdownButtonFormField<String>(
              value: _visibility,
              decoration: const InputDecoration(
                labelText: 'Visibility',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'excellent', child: Text('Excellent')),
                DropdownMenuItem(value: 'good', child: Text('Good')),
                DropdownMenuItem(value: 'fair', child: Text('Fair')),
                DropdownMenuItem(value: 'poor', child: Text('Poor')),
              ],
              onChanged: (value) {
                setState(() {
                  _visibility = value ?? 'good';
                });
              },
            ),
            const SizedBox(height: 16),

            // Notes
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes',
                hintText: 'Add any notes about the dive...',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
              maxLength: 1000,
              validator: (value) {
                if (value != null && value.length > 1000) {
                  return 'Notes must be 1000 characters or less';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Save Button
            ElevatedButton(
              onPressed: _isLoading ? null : _saveDive,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.green[600],
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey[300],
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Save Dive',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
