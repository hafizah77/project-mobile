import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddDestinationPage extends StatefulWidget {
  const AddDestinationPage({super.key});

  @override
  State<AddDestinationPage> createState() => _AddDestinationPageState();
}

class _AddDestinationPageState extends State<AddDestinationPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();

  bool _isLoading = false;
  String imageUrlPreview = '';

  void _submitDestination() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        await FirebaseFirestore.instance.collection('places').add({
          'name': _nameController.text.trim(),
          'location': _locationController.text.trim(),
          'description': _descriptionController.text.trim(),
          'price': int.tryParse(_priceController.text.trim()) ?? 0,
          'image_url': _imageUrlController.text.trim(),
          'created_at': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tempat wisata berhasil ditambahkan')),
        );

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal menambahkan: $e')));
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _imageUrlController.addListener(() {
      setState(() {
        imageUrlPreview = _imageUrlController.text.trim();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Tempat Wisata')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nama Tempat'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Lokasi'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Deskripsi'),
                maxLines: 3,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Harga Tiket'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'URL Gambar (harus berupa link gambar)',
                ),
              ),
              const SizedBox(height: 12),
              imageUrlPreview.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        imageUrlPreview,
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Text(
                            'Gambar tidak valid atau tidak bisa dimuat.',
                            style: TextStyle(color: Colors.red),
                          );
                        },
                      ),
                    )
                  : const Text('Preview gambar akan tampil di sini'),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _submitDestination,
                icon: const Icon(Icons.add),
                label: _isLoading
                    ? const Text('Menyimpan...')
                    : const Text('Simpan Tempat'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
