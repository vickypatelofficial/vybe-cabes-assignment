import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../data/models/location_model.dart';
import '../../data/services/places_service.dart';
import '../../providers/booking_provider.dart';

class LocationSearchScreen extends StatefulWidget {
  final bool isPickup;
  final ValueChanged<LocationModel> onLocationSelected;

  const LocationSearchScreen({
    super.key,
    required this.isPickup,
    required this.onLocationSelected,
  });

  @override
  State<LocationSearchScreen> createState() => _LocationSearchScreenState();
}

class _LocationSearchScreenState extends State<LocationSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<LocationModel> _suggestions = [];
  bool _isLoading = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    final booking = context.read<BookingProvider>();
    _suggestions = booking.popularLocations;
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
    if (query.isEmpty) {
      final booking = context.read<BookingProvider>();
      setState(() {
        _suggestions = booking.popularLocations;
        _isLoading = false;
      });
      return;
    }

    setState(() => _isLoading = true);

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      final results = await PlacesService.getSuggestions(query);
      if (mounted) {
        setState(() {
          _suggestions = results;
          _isLoading = false;
        });
      }
    });
  }

  void _handleSelection(LocationModel location) async {
    setState(() => _isLoading = true);
    final fullLocation = await PlacesService.getPlaceDetails(location);
    if (mounted && fullLocation != null) {
      widget.onLocationSelected(fullLocation);
      Navigator.pop(context);
    }
    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.isPickup ? 'Pickup Location' : 'Destination',
          style: AppTypography.heading2.copyWith(fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                onChanged: _onSearchChanged,
                style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: widget.isPickup ? 'Search pickup location...' : 'Search destination...',
                  hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted),
                  prefixIcon: Icon(
                    Icons.location_on_outlined, 
                    color: widget.isPickup ? AppColors.primaryEmerald : AppColors.accentCoral, 
                    size: 20,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: AppColors.textMuted, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            _onSearchChanged('');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: AppColors.cardSurfaceLight,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.cardBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.cardBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.primaryEmerald, width: 1.5),
                  ),
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Text(
                    _searchController.text.isEmpty ? 'Popular Locations' : 'Search Results',
                    style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                  ),
                  if (_isLoading) ...[
                    const Spacer(),
                    const SizedBox(
                      height: 12,
                      width: 12,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryEmerald),
                    ),
                  ]
                ],
              ),
            ),
            
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _suggestions.length,
                separatorBuilder: (_, _) => const Divider(color: AppColors.cardBorder, height: 1),
                itemBuilder: (context, index) {
                  final loc = _suggestions[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: widget.isPickup 
                            ? AppColors.primaryEmerald.withValues(alpha: 0.1)
                            : AppColors.accentCoral.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.place_rounded,
                        color: widget.isPickup ? AppColors.primaryEmerald : AppColors.accentCoral,
                        size: 20,
                      ),
                    ),
                    title: Text(loc.name, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      loc.address,
                      style: AppTypography.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () => _handleSelection(loc),
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
