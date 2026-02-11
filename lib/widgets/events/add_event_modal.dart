import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import 'package:gonullunet_app/utils/app_colors.dart';
import 'package:gonullunet_app/constants/app_constants.dart';
import 'package:gonullunet_app/widgets/custom_input_field.dart';

import '../../logic/add_event_cubit.dart';
import '../../logic/add_event_state.dart';
import '../../repo/event_repository.dart';
import '../../views/location_picker_page.dart';

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
          data: Theme.of(context).copyWith(
            colorScheme:
                const ColorScheme.light(primary: AppColors.primaryColor),
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
          data: Theme.of(context).copyWith(
            colorScheme:
                const ColorScheme.light(primary: AppColors.primaryColor),
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
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50,
      );
      if (pickedFile != null) {
        setState(() => _selectedImage = File(pickedFile.path));
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Resim seçilemedi: $e")),
      );
    }
  }

  void _saveEvent() {
    if (_titleController.text.trim().isEmpty ||
        _selectedAddress == null ||
        _selectedCoordinates == null ||
        _startDate == null ||
        _startTime == null ||
        _endDate == null ||
        _endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen tüm zorunlu alanları doldurun.')),
      );
      return;
    }

    // Tarih ve Saati birleştir
    final DateTime startDateTime = DateTime(_startDate!.year, _startDate!.month,
        _startDate!.day, _startTime!.hour, _startTime!.minute);

    final DateTime endDateTime = DateTime(_endDate!.year, _endDate!.month,
        _endDate!.day, _endTime!.hour, _endTime!.minute);

    // Mantık Kontrolü: Bitiş tarihi başlangıçtan önce olamaz
    if (endDateTime.isBefore(startDateTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bitiş tarihi başlangıçtan önce olamaz!')),
      );
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
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('İçerik başarıyla oluşturuldu!'),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is AddEventError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(24.0),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const Text('Yeni Oluştur',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryText)),
                const SizedBox(height: 24),

                CustomInputField(
                    controller: _titleController, hintText: 'Başlık'),
                const SizedBox(height: 16),

                // TÜR SEÇİMİ (ETKİNLİK / PROJE)
                DropdownButtonFormField<String>(
                  value: _selectedType,
                  decoration: InputDecoration(
                    labelText: 'Tür',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    filled: true,
                    fillColor: Colors.grey[100],
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300)),
                  ),
                  items: _types.map((String type) {
                    return DropdownMenuItem<String>(
                        value: type, child: Text(type));
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedType = val!),
                ),
                const SizedBox(height: 16),

                // KATEGORİ
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: InputDecoration(
                    labelText: 'Kategori',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    filled: true,
                    fillColor: Colors.grey[100],
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300)),
                  ),
                  items: _categories.map((String category) {
                    return DropdownMenuItem<String>(
                        value: category, child: Text(category));
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedCategory = val!),
                ),
                const SizedBox(height: 16),

                CustomInputField(
                    controller: _descController,
                    hintText: 'Açıklama',
                    maxLines: 3),
                const SizedBox(height: 16),

                CustomInputField(
                  controller: _quotaController,
                  hintText: 'Kontenjan (Boş bırakılırsa sınırsız)',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),

                // KONUM
                InkWell(
                  onTap: _pickLocation,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: _selectedAddress == null
                              ? Colors.grey.shade300
                              : AppColors.primaryColor),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.location_on_outlined,
                            color: _selectedAddress == null
                                ? Colors.grey
                                : AppColors.primaryColor),
                        const SizedBox(width: 12),
                        Expanded(
                            child: Text(
                                _selectedAddress ?? 'Konum Seçin (Haritadan)',
                                style: TextStyle(
                                    color: _selectedAddress == null
                                        ? Colors.grey[600]
                                        : Colors.black87,
                                    fontSize: 16),
                                overflow: TextOverflow.ellipsis)),
                        const Icon(Icons.arrow_forward_ios,
                            size: 16, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // --- TARİH SEÇİMİ (START & END) ---
                Row(
                  children: [
                    // Başlangıç Tarihi
                    Expanded(
                      child: InkWell(
                        onTap: () => _pickDateTime(isStart: true),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: _startDate == null
                                    ? Colors.grey.shade300
                                    : AppColors.primaryColor),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Başlangıç",
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey[600])),
                              const SizedBox(height: 4),
                              Text(formatDateTime(_startDate, _startTime),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Bitiş Tarihi
                    Expanded(
                      child: InkWell(
                        onTap: () => _pickDateTime(isStart: false),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: _endDate == null
                                    ? Colors.grey.shade300
                                    : AppColors.primaryColor),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Bitiş",
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey[600])),
                              const SizedBox(height: 4),
                              Text(formatDateTime(_endDate, _endTime),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // RESİM
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                      image: _selectedImage != null
                          ? DecorationImage(
                              image: FileImage(_selectedImage!),
                              fit: BoxFit.cover)
                          : null,
                    ),
                    child: _selectedImage == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                                Icon(Icons.add_photo_alternate_outlined,
                                    size: 30, color: Colors.grey[400]),
                                const SizedBox(height: 8),
                                Text("Görsel Ekle (İsteğe Bağlı)",
                                    style: TextStyle(
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500))
                              ])
                        : null,
                  ),
                ),
                if (_selectedImage != null)
                  TextButton(
                      onPressed: () => setState(() => _selectedImage = null),
                      child: const Text("Görseli Kaldır",
                          style: TextStyle(color: Colors.red))),

                const SizedBox(height: 24),

                // KAYDET BUTONU
                BlocBuilder<AddEventCubit, AddEventState>(
                  builder: (context, state) {
                    return ElevatedButton(
                      onPressed: (state is AddEventLoading) ? null : _saveEvent,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: (state is AddEventLoading)
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : const Text('Yayınla',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
