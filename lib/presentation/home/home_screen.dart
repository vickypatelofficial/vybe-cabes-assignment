import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_typography.dart';
import '../../core/utils/custom_map_markers.dart';
import '../../core/widgets/safe_map_view.dart';
import '../../data/services/location_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/tracking_provider.dart';
import '../auth/auth_screen.dart';
import '../finding_driver/finding_driver_screen.dart';
import '../ride_history/ride_history_screen.dart';
import 'location_search_screen.dart';
import 'widgets/ride_selection_sheet.dart';
import 'widgets/where_to_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GoogleMapController? _mapController;
  String? _darkMapStyle;
  LatLng _currentLocation = AppConstants.defaultLocation;

  @override
  void initState() {
    super.initState();
    _loadMapStyle();
    _fetchUserLocation();
  }

  Future<void> _loadMapStyle() async {}

  Future<void> _fetchUserLocation() async {
    final location = await LocationService.getCurrentUserLocation();
    if (mounted) {
      setState(() {
        _currentLocation = location;
      });
      context.read<BookingProvider>().setPickupCoordinates(location);
      _animateToLocation(location);
    }
  }

  void _animateToLocation(LatLng target, {double zoom = 15.0}) {
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: target, zoom: zoom),
      ),
    );
  }

  void _openLocationSearch(bool isPickup) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LocationSearchScreen(
          isPickup: isPickup,
          onLocationSelected: (location) {
            final booking = context.read<BookingProvider>();
            if (isPickup) {
              booking.setPickupLocation(location);
              if (booking.dropLocation != null) {
                _fitBounds(location.latLng, booking.dropLocation!.latLng);
              } else {
                _animateToLocation(location.latLng);
              }
            } else {
              booking.setDropLocation(location);
              _fitBounds(booking.pickupLocation.latLng, location.latLng);
            }
          },
        ),
      ),
    );
  }

  void _fitBounds(LatLng pickup, LatLng drop) {
    final southWestLat = pickup.latitude < drop.latitude ? pickup.latitude : drop.latitude;
    final southWestLng = pickup.longitude < drop.longitude ? pickup.longitude : drop.longitude;
    final northEastLat = pickup.latitude > drop.latitude ? pickup.latitude : drop.latitude;
    final northEastLng = pickup.longitude > drop.longitude ? pickup.longitude : drop.longitude;

    final bounds = LatLngBounds(
      southwest: LatLng(southWestLat - 0.01, southWestLng - 0.01),
      northeast: LatLng(northEastLat + 0.01, northEastLng + 0.01),
    );

    _mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 80));
  }

  void _handleBookRide() {
    final booking = context.read<BookingProvider>();
    final tracking = context.read<TrackingProvider>();

    if (booking.dropLocation == null || booking.selectedRideOption == null) return;

    tracking.startFindingDriver(
      pickup: booking.pickupLocation,
      drop: booking.dropLocation!,
      rideOption: booking.selectedRideOption!,
      paymentMethod: booking.selectedPaymentMethod,
    );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const FindingDriverScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final booking = context.watch<BookingProvider>();
    final user = auth.currentUser;

    final Set<Marker> markers = {
      Marker(
        markerId: const MarkerId('pickup_marker'),
        position: booking.pickupLocation.latLng,
        icon: CustomMapMarkers.pickupMarker ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(title: 'Pickup', snippet: booking.pickupLocation.name),
      ),
      if (booking.dropLocation != null)
        Marker(
          markerId: const MarkerId('drop_marker'),
          position: booking.dropLocation!.latLng,
          icon: CustomMapMarkers.dropMarker ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(title: 'Drop Destination', snippet: booking.dropLocation!.name),
        ),
    };

    return Scaffold(
      backgroundColor: AppColors.darkMidnight,
      body: Stack(
        children: [
          Positioned.fill(
            child: SafeMapView(
              key: const ValueKey('home_map'),
              initialCameraPosition: CameraPosition(
                target: _currentLocation,
                zoom: 15.0,
              ),
              markers: markers,
              myLocationEnabled: false,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              compassEnabled: false,
              mapToolbarEnabled: false,
              onMapCreated: (controller) {
                _mapController = controller;
                if (_darkMapStyle != null) {
                  _mapController!.setMapStyle(_darkMapStyle);
                }
              },
            ),
          ),

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.cardSurface.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: AppColors.primaryEmerald,
                          child: Text(
                            (user?.displayName.isNotEmpty == true ? user!.displayName[0] : 'V').toUpperCase(),
                            style: AppTypography.caption.copyWith(
                              color: AppColors.darkMidnight,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              user?.displayName ?? 'Vicky Patel',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '₹${user?.walletBalance.toStringAsFixed(0) ?? "850"} · ★ ${user?.rating ?? "4.95"}',
                              style: AppTypography.caption.copyWith(color: AppColors.primaryEmerald),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  Row(
                    children: [
                      IconButton.filled(
                        icon: const Icon(Icons.history_rounded, color: AppColors.textPrimary, size: 20),
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.cardSurface.withValues(alpha: 0.9),
                          side: const BorderSide(color: AppColors.cardBorder),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const RideHistoryScreen()),
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(
                        icon: const Icon(Icons.logout_rounded, color: AppColors.textMuted, size: 18),
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.cardSurface.withValues(alpha: 0.9),
                          side: const BorderSide(color: AppColors.cardBorder),
                        ),
                        onPressed: () async {
                          await auth.signOut();
                          if (context.mounted) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => const AuthScreen()),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ),
          ),

          Positioned(
            right: 20,
            bottom: booking.hasSelectedDestination ? 340 : 180,
            child: FloatingActionButton.small(
              backgroundColor: AppColors.cardSurface,
              foregroundColor: AppColors.primaryEmerald,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: const BorderSide(color: AppColors.cardBorder),
              ),
              onPressed: _fetchUserLocation,
              child: const Icon(Icons.my_location_rounded, size: 20),
            ),
          ),

          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: booking.hasSelectedDestination
                ? RideSelectionSheet(onBookRide: _handleBookRide)
                : WhereToCard(onTap: _openLocationSearch),
          ),
        ],
      ),
    );
  }
}
