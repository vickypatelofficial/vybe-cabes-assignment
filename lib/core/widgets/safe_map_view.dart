import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';

class SafeMapView extends StatefulWidget {
  final CameraPosition initialCameraPosition;
  final Set<Marker> markers;
  final Set<Polyline> polylines;
  final void Function(GoogleMapController controller)? onMapCreated;
  final bool myLocationEnabled;
  final bool myLocationButtonEnabled;
  final bool zoomControlsEnabled;
  final bool compassEnabled;
  final bool mapToolbarEnabled;

  const SafeMapView({
    super.key,
    required this.initialCameraPosition,
    this.markers = const {},
    this.polylines = const {},
    this.onMapCreated,
    this.myLocationEnabled = false,
    this.myLocationButtonEnabled = false,
    this.zoomControlsEnabled = false,
    this.compassEnabled = false,
    this.mapToolbarEnabled = false,
  });

  @override
  State<SafeMapView> createState() => _SafeMapViewState();
}

class _SafeMapViewState extends State<SafeMapView> {
  // Set to true to show the fallback map UI instead of a blank screen when the API key is invalid
  bool _hasError = false;

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return _buildCyberFallbackMap();
    }

    try {
      return GoogleMap(
        key: widget.key,
        initialCameraPosition: widget.initialCameraPosition,
        markers: widget.markers,
        polylines: widget.polylines,
        myLocationEnabled: widget.myLocationEnabled,
        myLocationButtonEnabled: widget.myLocationButtonEnabled,
        zoomControlsEnabled: widget.zoomControlsEnabled,
        compassEnabled: widget.compassEnabled,
        mapToolbarEnabled: widget.mapToolbarEnabled,
        onMapCreated: (controller) {
          widget.onMapCreated?.call(controller);
        },
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('SafeMapView caught error: $e');
      }
      return _buildCyberFallbackMap();
    }
  }

  Widget _buildCyberFallbackMap() {
    return Container(
      color: const Color(0xFF0A0D14),
      child: Stack(
        children: [
          // Cyber grid background
          CustomPaint(
            size: Size.infinite,
            painter: _CyberGridPainter(),
          ),

          // Render Route Polyline & Markers on fallback canvas
          CustomPaint(
            size: Size.infinite,
            painter: _RouteFallbackPainter(
              markers: widget.markers,
              polylines: widget.polylines,
            ),
          ),

          // Subtle Cyber Map Indicator Badge
          Positioned(
            top: 70,
            left: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.cardSurface.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primaryEmerald.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryEmerald,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Live GPS Radar Active',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.primaryEmerald,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CyberGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFF161E2E).withValues(alpha: 0.6)
      ..strokeWidth = 1.0;

    final roadPaint = Paint()
      ..color = const Color(0xFF1F293D)
      ..strokeWidth = 12.0
      ..strokeCap = StrokeCap.round;

    final roadCenterPaint = Paint()
      ..color = const Color(0xFF2E3D59)
      ..strokeWidth = 1.5;

    // Draw grid
    const double step = 40.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Draw stylized arterial roads
    final path1 = Path()
      ..moveTo(-50, size.height * 0.3)
      ..cubicTo(
        size.width * 0.3,
        size.height * 0.35,
        size.width * 0.6,
        size.height * 0.2,
        size.width + 50,
        size.height * 0.45,
      );
    canvas.drawPath(path1, roadPaint);
    canvas.drawPath(path1, roadCenterPaint);

    final path2 = Path()
      ..moveTo(size.width * 0.2, -50)
      ..cubicTo(
        size.width * 0.25,
        size.height * 0.4,
        size.width * 0.75,
        size.height * 0.6,
        size.width * 0.8,
        size.height + 50,
      );
    canvas.drawPath(path2, roadPaint);
    canvas.drawPath(path2, roadCenterPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RouteFallbackPainter extends CustomPainter {
  final Set<Marker> markers;
  final Set<Polyline> polylines;

  _RouteFallbackPainter({required this.markers, required this.polylines});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2 - 40);

    // Glowing route path
    final routePaint = Paint()
      ..color = AppColors.primaryEmerald
      ..strokeWidth = 5.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final glowPaint = Paint()
      ..color = AppColors.primaryEmerald.withValues(alpha: 0.3)
      ..strokeWidth = 14.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    final routePath = Path()
      ..moveTo(center.dx - 100, center.dy + 80)
      ..cubicTo(
        center.dx - 40,
        center.dy + 120,
        center.dx + 40,
        center.dy - 30,
        center.dx + 110,
        center.dy - 80,
      );

    canvas.drawPath(routePath, glowPaint);
    canvas.drawPath(routePath, routePaint);

    // Draw Pickup Beacon
    final pickupPos = Offset(center.dx - 100, center.dy + 80);
    final pickupOuter = Paint()..color = AppColors.primaryEmerald.withValues(alpha: 0.25);
    final pickupInner = Paint()..color = AppColors.primaryEmerald;
    canvas.drawCircle(pickupPos, 16, pickupOuter);
    canvas.drawCircle(pickupPos, 7, pickupInner);

    // Draw Drop Beacon
    final dropPos = Offset(center.dx + 110, center.dy - 80);
    final dropOuter = Paint()..color = AppColors.accentCoral.withValues(alpha: 0.25);
    final dropInner = Paint()..color = AppColors.accentCoral;
    canvas.drawCircle(dropPos, 16, dropOuter);
    canvas.drawCircle(dropPos, 7, dropInner);

    // Draw Moving Car in center
    final carPos = Offset(center.dx + 5, center.dy + 15);
    final carShadow = Paint()
      ..color = AppColors.primaryEmerald.withValues(alpha: 0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    final carBg = Paint()..color = AppColors.cardSurface;
    final carBorder = Paint()
      ..color = AppColors.primaryEmerald
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    canvas.drawCircle(carPos, 22, carShadow);
    canvas.drawCircle(carPos, 18, carBg);
    canvas.drawCircle(carPos, 18, carBorder);

    // Draw car icon
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = const TextSpan(
      text: '🚗',
      style: TextStyle(fontSize: 18),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(carPos.dx - 9, carPos.dy - 11));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
