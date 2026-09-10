import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/custom_map_markers.dart';
import '../../core/widgets/safe_map_view.dart';
import '../../providers/booking_provider.dart';
import '../../providers/history_provider.dart';
import '../../providers/tracking_provider.dart';
import '../home/home_screen.dart';
import '../trip_completed/trip_completed_screen.dart';
import 'widgets/driver_arrived_dialog.dart';
import 'widgets/driver_bottom_card.dart';

class LiveTrackingScreen extends StatefulWidget {
  const LiveTrackingScreen({super.key});

  @override
  State<LiveTrackingScreen> createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends State<LiveTrackingScreen> {
  GoogleMapController? _mapController;
  String? _darkMapStyle;
  bool _hasShownArrivedDialog = false;
  bool _hasNavigatedToCompleted = false;

  @override
  void initState() {
    super.initState();
    _loadMapStyle();
  }

  Future<void> _loadMapStyle() async {
    // Map style removed for simple default styling
  }

  void _onDriverArrived(TrackingProvider tracking) {
    if (_hasShownArrivedDialog || !mounted) return;
    _hasShownArrivedDialog = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => DriverArrivedDialog(
        driver: tracking.driver!,
        onStartTrip: () {
          Navigator.pop(context);
          tracking.startTripToDestination();
        },
      ),
    );
  }

  void _onTripCompleted(TrackingProvider tracking) {
    if (_hasNavigatedToCompleted || !mounted) return;
    _hasNavigatedToCompleted = true;

    // Save completed trip in history provider
    if (tracking.activeTrip != null) {
      context.read<HistoryProvider>().addTrip(tracking.activeTrip!);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const TripCompletedScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final tracking = context.watch<TrackingProvider>();
    final booking = context.watch<BookingProvider>();

    if (tracking.hasDriverArrived && !_hasShownArrivedDialog) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _onDriverArrived(tracking));
    }

    if (tracking.isTripCompleted && !_hasNavigatedToCompleted) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _onTripCompleted(tracking));
    }

    final driverPos = tracking.driverLocation ?? booking.pickupLocation.latLng;

    final Set<Marker> markers = {
      Marker(
        markerId: const MarkerId('pickup_marker'),
        position: booking.pickupLocation.latLng,
        icon: CustomMapMarkers.pickupMarker ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ),
      if (booking.dropLocation != null)
        Marker(
          markerId: const MarkerId('drop_marker'),
          position: booking.dropLocation!.latLng,
          icon: CustomMapMarkers.dropMarker ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      Marker(
        markerId: const MarkerId('car_marker'),
        position: driverPos,
        rotation: tracking.driverBearing,
        anchor: const Offset(0.5, 0.5),
        flat: true,
        icon: CustomMapMarkers.carMarker ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
      ),
    };

    final Set<Polyline> polylines = {
      if (tracking.currentPath.isNotEmpty)
        Polyline(
          polylineId: const PolylineId('route_path'),
          points: tracking.currentPath,
          color: AppColors.primaryEmerald,
          width: 5,
        ),
    };

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.darkMidnight,
        body: Stack(
          children: [
            Positioned.fill(
              child: SafeMapView(
                key: const ValueKey('tracking_map'),
                initialCameraPosition: CameraPosition(
                  target: driverPos,
                  zoom: 16.0,
                ),
                markers: markers,
                polylines: polylines,
                myLocationEnabled: false,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                compassEnabled: false,
                onMapCreated: (controller) {
                  _mapController = controller;
                  if (_darkMapStyle != null) {
                    _mapController!.setMapStyle(_darkMapStyle);
                  }
                },
              ),
            ),

            Positioned(
              right: 20,
              bottom: 270,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FloatingActionButton.small(
                    heroTag: 'zoom_in',
                    backgroundColor: AppColors.cardSurface,
                    foregroundColor: AppColors.textPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: const BorderSide(color: AppColors.cardBorder),
                    ),
                    onPressed: () {
                      _mapController?.animateCamera(CameraUpdate.zoomIn());
                    },
                    child: const Icon(Icons.add_rounded, size: 20),
                  ),
                  const SizedBox(height: 8),
                  FloatingActionButton.small(
                    heroTag: 'zoom_out',
                    backgroundColor: AppColors.cardSurface,
                    foregroundColor: AppColors.textPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: const BorderSide(color: AppColors.cardBorder),
                    ),
                    onPressed: () {
                      _mapController?.animateCamera(CameraUpdate.zoomOut());
                    },
                    child: const Icon(Icons.remove_rounded, size: 20),
                  ),
                  const SizedBox(height: 8),
                  FloatingActionButton.small(
                    heroTag: 'recenter',
                    backgroundColor: AppColors.cardSurface,
                    foregroundColor: AppColors.primaryEmerald,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: const BorderSide(color: AppColors.cardBorder),
                    ),
                    onPressed: () {
                      if (tracking.driverLocation != null) {
                        _mapController?.animateCamera(
                          CameraUpdate.newCameraPosition(
                            CameraPosition(target: tracking.driverLocation!, zoom: 16.5),
                          ),
                        );
                      }
                    },
                    child: const Icon(Icons.navigation_rounded, size: 20),
                  ),
                ],
              ),
            ),

            // Driver Card Bottom Sheet
            if (tracking.driver != null)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: DriverBottomCard(
                  driver: tracking.driver!,
                  onCancel: () {
                    tracking.cancelBooking();
                    booking.clearDestination();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const HomeScreen()),
                      (route) => false,
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
