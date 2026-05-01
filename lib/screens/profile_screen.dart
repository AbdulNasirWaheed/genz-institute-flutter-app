import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'login_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  final int userId;
  final String userName;
  const ProfileScreen({super.key, required this.userId, required this.userName});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  void loadProfile() async {
    // ✅ FIX: parse userId safely
    int userId = int.parse(widget.userId.toString());
    var result = await ApiService.getProfile(userId);

    print('🔍 PROFILE RESULT: $result'); // debug

    if (result['success'] == true) {
      setState(() {
        userData = result['user'];
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
      print('❌ Profile load failed: ${result['message']}');
    }
  }

  // ✅ FIX: safe value helper - handles null and non-String types
  String safeValue(dynamic val) {
    if (val == null) return '';
    return val.toString();
  }

  Widget infoRow(IconData icon, String label, dynamic value) {
    String displayValue = safeValue(value);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 4)],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded( // ✅ FIX: Expanded prevents overflow on long text
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                Text(
                  displayValue.isNotEmpty ? displayValue : 'Not provided',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis, // ✅ FIX: no overflow crash
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : userData == null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.red),
            const SizedBox(height: 12),
            const Text('Failed to load profile'),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: loadProfile, // ✅ FIX: retry button
              child: const Text('Retry'),
            ),
          ],
        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blue,
              child: Icon(Icons.person, size: 60, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Text(
              safeValue(userData!['name']),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              safeValue(userData!['email']),
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),

            infoRow(Icons.phone, 'Phone', userData!['phone']),
            infoRow(Icons.home, 'Address', userData!['address']),
            infoRow(Icons.calendar_today, 'Date of Birth', userData!['dob']),
            infoRow(Icons.people, 'Gender', userData!['gender']),
            infoRow(Icons.book, 'Course', userData!['course']),

            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.edit, color: Colors.white),
                label: const Text(
                  'Edit Profile',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditProfileScreen(
                        // ✅ FIX: always pass int
                        userId: int.parse(widget.userId.toString()),
                        currentData: userData!,
                      ),
                    ),
                  );
                  loadProfile();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}