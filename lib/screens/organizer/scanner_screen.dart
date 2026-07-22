import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../blocs/scanner/scanner_bloc.dart';
import '../../blocs/scanner/scanner_event.dart';
import '../../blocs/scanner/scanner_state.dart';
import '../../blocs/sync/sync_bloc.dart';
import '../../blocs/sync/sync_event.dart';
import '../../blocs/sync/sync_state.dart';
import '../../models/event.dart';
import '../../theme/app_theme.dart';
import '../../utils/snackbar_utils.dart';

class ScannerScreen extends StatefulWidget {
  final EventModel event;

  const ScannerScreen({super.key, required this.event});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen>
    with SingleTickerProviderStateMixin {
  late final MobileScannerController _controller;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    context.read<ScannerBloc>().add(ScannerStarted(widget.event.id));
    context.read<SyncBloc>().add(StartSyncMonitor(widget.event.id));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    context.read<ScannerBloc>().add(ScannerStopped());
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocConsumer<ScannerBloc, ScannerState>(
        listener: (context, state) {
          if (state is CheckInQueued) {
            SnackbarUtils.showSuccess(context, '✅ Ticket queued for check-in!');
          } else if (state is CheckInDuplicate) {
            SnackbarUtils.showError(context, '⚠️ Already checked in!');
          } else if (state is CheckInInvalid) {
            SnackbarUtils.showError(context, '❌ Invalid ticket QR code');
          }
        },
        builder: (context, scannerState) {
          final Color frameColor = _frameColor(scannerState);

          return Stack(
            fit: StackFit.expand,
            children: [
              // Camera
              MobileScanner(
                controller: _controller,
                onDetect: (capture) {
                  final barcode = capture.barcodes.firstOrNull;
                  if (barcode?.rawValue != null) {
                    context
                        .read<ScannerBloc>()
                        .add(ScanDetected(barcode!.rawValue!));
                  }
                },
              ),

              // Dark vignette overlay
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    radius: 0.75,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.65),
                    ],
                  ),
                ),
              ),

              // Top bar
              SafeArea(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_rounded,
                                color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Scanner',
                                  style: GoogleFonts.outfit(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  widget.event.name,
                                  style: GoogleFonts.outfit(
                                    fontSize: 12,
                                    color: Colors.white60,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          // Sync status pill
                          BlocBuilder<SyncBloc, SyncState>(
                            builder: (context, syncState) {
                              return _SyncPill(state: syncState);
                            },
                          ),
                        ],
                      ),
                    ),

                    // Scanner frame
                    Expanded(
                      child: Center(
                        child: AnimatedBuilder(
                          animation: _pulseAnim,
                          builder: (_, __) {
                            return Transform.scale(
                              scale: scannerState is ScannerIdle
                                  ? _pulseAnim.value
                                  : 1.0,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Outer glow
                                  if (scannerState is! ScannerIdle)
                                    Container(
                                      width: 264,
                                      height: 264,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        color:
                                            frameColor.withOpacity(0.15),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                frameColor.withOpacity(0.5),
                                            blurRadius: 32,
                                            spreadRadius: 4,
                                          ),
                                        ],
                                      ),
                                    ),
                                  // Frame
                                  Container(
                                    width: 256,
                                    height: 256,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: frameColor,
                                        width: 2.5,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  // Corner accents
                                  ..._corners(frameColor),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    // Status panel
                    _StatusPanel(state: scannerState),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Color _frameColor(ScannerState state) {
    if (state is CheckInQueued) return AppTheme.success;
    if (state is CheckInDuplicate) return AppTheme.warning;
    if (state is CheckInInvalid) return AppTheme.error;
    if (state is ScanInProgress) return AppTheme.info;
    return Colors.white;
  }

  List<Widget> _corners(Color color) {
    const size = 24.0;
    const thick = 3.5;
    const offset = 128.0; // half of frame 256

    Widget corner(double top, double left, double right, double bottom) {
      return Positioned(
        top: top == 0 ? null : -offset,
        left: left == 0 ? null : -offset,
        right: right == 0 ? null : -offset,
        bottom: bottom == 0 ? null : -offset,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            border: Border(
              top: top > 0
                  ? BorderSide(color: color, width: thick)
                  : BorderSide.none,
              left: left > 0
                  ? BorderSide(color: color, width: thick)
                  : BorderSide.none,
              right: right > 0
                  ? BorderSide(color: color, width: thick)
                  : BorderSide.none,
              bottom: bottom > 0
                  ? BorderSide(color: color, width: thick)
                  : BorderSide.none,
            ),
          ),
        ),
      );
    }

    return []; // frame already handles corners; keep simple
  }
}

class _SyncPill extends StatelessWidget {
  final SyncState state;

  const _SyncPill({required this.state});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    IconData icon;
    String label;

    if (!state.isOnline) {
      bg = AppTheme.warning.withOpacity(0.2);
      fg = AppTheme.warning;
      icon = Icons.cloud_off_rounded;
      label = state.pendingWritesCount > 0
          ? '${state.pendingWritesCount} pending'
          : 'Offline';
    } else if (state.pendingWritesCount > 0) {
      bg = AppTheme.info.withOpacity(0.2);
      fg = AppTheme.info;
      icon = Icons.sync_rounded;
      label = 'Syncing…';
    } else {
      bg = AppTheme.success.withOpacity(0.2);
      fg = AppTheme.success;
      icon = Icons.cloud_done_rounded;
      label = 'Online';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: fg.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: fg, size: 14),
          const SizedBox(width: 5),
          Text(label,
              style: GoogleFonts.outfit(
                  fontSize: 11, fontWeight: FontWeight.w600, color: fg)),
        ],
      ),
    );
  }
}

class _StatusPanel extends StatelessWidget {
  final ScannerState state;

  const _StatusPanel({required this.state});

  @override
  Widget build(BuildContext context) {
    Color bg;
    IconData icon;
    String title;
    String subtitle;

    if (state is CheckInQueued) {
      bg = AppTheme.success;
      icon = Icons.check_circle_rounded;
      title = 'Queued for Check-in!';
      subtitle = 'Will sync to server automatically';
    } else if (state is CheckInDuplicate) {
      bg = AppTheme.warning;
      icon = Icons.warning_amber_rounded;
      title = 'Already Checked In';
      subtitle = 'This attendee was already scanned';
    } else if (state is CheckInInvalid) {
      bg = AppTheme.error;
      icon = Icons.cancel_rounded;
      title = 'Invalid Ticket';
      subtitle = 'This QR code is not recognised';
    } else if (state is ScanInProgress) {
      bg = AppTheme.info;
      icon = Icons.hourglass_top_rounded;
      title = 'Processing…';
      subtitle = 'Validating ticket';
    } else {
      bg = Colors.transparent;
      icon = Icons.qr_code_scanner_rounded;
      title = 'Ready to scan';
      subtitle = 'Point the camera at a QR code';
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
      decoration: BoxDecoration(
        color: bg == Colors.transparent
            ? Colors.black.withOpacity(0.7)
            : bg,
        borderRadius:
            const BorderRadius.vertical(top: Radius.zero),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.75),
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
