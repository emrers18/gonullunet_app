import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:gonullunet_app/views/location_picker_page.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gonullunet_app/utils/app_colors.dart';
import 'package:gonullunet_app/widgets/custom_input_field.dart';
import 'package:intl/intl.dart';

class AddEventModal extends StatefulWidget {
  const AddEventModal({super.key});

  @override
  State<AddEventModal> createState() => _AddEventModalState();
}

class _AddEventModalState extends State<AddEventModal> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  DateTime? _selectedDate;
  LatLng? _selectedCoordinates;
  String? _selectedAddress;
  File? _selectedImage;

  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
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

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
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
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50, // Boyutu optimize etmeye yarıyor
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Resim seçilemedi: $e")),
      );
    }
  }

  Future<void> _saveEvent() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (_titleController.text.isEmpty ||
        _selectedAddress == null ||
        _selectedCoordinates == null ||
        _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Lütfen başlık, tarih ve konumu (haritadan) seçin.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      String imageUrl = '';

      if (_selectedImage != null) {
        final String fileName =
            'event_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final Reference storageRef =
            _storage.ref().child('event_images/$fileName');

        await storageRef.putFile(_selectedImage!);
        imageUrl = await storageRef.getDownloadURL();
      }

      await FirebaseFirestore.instance.collection('events').add({
        'title': _titleController.text.trim(),
        'description': _descController.text.trim(),
        'location': _selectedAddress,
        'geoPoint': GeoPoint(
            _selectedCoordinates!.latitude, _selectedCoordinates!.longitude),
        'date': Timestamp.fromDate(_selectedDate!),
        'imageUrl': imageUrl,
        'organizerId': user.uid,
        'createdAt': FieldValue.serverTimestamp(),
        'participants': [],
        'active': true,
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Etkinlik başarıyla oluşturuldu!')),
        );
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Hata: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
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
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Text(
                'Yeni Etkinlik Oluştur',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryText),
              ),
              const SizedBox(height: 24),
              CustomInputField(
                  controller: _titleController, hintText: 'Etkinlik Başlığı'),
              const SizedBox(height: 16),
              CustomInputField(
                  controller: _descController, hintText: 'Açıklama'),
              const SizedBox(height: 16),
              InkWell(
                onTap: _pickLocation,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: _selectedAddress == null
                            ? Colors.grey.shade300
                            : AppColors.primaryColor,
                        width: _selectedAddress == null ? 1 : 1.5),
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
                            fontSize: 16,
                            fontWeight: _selectedAddress == null
                                ? FontWeight.normal
                                : FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios,
                          size: 16, color: Colors.grey),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _pickDate,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: _selectedDate == null
                            ? Colors.grey.shade300
                            : AppColors.primaryColor,
                        width: _selectedDate == null ? 1 : 1.5),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedDate == null
                            ? 'Tarih Seçin'
                            : DateFormat('dd MMMM yyyy', 'tr_TR')
                                .format(_selectedDate!),
                        style: TextStyle(
                          color: _selectedDate == null
                              ? Colors.grey[600]
                              : Colors.black87,
                          fontSize: 16,
                          fontWeight: _selectedDate == null
                              ? FontWeight.normal
                              : FontWeight.w500,
                        ),
                      ),
                      Icon(Icons.calendar_today,
                          color: _selectedDate == null
                              ? Colors.grey
                              : AppColors.primaryColor),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                    image: _selectedImage != null
                        ? DecorationImage(
                            image: FileImage(_selectedImage!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _selectedImage == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate_outlined,
                                size: 40, color: Colors.grey[400]),
                            const SizedBox(height: 8),
                            Text(
                              "Görsel Ekle (İsteğe Bağlı)",
                              style: TextStyle(
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        )
                      : null,
                ),
              ),
              if (_selectedImage != null)
                TextButton(
                  onPressed: () => setState(() => _selectedImage = null),
                  child: const Text("Görseli Kaldır",
                      style: TextStyle(color: Colors.red)),
                ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSaving ? null : _saveEvent,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Text('Etkinliği Yayınla',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
