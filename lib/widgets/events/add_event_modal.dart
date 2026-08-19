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

import 'package:gonullunet_app/l10n/app_localizations.dart';
import 'package:gonullunet_app/utils/app_messages.dart';
import 'package:gonullunet_app/utils/app_colors.dart';
import 'package:gonullunet_app/utils/category_localizer.dart';
import 'package:gonullunet_app/constants/app_constants.dart';
import 'package:gonullunet_app/utils/responsive.dart';

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
  DateTime? _lastApplyDate;
  TimeOfDay? _lastApplyTime;

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

  Future<void> _pickDateTime({required String type}) async {
    DateTime initialDate = DateTime.now();
    DateTime firstDate = DateTime.now();
    DateTime lastDate = DateTime(2101);

    if (type == 'end' && _startDate != null) {
      initialDate = _startDate!;
      firstDate = _startDate!;
    } else if (type == 'lastApply') {
      if (_startDate != null) {
        lastDate = _startDate!;
      }
    }

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
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
      if (type == 'start') {
        _startDate = pickedDate;
        _startTime = pickedTime;
        if (_endDate == null || _endDate!.isBefore(_startDate!)) {
          _endDate = pickedDate;
          _endTime = TimeOfDay(
              hour: (pickedTime.hour + 2) % 24, minute: pickedTime.minute);
        }
        if (_lastApplyDate != null) {
          final startDateTime = DateTime(_startDate!.year, _startDate!.month,
              _startDate!.day, _startTime!.hour, _startTime!.minute);
          final lastApplyDateTime = DateTime(_lastApplyDate!.year, _lastApplyDate!.month,
              _lastApplyDate!.day, _lastApplyTime!.hour, _lastApplyTime!.minute);
          if (lastApplyDateTime.isAfter(startDateTime)) {
            _lastApplyDate = _startDate;
            _lastApplyTime = _startTime;
          }
        }
      } else if (type == 'end') {
        _endDate = pickedDate;
        _endTime = pickedTime;
      } else if (type == 'lastApply') {
        _lastApplyDate = pickedDate;
        _lastApplyTime = pickedTime;
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
      setState(() =>
          _errorMessage = AppLocalizations.of(context).imagePickFailed('$e'));
    }
  }

  void _saveEvent() {
    final l10n = AppLocalizations.of(context);
    setState(() => _errorMessage = null);

    if (_titleController.text.trim().isEmpty) {
      setState(() => _errorMessage = l10n.titleEmpty);
      return;
    }
    if (_selectedAddress == null || _selectedCoordinates == null) {
      setState(() => _errorMessage = l10n.selectLocationOnMap);
      return;
    }
    if (_startDate == null ||
        _startTime == null ||
        _endDate == null ||
        _endTime == null ||
        _lastApplyDate == null ||
        _lastApplyTime == null) {
      setState(() => _errorMessage = l10n.selectAllTimes);
      return;
    }

    // Tarih ve Saati birleştir
    final DateTime startDateTime = DateTime(_startDate!.year, _startDate!.month,
        _startDate!.day, _startTime!.hour, _startTime!.minute);

    final DateTime endDateTime = DateTime(_endDate!.year, _endDate!.month,
        _endDate!.day, _endTime!.hour, _endTime!.minute);

    final DateTime lastApplyDateTime = DateTime(_lastApplyDate!.year, _lastApplyDate!.month,
        _lastApplyDate!.day, _lastApplyTime!.hour, _lastApplyTime!.minute);

    // Mantık Kontrolü: Bitiş tarihi başlangıçtan önce olamaz
    if (endDateTime.isBefore(startDateTime)) {
      setState(() => _errorMessage = l10n.endBeforeStart);
      return;
    }

    // Mantık Kontrolü: Son başvuru tarihi başlangıçtan sonra olamaz
    if (lastApplyDateTime.isAfter(startDateTime)) {
      setState(() => _errorMessage = l10n.lastApplyAfterStart);
      return;
    }

    // Mantık Kontrolü: Son başvuru tarihi geçmiş bir zaman olamaz
    if (lastApplyDateTime.isBefore(DateTime.now())) {
      setState(() => _errorMessage = l10n.lastApplyInPast);
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
          lastApplyDate: lastApplyDateTime,
        );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final l10n = AppLocalizations.of(context);
    final localeName = Localizations.localeOf(context).toString();

    // Tarih gösterimi için formatlayıcı
    String formatDateTime(DateTime? d, TimeOfDay? t) {
      if (d == null || t == null) return l10n.selectPlaceholder;
      final dt = DateTime(d.year, d.month, d.day, t.hour, t.minute);
      return DateFormat('dd MMM yyyy, HH:mm', localeName).format(dt);
    }

    return BlocListener<AddEventCubit, AddEventState>(
      listener: (context, state) {
        if (state is AddEventSuccess) {
          context.read<EventCubit>().refresh();
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context).eventCreatedSuccess),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (state is AddEventError) {
          setState(() => _errorMessage = AppMessages.resolve(context, state.message));
        }
      },
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
              top: Radius.circular(Responsive.scale(context, 32))),
        ),
        padding: EdgeInsets.fromLTRB(
            0, Responsive.scale(context, 12), 0, bottomInset),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag Handle
            Container(
              width: Responsive.scale(context, 40),
              height: Responsive.scale(context, 4),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(Responsive.scale(context, 2)),
              ),
            ),
            SizedBox(height: Responsive.scale(context, 12)),

            // Header
            Padding(
              padding: Responsive.padding(context, horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      l10n.cancel,
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    l10n.newEvent,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: Responsive.sp(context, 17),
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryText,
                    ),
                  ),
                  BlocBuilder<AddEventCubit, AddEventState>(
                    builder: (context, state) {
                      if (state is AddEventLoading) {
                        return AppLoadingIndicator(
                            size: Responsive.scale(context, 28));
                      }
                      return ElevatedButton(
                        onPressed: _saveEvent,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.kPrimaryColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: Responsive.padding(context,
                              horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(Responsive.scale(context, 20)),
                          ),
                        ),
                        child: Text(
                          l10n.publish,
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
                padding: Responsive.padding(context,
                    horizontal: 20, vertical: 8),
                color: Colors.red.shade50,
                width: double.infinity,
                child: Text(
                  _errorMessage!,
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.red.shade700,
                    fontSize: Responsive.sp(context, 13),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

            Expanded(
              child: SingleChildScrollView(
                padding: Responsive.padding(context, all: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User Profile Section
                    BlocBuilder<UserCubit, UserState>(
                      builder: (context, state) {
                        String displayName = l10n.defaultVolunteerName;
                        String? imageUrl;
                        if (state is UserLoaded) {
                          displayName = state.user.displayName;
                          imageUrl = state.user.imageUrl;
                        }
                        return Row(
                          children: [
                            CircleAvatar(
                              radius: Responsive.scale(context, 20),
                              backgroundColor: AppColors.lightPrimaryColor,
                              backgroundImage:
                                  (imageUrl != null && imageUrl.isNotEmpty)
                                      ? CachedNetworkImageProvider(imageUrl)
                                      : null,
                              child: (imageUrl == null || imageUrl.isEmpty)
                                  ? Text(displayName[0].toUpperCase())
                                  : null,
                            ),
                            SizedBox(width: Responsive.scale(context, 12)),
                            Text(
                              displayName,
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.bold,
                                fontSize: Responsive.sp(context, 15),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    SizedBox(height: Responsive.scale(context, 24)),

                    // Title Input
                    TextField(
                      controller: _titleController,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: Responsive.sp(context, 20),
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        hintText: l10n.eventTitleHint,
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        border: InputBorder.none,
                      ),
                    ),

                    // Description Input
                    TextField(
                      controller: _descController,
                      maxLines: null,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: Responsive.sp(context, 16),
                        color: Colors.black87,
                      ),
                      decoration: InputDecoration(
                        hintText: l10n.eventDescriptionHint,
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        border: InputBorder.none,
                      ),
                    ),
                    SizedBox(height: Responsive.scale(context, 20)),

                    // Type & Category Selection
                    Row(
                      children: [
                        Expanded(
                          child: _buildDropdown(
                            label: l10n.type,
                            value: _selectedType,
                            items: _types,
                            itemLabel: (item) =>
                                CategoryLocalizer.type(l10n, item),
                            onChanged: (val) =>
                                setState(() => _selectedType = val!),
                          ),
                        ),
                        SizedBox(width: Responsive.scale(context, 12)),
                        Expanded(
                          child: _buildDropdown(
                            label: l10n.category,
                            value: _selectedCategory,
                            items: _categories,
                            itemLabel: (item) =>
                                CategoryLocalizer.category(l10n, item),
                            onChanged: (val) =>
                                setState(() => _selectedCategory = val!),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: Responsive.scale(context, 16)),

                    // Quota Input
                    Container(
                      padding: Responsive.padding(context, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(Responsive.scale(context, 16)),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: TextField(
                        controller: _quotaController,
                        keyboardType: TextInputType.number,
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: Responsive.sp(context, 15)),
                        decoration: InputDecoration(
                          hintText: l10n.quotaOptional,
                          hintStyle: GoogleFonts.plusJakartaSans(
                            color: Colors.grey[400],
                            fontSize: Responsive.sp(context, 14),
                          ),
                          border: InputBorder.none,
                          icon: Icon(Icons.people_outline,
                              color: Colors.grey[400],
                              size: Responsive.scale(context, 20)),
                        ),
                      ),
                    ),
                    SizedBox(height: Responsive.scale(context, 16)),

                    // Location Picker & Preview
                    Text(
                      l10n.location,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: Responsive.sp(context, 14),
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: Responsive.scale(context, 8)),
                    GestureDetector(
                      onTap: _pickLocation,
                      child: Container(
                        height: Responsive.scale(
                            context, _selectedCoordinates != null ? 200 : 80),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(Responsive.scale(context, 16)),
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
                                    borderRadius: BorderRadius.circular(Responsive.scale(context, 16)),
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
                                              width: Responsive.scale(context, 50),
                                              height: Responsive.scale(context, 60),
                                              alignment: Alignment.topCenter,
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Container(
                                                    width: Responsive.scale(context, 40),
                                                    height: Responsive.scale(context, 40),
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
                                                      size: Responsive.scale(context, 20),
                                                    ),
                                                  ),
                                                  CustomPaint(
                                                    size: Size(
                                                        Responsive.scale(context, 12),
                                                        Responsive.scale(context, 10)),
                                                    painter: const _PinTailPainter(
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
                                      padding: Responsive.padding(context, all: 8),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.6),
                                        borderRadius: BorderRadius.vertical(
                                          bottom: Radius.circular(Responsive.scale(context, 16)),
                                        ),
                                      ),
                                      child: Text(
                                        _selectedAddress ?? '',
                                        style: GoogleFonts.plusJakartaSans(
                                          color: Colors.white,
                                          fontSize: Responsive.sp(context, 12),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: Responsive.scale(context, 8),
                                    right: Responsive.scale(context, 8),
                                    child: Container(
                                      padding: Responsive.padding(context,
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(Responsive.scale(context, 8)),
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
                                          Icon(
                                              Icons.edit_location_alt_outlined,
                                              size: Responsive.scale(context, 14),
                                              color: AppColors.kPrimaryColor),
                                          SizedBox(width: Responsive.scale(context, 4)),
                                          Text(
                                            l10n.change,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: Responsive.sp(context, 11),
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
                                  SizedBox(width: Responsive.scale(context, 8)),
                                  Text(
                                    l10n.selectLocationFromMap,
                                    style: GoogleFonts.plusJakartaSans(
                                      color: AppColors.kPrimaryColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    SizedBox(height: Responsive.scale(context, 20)),

                    // Date & Time Selectors
                    Row(
                      children: [
                        Expanded(
                          child: _buildDateTimePicker(
                            label: l10n.startLabel,
                            dateTimeText:
                                formatDateTime(_startDate, _startTime),
                            onTap: () => _pickDateTime(type: 'start'),
                            icon: Icons.calendar_today_outlined,
                          ),
                        ),
                        SizedBox(width: Responsive.scale(context, 12)),
                        Expanded(
                          child: _buildDateTimePicker(
                            label: l10n.endLabel,
                            dateTimeText: formatDateTime(_endDate, _endTime),
                            onTap: () => _pickDateTime(type: 'end'),
                            icon: Icons.event_available_outlined,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: Responsive.scale(context, 16)),

                    _buildDateTimePicker(
                      label: l10n.lastApplyDateLabel,
                      dateTimeText: formatDateTime(_lastApplyDate, _lastApplyTime),
                      onTap: () => _pickDateTime(type: 'lastApply'),
                      icon: Icons.timer_outlined,
                    ),
                    SizedBox(height: Responsive.scale(context, 20)),

                    // Image Selection
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: double.infinity,
                        height: Responsive.scale(context, 160),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(Responsive.scale(context, 16)),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: _selectedImage != null
                            ? Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(Responsive.scale(context, 16)),
                                    child: Image.file(
                                      _selectedImage!,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: Responsive.scale(context, 10),
                                    right: Responsive.scale(context, 10),
                                    child: GestureDetector(
                                      onTap: () =>
                                          setState(() => _selectedImage = null),
                                      child: Container(
                                        padding: Responsive.padding(context, all: 4),
                                        decoration: const BoxDecoration(
                                          color: Colors.black54,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(Icons.close,
                                            color: Colors.white,
                                            size: Responsive.scale(context, 20)),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_photo_alternate_outlined,
                                      size: Responsive.scale(context, 32),
                                      color: Colors.grey[400]),
                                  SizedBox(height: Responsive.scale(context, 8)),
                                  Text(
                                    l10n.addImageOptional,
                                    style: GoogleFonts.plusJakartaSans(
                                      color: Colors.grey[500],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    SizedBox(height: Responsive.scale(context, 20)),
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
    String Function(String)? itemLabel,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: Responsive.sp(context, 13),
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: Responsive.scale(context, 6)),
        Container(
          padding: Responsive.padding(context, horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(Responsive.scale(context, 12)),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[400]),
              style: GoogleFonts.plusJakartaSans(
                color: Colors.black87,
                fontSize: Responsive.sp(context, 14),
                fontWeight: FontWeight.w500,
              ),
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(itemLabel != null ? itemLabel(item) : item),
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
            fontSize: Responsive.sp(context, 13),
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: Responsive.scale(context, 6)),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(Responsive.scale(context, 12)),
          child: Container(
            padding: Responsive.padding(context, all: 12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(Responsive.scale(context, 12)),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Row(
              children: [
                Icon(icon,
                    size: Responsive.scale(context, 16),
                    color: AppColors.kPrimaryColor.withOpacity(0.7)),
                SizedBox(width: Responsive.scale(context, 8)),
                Expanded(
                  child: Text(
                    dateTimeText,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: Responsive.sp(context, 12),
                      fontWeight: FontWeight.w600,
                      color: dateTimeText ==
                              AppLocalizations.of(context).selectPlaceholder
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
