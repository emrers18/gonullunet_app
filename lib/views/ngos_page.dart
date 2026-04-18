import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gonullunet_app/widgets/ngos/ngos_card.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:gonullunet_app/logic/ngo_cubit.dart';
import 'package:gonullunet_app/logic/ngo_state.dart';
import 'package:gonullunet_app/repo/ngo_repository.dart';
import 'package:gonullunet_app/utils/app_colors.dart';

class NgosPage extends StatelessWidget {
  const NgosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NgoCubit(NgoRepository())..loadNgos(),
      child: const NgosView(),
    );
  }
}

class NgosView extends StatefulWidget {
  const NgosView({super.key});

  @override
  State<NgosView> createState() => _NgosViewState();
}

class _NgosViewState extends State<NgosView> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  String? _activeCity;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 750), () {
      context.read<NgoCubit>().searchNgos(query);
    });
  }

  void _openCityFilterSheet() {
    final cubit = context.read<NgoCubit>();
    final cities = cubit.availableCities;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Şehre Göre Filtrele',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryText,
                        ),
                      ),
                      if (_activeCity != null)
                        TextButton(
                          onPressed: () {
                            setState(() => _activeCity = null);
                            cubit.filterByCity(null);
                            Navigator.pop(sheetContext);
                          },
                          child: Text(
                            'Temizle',
                            style: GoogleFonts.plusJakartaSans(
                              color: AppColors.kSecondaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (cities.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Text(
                          'Henüz şehir bilgisi mevcut değil.',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    )
                  else
                    Flexible(
                      child: SingleChildScrollView(
                        child: Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: cities.map((city) {
                            final isSelected = _activeCity == city;
                            return ChoiceChip(
                              label: Text(city),
                              selected: isSelected,
                              onSelected: (selected) {
                                final selectedCity = selected ? city : null;
                                setState(() => _activeCity = selectedCity);
                                setSheetState(() {});
                                cubit.filterByCity(selectedCity);
                                Navigator.pop(sheetContext);
                              },
                              selectedColor: AppColors.kSecondaryColor,
                              backgroundColor: Colors.grey.shade100,
                              labelStyle: GoogleFonts.plusJakartaSans(
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.primaryText,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                                side: BorderSide(
                                  color: isSelected
                                      ? AppColors.kSecondaryColor
                                      : Colors.transparent,
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.kBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text(
          'Kurumlar',
          style: GoogleFonts.plusJakartaSans(
            color: AppColors.kTextColor,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            color: AppColors.kBackgroundColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: _onSearchChanged,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppColors.kTextMain,
                          ),
                          decoration: InputDecoration(
                            hintText: "STK veya kategori ara...",
                            hintStyle: TextStyle(color: Colors.grey.shade400),
                            prefixIcon:
                                Icon(Icons.search, color: Colors.grey.shade400),
                            border: InputBorder.none,
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      height: 56,
                      width: 56,
                      decoration: BoxDecoration(
                        color: _activeCity != null
                            ? AppColors.kPrimaryColor
                            : AppColors.kSecondaryColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: (_activeCity != null
                                    ? AppColors.kPrimaryColor
                                    : AppColors.kSecondaryColor)
                                .withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: Icon(
                          _activeCity != null ? Icons.filter_alt : Icons.tune,
                          color: Colors.white,
                        ),
                        onPressed: _openCityFilterSheet,
                      ),
                    ),
                  ],
                ),
                // Aktif filtre etiketi
                if (_activeCity != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          size: 15, color: AppColors.kPrimaryColor),
                      const SizedBox(width: 4),
                      Text(
                        'Filtre: ',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.kPrimaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _activeCity!,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                color: AppColors.kPrimaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 6),
                            GestureDetector(
                              onTap: () {
                                setState(() => _activeCity = null);
                                context.read<NgoCubit>().filterByCity(null);
                              },
                              child: const Icon(Icons.close,
                                  size: 14, color: AppColors.kPrimaryColor),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 20),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: BlocBuilder<NgoCubit, NgoState>(
              builder: (context, state) {
                if (state is NgoLoading) {
                  return const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.kPrimaryColor));
                }

                if (state is NgoError) {
                  return Center(child: Text(state.message));
                }

                if (state is NgoLoaded) {
                  if (state.ngos.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off,
                              size: 64, color: Colors.grey[300]),
                          const SizedBox(height: 16),
                          Text('Sonuç bulunamadı.',
                              style: TextStyle(color: Colors.grey[500])),
                        ],
                      ),
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: state.ngos.length,
                    itemBuilder: (context, index) {
                      final ngo = state.ngos[index];
                      return NgoCard(ngo: ngo);
                    },
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}
