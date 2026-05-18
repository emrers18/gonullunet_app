import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_map/flutter_map.dart';
import 'dart:ui' as ui;

import 'package:gonullunet_app/utils/app_colors.dart';
import 'package:gonullunet_app/constants/app_constants.dart';

import '../../logic/add_event_cubit.dart';
import '../../logic/add_event_state.dart';
import '../../logic/event_cubit.dart';
import '../../logic/user_cubit.dart';
import '../../logic/user_state.dart';
import '../../repo/event_repository.dart';
import '../../views/location_picker_page.dart';
import '../app_loading_indicator.dart';

class AddEventModal extends StatelessWidget {
  const AddEventModal({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AddEventCubit(context.read<EventRepository>()),
      child: const AddEventView(),
    );
  }
}

class AddEventView extends StatefulWidget {
  const AddEventView({super.key});

  @override
  State<AddEventView> createState() => _AddEventViewState();
}

class _AddEventViewState extends State<AddEventView> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _quotaController = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  LatLng? _selectedCoordinates;
  String? _selectedAddress;
  File? _selectedImage;
  String? _errorMessage;

  String _selectedCategory = 'Genel';
  final List<String> _categories = AppConstants.eventCategories;

  String _selectedType = 'Etkinlik';
  final List<String> _types = ['Etkinlik', 'Proje'];

  DateTime? _startDate;
  TimeOfDay? _startTime;
  DateTime? _endDate;
  TimeOfDay? _endTime;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _quotaController.dispose();
    super.dispose();
  }

  Future<void> _pickLocation() async {
    setState(() => _errorMessage = null);
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LocationPickerPage()),
    );
    if (result != null && result is Map) {
      setState(() {
        _selectedCoordinates = result['geoPoint'] as LatLng;
        _selectedAddress = result['address'] as String;
      });
    }
  }

  Future<void> _pickDateTime({required bool isStart}) async {
    DateTime initialDate = DateTime.now();
    DateTime firstDate = DateTime.now();

    if (!isStart && _startDate != null) {
      initialDate = _startDate!;
      firstDate = _startDate!;
    }

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme:
                const ColorScheme.light(primary: AppColors.kPrimaryColor),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate == null) return;

    if (!mounted) return;
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme:
                const ColorScheme.light(primary: AppColors.kPrimaryColor),
          ),
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
            child: child!,
          ),
        );
      },
    );

    if (pickedTime == null) return;

    setState(() {
      if (isStart) {
        _startDate = pickedDate;
        _startTime = pickedTime;
        if (_endDate == null || _endDate!.isBefore(_startDate!)) {
          _endDate = pickedDate;
          _endTime = TimeOfDay(
              hour: (pickedTime.hour + 2) % 24, minute: pickedTime.minute);
        }
      } else {
        _endDate = pickedDate;
        _endTime = pickedTime;
      }
    });
  }

  Future<void> _pickImage() async {
    setState(() => _errorMessage = null);
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50,
      );
      if (pickedFile != null) {
        setState(() => _selectedImage = File(pickedFile.path));
      }
    } catch (e) {
      setState(() => _errorMessage = "Resim seçilemedi: $e");
    }
  }

  void _saveEvent() {
    setState(() => _errorMessage = null);

    if (_titleController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Başlık boş bırakılamaz.');
      return;
    }
    if (_selectedAddress == null || _selectedCoordinates == null) {
      setState(() => _errorMessage = 'Lütfen haritadan bir konum seçin.');
      return;
    }
    if (_startDate == null ||
        _startTime == null ||
        _endDate == null ||
        _endTime == null) {
      setState(
          () => _errorMessage = 'Lütfen başlangıç ve bitiş zamanlarını seçin.');
      return;
    }

    // Tarih ve Saati birleştir
    final DateTime startDateTime = DateTime(_startDate!.year, _startDate!.month,
        _startDate!.day, _startTime!.hour, _startTime!.minute);

    final DateTime endDateTime = DateTime(_endDate!.year, _endDate!.month,
        _endDate!.day, _endTime!.hour, _endTime!.minute);

    // Mantık Kontrolü: Bitiş tarihi başlangıçtan önce olamaz
    if (endDateTime.isBefore(startDateTime)) {
      setState(() => _errorMessage = 'Bitiş tarihi başlangıçtan önce olamaz!');
      return;
    }

    int? quota;
    if (_quotaController.text.isNotEmpty) {
      quota = int.tryParse(_quotaController.text.trim());
    }

    // Cubit'e emir ver
    context.read<AddEventCubit>().addEvent(
          title: _titleController.text.trim(),
          description: _descController.text.trim(),
          location: _selectedAddress!,
          coordinates: _selectedCoordinates!,
          startDate: startDateTime,
          endDate: endDateTime,
          category: _selectedCategory,
          type: _selectedType,
          imageFile: _selectedImage,
          quota: quota,
        );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    // Tarih gösterimi için formatlayıcı
    String formatDateTime(DateTime? d, TimeOfDay? t) {
      if (d == null || t == null) return "Seçiniz";
      final dt = DateTime(d.year, d.month, d.day, t.hour, t.minute);
      return DateFormat('dd MMM yyyy, HH:mm', 'tr_TR').format(dt);
    }

    return BlocListener<AddEventCubit, AddEventState>(
      listener: (context, state) {
        if (state is AddEventSuccess) {
          context.read<EventCubit>().refresh();
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('İçerik başarıyla oluşturuldu!'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (state is AddEventError) {
          setState(() => _errorMessage = state.message);
        }
      },
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: EdgeInsets.fromLTRB(0, 12, 0, bottomInset),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'İptal',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    'Yeni Etkinlik',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryText,
                    ),
                  ),
                  BlocBuilder<AddEventCubit, AddEventState>(
                    builder: (context, state) {
                      if (state is AddEventLoading) {
                        return const AppLoadingIndicator(size: 28);
                      }
                      return ElevatedButton(
                        onPressed: _saveEvent,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.kPrimaryColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text(
                          'Yayınla',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const Divider(),

            if (_errorMessage != null)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                color: Colors.red.shade50,
                width: double.infinity,
                child: Text(
                  _errorMessage!,
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.red.shade700,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User Profile Section
                    BlocBuilder<UserCubit, UserState>(
                      builder: (context, state) {
                        String displayName = 'Gönüllü';
                        String? imageUrl;
                        if (state is UserLoaded) {
                          displayName = state.user.displayName;
                          imageUrl = state.user.imageUrl;
                        }
                        return Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: AppColors.lightPrimaryColor,
                              backgroundImage:
                                  (imageUrl != null && imageUrl.isNotEmpty)
                                      ? CachedNetworkImageProvider(imageUrl)
                                      : null,
                              child: (imageUrl == null || imageUrl.isEmpty)
                                  ? Text(displayName[0].toUpperCase())
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              displayName,
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    // Title Input
                    TextField(
                      controller: _titleController,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Etkinlik Başlığı',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        border: InputBorder.none,
                      ),
                    ),

                    // Description Input
                    TextField(
                      controller: _descController,
                      maxLines: null,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Etkinlik hakkında bilgi ver...',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        border: InputBorder.none,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Type & Category Selection
                    Row(
                      children: [
                        Expanded(
                          child: _buildDropdown(
                            label: 'Tür',
                            value: _selectedType,
                            items: _types,
                            onChanged: (val) =>
                                setState(() => _selectedType = val!),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildDropdown(
                            label: 'Kategori',
                            value: _selectedCategory,
                            items: _categories,
                            onChanged: (val) =>
                                setState(() => _selectedCategory = val!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Quota Input
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: TextField(
                        controller: _quotaController,
                        keyboardType: TextInputType.number,
                        style: GoogleFonts.plusJakartaSans(fontSize: 15),
                        decoration: InputDecoration(
                          hintText: 'Kontenjan (Opsiyonel)',
                          hintStyle: GoogleFonts.plusJakartaSans(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          icon: Icon(Icons.people_outline,
                              color: Colors.grey[400], size: 20),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Location Picker & Preview
                    Text(
                      'Konum',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _pickLocation,
                      child: Container(
                        height: _selectedCoordinates != null ? 200 : 80,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _selectedCoordinates != null
                                ? AppColors.primaryColor.withOpacity(0.3)
                                : Colors.grey[200]!,
                          ),
                        ),
                        child: _selectedCoordinates != null
                            ? Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: FlutterMap(
                                      options: MapOptions(
                                        initialCenter: _selectedCoordinates!,
                                        initialZoom: 15.0,
                                        interactionOptions:
                                            const InteractionOptions(
                                          flags: InteractiveFlag.none,
                                        ),
                                      ),
                                      children: [
                                        TileLayer(
                                          urlTemplate:
                                              'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}@2x.png',
                                          subdomains: const [
                                            'a',
                                            'b',
                                            'c',
                                            'd'
                                          ],
                                          userAgentPackageName:
                                              'com.gonullunet.app',
                                        ),
                                        MarkerLayer(
                                          markers: [
                                            Marker(
                                              point: _selectedCoordinates!,
                                              width: 50,
                                              height: 60,
                                              alignment: Alignment.topCenter,
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Container(
                                                    width: 40,
                                                    height: 40,
                                                    decoration: BoxDecoration(
                                                      color: AppColors
                                                          .kPrimaryColor,
                                                      shape: BoxShape.circle,
                                                      border: Border.all(
                                                          color: Colors.white,
                                                          width: 3),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: AppColors
                                                              .kPrimaryColor
                                                              .withOpacity(0.3),
                                                          blurRadius: 10,
                                                          offset: const Offset(
                                                              0, 4),
                                                        ),
                                                      ],
                                                    ),
                                                    child: Icon(
                                                      _selectedType == 'Proje'
                                                          ? Icons.work_rounded
                                                          : Icons.event_rounded,
                                                      color: Colors.white,
                                                      size: 20,
                                                    ),
                                                  ),
                                                  const CustomPaint(
                                                    size: Size(12, 10),
                                                    painter: _PinTailPainter(
                                                        color: AppColors
                                                            .kPrimaryColor),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.6),
                                        borderRadius:
                                            const BorderRadius.vertical(
                                          bottom: Radius.circular(16),
                                        ),
                                      ),
                                      child: Text(
                                        _selectedAddress ?? '',
                                        style: GoogleFonts.plusJakartaSans(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.1),
                                            blurRadius: 4,
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                              Icons.edit_location_alt_outlined,
                                              size: 14,
                                              color: AppColors.kPrimaryColor),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Değiştir',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.kPrimaryColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_location_alt_outlined,
                                      color: AppColors.kPrimaryColor
                                          .withOpacity(0.6)),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Haritadan Konum Seç',
                                    style: GoogleFonts.plusJakartaSans(
                                      color: AppColors.kPrimaryColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Date & Time Selectors
                    Row(
                      children: [
                        Expanded(
                          child: _buildDateTimePicker(
                            label: 'Başlangıç',
                            dateTimeText:
                                formatDateTime(_startDate, _startTime),
                            onTap: () => _pickDateTime(isStart: true),
                            icon: Icons.calendar_today_outlined,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildDateTimePicker(
                            label: 'Bitiş',
                            dateTimeText: formatDateTime(_endDate, _endTime),
                            onTap: () => _pickDateTime(isStart: false),
                            icon: Icons.event_available_outlined,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Image Selection
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: double.infinity,
                        height: 160,
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: _selectedImage != null
                            ? Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Image.file(
                                      _selectedImage!,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: 10,
                                    right: 10,
                                    child: GestureDetector(
                                      onTap: () =>
                                          setState(() => _selectedImage = null),
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: Colors.black54,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.close,
                                            color: Colors.white, size: 20),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_photo_alternate_outlined,
                                      size: 32, color: Colors.grey[400]),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Görsel Ekle (Opsiyonel)',
                                    style: GoogleFonts.plusJakartaSans(
                                      color: Colors.grey[500],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[400]),
              style: GoogleFonts.plusJakartaSans(
                color: Colors.black87,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateTimePicker({
    required String label,
    required String dateTimeText,
    required VoidCallback onTap,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Row(
              children: [
                Icon(icon,
                    size: 16, color: AppColors.kPrimaryColor.withOpacity(0.7)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    dateTimeText,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: dateTimeText == 'Seçiniz'
                          ? Colors.grey[400]
                          : Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PinTailPainter extends CustomPainter {
  final Color color;
  const _PinTailPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = ui.Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _PinTailPainter oldDelegate) =>
      color != oldDelegate.color;
}
