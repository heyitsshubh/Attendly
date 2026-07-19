import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../blocs/scanner/scanner_bloc.dart';
import '../../blocs/scanner/scanner_event.dart';
import '../../blocs/scanner/scanner_state.dart';
import '../../blocs/sync/sync_bloc.dart';
import '../../blocs/sync/sync_state.dart';
import '../../models/event.dart';

class ScannerScreen extends StatefulWidget {
  final EventModel event;

  const ScannerScreen({super.key, required this.event});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  late final MobileScannerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController();
    context.read<ScannerBloc>().add(ScannerStarted(widget.event.id));
    context.read<SyncBloc>().add(StartSyncMonitor(widget.event.id));
  }

  @override
  void dispose() {
    context.read<ScannerBloc>().add(ScannerStopped());
    _controller.dispose();
    super.dispose();
  }

  Color _stateColor(ScannerState state) {
    if (state is CheckInQueued) return Colors.green;
    if (state is CheckInDuplicate) return Colors.orange;
    if (state is CheckInInvalid) return Colors.red;
    if (state is ScanInProgress) return Colors.blue;
    return Colors.transparent;
  }

  String _stateMessage(ScannerState state) {
    if (state is CheckInQueued) return '✓ Queued for check-in';
    if (state is CheckInDuplicate) return '⚠ Already checked in';
    if (state is CheckInInvalid) return '✗ Invalid ticket';
    if (state is ScanInProgress) return '⏳ Processing...';
    return 'Ready to scan';
  }

  IconData _stateIcon(ScannerState state) {
    if (state is CheckInQueued) return Icons.check_circle_outline;
    if (state is CheckInDuplicate) return Icons.warning_amber_rounded;
    if (state is CheckInInvalid) return Icons.cancel_outlined;
    return Icons.qr_code_scanner;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          widget.event.name,
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          // Sync Status Indicator
          BlocBuilder<SyncBloc, SyncState>(
            builder: (context, syncState) {
              if (!syncState.isOnline) {
                return Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: Row(
                    children: [
                      const Icon(Icons.cloud_off, color: Colors.orange, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        syncState.pendingWritesCount > 0
                            ? '${syncState.pendingWritesCount} pending'
                            : 'Offline',
                        style: const TextStyle(color: Colors.orange, fontSize: 13),
                      ),
                    ],
                  ),
                );
              }
              if (syncState.pendingWritesCount > 0) {
                return Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Syncing ${syncState.pendingWritesCount}...',
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                );
              }
              return Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: Row(
                  children: const [
                    Icon(Icons.cloud_done, color: Colors.green, size: 18),
                    SizedBox(width: 4),
                    Text('Online', style: TextStyle(color: Colors.green, fontSize: 13)),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<ScannerBloc, ScannerState>(
        builder: (context, scannerState) {
          final overlayColor = _stateColor(scannerState);

          return Stack(
            children: [
              // Camera feed
              MobileScanner(
                controller: _controller,
                onDetect: (capture) {
                  final barcode = capture.barcodes.firstOrNull;
                  if (barcode != null && barcode.rawValue != null) {
                    context
                        .read<ScannerBloc>()
                        .add(ScanDetected(barcode.rawValue!));
                  }
                },
              ),

              // Semi-transparent scanner frame overlay
              Center(
                child: Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: scannerState is ScannerIdle
                          ? Colors.white
                          : overlayColor,
                      width: 3,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              // Status banner at bottom
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  color: overlayColor.withOpacity(0.9),
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _stateIcon(scannerState),
                        color: Colors.white,
                        size: 36,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _stateMessage(scannerState),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
