import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:smart_eommerce/services/document_service.dart';
import 'account_success_screen.dart';

class IdVerificationScreen extends StatefulWidget {
  @override
  _IdVerificationScreenState createState() => _IdVerificationScreenState();
}

class _IdVerificationScreenState extends State<IdVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final DocumentService _documentService = DocumentService();
  
  // Document images
  File? _idImage;
  File? _bankPassbookImage;
  bool _isIdCaptured = false;
  bool _isPassbookCaptured = false;
  
  // Bank details controllers
  final _bankAccountController = TextEditingController();
  final _ifscCodeController = TextEditingController();
  final _kycDocumentNumberController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _branchNameController = TextEditingController();
  
  bool _isLoading = false;

  @override
  void dispose() {
    _bankAccountController.dispose();
    _ifscCodeController.dispose();
    _kycDocumentNumberController.dispose();
    _bankNameController.dispose();
    _branchNameController.dispose();
    super.dispose();
  }

  Future<void> _takeIdPhoto() async {
    try {
      final XFile? photo = await ImagePicker().pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        imageQuality: 85,
      );
      
      if (photo != null) {
        setState(() {
          _idImage = File(photo.path);
          _isIdCaptured = true;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ID photo captured successfully'),
            backgroundColor: Color(0xFF5F67EE),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error accessing camera: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pickIdFromGallery() async {
    try {
      final XFile? photo = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      
      if (photo != null) {
        setState(() {
          _idImage = File(photo.path);
          _isIdCaptured = true;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ID photo selected successfully'),
            backgroundColor: Color(0xFF5F67EE),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error accessing gallery: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _takePassbookPhoto() async {
    try {
      final XFile? photo = await ImagePicker().pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        imageQuality: 85,
      );
      
      if (photo != null) {
        setState(() {
          _bankPassbookImage = File(photo.path);
          _isPassbookCaptured = true;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Passbook photo captured successfully'),
            backgroundColor: Color(0xFF5F67EE),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error accessing camera: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pickPassbookFromGallery() async {
    try {
      final XFile? photo = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      
      if (photo != null) {
        setState(() {
          _bankPassbookImage = File(photo.path);
          _isPassbookCaptured = true;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Passbook photo selected successfully'),
            backgroundColor: Color(0xFF5F67EE),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error accessing gallery: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<String> _getBase64Image(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    return base64Encode(bytes);
  }

  Future<void> _uploadDocuments() async {
    if (_formKey.currentState!.validate()) {
      if (!_isIdCaptured || !_isPassbookCaptured) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please capture both ID and Passbook photos'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        // Convert images to base64
        final idImageBase64 = await _getBase64Image(_idImage!);
        final passbookImageBase64 = await _getBase64Image(_bankPassbookImage!);

        final result = await _documentService.uploadDocuments(
          bankAccountNumber: _bankAccountController.text.trim(),
          ifscCode: _ifscCodeController.text.trim(),
          kycDocumentNumber: _kycDocumentNumberController.text.trim(),
          kycDocumentImage: idImageBase64,
          bankName: _bankNameController.text.trim(),
          branchName: _branchNameController.text.trim(),
          bankPassbookImage: passbookImageBase64,
        );

        setState(() {
          _isLoading = false;
        });

        if (result['success']) {
          // Navigate to account success screen
          Navigator.of(context).pushReplacementNamed('/account_success');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message']),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading documents: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0B1D3A), Color(0xFF0B1D3A).withOpacity(0.9)],
            stops: [0.2, 0.8],
          ),
        ),
        child: SafeArea(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 15,
                  spreadRadius: 2,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Decorative circles
                Positioned(
                  top: -15,
                  right: -15,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFFFD700).withOpacity(0.2),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 60,
                  left: -8,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFFFD700).withOpacity(0.15),
                    ),
                  ),
                ),
                
                // Main content
                SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(30, 40, 20, 20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          const Text(
                            'ID Verification',
                            style: TextStyle(
                              color: Color(0xFF19173A),
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Please provide your bank details and upload required documents',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 20),
                          
                          // Bank Account Number
                          buildTextField(
                            controller: _bankAccountController,
                            label: 'Bank Account Number',
                            hintText: 'Enter your bank account number',
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your bank account number';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          
                          // IFSC Code
                          buildTextField(
                            controller: _ifscCodeController,
                            label: 'IFSC Code',
                            hintText: 'Enter your bank IFSC code',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your IFSC code';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          
                          // KYC Document Number
                          buildTextField(
                            controller: _kycDocumentNumberController,
                            label: 'KYC Document Number',
                            hintText: 'Enter your KYC document number',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your KYC document number';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          
                          // Bank Name
                          buildTextField(
                            controller: _bankNameController,
                            label: 'Bank Name',
                            hintText: 'Enter your bank name',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your bank name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          
                          // Branch Name
                          buildTextField(
                            controller: _branchNameController,
                            label: 'Branch Name',
                            hintText: 'Enter your branch name',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your branch name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          
                          // ID Image Section
                          buildImageSection(
                            title: 'ID Document',
                            subtitle: 'Upload your government issued ID',
                            image: _idImage,
                            isCaptured: _isIdCaptured,
                            onCapture: _takeIdPhoto,
                          ),
                          const SizedBox(height: 16),
                          
                          // Bank Passbook Section
                          buildImageSection(
                            title: 'Bank Passbook',
                            subtitle: 'Upload your bank passbook first page',
                            image: _bankPassbookImage,
                            isCaptured: _isPassbookCaptured,
                            onCapture: _takePassbookPhoto,
                          ),
                          
                          const SizedBox(height: 32),
                          
                          // Submit Button
                          Container(
                            width: double.infinity,
                            height: 52,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0xFFFFD700).withOpacity(0.3),
                                  blurRadius: 8,
                                  spreadRadius: 0,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _uploadDocuments,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFFFFD700),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                elevation: 0,
                              ),
                              child: _isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : const Text(
                                    'Submit Documents',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Back button
                Positioned(
                  top: 20,
                  left: 20,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFFFFD700).withOpacity(0.2),
                            blurRadius: 8,
                            spreadRadius: 1,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Color(0xFFFFD700),
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Color(0xFF19173A),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                spreadRadius: 1,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            validator: validator,
            style: TextStyle(
              fontSize: 15,
              color: Color(0xFF0B1D3A),
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(fontSize: 14, color: Colors.black38),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Color(0xFFE0E0E0), width: 0.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Color(0xFFE0E0E0), width: 0.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Color(0xFF5F67EE), width: 1.0),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.red, width: 1.0),
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget buildImageSection({
    required String title,
    required String subtitle,
    required File? image,
    required bool isCaptured,
    required VoidCallback onCapture,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFFE0E0E0), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            spreadRadius: 0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Color(0xFFFFD700).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.photo_camera_outlined,
                  color: Color(0xFFFFD700),
                  size: 22,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: Color(0xFF19173A),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          if (isCaptured && image != null)
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: FileImage(image),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: onCapture,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: Color(0xFFFFD700).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isCaptured ? Icons.refresh : Icons.camera_alt_outlined,
                            color: Color(0xFFFFD700),
                            size: 18,
                          ),
                          SizedBox(width: 8),
                          Text(
                            isCaptured ? 'Retake' : 'Camera',
                            style: TextStyle(
                              color: Color(0xFFFFD700),
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  onTap: title == 'ID Document' ? _pickIdFromGallery : _pickPassbookFromGallery,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: Color(0xFFFFD700).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.photo_library_outlined,
                            color: Color(0xFFFFD700),
                            size: 18,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Gallery',
                            style: TextStyle(
                              color: Color(0xFFFFD700),
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
} 