import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import '../models/saved_trip.dart';
import '../models/storytelling_response.dart';
import '../models/itinerary.dart';

class PDFService {
  // Generate PDF for itinerary
  Future<Uint8List> generateItineraryPDF(SavedTrip trip) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            _buildHeader(trip.title, trip.description),
            pw.SizedBox(height: 20),
            _buildTripInfo(trip),
            pw.SizedBox(height: 20),
            _buildItineraryDetails(trip.itinerary),
            pw.SizedBox(height: 20),
            _buildFooter(),
          ];
        },
      ),
    );

    return pdf.save();
  }

  // Generate PDF for visual story
  Future<Uint8List> generateStoryPDF(SavedTrip trip) async {
    if (trip.storytellingResponse == null) {
      throw Exception('No visual story available for this trip');
    }

    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            _buildStoryHeader(trip.title, trip.storytellingResponse!),
            pw.SizedBox(height: 20),
            _buildStoryContent(trip.storytellingResponse!),
            pw.SizedBox(height: 20),
            _buildFooter(),
          ];
        },
      ),
    );

    return pdf.save();
  }

  // Save PDF to device storage
  Future<String> savePDFToDevice(Uint8List pdfBytes, String fileName) async {
    try {
      // For Android 13+ (API 33+), we don't need storage permission for app-specific directories
      Directory directory;
      
      if (Platform.isAndroid) {
        // Use app-specific external storage directory (no permission needed)
        directory = await getExternalStorageDirectory() ?? await getApplicationDocumentsDirectory();
      } else if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        // For other platforms, try downloads directory
        directory = await getDownloadsDirectory() ?? await getApplicationDocumentsDirectory();
      }

      // Create the file
      final file = File('${directory.path}/$fileName.pdf');
      await file.writeAsBytes(pdfBytes);

      return file.path;
    } catch (e) {
      // Fallback to documents directory if external storage fails
      try {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/$fileName.pdf');
        await file.writeAsBytes(pdfBytes);
        return file.path;
      } catch (fallbackError) {
        throw Exception('Failed to save PDF: $fallbackError');
      }
    }
  }

  // Print PDF
  Future<void> printPDF(Uint8List pdfBytes, String title) async {
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
      name: title,
    );
  }

  // Share PDF
  Future<void> sharePDF(Uint8List pdfBytes, String fileName) async {
    await Printing.sharePdf(
      bytes: pdfBytes,
      filename: '$fileName.pdf',
    );
  }

  // Build PDF header
  pw.Widget _buildHeader(String title, String description) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 24,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue800,
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          description,
          style: pw.TextStyle(
            fontSize: 14,
            color: PdfColors.grey700,
          ),
        ),
        pw.SizedBox(height: 16),
        pw.Divider(color: PdfColors.blue800),
      ],
    );
  }

  // Build story header
  pw.Widget _buildStoryHeader(String title, StorytellingResponse story) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Visual Story: $title',
          style: pw.TextStyle(
            fontSize: 24,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.purple800,
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          'Visual Story',
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.purple700,
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          story.story,
          style: pw.TextStyle(
            fontSize: 14,
            color: PdfColors.grey700,
          ),
        ),
        pw.SizedBox(height: 16),
        pw.Divider(color: PdfColors.purple800),
      ],
    );
  }

  // Build trip information
  pw.Widget _buildTripInfo(SavedTrip trip) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Trip Information',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue800,
            ),
          ),
          pw.SizedBox(height: 12),
          _buildInfoRow('Destination', trip.itinerary.destination),
          _buildInfoRow('Duration', '${trip.itinerary.days.length} days'),
          _buildInfoRow('Travelers', '${trip.itinerary.travelers} people'),
          _buildInfoRow('Start Date', trip.itinerary.startDate),
          _buildInfoRow('End Date', trip.itinerary.endDate),
          _buildInfoRow('Estimated Cost', '₹${trip.itinerary.totalEstimatedCost.toStringAsFixed(0)}'),
        ],
      ),
    );
  }

  // Build info row
  pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 120,
            child: pw.Text(
              '$label:',
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.grey700,
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 12,
                color: PdfColors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Build itinerary details
  pw.Widget _buildItineraryDetails(Itinerary itinerary) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Daily Itinerary',
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue800,
          ),
        ),
        pw.SizedBox(height: 16),
        ...itinerary.days.asMap().entries.map((entry) {
          final dayIndex = entry.key;
          final day = entry.value;
          return _buildDayPlan(dayIndex + 1, day);
        }).toList(),
      ],
    );
  }

  // Build day plan
  pw.Widget _buildDayPlan(int dayNumber, dynamic day) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 16),
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Day $dayNumber',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue700,
            ),
          ),
          pw.SizedBox(height: 12),
          if (day.morning.isNotEmpty) ...[
            _buildActivitySection('Morning', day.morning),
            pw.SizedBox(height: 8),
          ],
          if (day.afternoon.isNotEmpty) ...[
            _buildActivitySection('Afternoon', day.afternoon),
            pw.SizedBox(height: 8),
          ],
          if (day.evening.isNotEmpty) ...[
            _buildActivitySection('Evening', day.evening),
          ],
        ],
      ),
    );
  }

  // Build activity section
  pw.Widget _buildActivitySection(String time, String activity) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          time,
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue600,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          activity,
          style: pw.TextStyle(
            fontSize: 11,
            color: PdfColors.black,
          ),
        ),
      ],
    );
  }

  // Build story content
  pw.Widget _buildStoryContent(StorytellingResponse story) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Story Chapters',
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.purple800,
          ),
        ),
        pw.SizedBox(height: 16),
        ...story.days.map((storyDay) => _buildStoryDay(storyDay)).toList(),
      ],
    );
  }

  // Build story day
  pw.Widget _buildStoryDay(dynamic storyDay) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 16),
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.purple300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            storyDay.title,
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.purple700,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            storyDay.summary,
            style: pw.TextStyle(
              fontSize: 12,
              color: PdfColors.black,
            ),
          ),
          pw.SizedBox(height: 12),
          if (storyDay.places.isNotEmpty) ...[
            pw.Text(
              'Places to Visit:',
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.purple600,
              ),
            ),
            pw.SizedBox(height: 8),
            ...storyDay.places.map((place) => pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 4),
              child: pw.Text(
                '• ${place.name}',
                style: pw.TextStyle(
                  fontSize: 11,
                  color: PdfColors.black,
                ),
              ),
            )).toList(),
          ],
        ],
      ),
    );
  }

  // Build footer
  pw.Widget _buildFooter() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            'Generated by Travel Companion App',
            style: pw.TextStyle(
              fontSize: 10,
              color: PdfColors.grey600,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'Generated on: ${DateTime.now().toString().split(' ')[0]}',
            style: pw.TextStyle(
              fontSize: 10,
              color: PdfColors.grey600,
            ),
          ),
        ],
      ),
    );
  }
}
