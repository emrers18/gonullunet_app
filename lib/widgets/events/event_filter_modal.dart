import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gonullunet_app/l10n/app_localizations.dart';
import 'package:gonullunet_app/utils/app_colors.dart';
import 'package:gonullunet_app/utils/category_localizer.dart';
import 'package:intl/intl.dart';

import '../../constants/app_constants.dart';
import '../../logic/event_cubit.dart';

class EventFilterModal extends StatefulWidget {
  const EventFilterModal({super.key});

  @override
  State<EventFilterModal> createState() => _EventFilterModalState();
}

class _EventFilterModalState extends State<EventFilterModal> {
  String? _selectedCity;
  String? _selectedCategory;
  DateTimeRange? _selectedDateRange;

  // Listeler
  final List<String> _cities = [
    'İstanbul',
    'Ankara',
    'İzmir',
    'Bursa',
    'Antalya',
    'Leiden'
  ];
  final List<String> _categories = ['Tümü', ...AppConstants.eventCategories];

  void _pickDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme:
                const ColorScheme.light(primary: AppColors.primaryColor),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }

  void _applyFilters() {
    context.read<EventCubit>().filterEvents(
          city: _selectedCity,
          category: _selectedCategory,
          dateRange: _selectedDateRange,
        );
    Navigator.pop(context);
  }

  void _clearFilters() {
    context.read<EventCubit>().clearFilters();
    Navigator.pop(context);
  }

  // Ortak Input Dekorasyonu (Tailwind stilini yansıtmak için)
  InputDecoration _buildInputDecoration(String hint, IconData icon) {
    return InputDecoration(
      labelText: hint,
      labelStyle: TextStyle(color: Colors.grey[600]),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      filled: true,
      fillColor: Colors.white,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12), // rounded-xl
        borderSide: BorderSide(color: Colors.grey.shade300), // border-gray-300
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
            color: AppColors.primaryColor, width: 2), // focus:ring-primary
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      suffixIcon: Icon(icon, color: Colors.grey[400]), // text-gray-400
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(24)), // rounded-t-3xl
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // --- DRAG HANDLE (SÜRÜKLEME ÇUBUĞU) ---
          Center(
            child: Container(
              width: 48, // w-12
              height: 6, // h-1.5
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(3), // rounded-full
              ),
            ),
          ),
          const SizedBox(height: 24),

          // --- BAŞLIK VE TEMİZLE BUTONU ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.filterTitle,
                style: const TextStyle(
                  fontSize: 24, // text-2xl
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937), // text-gray-900
                ),
              ),
              TextButton(
                onPressed: _clearFilters,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red[500], // text-red-500
                  textStyle: const TextStyle(fontWeight: FontWeight.w600),
                ),
                child: Text(l10n.clear),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // --- ŞEHİR SEÇİMİ ---
          DropdownButtonFormField<String>(
            value: _selectedCity,
            icon: const SizedBox
                .shrink(), // Varsayılan ikonu gizle, decoration'da var
            decoration:
                _buildInputDecoration(l10n.cityLabel, Icons.arrow_drop_down),
            items: _cities.map((city) {
              return DropdownMenuItem(value: city, child: Text(city));
            }).toList(),
            onChanged: (val) => setState(() => _selectedCity = val),
            dropdownColor: Colors.white,
          ),
          const SizedBox(height: 16),

          // --- ETKİNLİK TÜRÜ ---
          DropdownButtonFormField<String>(
            value: _selectedCategory,
            icon: const SizedBox.shrink(),
            decoration: _buildInputDecoration(
                l10n.eventCategoryLabel, Icons.arrow_drop_down),
            items: _categories.map((cat) {
              return DropdownMenuItem(
                  value: cat,
                  child: Text(CategoryLocalizer.category(l10n, cat)));
            }).toList(),
            onChanged: (val) => setState(() => _selectedCategory = val),
            dropdownColor: Colors.white,
          ),
          const SizedBox(height: 16),

          // --- TARİH ARALIĞI ---
          InkWell(
            onTap: _pickDateRange,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _selectedDateRange == null
                        ? l10n.selectDateRange
                        : '${DateFormat('dd/MM').format(_selectedDateRange!.start)} - ${DateFormat('dd/MM').format(_selectedDateRange!.end)}',
                    style: TextStyle(
                      fontSize: 16,
                      color: _selectedDateRange == null
                          ? Colors.grey[600]
                          : const Color(0xFF374151), // text-gray-700
                    ),
                  ),
                  Icon(Icons.calendar_today, color: Colors.grey[400]),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32), // mt-8

          // --- UYGULA BUTONU ---
          ElevatedButton(
            onPressed: _applyFilters,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16), // py-4
              elevation: 4,
              shadowColor: AppColors.primaryColor.withOpacity(0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12), // rounded-xl
              ),
            ),
            child: Text(
              l10n.apply,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // --- ALT ÇİZGİ (iOS Home Indicator Mimic) ---
          Center(
            child: Container(
              width: 128, // w-32
              height: 4, // h-1
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
