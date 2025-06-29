import 'package:flutter/material.dart';
import 'my_form.dart';
import 'login.dart';
import 'about.dart';
import 'contact.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Drawer Section
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF6E6E6E), Color(0xFFF6C2AD)],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CircleAvatar(
                      backgroundImage: AssetImage('assets/National Emblem.jpeg'),
                      radius: 30,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Welcome!",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.home, color: Colors.black),
                title: const Text('Home'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              const Divider(thickness: 1),
              ListTile(
                leading: const Icon(Icons.info, color: Colors.black),
                title: const Text('About'),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutPage()));
                },
              ),
              const Divider(thickness: 2),
              ListTile(
                leading: const Icon(Icons.contact_mail, color: Colors.black),
                title: const Text('Contact'),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const ContactPage()));
                },
              ),
              const Divider(thickness: 2),
              ListTile(
                leading: const Icon(Icons.app_registration, color: Colors.black),
                title: const Text('Sign Up'),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => MyForm()));
                },
              ),
              const Divider(thickness: 2),
              ListTile(
                leading: const Icon(Icons.login, color: Colors.black),
                title: const Text('Log In'),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
                },
              ),

            ],
          ),
        ),
      body: Container(
        width: double.infinity, // Full width
        height: double.infinity, // Full height
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF6E6E6E),
              Color(0xFFF6C2AD),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),

              // App Name with Favicon
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(right: 8.0),
                      child: Image(
                        image: AssetImage('assets/favicon.png'),
                        width: 40,
                        height: 40,
                      ),
                    ),
                    RichText(
                      text: const TextSpan(
                        children: [
                          TextSpan(
                            text: "Chief Minister's ",
                            style: TextStyle(
                              fontSize: 16.5,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic,
                              color: Colors.black,
                            ),
                          ),
                          TextSpan(
                            text: 'Atmanirbhar ',
                            style: TextStyle(
                              fontSize: 16.5,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic,
                              color: Colors.orange,
                            ),
                          ),
                          TextSpan(
                            text: 'Asom ',
                            style: TextStyle(
                              fontSize: 16.5,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic,
                              color: Colors.orange,
                            ),
                          ),
                          TextSpan(
                            text: 'Abhijan',
                            style: TextStyle(
                              fontSize: 16.5,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Divider Line
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Divider(thickness: 5, color: Colors.white),
              ),

              // AppBar Below the Divider
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  iconTheme: const IconThemeData(color: Colors.white),
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Quote Boxes
                      const SizedBox(height: 20),
                      const QuoteBox(
                        text: "Total Registration: 1,61,819",
                        icon: Icons.app_registration,
                        highlights: ["1,61,819"],
                      ),
                      const QuoteBox(
                        text: "Download Project Templates for different sectors.",
                        icon: Icons.download,
                        highlights: ["Download"],
                      ),
                      const QuoteBox(
                        text: "Total Beneficiaries: 25,000 +",
                        icon: Icons.groups,
                        highlights: ["25,000 +"],
                      ),

                     const SizedBox(height: 20),

                      DefaultTabController(
                        length: 4, // Number of tabs
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 12), // Add margins
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                              ),
                              child: TabBar(
                                labelColor: Colors.black87,
                                unselectedLabelColor: Colors.white,
                                indicator: BoxDecoration(
                                  color: Colors.transparent,
                                ),
                                labelStyle: const TextStyle(fontSize: 9.6),
                                tabs: const [
                                  Tab(icon: Icon(Icons.lightbulb, size: 16.5), text: "Objectives"),
                                  Tab(icon: Icon(Icons.school, size: 16.5), text: "Eligibility"),
                                  Tab(icon: Icon(Icons.description, size: 16.5), text: "Documents"),
                                  Tab(icon: Icon(Icons.help, size: 16.5), text: "How to Apply"),
                                ],
                              ),
                            ),

                            const SizedBox(height: 10),

                            /// 🔹 Fixed Overflow: Restrict Tab View height
                            SizedBox(
                              height: 350, // Adjust height as needed
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.transparent, // Ensure transparency
                                ),
                              child: Card(
                                color: Colors.transparent,
                                margin: const EdgeInsets.symmetric(horizontal: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 0,
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: TabBarView(
                                    children: [
                                      DefaultTextStyle(
                                        style: const TextStyle(fontWeight: FontWeight.w500, fontStyle: FontStyle.italic, color: Colors.black, height: 1.8),
                                        child: ObjectivesSection([
                                          "Provide self-employment to all categories of educated youth through suitable mechanisms.",
                                          "Create an entrepreneur-oriented ecosystem in Assam.",
                                          "Generate employment opportunities in rural and urban areas through setting up new/existing ventures.",
                                          "Provide financial assistance to enterprising individuals and groups.",
                                          "Strengthen the State Government's focus on rural economy.",
                                        ]),
                                      ),

                                      // Eligibility Section
                                      DefaultTextStyle(
                                        style: const TextStyle(fontWeight: FontWeight.w500, fontStyle: FontStyle.italic, color: Colors.black, height: 1.8),
                                        child: InfoSection([
                                        "The applicant should be permanent resident of Assam and should be above 28 years and below 45 years as on 1st April, 2024.",
                                        "The applicant should possess the minimum educational qualification as indicated below -\n"
                                            "   • Class X pass for General caste\n"
                                            "   • Upto Class X for candidates belonging to\n"
                                            "   SC/ST/OBC",
                                        "The applicant should possess skills, experiences, knowledge to undertake the income generating activities.",
                                        "The applicant should have a Scheduled commercial bank account, which has been opened before 1st April 2024.",
                                        "The applicant should not have defaulted any loan taken from any scheduled commercial Bank in the past.",
                                        "Not more than one member from any household shall be eligible to be a beneficiary under this scheme. For the purpose of the scheme, family mean Husband, Wife, Brother and Sister.",
                                        "The applicant must have valid registration in the Employment Exchange.",
                                        "The applicant must not be a beneficiary of CMAAA 1.0."
                                      ]),
                                      ),

                                      // Documents Required
                                      DefaultTextStyle(
                                        style: const TextStyle(fontWeight: FontWeight.w500, fontStyle: FontStyle.italic, color: Colors.black, height: 1.8),
                                        child: InfoSection([
                                        "Any of the following Identity/address Proof - Aadhaar /voter Id/Passport/Driving license.",
                                        "Proof of Educational Qualification.",
                                        "First page of active Bank account Passbook (Name in the bank passbook should be the same as the ID card submitted).",
                                        "PAN Card.",
                                        "Employment Exchange Registration Card.",
                                      ]),
                                      ),

                                      // How to Apply
                                      DefaultTextStyle(
                                        style: const TextStyle(fontWeight: FontWeight.w500, fontStyle: FontStyle.italic, color: Colors.black, height: 1.8),
                                        child: InfoSection([
                                        "Only the registered applicants are eligible for applying for the Scheme “Chief Minister's Atmanirbhar Asom Abhijan 2.0”.",
                                        "To apply in 'Chief Minister's Atmanirbhar Asom Abhijan 2.0', registered applicants need to click the 'Apply for Scheme' option.",
                                        "Registered applicants have to fill up all the necessary details, upload required documents as applicable.",
                                        "Registered applicants have to upload the project report based on the selected Sector/Sub-Sector.",
                                        "After successful submission an acknowledgement slip is generated along with a reference number, with the help of which a registered applicant can track the status of the application. An SMS and Email is being sent to the applicant.",
                                        "A registered applicant can view and track the status of the application by clicking the Track button and entering the applicant's application reference no.",
                                        " If the applicant is found eligible the same will be notified to the applicant over SMS and Email.",
                                      ]),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            )],
                        ),
                      ),
                    ],
          ),
        ),
      ),
      ],
    ),
    )));}
}

class InfoSection extends StatelessWidget {
  final List<String> items;
  const InfoSection(this.items, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ListView(
        children: items
            .map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.check_circle, size: 16 , color: Colors.lightGreen), // Custom bullet
              const SizedBox(width: 2.5),
              Expanded(
                child: Text(
                  item,
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                ),
              ),
            ],
          ),
        ))
            .toList(),
      ),
    );
  }
}

class ObjectivesSection extends StatelessWidget {
  final List<String> objectives; // Declare a final variable to store the list

  const ObjectivesSection(this.objectives, {super.key}); // Proper constructor

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            spreadRadius: 2,
          ),
        ],
      ),
      child: SizedBox(
        height: 150, // Adjust height as needed
        child: ListView(
         children: objectives
          .map((objective) => ObjectiveItem(objective))
          .toList(),
    ),
    ));
  }
}

class ObjectiveItem extends StatelessWidget {
  final String text;
  const ObjectiveItem(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, size: 16 , color: Colors.lightGreen), // Custom bullet
          const SizedBox(width: 2.5),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}

// Animated QuoteBox
class QuoteBox extends StatefulWidget {
  final String text;
  final IconData icon;
  final List<String> highlights;

  const QuoteBox({
    super.key,
    required this.text,
    required this.icon,
    this.highlights = const [],
  });

  @override
  _QuoteBoxState createState() => _QuoteBoxState();
}

class _QuoteBoxState extends State<QuoteBox> {
  double _scale = 1.0;
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        _opacity = 1.0;
      });
    });
  }

  void _onTapDown(TapDownDetails details) {
    setState(() {
      _scale = 1.05; // Enlarge when tapped
    });
  }

  void _onTapUp(TapUpDetails details) {
    setState(() {
      _scale = 1.0; // Return to normal size
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 500),
        opacity: _opacity,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.identity()..scale(_scale),
          padding: const EdgeInsets.all(10.0),
          margin: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6.0),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(widget.icon, color: Colors.white, size: 35),
              const SizedBox(width: 16),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    children: _highlightText(widget.text, widget.highlights),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  List<TextSpan> _highlightText(String text, List<String> highlights) {
    List<TextSpan> spans = [];
    String remainingText = text;

    for (var highlight in highlights) {
      if (remainingText.contains(highlight)) {
        final parts = remainingText.split(highlight);
        spans.add(TextSpan(text: parts[0]));
        spans.add(TextSpan(
          text: highlight,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ));
        remainingText = parts.length > 1 ? parts[1] : '';
      }
    }

    if (remainingText.isNotEmpty) {
      spans.add(TextSpan(text: remainingText));
    }

    return spans;
  }
}