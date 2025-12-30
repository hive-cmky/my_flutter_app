import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../database/database_helper.dart';
import '../utils/constants.dart';
import '../utils/validators.dart';
import '../utils/file_utils.dart';
import '../utils/session_manager.dart';
import 'preview_screen.dart';

class ResidentCertificateForm extends StatefulWidget {
  const ResidentCertificateForm({super.key});

  @override
  State<ResidentCertificateForm> createState() => _ResidentCertificateFormState();
}

class _ResidentCertificateFormState extends State<ResidentCertificateForm> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  // Controllers
  String? salutation, gender, maritalStatus, selectedEnclosureDoc;
  String? currentOfficeName, currentOfficeId;

  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final fatherNameController = TextEditingController();
  final motherNameController = TextEditingController();
  final husbandNameController = TextEditingController();
  final mobileController = TextEditingController();
  final emailController = TextEditingController();
  final aadhaarController = TextEditingController();

  String anyPersonOtherThanApplicant = 'No';
  final otherPersonNameController = TextEditingController();
  final otherPersonRelationController = TextEditingController();

  File? _photoFile;
  String? _photoError;
  File? _documentFile;
  String? _documentFileName;

  // Present Address
  String? presentDistrictCode, presentTehsilCode, presentVillageCode,
      presentRICode;
  String? presentDistrictOrgCode, presentTehsilOrgCode, presentRIOrgCode;
  String? presentDistrictName, presentTehsilName, presentVillageName,
      presentRIName;

  bool presentVillageNotInList = false;
  final presentVillageCustomController = TextEditingController();
  final presentPoliceStationController = TextEditingController();
  final presentPostOfficeController = TextEditingController();
  final presentPinController = TextEditingController();
  final presentYearsController = TextEditingController();
  final presentMonthsController = TextEditingController();

  // Permanent Address
  String? permanentDistrictCode, permanentTehsilCode, permanentVillageCode,
      permanentRICode;
  String? permanentDistrictOrgCode, permanentTehsilOrgCode, permanentRIOrgCode;
  String? permanentDistrictName, permanentTehsilName, permanentVillageName,
      permanentRIName;
  bool permanentVillageNotInList = false;
  final permanentVillageCustomController = TextEditingController();
  final permanentPoliceStationController = TextEditingController();
  final permanentPostOfficeController = TextEditingController();
  final permanentPinController = TextEditingController();

  String sameAsPresentAddress = 'No';
  final String permanentState = '21';

  final purposeController = TextEditingController();
  final placeController = TextEditingController();
  bool agreedToDeclaration = false;

  // Dropdown data
  List<Map<String, dynamic>> districts = [],
      presentTehsils = [],
      presentVillages = [],
      presentRIs = [];
  List<Map<String, dynamic>> permanentTehsils = [],
      permanentVillages = [],
      permanentRIs = [];

  @override
  void initState() {
    super.initState();
    _loadDistricts();
  }

  Future<void> _loadDistricts() async {
    final data = await DatabaseHelper.instance.getDistricts();
    if (mounted) {
      setState(() => districts = data);
    }
  }

  Future<void> _loadPresentTehsils(String districtOrgCode) async {
    final data = await DatabaseHelper.instance.getTehsils(districtOrgCode);
    if (mounted) {
      setState(() {
        presentTehsils = data;
        presentTehsilCode = presentVillageCode = presentRICode = null;
        presentTehsilOrgCode = presentRIOrgCode = null;
        presentTehsilName = presentVillageName = presentRIName = null;
        presentVillages = presentRIs = [];
        currentOfficeName = null;
        currentOfficeId = null;
      });
    }
  }

  Future<void> _loadPresentRIs(String tehsilOrgCode) async {
    final data = await DatabaseHelper.instance.getRIs(tehsilOrgCode);
    if (mounted) {
      setState(() {
        presentRIs = data;
        presentRICode = null;
        presentRIOrgCode = null;
        presentRIName = null;
        presentVillageCode = null;
        presentVillageName = null;
        presentVillages = [];
      });
    }
  }

  Future<void> _loadPresentVillages(String riOrgCode) async {
    final data = await DatabaseHelper.instance.getVillages(riOrgCode);
    if (mounted) {
      setState(() {
        presentVillages = data;
        presentVillageCode = null;
        presentVillageName = null;
      });
    }
  }

  Future<void> _loadPermanentTehsils(String districtOrgCode) async {
    final data = await DatabaseHelper.instance.getTehsils(districtOrgCode);
    if (mounted) {
      setState(() {
        permanentTehsils = data;
        permanentTehsilCode = permanentVillageCode = permanentRICode = null;
        permanentTehsilOrgCode = permanentRIOrgCode = null;
        permanentTehsilName = permanentVillageName = permanentRIName = null;
        permanentVillages = permanentRIs = [];
      });
    }
  }

  Future<void> _loadPermanentRIs(String tehsilOrgCode) async {
    final data = await DatabaseHelper.instance.getRIs(tehsilOrgCode);
    if (mounted) {
      setState(() {
        permanentRIs = data;
        permanentRICode = null;
        permanentRIOrgCode = null;
        permanentRIName = null;
        permanentVillageCode = null;
        permanentVillageName = null;
        permanentVillages = [];
      });
    }
  }

  Future<void> _loadPermanentVillages(String riOrgCode) async {
    final data = await DatabaseHelper.instance.getVillages(riOrgCode);
    if (mounted) {
      setState(() {
        permanentVillages = data;
        permanentVillageCode = null;
        permanentVillageName = null;
      });
    }
  }

  Future<void> _updateApplyToOffice(String tehsilName) async {
    final officeData = await DatabaseHelper.instance.getCoverageLocation(
        tehsilName);
    if (mounted && officeData != null) {
      setState(() {
        currentOfficeName = officeData['name'] ?? '';
        currentOfficeId = officeData['id'] ??
            ''; // This is the locationName/Coverage Location ID
      });
      print('DEBUG: currentOfficeId set to: $currentOfficeId'); // Add debug
      print('DEBUG: currentOfficeName set to: $currentOfficeName'); // Add debug
    } else {
      print('DEBUG: officeData is null for tehsil: $tehsilName');
    }
  }

  Future<void> _copyPresentToPermanent() async {
    _clearPermanentAddress();
    if (presentDistrictCode == null) return;

    // Fetch data for permanent dropdowns based on present selections
    final tehsils = await DatabaseHelper.instance.getTehsils(
        presentDistrictOrgCode!);
    List<Map<String, dynamic>> ris = [];
    List<Map<String, dynamic>> villages = [];

    if (presentTehsilOrgCode != null) {
      ris = await DatabaseHelper.instance.getRIs(presentTehsilOrgCode!);
    }
    if (presentRIOrgCode != null) {
      villages = await DatabaseHelper.instance.getVillages(presentRIOrgCode!);
    }

    if (mounted) {
      setState(() {
        permanentTehsils = tehsils;
        permanentRIs = ris;
        permanentVillages = villages;

        permanentDistrictCode = presentDistrictCode;
        permanentDistrictOrgCode = presentDistrictOrgCode;
        permanentDistrictName = presentDistrictName;

        permanentTehsilCode = presentTehsilCode;
        permanentTehsilOrgCode = presentTehsilOrgCode;
        permanentTehsilName = presentTehsilName;

        permanentRICode = presentRICode;
        permanentRIOrgCode = presentRIOrgCode;
        permanentRIName = presentRIName;

        permanentVillageCode = presentVillageCode;
        permanentVillageName = presentVillageName;

        permanentVillageNotInList = presentVillageNotInList;
        permanentVillageCustomController.text =
            presentVillageCustomController.text;
        permanentPoliceStationController.text =
            presentPoliceStationController.text;
        permanentPostOfficeController.text = presentPostOfficeController.text;
        permanentPinController.text = presentPinController.text;
      });
    }
  }

  void _clearPermanentAddress() {
    setState(() {
      permanentDistrictCode = permanentTehsilCode = permanentVillageCode =
          permanentRICode = null;
      permanentDistrictOrgCode = permanentTehsilOrgCode = permanentRIOrgCode =
      null;
      permanentDistrictName = permanentTehsilName = permanentVillageName =
          permanentRIName = null;
      permanentVillageNotInList = false;
      permanentVillageCustomController.clear();
      permanentPoliceStationController.clear();
      permanentPostOfficeController.clear();
      permanentPinController.clear();
      permanentTehsils = [];
      permanentVillages = [];
      permanentRIs = [];
    });
  }

  Future<void> _pickPhoto(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
          source: source, imageQuality: 25, maxWidth: 800, maxHeight: 800);
      if (image != null) {
        final file = File(image.path);
        if (!FileUtils.validateExtension(
            image.path, AppConstants.allowedPhotoExtensions)) {
          if (mounted) setState(() => _photoError = 'Only JPG/JPEG allowed');
          return;
        }
        final sizeValid = await FileUtils.validateFileSize(
            image.path, AppConstants.photoMinSizeKB,
            AppConstants.photoMaxSizeKB);
        if (mounted && !sizeValid) {
          setState(() => _photoError = 'Photo must be between ${AppConstants.photoMinSizeKB}KB and ${AppConstants.photoMaxSizeKB}KB');
          return;
        }
        if (mounted) {
          setState(() {
            _photoFile = file;
            _photoError = null;
          });
        }
      }
    } catch (e) {
      if (mounted) setState(() => _photoError = 'Error: $e');
    }
  }

  void _showPhotoSourceDialog() {
    showDialog(context: context, builder: (context) =>
        AlertDialog(
          title: const Text('Select Photo Source'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            ListTile(leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickPhoto(ImageSource.camera);
                }),
            ListTile(leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickPhoto(ImageSource.gallery);
                }),
          ]),
        ));
  }

  Future<void> _pickDocument() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: AppConstants.allowedDocumentExtensions);
      if (result != null) {
        final file = File(result.files.single.path!);
        final sizeValid = await FileUtils.validateFileSize(
            result.files.single.path!, 0, AppConstants.documentMaxSizeKB);
        if (mounted && !sizeValid) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Document is larger than ${AppConstants.documentMaxSizeKB}KB')));
          return;
        }
        if (mounted) {
          setState(() {
            _documentFile = file;
            _documentFileName = result.files.single.name;
          });
        }
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')));
    }
  }

  Future<Map<String, dynamic>> _prepareFormData() async {
    final String photoBase64 = await FileUtils.fileToBase64(_photoFile?.path) ??
        '';
    final String docBase64 = await FileUtils.fileToBase64(
        _documentFile?.path) ?? '';

    // Debug: Print the locationName value
    print('📤 DEBUG: Preparing form data...');
    print('   - currentOfficeId: $currentOfficeId');
    print('   - currentOfficeName: $currentOfficeName');

    // Verify the ID format
    if (currentOfficeId != null && currentOfficeId!.contains('.0')) {
      print('⚠️ WARNING: currentOfficeId still contains .0: $currentOfficeId');
      // Fallback: clean it here too
      currentOfficeId = currentOfficeId!.replaceAll('.0', '');
      print('   - Cleaned ID: $currentOfficeId');
    }

    const salutationMap = {'Shri': '1', 'Smt': '2', 'Miss': '3'};
    const genderMap = {'Male': '1', 'Female': '2', 'Transgender': '3'};
    const maritalStatusMap = {'Married': '1', 'Unmarried': '2', 'Widow': '3'};

    final Map<String, dynamic> appForm = {
      "locationName": currentOfficeId ?? "",
      "salutation": salutationMap[salutation] ?? "",
      "candidatename": nameController.text.trim().toUpperCase(),
      "gender": genderMap[gender] ?? "",
      "maritalstatus": maritalStatusMap[maritalStatus] ?? "",
      "age": ageController.text.trim(),
      "aadharno": aadhaarController.text.trim(),
      "fathername": fatherNameController.text.trim().toUpperCase(),
      "mothername": motherNameController.text.trim().toUpperCase(),
      if (gender == 'Female' && (maritalStatus == 'Married' ||
          maritalStatus == 'Widow')) "husbandname": husbandNameController.text
          .trim().toUpperCase(),
      "mobileno": mobileController.text.trim(),
      "email": emailController.text.trim(),
      "presentdistrict": presentDistrictCode ?? "",
      "presenttehasil": presentTehsilCode ?? "",
      "presentvillagenotinlist": presentVillageNotInList ? "1" : "",
      "presentvillage": presentVillageNotInList ? "" : (presentVillageCode ??
          ""),
      "presentvillagename": presentVillageNotInList
          ? presentVillageCustomController.text.trim().toUpperCase()
          : "",
      "presentri": presentVillageNotInList ? "" : (presentRICode ?? ""),
      "presentps": presentPoliceStationController.text
          .trim()
          .toUpperCase(),
      "presentpo": presentPostOfficeController.text
          .trim()
          .toUpperCase(),
      "presentpin": presentPinController.text.trim(),
      "residingpresentaddyears": presentYearsController.text.trim(),
      "residingpresentaddmonths": presentMonthsController.text.trim(),
      "permanentstate": "21",
      "sameaspresentadress": sameAsPresentAddress == 'Yes' ? "1" : "2",
      "permanentdistrict": permanentDistrictCode ?? "",
      "permanenttehasil": permanentTehsilCode ?? "",
      "permanentvillagenotinlist": permanentVillageNotInList ? "1" : "",
      "permanentvillage": permanentVillageNotInList
          ? ""
          : (permanentVillageCode ?? ""),
      "permanentvillagename": permanentVillageNotInList
          ? permanentVillageCustomController.text.trim().toUpperCase()
          : "",
      "permanentri": permanentVillageNotInList ? "" : (permanentRICode ?? ""),
      "permanentps": permanentPoliceStationController.text
          .trim()
          .toUpperCase(),
      "permanentpo": permanentPostOfficeController.text
          .trim()
          .toUpperCase(),
      "permanentpin": permanentPinController.text.trim(),
      "anypersionotherthancandidate": anyPersonOtherThanApplicant == 'Yes'
          ? "Yes"
          : "NO",
      if (anyPersonOtherThanApplicant ==
          'Yes') "otherpersonname": otherPersonNameController.text
          .trim()
          .toUpperCase(),
      if (anyPersonOtherThanApplicant ==
          'Yes') "otherpersonrelation": otherPersonRelationController.text
          .trim().toUpperCase(),
      "purpose": purposeController.text.trim().toUpperCase(),
      "place": placeController.text.trim().toUpperCase(),
      "iagree": "Y",
      "candidatephoto": photoBase64,
      "enclosures": [
        {
          "entype": "5022",
          "endocumenttype": AppConstants
              .enclosureDocuments[selectedEnclosureDoc] ?? "",
          "enbase64": docBase64
        }
      ],
    };

    appForm.removeWhere((key, value) =>
    value == null || (value is String && value.isEmpty));

    return {
      "input": {
        "serviceId": "908",
        "token": SessionManager.token ?? "",
        "referenceNo": SessionManager.referenceNo ?? "",
        "appForm": appForm
      }
    };
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all the required fields.')));
      return;
    }
    if (_photoFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please upload a photo.')));
      return;
    }
    if (_documentFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please upload an enclosure document.')));
      return;
    }
    if (selectedEnclosureDoc == null) {
       ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select an enclosure document type.')));
      return;
    }
    if (!agreedToDeclaration) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please agree to the declaration.')));
      return;
    }

    final formData = await _prepareFormData();

    debugPrint('District ORG : $presentDistrictCode');
    debugPrint('Tehsil ORG   : $presentTehsilCode');
    debugPrint('RI ORG       : $presentRICode');
    debugPrint('Village CODE: $presentVillageCode');

    final Map<String, String> displayData = {
      "Salutation": salutation ?? "",
      "Name": nameController.text.trim().toUpperCase(),
      "Gender": gender ?? "",
      "Marital Status": maritalStatus ?? "",
      "Age": ageController.text.trim(),
      "Aadhaar": aadhaarController.text.trim(),
      "Father's Name": fatherNameController.text.trim().toUpperCase(),
      "Mother's Name": motherNameController.text.trim().toUpperCase(),
      if (gender == 'Female' && (maritalStatus == 'Married' ||
          maritalStatus == 'Widow')) "Husband's Name": husbandNameController
          .text.trim().toUpperCase(),
      "Mobile": mobileController.text.trim(),
      "Email": emailController.text.trim(),

      "Present District": presentDistrictName ?? "",
      "Present Tehsil": presentTehsilName ?? "",
      "Present Village": presentVillageNotInList
          ? presentVillageCustomController.text.toUpperCase()
          : (presentVillageName ?? ""),
      "Present RI": presentRIName ?? "",
      "Present Police Station": presentPoliceStationController.text
          .trim()
          .toUpperCase(),
      "Present Post Office": presentPostOfficeController.text
          .trim()
          .toUpperCase(),
      "Present PIN": presentPinController.text.trim(),
      "Years Residing": presentYearsController.text.trim(),
      "Months Residing": presentMonthsController.text.trim(),

      "Same as Present": sameAsPresentAddress,
      "Permanent State": "ODISHA",
      "Permanent District": permanentDistrictName ?? "",
      "Permanent Tehsil": permanentTehsilName ?? "",
      "Permanent Village": permanentVillageNotInList
          ? permanentVillageCustomController.text.toUpperCase()
          : (permanentVillageName ?? ""),
      "Permanent RI": permanentRIName ?? "",
      "Permanent Police Station": permanentPoliceStationController.text
          .trim()
          .toUpperCase(),
      "Permanent Post Office": permanentPostOfficeController.text
          .trim()
          .toUpperCase(),
      "Permanent PIN": permanentPinController.text.trim(),

      "Other Person Filling?": anyPersonOtherThanApplicant,
      if (anyPersonOtherThanApplicant ==
          'Yes') "Guardian Name": otherPersonNameController.text
          .trim()
          .toUpperCase(),
      if (anyPersonOtherThanApplicant ==
          'Yes') "Guardian Relation": otherPersonRelationController.text
          .trim()
          .toUpperCase(),

      "Purpose": purposeController.text.trim().toUpperCase(),
      "Document Type": selectedEnclosureDoc ?? "",
      "Apply to": currentOfficeName ?? "",
      "Place": placeController.text.trim().toUpperCase(),
    };

    if (mounted) {
      Navigator.push(context, MaterialPageRoute(builder: (context) =>
          FormPreviewScreen(
            formData: formData,
            displayData: displayData,
            photoPath: _photoFile!.path,
            documentFileName: _documentFileName,
          )));
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    fatherNameController.dispose();
    motherNameController.dispose();
    husbandNameController.dispose();
    mobileController.dispose();
    emailController.dispose();
    aadhaarController.dispose();
    otherPersonNameController.dispose();
    otherPersonRelationController.dispose();
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
    purposeController.dispose();
    placeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool showHusbandField = gender == 'Female' &&
        (maritalStatus == 'Married' || maritalStatus == 'Widow');

    return Scaffold(
      appBar: AppBar(title: const Text('Resident Certificate'),
          backgroundColor: Colors.blue[700]),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Center(
              child: Image.asset(
                'assets/images/oglogo.png',
                height: 80,
                errorBuilder: (context, error, stackTrace) =>
                const Icon(
                    Icons.image_not_supported, size: 50, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'APPLICATION FORM FOR ISSUE OF RESIDENT CERTIFICATE',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue),
            ),
            const SizedBox(height: 32),
            const Text('PERSONAL DETAILS',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(children: [
              _photoFile != null
                  ? Image.file(
                  _photoFile!, width: 80, height: 80, fit: BoxFit.cover)
                  : Container(width: 80,
                  height: 80,
                  color: Colors.grey[300],
                  child: const Icon(Icons.person)),
              const SizedBox(width: 16),
              ElevatedButton(onPressed: _showPhotoSourceDialog,
                  child: const Text('Upload Photo')),
            ]),
            if (_photoError != null) Text(_photoError!,
                style: const TextStyle(color: Colors.red, fontSize: 12)),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Salutation *'),
                initialValue: salutation,
                items: AppConstants.salutations.map((s) =>
                    DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (v) => setState(() => salutation = v),
                validator: (v) => v == null ? 'Required' : null
            ),
            const SizedBox(height: 16),
            TextFormField(controller: nameController,
                decoration: const InputDecoration(labelText: 'Name *'),
                textCapitalization: TextCapitalization.characters,
                validator: (v) => FormValidators.validateRequired(v, 'Name')),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Gender *'),
                initialValue: gender,
                items: AppConstants.genders.map((g) =>
                    DropdownMenuItem(value: g, child: Text(g))).toList(),
                onChanged: (v) => setState(() => gender = v),
                validator: (v) => v == null ? 'Required' : null
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                    labelText: 'Marital Status *'),
                initialValue: maritalStatus,
                items: AppConstants.maritalStatuses.map((m) =>
                    DropdownMenuItem(value: m, child: Text(m))).toList(),
                onChanged: (v) => setState(() => maritalStatus = v),
                validator: (v) => v == null ? 'Required' : null
            ),

            if (showHusbandField) ...[
              const SizedBox(height: 16),
              TextFormField(controller: husbandNameController,
                  decoration: const InputDecoration(
                      labelText: "Husband's Name *"),
                  textCapitalization: TextCapitalization.characters,
                  validator: (v) =>
                      FormValidators.validateRequired(v, "Husband's Name")),
            ],

            const SizedBox(height: 16),
            TextFormField(controller: ageController,
                decoration: const InputDecoration(labelText: 'Age *'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: FormValidators.validateAge),
            const SizedBox(height: 16),
            TextFormField(controller: aadhaarController,
                decoration: const InputDecoration(
                    labelText: 'Aadhaar', counterText: ''),
                keyboardType: TextInputType.number,
                maxLength: 12,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: FormValidators.validateAadhaar),
            const SizedBox(height: 16),
            TextFormField(controller: fatherNameController,
                decoration: const InputDecoration(labelText: "Father's Name *"),
                textCapitalization: TextCapitalization.characters,
                validator: (v) =>
                    FormValidators.validateRequired(v, "Father's Name")),
            const SizedBox(height: 16),
            TextFormField(controller: motherNameController,
                decoration: const InputDecoration(labelText: "Mother's Name *"),
                textCapitalization: TextCapitalization.characters,
                validator: (v) =>
                    FormValidators.validateRequired(v, "Mother's Name")),
            const SizedBox(height: 16),
            TextFormField(controller: mobileController,
                decoration: const InputDecoration(
                    labelText: 'Mobile *', counterText: ''),
                keyboardType: TextInputType.phone,
                maxLength: 10,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: FormValidators.validateMobile),
            const SizedBox(height: 16),
            TextFormField(controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: FormValidators.validateEmail),

            const SizedBox(height: 32),
            const Text('PRESENT ADDRESS',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildAddressSection(true),

            const SizedBox(height: 32),
            const Text('PERMANENT ADDRESS',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'State *',
                filled: true,
                fillColor: Color(0xFFF5F5F5),
              ),
              initialValue: 'ODISHA',
              readOnly: true,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                    labelText: 'Same as Present Address?'),
                initialValue: sameAsPresentAddress,
                items: AppConstants.yesNoOptions.map((o) =>
                    DropdownMenuItem(value: o, child: Text(o))).toList(),
                onChanged: (v) {
                  setState(() => sameAsPresentAddress = v!);
                  if (v == 'Yes') {
                    _copyPresentToPermanent();
                  } else {
                    _clearPermanentAddress();
                  }
                }
            ),
            const SizedBox(height: 16),
            _buildAddressSection(false),

            const SizedBox(height: 32),
            const Text('FAMILY MEMBERS / GUARDIAN DETAILS',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                  labelText: 'If any person other than applicant filling the Application? *'),
              initialValue: anyPersonOtherThanApplicant,
              items: AppConstants.yesNoOptions.map((o) =>
                  DropdownMenuItem(value: o, child: Text(o))).toList(),
              onChanged: (v) =>
                  setState(() => anyPersonOtherThanApplicant = v!),
            ),
            if (anyPersonOtherThanApplicant == 'Yes') ...[
              const SizedBox(height: 16),
              TextFormField(controller: otherPersonNameController,
                  decoration: const InputDecoration(
                      labelText: 'Name of the person *'),
                  textCapitalization: TextCapitalization.characters,
                  validator: (v) =>
                      FormValidators.validateRequired(v, 'Name of the person')),
              const SizedBox(height: 16),
              TextFormField(controller: otherPersonRelationController,
                  decoration: const InputDecoration(
                      labelText: 'Relations of with applicant *'),
                  textCapitalization: TextCapitalization.characters,
                  validator: (v) =>
                      FormValidators.validateRequired(v, 'Relation')),
            ],

            const SizedBox(height: 32),
            const Text('PURPOSE & DOCUMENTS',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextFormField(controller: purposeController,
                decoration: const InputDecoration(labelText: 'Purpose *'),
                maxLines: 2,
                textCapitalization: TextCapitalization.characters,
                validator: (v) =>
                    FormValidators.validateRequired(v, 'Purpose')),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                    labelText: 'Enclosure Document *'),
                initialValue: selectedEnclosureDoc,
                items: AppConstants.enclosureDocuments.keys.map((doc) =>
                    DropdownMenuItem(value: doc, child: Text(doc))).toList(),
                onChanged: (v) => setState(() => selectedEnclosureDoc = v),
                validator: (v) => v == null ? 'Required' : null
            ),
            const SizedBox(height: 16),
            ElevatedButton(
                onPressed: _pickDocument, child: const Text('Upload Document')),
            if (_documentFileName != null) Text('File: $_documentFileName'),

            if (currentOfficeName != null) ...[
              const SizedBox(height: 32),
              const Text('APPLY TO THE OFFICE',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextFormField(
                controller: TextEditingController(text: currentOfficeName),
                readOnly: true,
                decoration: const InputDecoration(
                    labelText: 'Designation of Office',
                    filled: true,
                    fillColor: Color(0xFFF5F5F5)),
              ),
            ],

            const SizedBox(height: 32),
            const Text('DECLARATION',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Text(AppConstants.declarationText,
                style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 16),
            TextFormField(controller: placeController,
                decoration: const InputDecoration(labelText: 'Place *'),
                textCapitalization: TextCapitalization.characters,
                validator: (v) => FormValidators.validateRequired(v, 'Place')),
            const SizedBox(height: 16),
            Row(children: [
              Checkbox(value: agreedToDeclaration,
                  onChanged: (v) =>
                      setState(() => agreedToDeclaration = v ?? false)),
              const Text('I Agree *')
            ]),
            const SizedBox(height: 32),
            SizedBox(width: double.infinity,
                height: 50,
                child: ElevatedButton(onPressed: _submitForm,
                    child: const Text('Review Application'))),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressSection(bool isPresent) {
    final distCode = isPresent ? presentDistrictCode : permanentDistrictCode;
    final tehCode = isPresent ? presentTehsilCode : permanentTehsilCode;
    final riCode = isPresent ? presentRICode : permanentRICode;
    final vilCode = isPresent ? presentVillageCode : permanentVillageCode;

    final villageNotInList =
    isPresent ? presentVillageNotInList : permanentVillageNotInList;

    final currentTehsils = isPresent ? presentTehsils : permanentTehsils;
    final currentRIs = isPresent ? presentRIs : permanentRIs;
    final currentVillages = isPresent ? presentVillages : permanentVillages;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

      /// DISTRICT
      DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: isPresent ? 'District *' : 'Permanent District *',
        ),
        value: distCode,
        items: districts.map((d) {
          return DropdownMenuItem(
            value: d['org_code']?.toString(),
            child: Text(d['name']?.toString() ?? ''),
          );
        }).toList(),
        onChanged: (orgCode) {
          if (orgCode == null) return;
          final dist = districts.firstWhere((d) => d['org_code'] == orgCode);
          setState(() {
            if (isPresent) {
              presentDistrictCode = orgCode;
              presentDistrictOrgCode = dist['org_code'];
              presentDistrictName = dist['name'];
              // 🔥 CLEAR DEPENDENTS
              presentTehsilCode = null;
              presentTehsilOrgCode = null;
              presentTehsilName = null;
              presentRICode = null;
              presentRIOrgCode = null;
              presentRIName = null;
              presentVillageCode = null;
              presentVillageName = null;

              presentTehsils.clear();
              presentRIs.clear();
              presentVillages.clear();
            } else {
              permanentDistrictCode = orgCode;
              permanentDistrictOrgCode = dist['org_code'];
              permanentDistrictName = dist['name'];
              permanentTehsilCode = null;
              permanentTehsilOrgCode = null;
              permanentTehsilName = null;
              permanentRICode = null;
              permanentRIOrgCode = null;
              permanentRIName = null;
              permanentVillageCode = null;
              permanentVillageName = null;

              permanentTehsils.clear();
              permanentRIs.clear();
              permanentVillages.clear();
            }
          });

          isPresent
              ? _loadPresentTehsils(orgCode)
              : _loadPermanentTehsils(orgCode);
        },

        validator: (v) => v == null ? 'Required' : null,
      ),

      const SizedBox(height: 16),

      /// TEHSIL
      DropdownButtonFormField<String>(
        decoration: const InputDecoration(labelText: 'Tehsil *'),
        value: tehCode,
        items: currentTehsils.map((t) {
          return DropdownMenuItem<String>(
            value: t['org_code']?.toString(),
            child: Text(t['name']?.toString() ?? ''),
          );
        }).toList(),
        onChanged: (orgCode) {
          if (orgCode == null) return;
          final teh = currentTehsils.firstWhere((t) => t['org_code'] == orgCode);
          setState(() {
            if (isPresent) {
              presentTehsilCode = orgCode;
              presentTehsilOrgCode = teh['org_code'];
              presentTehsilName = teh['name'];
              // 🔥 CLEAR CHILDREN
              presentRICode = null;
              presentRIOrgCode = null;
              presentRIName = null;
              presentVillageCode = null;
              presentVillageName = null;

              presentRIs.clear();
              presentVillages.clear();

               _updateApplyToOffice(presentTehsilName!);
            } else {
              permanentTehsilCode = orgCode;
              permanentTehsilOrgCode = teh['org_code'];
              permanentTehsilName = teh['name'];
              permanentRICode = null;
              permanentRIOrgCode = null;
              permanentRIName = null;
              permanentVillageCode = null;
              permanentVillageName = null;

              permanentRIs.clear();
              permanentVillages.clear();
            }
          });



          isPresent
              ? _loadPresentRIs(orgCode)
              : _loadPermanentRIs(orgCode);
        },

        validator: (v) => v == null ? 'Required' : null,
      ),

      const SizedBox(height: 16),

      /// RI
      DropdownButtonFormField<String>(
        decoration: const InputDecoration(labelText: 'RI Circle *'),
        value: riCode,
        items: currentRIs.map((r) {
          return DropdownMenuItem<String>(
            value: r['org_code']?.toString(),
            child: Text(r['name']?.toString() ?? ''),
          );
        }).toList(),
          onChanged: (orgCode) {
            if (orgCode == null) return;
            final ri = currentRIs.firstWhere((r) => r['org_code'] == orgCode);
            setState(() {
              if (isPresent) {
                presentRICode = orgCode;
                presentRIOrgCode = ri['org_code'];
                presentRIName = ri['name'];
                // 🔥 CLEAR VILLAGES
                presentVillageCode = null;
                presentVillages.clear();
              } else {
                permanentRICode = orgCode;
                permanentRIOrgCode = ri['org_code'];
                permanentRIName = ri['name'];
                permanentVillageCode = null;
                permanentVillages.clear();
              }
            });

            isPresent
                ? _loadPresentVillages(orgCode)
                : _loadPermanentVillages(orgCode);
          },
        validator: villageNotInList ? null : (v) => v == null ? 'Required' : null,
      ),

          const SizedBox(height: 16),

      /// VILLAGE
      DropdownButtonFormField<String>(
        decoration: const InputDecoration(labelText: 'Village *'),
        value: vilCode,
        items: currentVillages.map((v) {
          return DropdownMenuItem(
            value: v['village_id']?.toString(),
            child: Text(v['name']?.toString() ?? ''),
          );
        }).toList(),
        onChanged: villageNotInList ? null : (v) {
          if (v == null) return;
          final vil = currentVillages.firstWhere((e) => e['village_id'] == v);
          setState(() {
            if (isPresent) {
              presentVillageCode = v;
              presentVillageName = vil['name'];
            } else {
              permanentVillageCode = v;
              permanentVillageName = vil['name'];
            }
          });
        },
        validator: villageNotInList ? null : (v) =>
        v == null
            ? 'Required'
            : null,
      ),

      const SizedBox(height: 16),

      /// VILLAGE NOT IN LIST
      Row(children: [
        Checkbox(
          value: villageNotInList,
          onChanged: (v) {
            setState(() {
              if (isPresent) {
                presentVillageNotInList = v ?? false;
                presentVillageCode = null;
                presentVillageName = null;
                 if (v == false) {
                  presentVillageCustomController.clear();
                }
              } else {
                permanentVillageNotInList = v ?? false;
                permanentVillageCode = null;
                permanentVillageName = null;
                if (v == false) {
                  permanentVillageCustomController.clear();
                }
              }
            });
          },
        ),
        const Text('Village Not in List'),
      ]),

      if (villageNotInList) ...[
        TextFormField(
          controller: isPresent
              ? presentVillageCustomController
              : permanentVillageCustomController,
          decoration: const InputDecoration(labelText: 'Village Name *'),
          textCapitalization: TextCapitalization.characters,
          validator: (v) => FormValidators.validateRequired(v, 'Village'),
        ),
        const SizedBox(height: 16),
      ],

      TextFormField(
        controller:
        isPresent
            ? presentPoliceStationController
            : permanentPoliceStationController,
        decoration: const InputDecoration(labelText: 'Police Station'),
        textCapitalization: TextCapitalization.characters,
      ),

      const SizedBox(height: 16),

      TextFormField(
        controller:
        isPresent ? presentPostOfficeController : permanentPostOfficeController,
        decoration: const InputDecoration(labelText: 'Post Office'),
        textCapitalization: TextCapitalization.characters,
      ),

      const SizedBox(height: 16),

      TextFormField(
        controller: isPresent ? presentPinController : permanentPinController,
        decoration: const InputDecoration(labelText: 'PIN', counterText: ''),
        keyboardType: TextInputType.number,
        maxLength: 6,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        validator: FormValidators.validatePin,
      ),

      if (isPresent) ...[
        const SizedBox(height: 16),
        TextFormField(
          controller: presentYearsController,
          decoration: const InputDecoration(labelText: 'Years Residing'),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: presentMonthsController,
          decoration: const InputDecoration(
              labelText: 'Months Residing', counterText: ''),
          keyboardType: TextInputType.number,
          maxLength: 2,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            TextInputFormatter.withFunction((o, n) {
              if (n.text.isEmpty) return n;
              final v = int.tryParse(n.text);
              return (v != null && v <= 11) ? n : o;
            }),
          ],
          validator: FormValidators.validateMonths,
        ),
      ],
    ]);
  }
}
