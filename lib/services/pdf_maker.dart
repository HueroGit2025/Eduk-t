import 'package:eudkt/services/shared_preference.dart';
import 'package:pdf/pdf.dart' as pdf;
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart';


class PDFMaker{

   static Future<Uint8List> generateCertificatePdfBytes(double score, String courseName) async {
    final doc = pw.Document();

    final logoBytes = await rootBundle.load('assets/template.png');
    final logoImage = pw.MemoryImage(logoBytes.buffer.asUint8List());

    doc.addPage(
      pw.Page(
        pageFormat: pdf.PdfPageFormat.letter.landscape.copyWith(
          marginBottom: 0,
          marginLeft: 0,
          marginRight: 0,
          marginTop: 0,
        ),
        build: (pw.Context context) {
          return pw.Stack(
            children: [

              pw.Container(
                width: double.infinity,
                height: double.infinity,
                child: pw.Positioned.fill(
                  child: pw.Image(
                    logoImage,
                    fit: pw.BoxFit.cover,
                  ),
                ),
              ),

              pw.Center(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.SizedBox(height: 100),
                    pw.Text('Constancia de Acreditación',
                        style: pw.TextStyle(
                          fontSize: 28,
                          fontWeight: pw.FontWeight.bold,
                        )),
                    pw.SizedBox(height: 30),
                    pw.Text('Se certifica que el alumno:',
                        style: const pw.TextStyle(fontSize: 16)),
                    pw.SizedBox(height: 8),
                    pw.Text(SharedPreferencesService.name!,
                        style: pw.TextStyle(
                          fontSize: 22,
                          fontWeight: pw.FontWeight.bold,
                        )),
                    pw.SizedBox(height: 20),
                    pw.Text('De la carrera de:',
                        style: const pw.TextStyle(fontSize: 16)),
                    pw.SizedBox(height: 8),
                    pw.Text(SharedPreferencesService.career!,
                        style: pw.TextStyle(
                          fontSize: 22,
                          fontWeight: pw.FontWeight.bold,
                        )),
                    pw.SizedBox(height: 20),
                    pw.Text('Acreditó satisfactoriamente el curso:',
                        style: const pw.TextStyle(fontSize: 16)),
                    pw.SizedBox(height: 8),
                    pw.Text(courseName,
                        style: pw.TextStyle(
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold,
                        )),
                    pw.SizedBox(height: 30),
                    pw.Text('Con un promedio de: $score',
                        style: const pw.TextStyle(fontSize: 12)),
                    pw.Text('ID del alumno: ${SharedPreferencesService.enrollment}',
                        style: const pw.TextStyle(fontSize: 12)),
                    pw.SizedBox(height: 30),
                    pw.Text(
                      'Fecha: ${DateTime.now().toLocal().toString().split(" ").first}',
                      style: const pw.TextStyle(fontSize: 12),
                    ),
                    pw.Spacer(),

                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    return doc.save();
  }

}