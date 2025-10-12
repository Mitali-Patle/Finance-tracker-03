//  feedback_form.dart
import 'package:flutter/material.dart';


class FeedbackForm extends StatefulWidget {
  @override
  _FeedbackFormState createState() => _FeedbackFormState();
}

class _FeedbackFormState extends State<FeedbackForm> {
  String? _degree = "UG Student";
  List<String> _programs = [];

  final _nameController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _feedbackController = TextEditingController();
  final _improveController = TextEditingController(); // New field
  final _featuresController = TextEditingController(); // New field


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Feedback Form"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Feedback Image and Heading
              Center(
                child: Column(
                  children: [
                    Image.network(
                      'https://cdn-icons-png.flaticon.com/512/9068/9068670.png',
                      height: 150,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),

              // Name Field
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: "Your Name",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              SizedBox(height: 16),

              
              // How can we improve?
              TextField(
                controller: _improveController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: "How can we improve our service?",
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
              SizedBox(height: 16),

              // What features would you like?
              TextField(
                controller: _featuresController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: "What features would you like to see?",
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
              SizedBox(height: 20),

              // Submit Button
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    print("Name: ${_nameController.text}");
                    print("WhatsApp: ${_whatsappController.text}");
                    print("Degree: $_degree");
                    print("Programs: $_programs");
                    print("Feedback: ${_feedbackController.text}");
                    print("Improve: ${_improveController.text}");
                    print("Features: ${_featuresController.text}");
                  },
                  child: Text("Submit Feedback"),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
