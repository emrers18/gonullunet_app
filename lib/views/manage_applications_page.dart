import 'dart:io';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:excel/excel.dart' as ex;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gonullunet_app/utils/app_colors.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../logic/manage_applications_cubit.dart';
import '../logic/manage_applications_state.dart';
import '../models/application_model.dart';
import '../repo/event_repository.dart';
import '../utils/gamification_utils.dart';

import 'applicant_profile_page.dart';
import '../widgets/app_loading_indicator.dart';

class ManageApplicationsPage extends StatelessWidget {
  final String eventId;
  final String eventTitle;

  const ManageApplicationsPage({
    super.key,
    required this.eventId,
    required this.eventTitle,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ManageApplicationsCubit(
        eventRepository: context.read<EventRepository>(),
        eventId: eventId,
      )..loadApplications(),
      child: ManageApplicationsView(eventTitle: eventTitle),
    );
  }
}

class ManageApplicationsView extends StatelessWidget {
  final String eventTitle;
  const ManageApplicationsView({super.key, required this.eventTitle});

  // ── Excel Export ──────────────────────────────────────────────────────────
  Future<void> _exportExcel(
      BuildContext context, List<ApplicationModel> apps) async {
    try {
      // Türkçe locale başlat
      await initializeDateFormatting('tr_TR', null);

      final excel = ex.Excel.createExcel();
      final sheet = excel['Başvurular'];

      // Başlık satırı
      final headers = [
        'Ad',
        'Soyad',
        'E-posta',
        'Telefon',
        'Başvuru Durumu',
        'Başvuru Tarihi',
      ];
      for (int i = 0; i < headers.length; i++) {
        final cell = sheet.cell(
            ex.CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
        cell.value = ex.TextCellValue(headers[i]);
        cell.cellStyle = ex.CellStyle(
          bold: true,
          backgroundColorHex: ex.ExcelColor.fromHexString('#1E7E34'),
          fontColorHex: ex.ExcelColor.fromHexString('#FFFFFF'),
        );
      }

      // Veri satırları
      for (int r = 0; r < apps.length; r++) {
        final app = apps[r];
        String statusText;
        switch (app.status) {
          case 'approved':
            statusText = 'Onaylandı';
            break;
          case 'rejected':
            statusText = 'Reddedildi';
            break;
          default:
            statusText = 'Bekliyor';
        }

        final row = [
          app.userName ?? '',
          app.userSurname ?? '',
          app.userEmail ?? '',
          app.userPhone ?? '',
          statusText,
          DateFormat('dd MMMM yyyy HH:mm', 'tr_TR')
              .format(app.appliedAt.toDate()),
        ];

        for (int c = 0; c < row.length; c++) {
          sheet
              .cell(ex.CellIndex.indexByColumnRow(
                  columnIndex: c, rowIndex: r + 1))
              .value = ex.TextCellValue(row[c]);
        }
      }

      // Kolon genişliklerini ayarla
      for (int i = 0; i < headers.length; i++) {
        sheet.setColumnWidth(i, 22);
      }

      final rawBytes = excel.encode();
      if (rawBytes == null) throw Exception('Excel oluşturulamadı');
      final bytes = Uint8List.fromList(rawBytes);

      final dir = await getTemporaryDirectory();
      final safeTitle = eventTitle.replaceAll(RegExp(r'[^\w\s]'), '');
      final file = File(
          '${dir.path}/${safeTitle}_basvurular_${DateFormat('yyyyMMdd').format(DateTime.now())}.xlsx');
      await file.writeAsBytes(bytes);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Excel dosyası oluşturuldu: ${file.path}',
              style: GoogleFonts.plusJakartaSans(),
            ),
            backgroundColor: const Color(0xFF16A34A),
            behavior: SnackBarBehavior.floating,
          ),
        );
        // Paylaş / Önizle
        await Printing.sharePdf(
          bytes: bytes,
          filename: file.path.split('/').last,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Excel oluşturulamadı: $e',
                style: GoogleFonts.plusJakartaSans()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ── PDF Export (sadece onaylananlar – katılım listesi) ────────────────────
  Future<void> _exportPdf(
      BuildContext context, List<ApplicationModel> apps) async {
    try {
      // Türkçe locale başlat
      await initializeDateFormatting('tr_TR', null);

      final approved = apps.where((a) => a.status == 'approved').toList();

      if (approved.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Onaylanmış başvuru bulunamadı.',
                  style: GoogleFonts.plusJakartaSans()),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }

      // ── Türkçe karakterleri destekleyen fontlar ──
      final fontRegular =
          await PdfGoogleFonts.notoSansRegular();
      final fontBold =
          await PdfGoogleFonts.notoSansBold();

      // ── Logo (assets'ten) ──
      final logoBytes =
          await rootBundle.load('lib/assets/images/logo.png');
      final logoImage = pw.MemoryImage(logoBytes.buffer.asUint8List());

      final now = DateTime.now();
      final dateStr =
          DateFormat('dd MMMM yyyy HH:mm', 'tr_TR').format(now);
      final fileDate = DateFormat('yyyyMMdd').format(now);

      final pdf = pw.Document();

      // ── Sayfa ──────────────────────────────────────────────────────────────
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(36),
          header: (ctx) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Üst başlık satırı: metin sol, logo sağ
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'ETKİNLİK KATILIM LİSTESİ',
                        style: pw.TextStyle(
                          font: fontBold,
                          fontSize: 16,
                          color: PdfColors.green800,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        eventTitle,
                        style: pw.TextStyle(
                          font: fontRegular,
                          fontSize: 12,
                          color: PdfColors.grey700,
                        ),
                      ),
                    ],
                  ),
                  // Logo – sağ üst
                  pw.Image(logoImage, width: 64, height: 64),
                ],
              ),
              pw.SizedBox(height: 6),
              pw.Row(
                children: [
                  pw.Text(
                    'Oluşturma Tarihi: $dateStr',
                    style:
                        pw.TextStyle(font: fontRegular, fontSize: 9,
                            color: PdfColors.grey600),
                  ),
                  pw.Spacer(),
                  pw.Text(
                    'Toplam Onaylı Katılımcı: ${approved.length}',
                    style: pw.TextStyle(
                        font: fontBold, fontSize: 9, color: PdfColors.green800),
                  ),
                ],
              ),
              pw.SizedBox(height: 6),
              pw.Divider(thickness: 0.8, color: PdfColors.green700),
              pw.SizedBox(height: 8),
            ],
          ),
          build: (pw.Context ctx) => [
            pw.Table(
              border: pw.TableBorder.all(
                color: PdfColors.grey400,
                width: 0.5,
              ),
              columnWidths: {
                0: const pw.FixedColumnWidth(28),
                1: const pw.FlexColumnWidth(2.5),
                2: const pw.FlexColumnWidth(3),
                3: const pw.FlexColumnWidth(2),
              },
              children: [
                // Tablo başlığı
                pw.TableRow(
                  decoration:
                      const pw.BoxDecoration(color: PdfColors.green700),
                  children: [
                    '#',
                    'Ad Soyad',
                    'E-posta',
                    'Telefon',
                  ]
                      .map(
                        (h) => pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(
                              horizontal: 6, vertical: 5),
                          child: pw.Text(
                            h,
                            style: pw.TextStyle(
                              font: fontBold,
                              fontSize: 10,
                              color: PdfColors.white,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
                // Katılımcı satırları
                ...approved.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final a = entry.value;
                  final bg = idx.isEven ? PdfColors.white : PdfColors.grey100;
                  return pw.TableRow(
                    decoration: pw.BoxDecoration(color: bg),
                    children: [
                      '${idx + 1}',
                      '${a.userName ?? ''} ${a.userSurname ?? ''}'.trim(),
                      a.userEmail ?? '-',
                      a.userPhone ?? '-',
                    ]
                        .map(
                          (cell) => pw.Padding(
                            padding: const pw.EdgeInsets.symmetric(
                                horizontal: 6, vertical: 5),
                            child: pw.Text(
                              cell,
                              style: pw.TextStyle(
                                  font: fontRegular, fontSize: 9),
                            ),
                          ),
                        )
                        .toList(),
                  );
                }),
              ],
            ),
          ],
          footer: (ctx) => pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
              'Sayfa ${ctx.pageNumber} / ${ctx.pagesCount}',
              style: pw.TextStyle(
                  font: fontRegular,
                  fontSize: 8,
                  color: PdfColors.grey500),
            ),
          ),
        ),
      );

      final bytes = await pdf.save();

      if (context.mounted) {
        await Printing.layoutPdf(
          onLayout: (_) async => bytes,
          name:
              '${eventTitle}_katilim_listesi_$fileDate.pdf',
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF oluşturulamadı: $e',
                style: GoogleFonts.plusJakartaSans()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F5),
      appBar: AppBar(
        title: Text(
          "Başvurular",
          style: GoogleFonts.plusJakartaSans(
            color: const Color(0xFF181210),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFF8F6F5).withOpacity(0.95),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF181210)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          BlocBuilder<ManageApplicationsCubit, ManageApplicationsState>(
            builder: (context, state) {
              if (state is! ManageApplicationsLoaded) {
                return const SizedBox.shrink();
              }
              final apps = state.applications;
              return Row(
                children: [
                  // Excel ikonu
                  Tooltip(
                    message: 'Excel\'e Aktar',
                    child: IconButton(
                      onPressed: () => _exportExcel(context, apps),
                      icon: const Icon(Icons.table_view_rounded),
                      color: const Color(0xFF1E7E34),
                      style: IconButton.styleFrom(
                        backgroundColor:
                            const Color(0xFF1E7E34).withOpacity(0.1),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  // PDF ikonu
                  Tooltip(
                    message: 'Katılım Listesi (PDF)',
                    child: IconButton(
                      onPressed: () => _exportPdf(context, apps),
                      icon: const Icon(Icons.picture_as_pdf_rounded),
                      color: const Color(0xFFDC2626),
                      style: IconButton.styleFrom(
                        backgroundColor:
                            const Color(0xFFDC2626).withOpacity(0.1),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<ManageApplicationsCubit, ManageApplicationsState>(
        builder: (context, state) {
          if (state is ManageApplicationsLoading) {
            return const AppLoadingCenter();
          }
          if (state is ManageApplicationsError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline,
                        size: 48, color: Colors.red.shade300),
                    const SizedBox(height: 12),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            );
          }
          if (state is ManageApplicationsLoaded) {
            if (state.applications.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.inbox_outlined,
                        size: 64, color: Colors.grey.shade300),
                    const SizedBox(height: 12),
                    Text(
                      "Henüz başvuru yok.",
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.grey.shade500,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.applications.length,
              itemBuilder: (context, index) {
                final app = state.applications[index];
                return _ApplicationCard(app: app);
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _ApplicationCard extends StatelessWidget {
  final ApplicationModel app;

  const _ApplicationCard({required this.app});

  @override
  Widget build(BuildContext context) {
    // Status styling
    Color statusColor;
    IconData statusIcon;
    String statusText;
    Color statusBg;

    switch (app.status) {
      case 'approved':
        statusColor = const Color(0xFF16A34A);
        statusIcon = Icons.check_circle_rounded;
        statusText = "Onaylandı";
        statusBg = const Color(0xFFDCFCE7);
        break;
      case 'rejected':
        statusColor = const Color(0xFFDC2626);
        statusIcon = Icons.cancel_rounded;
        statusText = "Reddedildi";
        statusBg = const Color(0xFFFEE2E2);
        break;
      default:
        statusColor = const Color(0xFFF59E0B);
        statusIcon = Icons.schedule_rounded;
        statusText = "Bekliyor";
        statusBg = const Color(0xFFFEF3C7);
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ApplicantProfilePage(userId: app.userId),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Top Row: Avatar + Name + Status
            Row(
              children: [
                // Avatar
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.shade100,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.06), blurRadius: 6),
                    ],
                    image: (app.userImageUrl != null &&
                            app.userImageUrl!.isNotEmpty)
                        ? DecorationImage(
                            image:
                                CachedNetworkImageProvider(app.userImageUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: (app.userImageUrl == null || app.userImageUrl!.isEmpty)
                      ? Center(
                          child: Text(
                            _getInitials(app.userName, app.userSurname),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.kPrimaryColor,
                            ),
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),

                // Name & time
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${app.userName ?? 'İsimsiz'} ${app.userSurname ?? ''}",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF181210),
                        ),
                      ),
                      if (app.xp != null) ...[
                        const SizedBox(height: 4),
                        _buildLevelBadge(app.xp!),
                      ],
                      const SizedBox(height: 3),
                      Text(
                        app.timeAgo,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: const Color(0xFF8D6A5E),
                        ),
                      ),
                    ],
                  ),
                ),

                // Status badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 14, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        statusText,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Bottom Row: Action buttons or profile link
            if (app.status == 'pending') ...[
              const SizedBox(height: 14),
              const Divider(height: 1, color: Color(0xFFF0EDED)),
              const SizedBox(height: 12),
              Row(
                children: [
                  // Profili Gör
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ApplicantProfilePage(userId: app.userId),
                          ),
                        );
                      },
                      icon: const Icon(Icons.person_outline, size: 18),
                      label: Text(
                        "Profili Gör",
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF6B7280),
                        side: const BorderSide(color: Color(0xFFE5E7EB)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Reddet
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        context
                            .read<ManageApplicationsCubit>()
                            .updateStatus(app, 'rejected');
                      },
                      icon: const Icon(Icons.close_rounded, size: 18),
                      label: Text(
                        "Reddet",
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFDC2626),
                        side: BorderSide(color: Colors.red.shade200),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Onayla
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        context
                            .read<ManageApplicationsCubit>()
                            .updateStatus(app, 'approved');
                      },
                      icon: const Icon(Icons.check_rounded, size: 18),
                      label: Text(
                        "Onayla",
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF16A34A),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getInitials(String? name, String? surname) {
    final n = (name != null && name.isNotEmpty) ? name[0].toUpperCase() : '';
    final s =
        (surname != null && surname.isNotEmpty) ? surname[0].toUpperCase() : '';
    if (n.isEmpty && s.isEmpty) return '?';
    return '$n$s';
  }

  Widget _buildLevelBadge(int xp) {
    final level = GamificationUtils.getLevelInfo(xp);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: level.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: level.color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.stars, size: 12, color: level.color),
          const SizedBox(width: 4),
          Text(
            level.title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: level.color,
            ),
          ),
        ],
      ),
    );
  }
}
