
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_document_reader_api/flutter_document_reader_api.dart';
import 'package:permission_handler/permission_handler.dart';

class RegulaService with ChangeNotifier{

  //late DocumentReader? _scanner;
  bool isInitialized = false;
  bool isScanningPassport = false;
  bool isScanningIDCard = false;
  String statusMessage = "Initializing...";
  Map<String, dynamic> documentData = {};
  List<Uint8List>? documentImage;
  Uint8List? faceImage;
  double downloadProgress = 0.0;


  Future<bool> requestCameraPermission() async {

    final status = await Permission.camera.request();

    print("...........$status");

    if (status.isDenied) {

      final result = await Permission.camera.request();

      print(".....result........${result.isGranted}");
      if (status.isPermanentlyDenied) {
        await openAppSettings(); // opens iOS Settings
        //return false;
      }

      return result.isGranted;
    }
    else if (status.isPermanentlyDenied) {
      await openAppSettings(); // opens iOS Settings
      //return false;
    }

    return status.isGranted;
  }

  Future<void> initializeSDK() async {
    try {

        statusMessage = "Requesting permissions...";


      // Request camera permission
      //var status = await Permission.camera.request();
      if (await requestCameraPermission() == false) {

          statusMessage = "Camera permission denied";

        return;
      }

      // Prepare database with progress callback

        statusMessage = "Preparing database...";


      final dbResult = await DocumentReader.instance.prepareDatabase("Full", (progress) {

          downloadProgress = progress.progress.toDouble();
          statusMessage = "Downloading database: ${(downloadProgress * 100).toStringAsFixed(1)}%";
          notifyListeners();
      });

      if (!dbResult.$1) {

          statusMessage = "Database preparation failed";

        return;
      }

      // Initialize with license

        statusMessage = "Initializing SDK...";

      final license = await rootBundle.load("assets/regula.license");
      final initResult = await DocumentReader.instance.initializeReader(InitConfig(license));

      if (initResult.$1) {

          isInitialized = true;
          statusMessage = "Ready to scan";

        // Configure processing parameters
        DocumentReader.instance.processParams = ProcessParams()
          ..multipageProcessing = true
          ..returnUncroppedImage = true
          ..timeout = 30
          ..debugSaveImages = false
          ..debugSaveLogs = false;

        // Configure functionality
        DocumentReader.instance.functionality = Functionality()
        // ..showHelpAnimation = true
          ..manualMultipageMode = true;

          notifyListeners();
          print('✅ Regula SDK initialized successfully with offline database');

      } else {

          statusMessage = "SDK initialization failed";
          notifyListeners();
      }
        notifyListeners();
    } catch (e) {

        statusMessage = "Initialization error: $e";
        notifyListeners();
    }
  }

  /// scan passport
  ///
  Future<void> scanDocumentPassport() async {
    if (!isInitialized || isScanningPassport || !await DocumentReader.instance.isReady) return;

    isScanningPassport = true;
    statusMessage = "Preparing scanner...";
    documentData = {};
    documentImage = null;
    faceImage = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 300));

      final config = ScannerConfig.withScenario(Scenario.FULL_PROCESS);

      DocumentReader.instance.functionality = Functionality()
        ..showCameraSwitchButton = true
        ..showTorchButton = true
        ..showCloseButton = true
        ..showCaptureButton = true
        ..orientation = DocReaderOrientation.LANDSCAPE_RIGHT
        ..manualMultipageMode = false;

      DocumentReader.instance.processParams = ProcessParams()
        ..timeout = 30
        ..multipageProcessing = false
        ..returnUncroppedImage = true
        ..generateDoublePageSpreadImage = false
        ..debugSaveImages = false
        ..debugSaveLogs = false
        ..useFaceApi = true
        ..dateFormat = "dd/MM/yyyy";

      await Future.delayed(Duration(seconds: 2));

      DocumentReader.instance.scan(config, (action, results, error) async {
        try {
          if (action == DocReaderAction.COMPLETE || action == DocReaderAction.TIMEOUT) {
            if (results != null) {
              final extractedData = await extractDocumentData(results);
              final allDocImages = await getAllDocumentImages(results);
              final faceImg = await cropFaceImage(results);

              documentData = extractedData;
              documentImage = allDocImages;
              faceImage = faceImg;
              statusMessage = "Scan completed successfully";
            } else {
              statusMessage = "Scan failed";
            }
          } else if (action == DocReaderAction.CANCEL) {
            statusMessage = "Scan cancelled";
          } else if (error != null) {
            try {
              await DocumentReader.instance.stopScanner();
              await Future.delayed(Duration(milliseconds: 300));
            } catch (_) {}
            statusMessage = "Error: ${error.message}";
          }
        } catch (e) {
          statusMessage = "Callback error: $e";
          print("Scan callback error: $e");
        } finally {
          isScanningPassport = false;
          notifyListeners();
        }
      });
    } catch (e) {
      statusMessage = "Scan error: $e";
      print("scan error $e");
      isScanningPassport = false;
      notifyListeners();
    }
  }


  ///scan id Card

  Future<void> scanIDCard() async {
    if (!isInitialized || isScanningIDCard||!await DocumentReader.instance.isReady) return;


      isScanningIDCard = true;
      statusMessage = "Preparing scanner...";
      documentData = {};
      documentImage = null;
      faceImage = null;
    notifyListeners();

    try {

      if (! await DocumentReader.instance.isReady) {
        debugPrint("❌ SDK not ready");
        return;
      }
      // if(!await DocumentReader.instance.isReady){
      //    await initializeSDK();
      // }
      // ✅ Optional: small delay to let native memory settle
      await Future.delayed(const Duration(milliseconds: 300));

      final config = ScannerConfig.withScenario(Scenario.OCR);
      // ..cameraPreviewMode = true
      // ..showCameraSwitchButton = true;
      // Set functionality parameters separately
      DocumentReader.instance.functionality = Functionality()
        ..showCameraSwitchButton = true  // Enable camera switching
        ..showTorchButton = true      // Show flash/torch button
        ..showCloseButton = true      // Show close button
        ..showCaptureButton = true
        ..orientation = DocReaderOrientation.LANDSCAPE_RIGHT
        ..manualMultipageMode = true;//true;   // Enable camera preview

      DocumentReader.instance.processParams = ProcessParams()
        ..timeout = 30 // ✅ Set to 30–60 seconds
        ..multipageProcessing =  true//true
        ..returnUncroppedImage = true
        ..generateDoublePageSpreadImage =  true//true
        ..debugSaveImages = false
        ..debugSaveLogs = false
        ..useFaceApi = true
        ..dateFormat = "dd/MM/yyyy";

      // Set process parameters
      // DocumentReader.instance.processParams = ProcessParams()
      //   ..returnUncroppedImage = true
      //   ..generateDoublePageSpreadImage = true
      //   ..debugSaveImages = true
      //   ..debugSaveLogs = true
      //   ..dateFormat = "dd/MM/yyyy"
      //   ..useFaceApi = true;
      await Future.delayed(Duration(seconds: 2));
      DocumentReader.instance.scan(config, (action, results, error) async {
        if (action == DocReaderAction.COMPLETE  || action == DocReaderAction.TIMEOUT) {
          if(results !=null){
            // Process document data
            final extractedData = await extractDocumentData(results);

            final allDocImages = await getAllDocumentImages(results);


            // Get and save images
            // final docImage = await cropDocumentImage(results);
            final faceImg = await cropFaceImage(results);

            // Save images to device storage
            // if (docImage != null) {
            //   await saveImage(docImage, 'document_${DateTime.now().millisecondsSinceEpoch}.jpg');
            // }
            // if (faceImg != null) {
            //   await saveImage(faceImg, 'face_${DateTime.now().millisecondsSinceEpoch}.jpg');
            // }
            //await DocumentReader.instance.stopScanner();

              documentData = extractedData;
              documentImage = allDocImages;
              //_documentImage = docImage;
              faceImage = faceImg;
              isScanningIDCard = false;
              statusMessage = "Scan completed successfully";
            notifyListeners();

          }
          else{

              isScanningIDCard = false;
              statusMessage = "Scan failed ";
              notifyListeners();
          }
        } else if (action == DocReaderAction.CANCEL) {

            isScanningIDCard = false;
            statusMessage = "Scan cancelled";
         notifyListeners();
        } else if (error != null) {

          // ✅ Only stop scanner after processing is done
          try {
            await DocumentReader.instance.stopScanner();
            await Future.delayed(Duration(milliseconds: 300)); // Let native clean up
          } catch (_) {}


            isScanningIDCard = false;
            statusMessage = "Error: ${error.message}";
         notifyListeners();
        }
      });
    } catch (e) {

        isScanningIDCard = false;
        statusMessage = "Scan error: $e";
     notifyListeners();
      print("scan error $e");
    }

  }

  Future<Map<String, dynamic>> extractDocumentData(Results results) async {
    Map<String, dynamic> data = {};

    // Document type information
    if (results.documentType?.isNotEmpty == true) {
      debugPrint("Document type...........................: ${results.documentType!.first.name}");
      //debugPrint("Supports face image: ${results.documentType!.first.po");

      final docType = results.documentType!.first;
      data['documentType'] = {
        'name': docType.name ?? 'Unknown',
        'country': docType.countryName ?? 'Unknown',
        'ICAOCode': docType.iCAOCode ?? 'N/A',
        'isMRZ': docType.mrz ? 'Yes' : 'No'
      };
    }
    else{
      debugPrint("Document type.....................: ${results.documentType!.first.name}");
    }

    // Text fields from document
    if (results.textResult != null) {
      Map<String, dynamic> textFields = {};
      for (var field in results.textResult!.fields) {
        if (field.values.isNotEmpty) {
          textFields[field.fieldName] = {
            'value': field.values.first.value?.toString() ?? 'N/A',
            'source': field.values.first.sourceType.toString(),
            'confidence': field.values.first.probability
          };
        }
      }
      data['textFields'] = textFields;
    }

    // Common fields
    data['personalData'] = {
      'fullName': await _getFullName(results),
      'documentNumber': await results.textFieldValueByType(FieldType.DOCUMENT_NUMBER),
      'dateOfBirth': await results.textFieldValueByType(FieldType.DATE_OF_BIRTH),
      'nationality': await results.textFieldValueByType(FieldType.NATIONALITY),
      'gender': await results.textFieldValueByType(FieldType.SEX),
      'expiryDate': await results.textFieldValueByType(FieldType.DATE_OF_EXPIRY),
      'issueDate': await results.textFieldValueByType(FieldType.DATE_OF_ISSUE),
    };

    // Address field extraction
    data['address'] = await results.textFieldValueByType(FieldType.ADDRESS) ??
        await results.textFieldValueByType(FieldType.ADDRESS_POSTAL_CODE) ??
        await results.textFieldValueByType(FieldType.ADDRESS_HOUSE) ??
        await results.textFieldValueByType(FieldType.ADDRESS_AREA) ??
        'N/A';

    // Validation results
    if (results.status != null) {
      data['validation'] = {
        'overallStatus': results.status.overallStatus.toString(),
        'opticalStatus': results.status.optical.toString(),
        'RFIDStatus': results.status.rfid.toString() ?? 'N/A',
      };
    }

    return data;
  }

  Future<String?> _getFieldValueByLabel(Results results, List<String> keywords) async {
    if (results.textResult == null) return null;
    for (final field in results.textResult!.fields) {
      final fieldName = field.fieldName.toLowerCase();
      if (keywords.any((keyword) => fieldName.contains(keyword))) {
        if (field.values.isNotEmpty) {
          return field.values.first.value?.toString();
        }
      }
    }
    return null;
  }


  Future<String> _getFullName(Results results) async {
    String? firstName = await results.textFieldValueByType(FieldType.FIRST_NAME);
    firstName ??= await results.textFieldValueByType(FieldType.GIVEN_NAMES);
    final lastName = await results.textFieldValueByType(FieldType.SURNAME);
    return '${firstName ?? ''} ${lastName ?? ''}'.trim();
  }


  Future<List<Uint8List>> getAllDocumentImages(Results results) async {
    List<Uint8List> images = [];

    for (int i = 0; i < 2; i++) {
      try {
        final img = await results.graphicFieldImageByTypeSourcePageIndexLight(
          GraphicFieldType.DOCUMENT_IMAGE,
          ResultType.RAW_IMAGE,
          i,
          Lights.WHITE_FULL,
        );
        if (img != null) images.add(img);
      } catch (e) {
        print("Image not found for page $i: $e");
      }
    }

    return images;
  }




  Future<Uint8List?> cropFaceImage(Results results) async {
    try {
      // Check if portrait field exists in graphicResult
      if (results.graphicResult != null) {
        for (final field in results.graphicResult!.fields) {
          debugPrint("📷 Found field: ${field.fieldType} - Page: ${field.pageIndex} - Light: ${field.light} - field name ${field.fieldName}");
        }
      }
      if (results.graphicResult != null) {
        for (final field in results.graphicResult!.fields) {
          if (field.fieldType == GraphicFieldType.PORTRAIT) {
            try {
              final image = await results.graphicFieldImageByTypeSourcePageIndexLight(
                field.fieldType,
                ResultType.GRAPHICS,
                field.pageIndex,
                field.light,
              );
              if (image != null) {
                debugPrint("✅ Extracted face using: page=${field.pageIndex}, light=${field.light}");
                return image;
              }
            } catch (e) {
              debugPrint("⚠️ Failed to extract with field info: $e");
            }
          }
        }
      }

      debugPrint("❌ Could not extract face image after checking all fields");
      return null;
    } catch (e) {
      debugPrint("❌ Face image extraction error: $e");
      return null;
    }
  }


Future<void> reInitializeSDK() async {
  try {
    await DocumentReader.instance.deinitializeReader();
    await Future.delayed(Duration(milliseconds: 300));
    await initializeSDK();
    documentData = {};
    documentImage = null;
   faceImage = null;
    statusMessage = "Cleared, scan again";
    notifyListeners();

  } catch (e) {
    print("error in clear $e");
  }

}

  void checkRegulaReady() async {
    bool initialized =  await DocumentReader.instance.isReady;

    if (initialized) {
      print("SDK is already initialized");

    } else {
      print("SDK is not initialized");

    }

  }

}