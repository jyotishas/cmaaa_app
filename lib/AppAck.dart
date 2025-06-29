import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class AppAckData {
  final String App_reg_No;
  final String App_applicant_Name;
  final String App_submitted_on;
  final String App_permanentadd;
  final String App_sector;
  final String App_subsector;
  final String App_bus_address;
  final String App_district;
  final String App_lac;
  final String App_sub_district;
  final String App_block;
  final String App_pincode;
  final String App_mobile;



  AppAckData({
    required this.App_reg_No,
    required this.App_applicant_Name,
    required this.App_submitted_on,
    required this.App_permanentadd,
    required this.App_sector,
    required this.App_subsector,
    required this.App_bus_address,
    required this.App_district,
    required this.App_lac,
    required this.App_sub_district,
    required this.App_block,
    required this.App_pincode,
    required this.App_mobile,
  });
}

class AppAck extends StatelessWidget {
  final AppAckData data;

  const AppAck({required this.data, Key? key}) : super(key: key);

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
                  "Dear ${data.App_applicant_Name},\n\nYour application form for “Chief Minister's Atmanirbhar Asom Abhijan 2.0” have been submitted successfully."
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
                                      "Dear ${data.App_applicant_Name},\n\nYour application form for \"Chief Minister's Atmanirbhar Asom Abhijan 2.0\" has been submitted successfully."
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

  pw.Widget _buildPdfTable(AppAckData data) {
    List<List<String>> fields = [
      ["Application Reference No.", data.App_reg_No],
      ["Applicant Name", data.App_applicant_Name],
      ["Submitted on", data.App_submitted_on],
      ["Permanent Address", data.App_permanentadd],
      ["Sector", data.App_sector],
      ["Sub Sector", data.App_subsector],
      ["Business Address", data.App_bus_address],
      ["District", data.App_district],
      ["LAC", data.App_lac],
      ["Sub District", data.App_sub_district],
      ["Block", data.App_block],
      ["Pin Code", data.App_pincode],
      ["Mobile No", data.App_mobile],
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


  Widget buildInfoTable(AppAckData data) {
    return Table(
      border: TableBorder.all(),
      columnWidths: const {
        0: FlexColumnWidth(3),
        1: FlexColumnWidth(7),
      },
      children: [
        row("Application Reference No.", data.App_reg_No),
        row("Applicant Name", data.App_applicant_Name),
        row("Submitted on", data.App_submitted_on),
        row("Permanent Address", data.App_permanentadd),
        row("Sector", data.App_sector),
        row("Sub Sector", data.App_subsector),
        row("Business Address", data.App_bus_address),
        row("District", data.App_district),
        row("LAC", data.App_lac),
        row("Sub District", data.App_sub_district),
        row("Block", data.App_block),
        row("Pin Code", data.App_pincode),
        row("Mobile No", data.App_mobile),

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
