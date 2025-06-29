import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class AcknowledgementData {
  final String reg_No;
  final String applicant_Name;
  final String permanentadd;
  final String ackdistrict;
  final String acklac;
  final String ackpincode;
  final String ackmobile;
  final String submitted_on;

  AcknowledgementData({
    required this.reg_No,
    required this.applicant_Name,
    required this.permanentadd,
    required this.ackdistrict,
    required this.acklac,
    required this.ackpincode,
    required this.ackmobile,
    required this.submitted_on,
  });
}

class AcknowledgementReg extends StatelessWidget {
  final AcknowledgementData data;

  const AcknowledgementReg({required this.data, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Acknowledgement Receipt")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Image.asset("assets/assam_seal.png", height: 140),
              const SizedBox(height: 10),
              const Text(
                "Acknowledgement Receipt",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 40),
              Text(
                "Dear ${data.applicant_Name},\n\nYou have successfully registered for Chief Minister’s Atmanirbhar Asom Abhijan 2.0"
              ),
              const SizedBox(height: 20),
              buildInfoTable(data),
              const SizedBox(height: 20),
              const Text("Thank You", style: TextStyle(fontWeight: FontWeight.bold,),),
              const SizedBox(height: 20),
              const Text(
                "**This is a system-generated acknowledgement receipt and no physical signature is required**",
                style: TextStyle(fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () async {
                  final pdf = pw.Document();
                  final image = await imageFromAssetBundle('assets/assam_seal.png');

                  pdf.addPage(
                    pw.Page(
                      build: (pw.Context context) => pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Center(child: pw.Image(image, height: 100)),
                          pw.SizedBox(height: 10),
                          pw.Center(
                            child: pw.Text(
                              "Acknowledgement Receipt",
                              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                            ),
                          ),
                          pw.SizedBox(height: 20),
                          pw.Text(
                              "Dear ${data.applicant_Name},\n\nYou have successfully registered for Chief Minister's Atmanirbhar Asom Abhijan 2.0"
                          ),
                          pw.SizedBox(height: 20),
                          _buildPdfTable(data),
                          pw.SizedBox(height: 20),
                          pw.Text("Thank You", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          pw.SizedBox(height: 10),
                          pw.Center(
                            child: pw.Text(
                              "**This is a system-generated acknowledgement receipt and no physical signature is required**",
                              style: pw.TextStyle(fontStyle: pw.FontStyle.italic, fontSize: 10),
                              textAlign: pw.TextAlign.center,),),
                        ],
                      ),),
                  );
                  await Printing.layoutPdf(onLayout: (format) async => pdf.save());
                },
                icon: const Icon(Icons.print),
                label: const Text("Print"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  pw.Widget _buildPdfTable(AcknowledgementData data) {
    List<List<String>> fields = [
      ["Registration No.", data.reg_No],
      ["Applicant Name", data.applicant_Name],
      ["Permanent Address", data.permanentadd],
      ["District", data.ackdistrict],
      ["LAC", data.acklac],
      ["Pin Code", data.ackpincode],
      ["Mobile No", data.ackmobile],
      ["Submitted on", data.submitted_on],
    ];

    return pw.Table(
      border: pw.TableBorder.all(),
      columnWidths: {
        0: const pw.FlexColumnWidth(3),
        1: const pw.FlexColumnWidth(7),
      },
      children: fields.map(
            (row) => pw.TableRow(
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(6),
              child: pw.Text(row[0], style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(6),
              child: pw.Text(row[1]),
            ),
          ],
        ),
      ).toList(),
    );
  }


  Widget buildInfoTable(AcknowledgementData data) {
    return Table(
      border: TableBorder.all(),
      columnWidths: const {
        0: FlexColumnWidth(3),
        1: FlexColumnWidth(7),
      },
      children: [
        row("Registration No.", data.reg_No),
        row("Applicant Name", data.applicant_Name),
        row("Permanent Address", data.permanentadd),
        row("District", data.ackdistrict),
        row("LAC", data.acklac),
        row("Pin Code", data.ackpincode),
        row("Mobile No", data.ackmobile),
        row("Submitted on", data.submitted_on),
      ],
    );
  }

  TableRow row(String title, String value) {
    return TableRow(children: [
      Padding(
        padding: const EdgeInsets.all(8),
        child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      Padding(
        padding: const EdgeInsets.all(8),
        child: Text(value),
      ),
    ]);
  }
}
