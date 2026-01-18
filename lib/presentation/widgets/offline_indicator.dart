import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../core/services/connectivity_service.dart';

/// Widget to show offline/online status indicator
class OfflineIndicator extends StatefulWidget {
  const OfflineIndicator({super.key});

  @override
  State<OfflineIndicator> createState() => _OfflineIndicatorState();
}

class _OfflineIndicatorState extends State<OfflineIndicator> {
  bool _isOnline = true;
  final Connectivity _connectivity = Connectivity();

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    _connectivity.onConnectivityChanged.listen((result) {
      _checkConnectivity();
    });
  }

  Future<void> _checkConnectivity() async {
    final isOnline = await ConnectivityService.hasConnectionWithTimeout();
    if (mounted) {
      setState(() {
        _isOnline = isOnline;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isOnline) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: Colors.orange,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.cloud_off,
            color: Colors.white,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Offline. Changes will sync when connection is restored.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
