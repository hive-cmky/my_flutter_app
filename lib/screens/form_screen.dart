import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../database/database_helper.dart';
import '../utils/constants.dart';
import '../utils/validators.dart';
import '../utils/file_utils.dart';
import 'acknowledgement_screen.dart';

class ResidentCertificateForm extends StatefulWidget {
  const ResidentCertificateForm({super.key});

  @override
  State<ResidentCertificateForm> createState() => _ResidentCertificateFormState();
}

class _ResidentCertificateFormState extends State<ResidentCertificateForm> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  // Controllers
  String? salutation, gender, maritalStatus;
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final fatherNameController = TextEditingController();
  final motherNameController = TextEditingController();
  final mobileController = TextEditingController();
  final emailController = TextEditingController();
  final aadhaarController = TextEditingController();

  File? _photoFile;
  String? _photoError;
  File? _documentFile;
  String? _documentFileName;
  String? _documentError;

  // Present Address
  int? presentDistrictId, presentTehsilId, presentVillageId, presentRIId;
  bool presentVillageNotInList = false;
  final presentVillageCustomController = TextEditingController();
  final presentPoliceStationController = TextEditingController();
  final presentPostOfficeController = TextEditingController();
  final presentPinController = TextEditingController();
  final presentYearsController = TextEditingController();
  final presentMonthsController = TextEditingController();

  // Permanent Address
  String? permanentState = 'ODISHA', sameAsPresentAddress = 'No';
  int? permanentDistrictId, permanentTehsilId, permanentVillageId, permanentRIId;
  bool permanentVillageNotInList = false;
  final permanentVillageCustomController = TextEditingController();
  final permanentPoliceStationController = TextEditingController();
  final permanentPostOfficeController = TextEditingController();
  final permanentPinController = TextEditingController();

  // Guardian
  String? otherPersonFilling = 'No';
  final otherPersonNameController = TextEditingController();
  final otherPersonRelationController = TextEditingController();

  // Purpose & Declaration
  final purposeController = TextEditingController();
  final placeController = TextEditingController();
  bool agreedToDeclaration = false;

  // Dropdown data
  List<Map<String, dynamic>> districts = [], presentTehsils = [], presentVillages = [], presentRIs = [];
  List<Map<String, dynamic>> permanentTehsils = [], permanentVillages = [], permanentRIs = [];

  @override
  void initState() {
    super.initState();
    _loadDistricts();
  }

  Future<void> _loadDistricts() async {
    final data = await DatabaseHelper.instance.getDistricts();
    setState(() => districts = data);
  }

  Future<void> _loadPresentTehsils(int districtId) async {
    final data = await DatabaseHelper.instance.getTehsilsByDistrict(districtId);
    setState(() {
      presentTehsils = data;
      presentTehsilId = null;
      presentVillageId = null;
      presentRIId = null;
      presentVillages = [];
      presentRIs = [];
    });
  }

  Future<void> _loadPresentVillages(int tehsilId) async {
    final data = await DatabaseHelper.instance.getVillagesByTehsil(tehsilId);
    setState(() {
      presentVillages = data;
      presentVillageId = null;
    });
  }

  Future<void> _loadPresentRIs(int tehsilId) async {
    final data = await DatabaseHelper.instance.getRIsByTehsil(tehsilId);
    setState(() {
      presentRIs = data;
      presentRIId = null;
    });
  }

  Future<void> _loadPermanentTehsils(int districtId) async {
    final data = await DatabaseHelper.instance.getTehsilsByDistrict(districtId);
    setState(() {
      permanentTehsils = data;
      permanentTehsilId = null;
      permanentVillageId = null;
      permanentRIId = null;
      permanentVillages = [];
      permanentRIs = [];
    });
  }

  Future<void> _loadPermanentVillages(int tehsilId) async {
    final data = await DatabaseHelper.instance.getVillagesByTehsil(tehsilId);
    setState(() {
      permanentVillages = data;
      permanentVillageId = null;
    });
  }

  Future<void> _loadPermanentRIs(int tehsilId) async {
    final data = await DatabaseHelper.instance.getRIsByTehsil(tehsilId);
    setState(() {
      permanentRIs = data;
      permanentRIId = null;
    });
  }

  void _copyPresentToPermanent() {
    setState(() {
      permanentDistrictId = presentDistrictId;
      permanentTehsilId = presentTehsilId;
      permanentVillageId = presentVillageId;
      permanentRIId = presentRIId;
      permanentVillageNotInList = presentVillageNotInList;
      permanentVillageCustomController.text = presentVillageCustomController.text;
      permanentPoliceStationController.text = presentPoliceStationController.text;
      permanentPostOfficeController.text = presentPostOfficeController.text;
      permanentPinController.text = presentPinController.text;
    });
    if (permanentDistrictId != null) _loadPermanentTehsils(permanentDistrictId!);
    if (permanentTehsilId != null) {
      _loadPermanentVillages(permanentTehsilId!);
      _loadPermanentRIs(permanentTehsilId!);
    }
  }

  Future<void> _pickPhoto(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source, imageQuality: 85);
      if (image != null) {
        final file = File(image.path);
        if (!FileUtils.validateExtension(image.path, AppConstants.allowedPhotoExtensions)) {
          setState(() {
            _photoError = 'Only JPG/JPEG allowed';
            _photoFile = null;
          });
          return;
        }
        final sizeValid = await FileUtils.validateFileSize(
            image.path, AppConstants.photoMinSizeKB, AppConstants.photoMaxSizeKB);
        if (!sizeValid) {
          final sizeKB = await FileUtils.getFileSizeKB(image.path);
          setState(() {
            _photoError = 'Photo: 20-250KB (Current: ${sizeKB.toStringAsFixed(2)}KB)';
            _photoFile = null;
          });
          return;
        }
        setState(() {
          _photoFile = file;
          _photoError = null;
        });
      }
    } catch (e) {
      setState(() => _photoError = 'Error: $e');
    }
  }

  void _showPhotoSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Photo Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _pickPhoto(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickPhoto(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDocument() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: AppConstants.allowedDocumentExtensions,
      );
      if (result != null) {
        final file = File(result.files.single.path!);
        final sizeValid = await FileUtils.validateFileSize(result.files.single.path!, 0, AppConstants.documentMaxSizeKB);
        if (!sizeValid) {
          final sizeKB = await FileUtils.getFileSizeKB(result.files.single.path!);
          setState(() {
            _documentError = 'Document < 512KB (Current: ${sizeKB.toStringAsFixed(2)}KB)';
            _documentFile = null;
            _documentFileName = null;
          });
          return;
        }
        setState(() {
          _documentFile = file;
          _documentFileName = result.files.single.name;
          _documentError = null;
        });
      }
    } catch (e) {
      setState(() => _documentError = 'Error: $e');
    }
  }

  Future<Map<String, dynamic>> _prepareFormData() async {
    final photoBase64 = await FileUtils.fileToBase64(_photoFile?.path);
    final docBase64 = await FileUtils.fileToBase64(_documentFile?.path);
    return {
      'formType': 'RESIDENT_CERTIFICATE',
      'personalDetails': {
        'salutation': salutation,
        'name': nameController.text.trim(),
        'gender': gender,
        'maritalStatus': maritalStatus,
        'age': ageController.text.trim(),
        'aadhaarNo': aadhaarController.text.trim(),
        'fatherName': fatherNameController.text.trim(),
        'motherName': motherNameController.text.trim(),
        'mobileNumber': mobileController.text.trim(),
        'email': emailController.text.trim(),
        'photoBase64': photoBase64,
      },
      'presentAddress': {
        'districtId': presentDistrictId,
        'district': districts.firstWhere((d) => d['id'] == presentDistrictId, orElse: () => {})['name'],
        'tehsilId': presentTehsilId,
        'tehsil': presentTehsils.firstWhere((t) => t['id'] == presentTehsilId, orElse: () => {})['name'],
        'villageId': presentVillageId,
        'village': presentVillageNotInList ? presentVillageCustomController.text.trim() : presentVillages.firstWhere((v) => v['id'] == presentVillageId, orElse: () => {})['name'],
        'villageNotInList': presentVillageNotInList,
        'riId': presentRIId,
        'ri': presentRIs.firstWhere((r) => r['id'] == presentRIId, orElse: () => {})['name'],
        'policeStation': presentPoliceStationController.text.trim(),
        'postOffice': presentPostOfficeController.text.trim(),
        'pin': presentPinController.text.trim(),
        'residingYears': presentYearsController.text.trim(),
        'residingMonths': presentMonthsController.text.trim(),
      },
      'permanentAddress': {
        'state': permanentState,
        'sameAsPresent': sameAsPresentAddress == 'Yes',
        'districtId': permanentDistrictId,
        'district': districts.firstWhere((d) => d['id'] == permanentDistrictId, orElse: () => {})['name'],
        'tehsilId': permanentTehsilId,
        'tehsil': permanentTehsils.firstWhere((t) => t['id'] == permanentTehsilId, orElse: () => {})['name'],
        'villageId': permanentVillageId,
        'village': permanentVillageNotInList ? permanentVillageCustomController.text.trim() : permanentVillages.firstWhere((v) => v['id'] == permanentVillageId, orElse: () => {})['name'],
        'villageNotInList': permanentVillageNotInList,
        'riId': permanentRIId,
        'ri': permanentRIs.firstWhere((r) => r['id'] == permanentRIId, orElse: () => {})['name'],
        'policeStation': permanentPoliceStationController.text.trim(),
        'postOffice': permanentPostOfficeController.text.trim(),
        'pin': permanentPinController.text.trim(),
      },
      'guardianDetails': {
        'otherPersonFilling': otherPersonFilling == 'Yes',
        'otherPersonName': otherPersonNameController.text.trim(),
        'relationshipWithApplicant': otherPersonRelationController.text.trim(),
      },
      'purpose': purposeController.text.trim(),
      'supportingDocumentBase64': docBase64,
      'supportingDocumentName': _documentFileName,
      'declaration': {
        'place': placeController.text.trim(),
        'agreed': agreedToDeclaration,
        'date': DateTime.now().toIso8601String(),
      },
    };
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fill all required fields')));
      return;
    }
    if (_photoFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Upload photo')));
      return;
    }
    if (!agreedToDeclaration) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Agree to declaration')));
      return;
    }

    // Show loading indicator
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()));

    try {
      // 1. Prepare the JSON payload
      final formData = await _prepareFormData();

      // 2. Send the JSON to your Spring Boot API
      //    NOTE: Replace with your actual API URL. 
      //    10.0.2.2 is a special address to access the host machine's localhost from the Android emulator.
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8080/api/submit'), 
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(formData),
      ).timeout(const Duration(seconds: 30));

      // Pop the loading indicator
      if (mounted) Navigator.pop(context);

      // 3. Handle the response from the API
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Success! Parse the acknowledgement slip from the API response
        final acknowledgementData = jsonDecode(response.body);

        // You can also save the form locally for reference if needed
        // await DatabaseHelper.instance.saveFormSubmission(formData);

        // 4. Navigate to the AcknowledgementScreen with the data from the API
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  AcknowledgementScreen(applicationId: acknowledgementData['applicationId'], jsonData: acknowledgementData),
            ),
            (Route<dynamic> route) => false, // Removes all previous routes
          );
        }
      } else {
        // Handle API errors (e.g., show an error message)
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Server Error: ${response.statusCode} - ${response.body}')),
          );
        }
      }
    } catch (e) {
      // Handle network errors (e.g., no internet connection, timeout)
      if (mounted) Navigator.pop(context);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Network Error: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    fatherNameController.dispose();
    motherNameController.dispose();
    mobileController.dispose();
    emailController.dispose();
    aadhaarController.dispose();
    presentVillageCustomController.dispose();
    presentPoliceStationController.dispose();
    presentPostOfficeController.dispose();
    presentPinController.dispose();
    presentYearsController.dispose();
    presentMonthsController.dispose();
    permanentVillageCustomController.dispose();
    permanentPoliceStationController.dispose();
    permanentPostOfficeController.dispose();
    permanentPinController.dispose();
    otherPersonNameController.dispose();
    otherPersonRelationController.dispose();
    purposeController.dispose();
    placeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Resident Certificate')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('PERSONAL DETAILS', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const Text('Photo *'),
            Row(children: [
              _photoFile != null ? Image.file(_photoFile!, width: 80, height: 80, fit: BoxFit.cover) : Container(width: 80, height: 80, color: Colors.grey[300], child: const Icon(Icons.person)),
              const SizedBox(width: 16),
              ElevatedButton(onPressed: _showPhotoSourceDialog, child: const Text('Upload')),
            ]),
            if (_photoError != null) Text(_photoError!, style: const TextStyle(color: Colors.red, fontSize: 12)),
            const SizedBox(height: 16),
            const Text('Salutation *'),
            DropdownButtonFormField<String>(value: salutation, items: AppConstants.salutations.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(), onChanged: (v) => setState(() => salutation = v), validator: (v) => v == null ? 'Required' : null),
            const SizedBox(height: 16),
            const Text('Name *'),
            TextFormField(controller: nameController, validator: (v) {
              final r = FormValidators.validateRequired(v, 'Name');
              if (r != null) return r;
              return FormValidators.validateOnlyLetters(v, 'Name');
            }),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Gender *'), DropdownButtonFormField<String>(value: gender, items: AppConstants.genders.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(), onChanged: (v) => setState(() => gender = v), validator: (v) => v == null ? 'Required' : null)])),
                  const SizedBox(width: 16),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Marital Status *'), DropdownButtonFormField<String>(value: maritalStatus, items: AppConstants.maritalStatuses.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(), onChanged: (v) => setState(() => maritalStatus = v), validator: (v) => v == null ? 'Required' : null)])),
                ]),
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Age *'), TextFormField(controller: ageController, keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly], validator: FormValidators.validateAge)])),
                  const SizedBox(width: 16),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Aadhaar'), TextFormField(controller: aadhaarController, keyboardType: TextInputType.number, maxLength: 12, inputFormatters: [FilteringTextInputFormatter.digitsOnly], validator: FormValidators.validateAadhaar, decoration: const InputDecoration(counterText: ''))])),
                ]),
              ],
            ),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text("Father's Name *"), TextFormField(controller: fatherNameController, validator: (v) {
                final r = FormValidators.validateRequired(v, "Father's Name");
                if (r != null) return r;
                return FormValidators.validateOnlyLetters(v, "Father's Name");
              })])),
              const SizedBox(width: 16),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text("Mother's Name *"), TextFormField(controller: motherNameController, validator: (v) {
                final r = FormValidators.validateRequired(v, "Mother's Name");
                if (r != null) return r;
                return FormValidators.validateOnlyLetters(v, "Mother's Name");
              })])),
            ]),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Mobile *'), TextFormField(controller: mobileController, keyboardType: TextInputType.phone, maxLength: 10, inputFormatters: [FilteringTextInputFormatter.digitsOnly], validator: FormValidators.validateMobile, decoration: const InputDecoration(counterText: ''))])),
              const SizedBox(width: 16),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Email'), TextFormField(controller: emailController, keyboardType: TextInputType.emailAddress, validator: FormValidators.validateEmail)])),
            ]),
            const SizedBox(height: 32),
            const Text('PRESENT ADDRESS', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildAddressSection(true),
            const SizedBox(height: 32),
            const Text('PERMANENT ADDRESS', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const Text('Same as Present Address'),
            DropdownButtonFormField<String>(value: sameAsPresentAddress, items: AppConstants.yesNoOptions.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(), onChanged: (v) {
              setState(() => sameAsPresentAddress = v);
              if (v == 'Yes') _copyPresentToPermanent();
            }),
            const SizedBox(height: 16),
            const Text('State *'),
            DropdownButtonFormField<String>(value: permanentState, items: AppConstants.states.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(), onChanged: (v) => setState(() => permanentState = v), validator: (v) => v == null ? 'Required' : null),
            const SizedBox(height: 16),
            _buildAddressSection(false),
            const SizedBox(height: 32),
            const Text('GUARDIAN DETAILS', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const Text('Person other than applicant filling? *'),
            DropdownButtonFormField<String>(value: otherPersonFilling, items: AppConstants.yesNoOptions.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(), onChanged: (v) => setState(() => otherPersonFilling = v), validator: (v) => v == null ? 'Required' : null),
            if (otherPersonFilling == 'Yes') ...[
              const SizedBox(height: 16),
              const Text('Name *'),
              TextFormField(controller: otherPersonNameController, validator: (v) {
                final r = FormValidators.validateRequired(v, 'Name');
                if (r != null) return r;
                return FormValidators.validateOnlyLetters(v, 'Name');
              }),
              const SizedBox(height: 16),
              const Text('Relationship *'),
              TextFormField(controller: otherPersonRelationController, validator: (v) {
                final r = FormValidators.validateRequired(v, 'Relationship');
                if (r != null) return r;
                return FormValidators.validateOnlyLetters(v, 'Relationship');
              }),
            ],
            const SizedBox(height: 32),
            const Text('PURPOSE', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const Text('Purpose *'),
            TextFormField(controller: purposeController, maxLines: 3, validator: (v) => FormValidators.validateRequired(v, 'Purpose')),
            const SizedBox(height: 32),
            const Text('SUPPORTING DOCUMENT', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _pickDocument, child: const Text('Upload Document')),
            if (_documentFileName != null) Text('File: $_documentFileName'),
            if (_documentError != null) Text(_documentError!, style: const TextStyle(color: Colors.red, fontSize: 12)),
            const SizedBox(height: 32),
            const Text('DECLARATION', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Text(AppConstants.declarationText, style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 16),
            const Text('Place *'),
            TextFormField(controller: placeController, validator: (v) => FormValidators.validateRequired(v, 'Place')),
            const SizedBox(height: 16),
            Row(children: [Checkbox(value: agreedToDeclaration, onChanged: (v) => setState(() => agreedToDeclaration = v ?? false)), const Text('I Agree *')]),
            const SizedBox(height: 32),
            SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: _submitForm, child: const Text('Submit'))),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressSection(bool isPresent) {
    final districtId = isPresent ? presentDistrictId : permanentDistrictId;
    final tehsilId = isPresent ? presentTehsilId : permanentTehsilId;
    final villageId = isPresent ? presentVillageId : permanentVillageId;
    final riId = isPresent ? presentRIId : permanentRIId;
    final villageNotInList = isPresent ? presentVillageNotInList : permanentVillageNotInList;
    final tehsils = isPresent ? presentTehsils : permanentTehsils;
    final villages = isPresent ? presentVillages : permanentVillages;
    final ris = isPresent ? presentRIs : permanentRIs;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('District *'), DropdownButtonFormField<int>(value: districtId, items: districts.map((d) => DropdownMenuItem(value: d['id'] as int, child: Text(d['name'] as String))).toList(), onChanged: (v) {
          if (isPresent) {
            setState(() => presentDistrictId = v);
            if (v != null) _loadPresentTehsils(v);
          } else {
            setState(() => permanentDistrictId = v);
            if (v != null) _loadPermanentTehsils(v);
          }
        }, validator: (v) => v == null ? 'Required' : null)])),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Tehsil *'), DropdownButtonFormField<int>(value: tehsilId, items: tehsils.map((t) => DropdownMenuItem(value: t['id'] as int, child: Text(t['name'] as String))).toList(), onChanged: (v) {
          if (isPresent) {
            setState(() => presentTehsilId = v);
            if (v != null) {
              _loadPresentVillages(v);
              _loadPresentRIs(v);
            }
          } else {
            setState(() => permanentTehsilId = v);
            if (v != null) {
              _loadPermanentVillages(v);
              _loadPermanentRIs(v);
            }
          }
        }, validator: (v) => v == null ? 'Required' : null)])),
      ]),
      const SizedBox(height: 16),
      Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Village *'), DropdownButtonFormField<int>(value: villageId, items: villages.map((v) => DropdownMenuItem(value: v['id'] as int, child: Text(v['name'] as String))).toList(), onChanged: (v) {
          if (isPresent) {
            setState(() => presentVillageId = v);
          } else {
            setState(() => permanentVillageId = v);
          }
        }, validator: villageNotInList ? null : (v) => v == null ? 'Required' : null)])),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('RI'), DropdownButtonFormField<int>(value: riId, items: ris.map((r) => DropdownMenuItem(value: r['id'] as int, child: Text(r['name'] as String))).toList(), onChanged: (v) {
          if (isPresent) {
            setState(() => presentRIId = v);
          } else {
            setState(() => permanentRIId = v);
          }
        })])),
      ]),
      const SizedBox(height: 16),
      Row(children: [Checkbox(value: villageNotInList, onChanged: (v) {
        if (isPresent) {
          setState(() {
            presentVillageNotInList = v ?? false;
            if (v == true) presentVillageId = null;
          });
        } else {
          setState(() {
            permanentVillageNotInList = v ?? false;
            if (v == true) permanentVillageId = null;
          });
        }
      }), const Text('Village Not in List')]),
      if (villageNotInList) ...[const Text('Village Name *'), TextFormField(controller: isPresent ? presentVillageCustomController : permanentVillageCustomController, validator: (v) => FormValidators.validateRequired(v, 'Village')), const SizedBox(height: 16)],
      Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Police Station'), TextFormField(controller: isPresent ? presentPoliceStationController : permanentPoliceStationController)])),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Post Office'), TextFormField(controller: isPresent ? presentPostOfficeController : permanentPostOfficeController)])),
      ]),
      const SizedBox(height: 16),
      const Text('PIN'),
      TextFormField(controller: isPresent ? presentPinController : permanentPinController, keyboardType: TextInputType.number, maxLength: 6, inputFormatters: [FilteringTextInputFormatter.digitsOnly], validator: FormValidators.validatePin, decoration: const InputDecoration(counterText: '')),
      if (isPresent) ...[
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Years'), TextFormField(controller: presentYearsController, keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly])])),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Months'), TextFormField(controller: presentMonthsController, keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly])])),
        ]),
      ],
    ]);
  }
}
