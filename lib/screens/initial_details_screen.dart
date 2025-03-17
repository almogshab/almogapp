import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart'; // ייבוא חבילת image_picker

// מחלקה לשמירת נתיב התמונה
class UserDetailsNotifier extends StateNotifier<UserDetailsState> {
  UserDetailsNotifier() : super(UserDetailsState());

  void setFullName(String name) {
    state = state.copyWith(fullName: name);
  }

  void setBirthDate(DateTime date) {
    state = state.copyWith(birthDate: date);
  }

  void setGender(Gender gender) {
    state = state.copyWith(gender: gender);
  }

  void setProfileImage(String? imagePath) {
    state = state.copyWith(profileImagePath: imagePath);
  }
}

// Enum for gender
enum Gender { male, female, notSpecified }

// User details state
class UserDetailsState {
  final String fullName;
  final DateTime? birthDate;
  final Gender gender;
  final String? profileImagePath; // נתיב לתמונת הפרופיל

  UserDetailsState({
    this.fullName = '',
    this.birthDate,
    this.gender = Gender.notSpecified,
    this.profileImagePath,
  });

  UserDetailsState copyWith({
    String? fullName,
    DateTime? birthDate,
    Gender? gender,
    String? profileImagePath,
  }) {
    return UserDetailsState(
      fullName: fullName ?? this.fullName,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      profileImagePath: profileImagePath ?? this.profileImagePath,
    );
  }
}

// Providers
final userDetailsProvider = StateNotifierProvider<UserDetailsNotifier, UserDetailsState>((ref) {
  return UserDetailsNotifier();
});

final fullNameProvider = Provider<String>((ref) {
  return ref.watch(userDetailsProvider).fullName;
});

final birthDateProvider = Provider<DateTime?>((ref) {
  return ref.watch(userDetailsProvider).birthDate;
});

final genderProvider = Provider<Gender>((ref) {
  return ref.watch(userDetailsProvider).gender;
});

final profileImageProvider = Provider<String?>((ref) {
  return ref.watch(userDetailsProvider).profileImagePath;
});

// Formatter for date
final dateFormatterProvider = Provider<String>((ref) {
  final birthDate = ref.watch(birthDateProvider);
  if (birthDate == null) return '';
  return '${birthDate.day}/${birthDate.month}/${birthDate.year}';
});

class InitialDetailsScreen extends ConsumerWidget {
  const InitialDetailsScreen({Key? key}) : super(key: key);

  // פונקציה לבחירת תמונה
  Future<void> _pickImage(BuildContext context, WidgetRef ref, ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        ref.read(userDetailsProvider.notifier).setProfileImage(image.path);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('שגיאה בעת בחירת תמונה: $e')),
      );
    }
  }

  // פונקציה להצגת תפריט בחירת תמונה
  void _showImagePickerOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: SafeArea(
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('צלם תמונה'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickImage(context, ref, ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('העלאה מהספרייה'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickImage(context, ref, ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gender = ref.watch(genderProvider);
    final dateFormatter = ref.watch(dateFormatterProvider);
    final nameController = TextEditingController(text: ref.watch(fullNameProvider));
    final profileImagePath = ref.watch(profileImageProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl, // For Hebrew language support
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Profile picture area
              Center(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () => _showImagePickerOptions(context, ref),
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          shape: BoxShape.circle,
                          image: profileImagePath != null
                              ? DecorationImage(
                            image: FileImage(File(profileImagePath)),
                            fit: BoxFit.cover,
                          )
                              : null,
                        ),
                        child: profileImagePath == null
                            ? Center(
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () => _showImagePickerOptions(context, ref),
                      child: const Text(
                        "+ הוספת תמונת פרופיל",
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Full name field
              TextField(
                controller: nameController,
                onChanged: (value) {
                  ref.read(userDetailsProvider.notifier).setFullName(value);
                },
                decoration: InputDecoration(
                  labelText: "שם מלא",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Birth date field
              TextField(
                readOnly: true,
                controller: TextEditingController(text: dateFormatter),
                onTap: () async {
                  // Show date picker
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    ref.read(userDetailsProvider.notifier).setBirthDate(picked);
                  }
                },
                decoration: InputDecoration(
                  labelText: "תאריך לידה",
                  suffixIcon: const Icon(Icons.calendar_today),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Gender selection
              const Text(
                "מגדר",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        ref.read(userDetailsProvider.notifier).setGender(Gender.male);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: gender == Gender.male ? Colors.blue : Colors.grey.shade300,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.male,
                              color: gender == Gender.male ? Colors.blue : Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "גבר",
                              style: TextStyle(
                                color: gender == Gender.male ? Colors.blue : Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        ref.read(userDetailsProvider.notifier).setGender(Gender.female);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: gender == Gender.female ? Colors.blue : Colors.grey.shade300,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.female,
                              color: gender == Gender.female ? Colors.blue : Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "אישה",
                              style: TextStyle(
                                color: gender == Gender.female ? Colors.blue : Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // Continue button
              Container(
                margin: const EdgeInsets.only(bottom: 24),
                child: ElevatedButton(
                  onPressed: () {
                    // Handle continue button press with Riverpod state
                    final userDetails = ref.read(userDetailsProvider);
                    debugPrint('User details: ${userDetails.fullName}, ${userDetails.birthDate}, ${userDetails.gender}, ${userDetails.profileImagePath}');
                    // Navigate to next screen or submit data
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "המשיך",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}