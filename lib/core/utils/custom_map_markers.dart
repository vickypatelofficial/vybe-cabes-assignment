import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../constants/app_colors.dart';

class CustomMapMarkers {
  static BitmapDescriptor? pickupMarker;
  static BitmapDescriptor? dropMarker;
  static BitmapDescriptor? carMarker;

  static Future<void> initializeMarkers() async {
    pickupMarker ??= await _createCustomPinMarker(
      color: AppColors.primaryEmerald,
      iconData: Icons.my_location_rounded,
      label: 'Pickup',
    );

    dropMarker ??= await _createCustomPinMarker(
      color: AppColors.accentCoral,
      iconData: Icons.location_on_rounded,
      label: 'Drop',
    );

    carMarker ??= await _createCarMarker();
  }

  static Future<BitmapDescriptor> _createCustomPinMarker({
    required Color color,
    required IconData iconData,
    required String label,
    String? imageUrl,
  }) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    const double width = 120.0;
    const double height = 120.0;

    // Pin shadow
    final Paint shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(const Offset(width / 2, height / 2 + 4), 36, shadowPaint);

    // Outer ring
    final Paint outerPaint = Paint()..color = color;
    canvas.drawCircle(const Offset(width / 2, height / 2), 34, outerPaint);

    // Inner background circle (white border for image)
    final Paint innerPaint = Paint()..color = Colors.white;
    canvas.drawCircle(const Offset(width / 2, height / 2), 28, innerPaint);

    if (imageUrl != null) {
      try {
        final http.Response response = await http.get(Uri.parse(imageUrl));
        if (response.statusCode == 200) {
          final ui.Codec codec = await ui.instantiateImageCodec(response.bodyBytes);
          final ui.FrameInfo fi = await codec.getNextFrame();
          final ui.Image image = fi.image;

          // Create a circular clip path for the image
          final Path clipPath = Path()..addOval(Rect.fromCircle(
            center: Offset(width / 2, height / 2),
            radius: 26,
          ));
          canvas.save();
          canvas.clipPath(clipPath);

          // Draw the image scaled to fit the circle
          final Rect srcRect = Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble());
          final Rect dstRect = Rect.fromLTWH(width / 2 - 26, height / 2 - 26, 52, 52);
          canvas.drawImageRect(image, srcRect, dstRect, Paint());
          canvas.restore();
        }
      } catch (e) {
        // Fallback to icon on error
        _drawIconOnCanvas(canvas, iconData, color, width, height);
      }
    } else {
      // Draw background for icon
      final Paint iconBgPaint = Paint()..color = AppColors.darkMidnight;
      canvas.drawCircle(const Offset(width / 2, height / 2), 28, iconBgPaint);
      _drawIconOnCanvas(canvas, iconData, color, width, height);
    }

    final ui.Image finalImage = await pictureRecorder.endRecording().toImage(width.toInt(), height.toInt());
    final byteData = await finalImage.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.bytes(byteData!.buffer.asUint8List());
  }

  static void _drawIconOnCanvas(Canvas canvas, IconData iconData, Color color, double width, double height) {
    final TextPainter textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = TextSpan(
      text: String.fromCharCode(iconData.codePoint),
      style: TextStyle(
        fontSize: 28,
        fontFamily: iconData.fontFamily,
        package: iconData.fontPackage,
        color: color,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(width / 2 - textPainter.width / 2, height / 2 - textPainter.height / 2),
    );
  }

  static Future<BitmapDescriptor> _createCarMarker() async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    const double size = 96.0;

    // Glowing circle shadow
    final Paint glowPaint = Paint()
      ..color = AppColors.primaryEmerald.withValues(alpha: 0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawCircle(const Offset(size / 2, size / 2), 34, glowPaint);

    // Car background bubble
    final Paint bgPaint = Paint()..color = AppColors.cardSurface;
    canvas.drawCircle(const Offset(size / 2, size / 2), 28, bgPaint);

    // Border ring
    final Paint borderPaint = Paint()
      ..color = AppColors.primaryEmerald
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(const Offset(size / 2, size / 2), 28, borderPaint);

    // Car icon in center
    final TextPainter textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = TextSpan(
      text: String.fromCharCode(Icons.directions_car_rounded.codePoint),
      style: TextStyle(
        fontSize: 30,
        fontFamily: Icons.directions_car_rounded.fontFamily,
        package: Icons.directions_car_rounded.fontPackage,
        color: AppColors.primaryEmerald,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(size / 2 - textPainter.width / 2, size / 2 - textPainter.height / 2),
    );

    final ui.Image image = await pictureRecorder.endRecording().toImage(size.toInt(), size.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.bytes(byteData!.buffer.asUint8List());
  }
}
