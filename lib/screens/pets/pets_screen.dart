// lib/screens/pets/pets_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/pet_model.dart';
import '../../services/database_service.dart';

class PetsScreen extends StatefulWidget {
  const PetsScreen({super.key});

  @override
  State<PetsScreen> createState() => _PetsScreenState();
}

class _PetsScreenState extends State<PetsScreen> {
  final DatabaseService _dbService = DatabaseService();
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  void _showPetFormModal([Pet? existingPet]) {
    final nameController = TextEditingController(text: existingPet?.name ?? '');
    final ageController = TextEditingController(text: existingPet?.age.toString() ?? '');
    final weightController = TextEditingController(text: existingPet?.weight.toString() ?? '');
    String selectedType = existingPet?.type ?? 'Dog';
    String selectedGender = existingPet?.gender ?? 'Male';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 24, right: 24, top: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    existingPet == null ? 'Add New Pet' : 'Edit Pet',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Pet Name *'),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: selectedType,
                          decoration: const InputDecoration(labelText: 'Type *'),
                          items: ['Dog', 'Cat', 'Bird', 'Rabbit', 'Fish', 'Other']
                              .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                              .toList(),
                          onChanged: (val) => setModalState(() => selectedType = val!),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: selectedGender,
                          decoration: const InputDecoration(labelText: 'Gender'),
                          items: ['Male', 'Female']
                              .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                              .toList(),
                          onChanged: (val) => setModalState(() => selectedGender = val!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: ageController,
                          decoration: const InputDecoration(labelText: 'Age (years)'),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: weightController,
                          decoration: const InputDecoration(labelText: 'Weight (kg)'),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () async {
                      if (nameController.text.isEmpty) return;

                      final pet = Pet(
                        id: existingPet?.id ?? '',
                        ownerId: currentUserId,
                        name: nameController.text.trim(),
                        type: selectedType,
                        age: double.tryParse(ageController.text) ?? 0.0,
                        weight: double.tryParse(weightController.text) ?? 0.0,
                        gender: selectedGender,
                      );

                      if (existingPet == null) {
                        await _dbService.addPet(pet);
                      } else {
                        await _dbService.updatePet(pet);
                      }

                      if (context.mounted) Navigator.pop(context);
                    },
                    child: Text(
                      existingPet == null ? 'Save Pet' : 'Update Pet',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Pets', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: StreamBuilder<List<Pet>>(
        stream: _dbService.getUserPets(currentUserId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            debugPrint('PetsScreen stream error: ${snapshot.error}');
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          
          final pets = snapshot.data ?? [];
          
          if (pets.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text('🐾', style: TextStyle(fontSize: 64)),
                  SizedBox(height: 16),
                  Text('No pets yet', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text('Add your first pet to get started', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: pets.length,
            itemBuilder: (context, index) {
              final pet = pets[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: const Color(0xFFEFF6FF),
                            child: const Text('🐾', style: TextStyle(fontSize: 24)),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(pet.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                Text(pet.type, style: const TextStyle(color: Colors.grey)),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.grey),
                            onPressed: () => _showPetFormModal(pet),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.redAccent),
                            onPressed: () => _dbService.deletePet(pet.id),
                          ),
                        ],
                      ),
                      const Divider(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildPetStat('Age', '${pet.age} yrs'),
                          _buildPetStat('Weight', '${pet.weight} kg'),
                          _buildPetStat('Gender', pet.gender),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showPetFormModal(),
        backgroundColor: const Color(0xFF2563EB),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Pet', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildPetStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }
}