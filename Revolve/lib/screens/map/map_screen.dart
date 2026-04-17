import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../../../services/issue_service.dart';
import '../../../models/issue_model.dart';

/// Interactive map screen showing all reported issues
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  Set<Marker> _markers = {};
  Issue? _selectedIssue;

  // Default location (India)
  final LatLng _defaultLocation = const LatLng(15.2993, 74.1240); // Goa, India

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _loadIssues();
  }

  /// Get current GPS location
  Future<void> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentPosition = position;
      });

      _mapController?.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(position.latitude, position.longitude),
        ),
      );
    } catch (e) {
      debugPrint('Error getting location: $e');
    }
  }

  /// Load issues and create markers
  Future<void> _loadIssues() async {
    final issueService = Provider.of<IssueService>(context, listen: false);
    await issueService.fetchIssues();
    _createMarkers();
  }

  /// Create map markers from issues
  void _createMarkers() {
    final issueService = Provider.of<IssueService>(context, listen: false);
    final markers = <Marker>{};

    for (var issue in issueService.issues) {
      markers.add(
        Marker(
          markerId: MarkerId(issue.id),
          position: LatLng(issue.latitude, issue.longitude),
          icon: _getMarkerIcon(issue.status),
          onTap: () {
            setState(() {
              _selectedIssue = issue;
            });
          },
          infoWindow: InfoWindow(
            title: issue.title,
            snippet: issue.category.name.toUpperCase(),
          ),
        ),
      );
    }

    setState(() {
      _markers = markers;
    });
  }

  /// Get marker color based on issue status
  BitmapDescriptor _getMarkerIcon(IssueStatus status) {
    switch (status) {
      case IssueStatus.resolved:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
      case IssueStatus.inProgress:
        return BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueOrange);
      case IssueStatus.unresolved:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
    }
  }

  Color _getStatusColor(IssueStatus status) {
    switch (status) {
      case IssueStatus.resolved:
        return Colors.green;
      case IssueStatus.inProgress:
        return Colors.orange;
      case IssueStatus.unresolved:
        return Colors.red;
    }
  }

  String _getStatusLabel(IssueStatus status) {
    switch (status) {
      case IssueStatus.resolved:
        return 'Resolved';
      case IssueStatus.inProgress:
        return 'In Progress';
      case IssueStatus.unresolved:
        return 'Unresolved';
    }
  }

  @override
  Widget build(BuildContext context) {
    final initialPosition = _currentPosition != null
        ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
        : _defaultLocation;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Issue Map'),
        actions: [
          // Legend button
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Map Legend'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildLegendItem(Colors.red, 'Unresolved Issues'),
                      _buildLegendItem(Colors.orange, 'In Progress'),
                      _buildLegendItem(Colors.green, 'Resolved Issues'),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Google Map
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: initialPosition,
              zoom: 14,
            ),
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            onMapCreated: (controller) {
              _mapController = controller;
            },
            onTap: (_) {
              // Close issue detail card when tapping map
              setState(() {
                _selectedIssue = null;
              });
            },
          ),

          // Issue detail card
          if (_selectedIssue != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildIssueCard(_selectedIssue!),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _getCurrentLocation();
        },
        backgroundColor: const Color(0xFF2196F3),
        child: const Icon(Icons.my_location),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Text(label),
        ],
      ),
    );
  }

  Widget _buildIssueCard(Issue issue) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Image
          if (issue.imageUrls.isNotEmpty)
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                issue.imageUrls.first,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(issue.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getStatusLabel(issue.status),
                    style: TextStyle(
                      color: _getStatusColor(issue.status),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Title
                Text(
                  issue.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),

                // Category
                Row(
                  children: [
                    Icon(Icons.category_outlined,
                        size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      issue.category.name.toUpperCase(),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Location
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        issue.address,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // View details button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // Navigate to issue detail screen
                      // (Implementation depends on your navigation setup)
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2196F3),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('View Details'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
