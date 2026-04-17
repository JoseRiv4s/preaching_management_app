import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/model/report_data.dart';
import '../provider/report_filters_provider.dart';

class ReportPdfExporter {
  static Future<void> export({
    required BuildContext context,
    required ReportData report,
    required ReportFilters filters,
  }) async {
    final pdf = pw.Document();
    final monthStr = DateFormat('MMMM yyyy', 'es').format(report.month);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Informe de Actividad',
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  monthStr,
                  style: const pw.TextStyle(fontSize: 12),
                ),
              ],
            ),
            pw.Divider(),
            pw.SizedBox(height: 8),
          ],
        ),
        build: (ctx) => [
          // Resumen
          pw.Text('Resumen Mensual',
              style:
                  pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          pw.Row(children: [
            _pdfStatBox(
              'Cobertura de Territorio',
              '${(report.territoryCoverage * 100).toStringAsFixed(0)}%',
            ),
            pw.SizedBox(width: 16),
            _pdfStatBox(
              'Total Personas',
              '${report.totalParticipants}',
            ),
            pw.SizedBox(width: 16),
            _pdfStatBox(
              'Total Jornadas',
              '${report.totalJourneys}',
            ),
          ]),

          pw.SizedBox(height: 16),

          // Actividad semanal
          pw.Text('Salidas por Semana',
              style:
                  pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            children: [
              pw.TableRow(
                decoration:
                    const pw.BoxDecoration(color: PdfColors.blueGrey100),
                children: ['Semana', 'Jornadas']
                    .map((h) => pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(h,
                              style:
                                  pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ))
                    .toList(),
              ),
              ...report.weeklyActivity.map((w) => pw.TableRow(children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text('Semana ${w.week}'),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text('${w.journeyCount}'),
                    ),
                  ])),
            ],
          ),

          pw.SizedBox(height: 16),

          // Ranking
          pw.Text('Ranking de Territorios',
              style:
                  pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            columnWidths: {
              0: const pw.FlexColumnWidth(1),
              1: const pw.FlexColumnWidth(3),
              2: const pw.FlexColumnWidth(2),
              3: const pw.FlexColumnWidth(1),
            },
            children: [
              pw.TableRow(
                decoration:
                    const pw.BoxDecoration(color: PdfColors.blueGrey100),
                children: ['#', 'Territorio', 'Cobertura', 'Bloques']
                    .map((h) => pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(h,
                              style:
                                  pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ))
                    .toList(),
              ),
              ...report.territoryRanking.map((r) => pw.TableRow(children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text('${r.rank}'),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(r.territoryName),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child:
                          pw.Text('${(r.coverage * 100).toStringAsFixed(0)}%'),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text('${r.completedBlocks}/${r.totalBlocks}'),
                    ),
                  ])),
            ],
          ),

          pw.SizedBox(height: 24),
          pw.Text(
            'Generado el ${DateFormat('d/MM/yyyy HH:mm', 'es').format(DateTime.now())}',
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (_) async => pdf.save(),
      name: 'informe_predicacion_$monthStr.pdf',
    );
  }

  static pw.Widget _pdfStatBox(String label, String value) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(12),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.grey300),
          borderRadius: pw.BorderRadius.circular(8),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Text(value,
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                )),
            pw.SizedBox(height: 4),
            pw.Text(label,
                style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey)),
          ],
        ),
      ),
    );
  }
}
