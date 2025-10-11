import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/dive.dart';
import '../services/database_service.dart';
import 'edit_dive_screen.dart';

class EndDiveScreen extends StatefulWidget {
  const EndDiveScreen({super.key});

  @override
  State<EndDiveScreen> createState() => _EndDiveScreenState();
}

class _EndDiveScreenState extends State<EndDiveScreen> {
  bool _isLoading = true;
  List<Dive> _inProgressDives = [];
  int? _selectedDiveId;

  @override
  void initState() {
    super.initState();
    _loadInProgressDives();
  }

  /// Load all in-progress dives from database
  Future<void> _loadInProgressDives() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final db = DatabaseService.instance;
      final allDives = await db.getAllDives();

      // Get all in-progress dives by querying directly
      final dbInstance = await db.database;
      final result = await dbInstance.query(
        'dives',
        where: 'status = ?',
        whereArgs: ['in_progress'],
        orderBy: 'date DESC, time DESC',
      );

      final inProgressDives = result.map((map) => Dive.fromMap(map)).toList();

      setState(() {
        _inProgressDives = inProgressDives;
        // Auto-select if only one dive
        if (_inProgressDives.length == 1) {
          _selectedDiveId = _inProgressDives.first.id;
        }
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

  /// End the selected dive and navigate to edit screen
  Future<void> _endDive() async {
    if (_selectedDiveId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a dive to end'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Get the selected dive
      final db = DatabaseService.instance;
      final dive = await db.getDive(_selectedDiveId!);

      if (dive == null) {
        throw Exception('Dive not found');
      }

      // Parse start time to calculate duration
      final startDateTime = DateTime.parse('${dive.date}T${dive.time}:00');
      final endDateTime = DateTime.now();
      final durationMinutes = endDateTime.difference(startDateTime).inMinutes;

      // Update dive with end time and duration
      // Keep status as in_progress - will be set to completed in edit screen
      final updatedDive = dive.copyWith(
        duration: durationMinutes > 0 ? durationMinutes : 0,
        updatedAt: endDateTime.toIso8601String(),
      );

      await db.updateDive(updatedDive);

      setState(() {
        _isLoading = false;
      });

      // Navigate to edit dive screen with the dive
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => EditDiveScreen(dive: updatedDive),
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
            content: Text('Error ending dive: ${e.toString()}'),
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
        title: const Text('End Dive'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_inProgressDives.isEmpty) {
      return _buildNoDivesView();
    } else if (_inProgressDives.length == 1) {
      return _buildSingleDiveView();
    } else {
      return _buildMultipleDivesView();
    }
  }

  /// Build view when no in-progress dives exist
  Widget _buildNoDivesView() {
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
              'No Active Dives',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'You don\'t have any dives in progress.\nStart a new dive first!',
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

  /// Build view when exactly one in-progress dive exists
  Widget _buildSingleDiveView() {
    final dive = _inProgressDives.first;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.timer_off,
              size: 80,
              color: Colors.orange,
            ),
            const SizedBox(height: 24),
            Text(
              'End This Dive?',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.blue[900],
              ),
            ),
            const SizedBox(height: 32),
            _buildDiveCard(dive),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    backgroundColor: Colors.grey[400],
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                ElevatedButton(
                  onPressed: _endDive,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    backgroundColor: Colors.orange[600],
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    'End Dive',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Build view when multiple in-progress dives exist
  Widget _buildMultipleDivesView() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Select Dive to End',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blue[900],
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _inProgressDives.length,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemBuilder: (context, index) {
              final dive = _inProgressDives[index];
              return _buildDiveSelectionCard(dive);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  backgroundColor: Colors.grey[400],
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              ElevatedButton(
                onPressed: _selectedDiveId == null ? null : _endDive,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  backgroundColor: Colors.orange[600],
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey[300],
                ),
                child: const Text(
                  'End Selected Dive',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build dive info card (non-selectable)
  Widget _buildDiveCard(Dive dive) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('Started', '${dive.date} at ${dive.time}'),
          if (dive.country != null || dive.diveSiteName != null) ...[
            const SizedBox(height: 8),
            _buildInfoRow('Location', dive.getLocationDisplay()),
          ],
          const SizedBox(height: 8),
          _buildInfoRow('Status', 'In Progress', statusColor: Colors.orange),
        ],
      ),
    );
  }

  /// Build selectable dive card with radio button
  Widget _buildDiveSelectionCard(Dive dive) {
    final isSelected = _selectedDiveId == dive.id;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDiveId = dive.id;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[50] : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.2),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Radio<int>(
              value: dive.id!,
              groupValue: _selectedDiveId,
              onChanged: (value) {
                setState(() {
                  _selectedDiveId = value;
                });
              },
              activeColor: Colors.blue,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow('Started', '${dive.date} at ${dive.time}'),
                  if (dive.country != null || dive.diveSiteName != null) ...[
                    const SizedBox(height: 4),
                    _buildInfoRow('Location', dive.getLocationDisplay()),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build info row widget
  Widget _buildInfoRow(String label, String value, {Color? statusColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: statusColor ?? Colors.black87,
              fontWeight: statusColor != null ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }
}
