import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/dive.dart';
import '../services/database_service.dart';

class DiveLogScreen extends StatefulWidget {
  const DiveLogScreen({super.key});

  @override
  State<DiveLogScreen> createState() => _DiveLogScreenState();
}

class _DiveLogScreenState extends State<DiveLogScreen> {
  List<Dive> _allDives = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAllDives();
  }

  /// Load all dives (both completed and in-progress) from database
  Future<void> _loadAllDives() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Get all dives directly from database (including in-progress)
      final db = await DatabaseService.instance.database;
      final result = await db.query(
        'dives',
        orderBy: 'date DESC, time DESC',
      );

      final dives = result.map((map) => Dive.fromMap(map)).toList();

      setState(() {
        _allDives = dives;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading dives: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  /// Show dive details in a dialog
  void _showDiveDetails(Dive dive) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              dive.status == 'in_progress' ? Icons.timer : Icons.check_circle,
              color: dive.status == 'in_progress' ? Colors.orange : Colors.green,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                dive.status == 'in_progress' ? 'Dive In Progress' : 'Dive Details',
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('ID', dive.id?.toString() ?? 'N/A', Icons.tag),
              const Divider(),
              _buildDetailRow('Date', dive.date, Icons.calendar_today),
              _buildDetailRow('Time', dive.time, Icons.access_time),
              const Divider(),
              _buildDetailRow('Status', dive.status.toUpperCase(), Icons.info),
              const Divider(),
              _buildDetailRow('Country', dive.country ?? 'Not specified', Icons.flag),
              _buildDetailRow('Dive Site', dive.diveSiteName ?? 'Not specified', Icons.location_on),
              if (dive.latitude != null && dive.longitude != null) ...[
                _buildDetailRow(
                  'GPS Coordinates',
                  '${dive.latitude!.toStringAsFixed(6)}, ${dive.longitude!.toStringAsFixed(6)}',
                  Icons.gps_fixed,
                ),
              ],
              const Divider(),
              _buildDetailRow('Max Depth', '${dive.maxDepth} m', Icons.arrow_downward),
              _buildDetailRow('Duration', '${dive.duration} min', Icons.timer),
              if (dive.waterTemperature != null)
                _buildDetailRow('Water Temp', '${dive.waterTemperature} °C', Icons.thermostat),
              if (dive.visibility != null)
                _buildDetailRow('Visibility', dive.visibility!, Icons.visibility),
              if (dive.notes != null && dive.notes!.isNotEmpty) ...[
                const Divider(),
                _buildDetailRow('Notes', dive.notes!, Icons.notes),
              ],
              const Divider(),
              _buildDetailRow('Created At', _formatTimestamp(dive.createdAt), Icons.add_circle),
              _buildDetailRow('Updated At', _formatTimestamp(dive.updatedAt), Icons.update),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('CLOSE'),
          ),
        ],
      ),
    );
  }

  /// Build a detail row for the dialog
  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.blue[700]),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Format ISO 8601 timestamp for display
  String _formatTimestamp(String isoString) {
    try {
      final dateTime = DateTime.parse(isoString);
      return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
    } catch (e) {
      return isoString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dive Log'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAllDives,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadAllDives,
                child: const Text('RETRY'),
              ),
            ],
          ),
        ),
      );
    }

    if (_allDives.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.scuba_diving, size: 80, color: Colors.grey[400]),
              const SizedBox(height: 24),
              Text(
                'No dives logged yet',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Start your first dive to see it here!',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAllDives,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _allDives.length,
        itemBuilder: (context, index) {
          final dive = _allDives[index];
          return _DiveCard(
            dive: dive,
            onTap: () => _showDiveDetails(dive),
          );
        },
      ),
    );
  }
}

/// Widget for displaying a single dive in the list
class _DiveCard extends StatelessWidget {
  final Dive dive;
  final VoidCallback onTap;

  const _DiveCard({
    required this.dive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isInProgress = dive.status == 'in_progress';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isInProgress
            ? const BorderSide(color: Colors.orange, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with status badge
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${dive.date} ${dive.time}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isInProgress)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'IN PROGRESS',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    )
                  else
                    const Icon(
                      Icons.check_circle,
                      size: 20,
                      color: Colors.green,
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Location
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 18,
                    color: Colors.blue[700],
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      dive.getLocationDisplay(),
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Dive stats
              Row(
                children: [
                  _buildStatChip(
                    Icons.arrow_downward,
                    '${dive.maxDepth}m',
                    Colors.blue,
                  ),
                  const SizedBox(width: 8),
                  _buildStatChip(
                    Icons.timer,
                    '${dive.duration}min',
                    Colors.green,
                  ),
                  if (dive.waterTemperature != null) ...[
                    const SizedBox(width: 8),
                    _buildStatChip(
                      Icons.thermostat,
                      '${dive.waterTemperature}°C',
                      Colors.orange,
                    ),
                  ],
                ],
              ),

              // Debug info (ID)
              const SizedBox(height: 8),
              Text(
                'ID: ${dive.id ?? "N/A"}',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[500],
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
