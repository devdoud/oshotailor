import 'package:flutter/material.dart';
import 'package:osho/common/widgets/appbar/appbar.dart';
import 'package:osho/utils/constants/image_strings.dart';

class ModelPhotosScreen extends StatelessWidget {
  const ModelPhotosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const OAppBar(
        title: Text('Photos de référence', style: TextStyle(fontWeight: FontWeight.bold)),
        showBackArrow: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Inspiration et détails du modèle",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              
              // Grid of photos
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 4,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 0.8,
                ),
                itemBuilder: (context, index) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.asset(
                      OImages.modelstore, // Using default image for now
                      fit: BoxFit.cover,
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 24),
              const Text(
                "Instructions spéciales",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  "Veuillez faire attention aux broderies sur le col. Le client souhaite un tissu légèrement plus épais que le modèle original.",
                  style: TextStyle(color: Colors.black87, height: 1.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
