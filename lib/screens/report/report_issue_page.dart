import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';

import '../../models/report/reportissue.dart';
import '../../widgets/drawer.dart';
import '../../providers/report/report_provider.dart';

class ReportIssuePage extends StatefulWidget {
  const ReportIssuePage({super.key});

  @override
  State<ReportIssuePage> createState() => _ReportIssuePageState();
}

class _ReportIssuePageState extends State<ReportIssuePage> {
  final TextEditingController descriptionController =
  TextEditingController();

  final TextEditingController nameEmailController =
  TextEditingController();

  final GlobalKey<ScaffoldState> _scaffoldKey =
  GlobalKey<ScaffoldState>();

  String selectedUrgency = '';
  String selectedLocation = '';

  // ============================================================
  // UPLOAD VARIABLES
  // ============================================================

  File? selectedFile;

  bool uploadSuccessful = false;

  String uploadedFileName = '';

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    descriptionController.dispose();
    nameEmailController.dispose();
    super.dispose();
  }

  // ============================================================
  // LOCATION
  // ============================================================

  void selectLocation() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Location'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.location_on),
                title: const Text('Kuala Lumpur'),
                onTap: () {
                  setState(() {
                    selectedLocation = 'Kuala Lumpur';
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.location_on),
                title: const Text('Petaling Jaya'),
                onTap: () {
                  setState(() {
                    selectedLocation = 'Petaling Jaya';
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.location_on),
                title: const Text('Shah Alam'),
                onTap: () {
                  setState(() {
                    selectedLocation = 'Shah Alam';
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // UPLOAD FILE
  // ============================================================

  Future<void> uploadFile() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 15,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                const Text(
                  'Select File',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 10),

                // Choose File
                ListTile(
                  leading: const Icon(
                    Icons.folder_outlined,
                    size: 30,
                  ),
                  title: const Text(
                    'Choose File',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    chooseFile();
                  },
                ),

                // Cancel
                ListTile(
                  leading: const Icon(
                    Icons.close,
                    size: 30,
                  ),
                  title: const Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // CHOOSE FILE
  // ============================================================

  Future chooseFile() async {
    try {
      FilePickerResult? result =
      await FilePicker.platform.pickFiles(
        type: FileType.any,
      );

      if (result == null) {
        return;
      }

      final pickedFile = result.files.single;

      print('Name: ${pickedFile.name}');
      print('Path: ${pickedFile.path}');

      if (pickedFile.path == null) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cannot access this file'),
          ),
        );
        return;
      }

      setState(() {
        selectedFile = File(pickedFile.path!);
        uploadedFileName = pickedFile.name;
        uploadSuccessful = true;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Upload Successful'),
        ),
      );
    } catch (e) {
      print('ERROR: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Upload failed: $e'),
        ),
      );
    }
  }

  // ============================================================
  // REMOVE FILE
  // ============================================================

  void removeUploadedFile() {
    setState(() {
      selectedFile = null;
      uploadedFileName = '';
      uploadSuccessful = false;
    });
  }

  // ============================================================
  // SUBMIT
  // ============================================================

  Future<void> submitReport() async {
    // Check description
    if (descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter description'),
        ),
      );
      return;
    }

    // Check location
    if (selectedLocation.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select location'),
        ),
      );
      return;
    }

    // Check urgency
    if (selectedUrgency.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select urgency'),
        ),
      );
      return;
    }

    try {
      final report = ReportIssue(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        description: descriptionController.text.trim(),
        location: selectedLocation,
        urgency: selectedUrgency,
        nameEmail: nameEmailController.text.trim(),
        fileName: uploadedFileName,
        createdAt: DateTime.now().toIso8601String(),
      );

      await context.read<ReportProvider>().addReport(report);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Report submitted successfully'),
        ),
      );

      descriptionController.clear();
      nameEmailController.clear();

      setState(() {
        selectedLocation = '';
        selectedUrgency = '';
        selectedFile = null;
        uploadedFileName = '';
        uploadSuccessful = false;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit report: $e'),
        ),
      );
    }
  }

  // ============================================================
  // UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,

      // ========================================================
      // DRAWER
      // ========================================================

      drawer: const AppDrawer(),

      // ========================================================
      // BODY
      // ========================================================

      body: SafeArea(
        child: Column(
          children: [

            // ==================================================
            // TOP BAR
            // ==================================================

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 7,
                vertical: 12,
              ),
              child: SizedBox(
                height: 35,
                child: Row(
                  children: [

                    // Menu
                    SizedBox(
                      width: 40,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: const Icon(
                          Icons.menu,
                          size: 25,
                          color: Colors.black,
                        ),
                        onPressed: () {
                          _scaffoldKey.currentState?.openDrawer();
                        },
                      ),
                    ),

                    // Title
                    const Expanded(
                      child: Center(
                        child: Text(
                          'Voltix',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),

                    // Profile
                    Padding(
                      padding: const EdgeInsets.only(right: 2),
                      child: Container(
                        width: 23,
                        height: 23,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black,
                        ),
                        child: const Icon(
                          Icons.person,
                          size: 15,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ==================================================
            // MAIN CONTENT
            // ==================================================

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    const SizedBox(height: 8),

                    // ==================================================
                    // REPORT ISSUE BUTTON
                    // ==================================================

                    SizedBox(
                      width: double.infinity,
                      height: 41,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Report Issue',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // ==================================================
                    // ISSUE
                    // ==================================================

                    const Text(
                      'Issue',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                      ),
                    ),

                    const SizedBox(height: 7),

                    Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE3E3E3),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: TextField(
                        controller: descriptionController,
                        maxLines: 1,
                        style: const TextStyle(
                          fontSize: 15,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Description',
                          hintStyle: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 17,
                            vertical: 9,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // ==================================================
                    // LOCATION
                    // ==================================================

                    const Text(
                      'Location',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),

                    const SizedBox(height: 7),

                    GestureDetector(
                      onTap: selectLocation,
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE3E3E3),
                          borderRadius: BorderRadius.circular(11),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 17,
                        ),
                        child: Row(
                          children: [

                            Expanded(
                              child: Text(
                                selectedLocation.isEmpty
                                    ? 'Select Location'
                                    : selectedLocation,
                                style: TextStyle(
                                  color: selectedLocation.isEmpty
                                      ? Colors.white
                                      : Colors.black,
                                  fontSize: 15,
                                ),
                              ),
                            ),

                            const Icon(
                              Icons.location_on,
                              size: 21,
                              color: Colors.black87,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // ==================================================
                    // UPLOAD TITLE
                    // ==================================================

                    const Text(
                      'Upload (jpg,png,pdf...)',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                      ),
                    ),

                    const SizedBox(height: 4),

                    // ==================================================
                    // UPLOAD BOX
                    // ==================================================

                    _buildUploadBox(),

                    const SizedBox(height: 15),

                    // ==================================================
                    // URGENCY
                    // ==================================================

                    const Text(
                      'Urgency',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                      ),
                    ),

                    const SizedBox(height: 7),

                    Row(
                      children: [

                        Expanded(
                          child: _urgencyButton('Low'),
                        ),

                        const SizedBox(width: 19),

                        Expanded(
                          child: _urgencyButton('Medium'),
                        ),

                        const SizedBox(width: 19),

                        Expanded(
                          child: _urgencyButton('High'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 13),

                    // ==================================================
                    // NAME / EMAIL
                    // ==================================================

                    Container(
                      height: 40,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE3E3E3),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: TextField(
                        controller: nameEmailController,
                        style: const TextStyle(
                          fontSize: 14,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Optional: Your Name/Email',
                          hintStyle: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 17,
                            vertical: 9,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 21),

                    // ==================================================
                    // SUBMIT
                    // ==================================================

                    Center(
                      child: SizedBox(
                        width: 132,
                        height: 40,
                        child: ElevatedButton(
                          onPressed: submitReport,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                            const Color(0xFF303030),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Submit',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // UPLOAD BOX
  // ============================================================

  Widget _buildUploadBox() {

    // ==========================================================
    // AFTER UPLOAD
    // ==========================================================

    if (uploadSuccessful && selectedFile != null) {
      return Container(
        width: double.infinity,
        height: 194,
        decoration: BoxDecoration(
          color: const Color(0xFFE8E8E8),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Stack(
          children: [

            // ==================================================
            // FILE ICON
            // ==================================================

            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  const Icon(
                    Icons.insert_drive_file,
                    size: 55,
                    color: Colors.black,
                  ),

                  const SizedBox(height: 8),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                    ),
                    child: Text(
                      uploadedFileName,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    'Upload Successful',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // ==================================================
            // REMOVE BUTTON
            // ==================================================

            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: removeUploadedFile,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: const Icon(
                    Icons.close,
                    size: 20,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // ==========================================================
    // BEFORE UPLOAD
    // ==========================================================

    return GestureDetector(
      onTap: uploadFile,
      child: Container(
        width: double.infinity,
        height: 194,
        color: const Color(0xFFE8E8E8),
        child: const Center(
          child: Icon(
            Icons.upload_outlined,
            size: 50,
            color: Color(0xFF202020),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // URGENCY BUTTON
  // ============================================================

  Widget _urgencyButton(String text) {
    final bool selected = selectedUrgency == text;

    return SizedBox(
      height: 30,
      child: OutlinedButton(
        onPressed: () {
          setState(() {
            selectedUrgency = text;
          });
        },
        style: OutlinedButton.styleFrom(
          backgroundColor:
          selected ? Colors.black : Colors.white,
          foregroundColor:
          selected ? Colors.white : Colors.black,
          side: BorderSide(
            color: selected
                ? Colors.black
                : const Color(0xFFD0C8D4),
            width: 1,
          ),
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(7),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}