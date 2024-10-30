import 'package:app/modeles/Cafe.dart';
import 'package:app/provider/cafe_provider.dart';
import 'package:app/services/VolunteerService.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config.dart';

class DeleteBenevole extends StatefulWidget {
  const DeleteBenevole({super.key});

  @override
  State<DeleteBenevole> createState() => _DeleteBenevoleState();
}

class _DeleteBenevoleState extends State<DeleteBenevole> {
  bool _isLoading = false;
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    Cafe? selectedCafe =
        Provider.of<CafeProvider>(context, listen: false).selectedCafe;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Supprimer un bénévole'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          //title for matricule
          Container(
            padding: EdgeInsets.only(left: screenHeight * 0.025),
            child: const Text(
              "Matricule du benevole",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.left,
            ),
          ),
          //Textfield for matricule
          Container(
            padding: const EdgeInsets.all(0.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blueAccent),
              borderRadius: BorderRadius.circular(8),
            ),
            width: screenWidth * 0.95,
            margin: const EdgeInsets.all(10.0),
            //Textefield
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: "Entrer le matricule du bénévole",
                hintStyle: TextStyle(color: Colors.grey),
              ),
            ),
          ),

          // add benevole button
          ButtonBar(
            alignment: MainAxisAlignment.center,
            buttonPadding: EdgeInsets.symmetric(horizontal: 16.0),
            children: [
              ElevatedButton(
                onPressed: () async {
                  setState(() {
                    _isLoading = true;
                  });
                  try {
                    //String message = await VolunteerService()
                    //    .deleteVolunteer(Config.cafeName, _controller.text);
                    String message = await VolunteerService()
                        .deleteVolunteer("tore-et-fraction", _controller.text);

                    // pop up message
                    print(message);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: Colors.blue,
                        content: Text(message,
                            style: const TextStyle(color: Colors.white)),
                        duration:
                            const Duration(seconds: 4), // Durée du SnackBar
                      ),
                    );
                  } catch (e) {
                    print("Failed to post volunteer: $e");
                    // pop up message
                    if (!mounted) {
                      return;
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Failed to post volunteer: $e",
                            style: const TextStyle(color: Colors.white)),
                        duration: const Duration(seconds: 4),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: Colors.red, // Durée du SnackBar
                      ),
                    );
                  } finally {
                    setState(() {
                      _isLoading = false;
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // Couleur de fond du bouton
                  foregroundColor: Colors.white, // Couleur du texte du bouton
                  padding:
                      EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                  textStyle:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Confirmer la suppression'),
              ),
            ],
          ),

          if (_isLoading) const Center(child: CircularProgressIndicator()),

          // delete text button
          ButtonBar(
            alignment: MainAxisAlignment.center,
            buttonPadding: EdgeInsets.symmetric(horizontal: 16.0),
            children: [
              ElevatedButton(
                onPressed: () {
                  _controller.clear();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, // Couleur de fond du bouton
                  foregroundColor: Colors.white, // Couleur du texte du bouton
                  padding:
                      EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                  textStyle:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Effacer tout'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
