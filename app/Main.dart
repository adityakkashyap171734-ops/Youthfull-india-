import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.android);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Youthfull India',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: const ServicesPage(),
    );
  }
}

class ServicesPage extends StatelessWidget {
  const ServicesPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Youthfull India')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('services').snapshots(),
        builder: (context, snap) {
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs =
              snap.data!.docs.where((d) => d.data()['active'] != false).toList();
          if (docs.isEmpty) {
            return const Center(child: Text('No services yet'));
          }
          return ListView(
            children: docs.map((d) {
              final s = d.data();
              final name = '${s['name'] ?? ''}';
              return ListTile(
                leading: const Icon(Icons.build_circle),
                title: Text(name),
                subtitle: Text('Rs ${s['price'] ?? ''}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        BookingPage(serviceId: d.id, serviceName: name),
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class BookingPage extends StatefulWidget {
  final String serviceId;
  final String serviceName;
  const BookingPage(
      {super.key, required this.serviceId, required this.serviceName});
  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final name = TextEditingController();
  final phone = TextEditingController();
  final address = TextEditingController();
  bool saving = false;

  Future<void> submit() async {
    if (name.text.trim().isEmpty ||
        phone.text.trim().isEmpty ||
        address.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Sab fields bharo')));
      return;
    }
    setState(() => saving = true);
    try {
      await FirebaseFirestore.instance.collection('bookings').add({
        'serviceId': widget.serviceId,
        'serviceName': widget.serviceName,
        'name': name.text.trim(),
        'phone': phone.text.trim(),
        'address': address.text.trim(),
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Booking ho gayi!')));
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => saving = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.serviceName)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
              controller: name,
              decoration: const InputDecoration(labelText: 'Naam')),
          const SizedBox(height: 12),
          TextField(
              controller: phone,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Phone')),
          const SizedBox(height: 12),
          TextField(
              controller: address,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Pata')),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: saving ? null : submit,
            child: Text(saving ? 'Wait...' : 'Book karo'),
          ),
        ],
      ),
    );
  }
}
