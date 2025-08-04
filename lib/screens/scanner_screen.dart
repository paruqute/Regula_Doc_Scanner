import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_document_reader_api/flutter_document_reader_api.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:regula_doc_scanner_app/services/regula_services.dart';

import '../utils/color.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  @override
  void initState() {
    // TODO: implement initState
    Provider.of<RegulaService>(context,listen: false).initializeSDK();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<RegulaService>(builder: (context, value, child) {
        return Container(
          padding: EdgeInsets.only(
            left: 20.w,
            top: 0.h,
            right: 20.w,
            bottom: 16.h,
          ),
          margin: EdgeInsets.only(
            left: 20.w,
            top: 20.h,
            right: 20.w,
            bottom: 20.h,
          ),
          decoration: BoxDecoration(color: backgroundColor),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // if(checkRegulaReady())
              //   CustomOutlinedButton(
              //   height: 40.h,
              //     titleWidget: Text("Initialize SDK",style: Theme.of(context).textTheme.labelMedium,),
              //     onPressed: (){
              //
              //     },
              //     width: 200.w,
              //   ),
              // Status indicator
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: value.isInitialized
                      ? Colors.green[100]
                      : Colors.orange[100],
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  children: [
                    Icon(
                      value.isInitialized ? Icons.check_circle : Icons.error,
                      color: value.isInitialized ? Colors.green : Colors.orange,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            value.statusMessage,
                            style: TextStyle(
                              color: value.isInitialized
                                  ? Colors.green[800]
                                  : Colors.orange[800],
                            ),
                          ),
                          if (value.downloadProgress > 0 && value.downloadProgress < 1)
                            Padding(
                              padding: EdgeInsets.only(top: 4.0.h),
                              child: LinearProgressIndicator(
                                value: value.downloadProgress,
                                backgroundColor: Colors.grey[200],
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.blue,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20.h),
              // Scan button
              Row(
                spacing: 10.w,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    flex: 3,
                    child: GestureDetector(

                      onTap: value.isInitialized
                          ? () {
                        Provider.of<RegulaService>(context,listen: false).scanDocumentPassport();
                      }
                          : () {
                        print(
                          ".......${value.isInitialized} & ${value.isScanningPassport}",
                        );
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            height: 100.h,
                            width: 100.w,
                            child: Image.asset("assets/scan img.jpg",fit: BoxFit.contain,),
                          ),
                          Text(
                            value.isScanningPassport ? 'Scanning...' : 'Scan Document',
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Flexible(
                  //   flex: 1,
                  //   child: SizedBox(
                  //     height: 40.h,
                  //     child: ElevatedButton(
                  //
                  //       onPressed: value.isInitialized && !value.isScanningIDCard
                  //           ? () async {
                  //         await Provider.of<RegulaService>(context,listen: false).scanIDCard();
                  //       }
                  //           : () {
                  //         print(
                  //           ".......${value.isInitialized} & ${value.isScanningIDCard}",
                  //         );
                  //       },
                  //       child: Text(
                  //         value.isScanningIDCard ? 'Scanning...' : 'Scan ID Card',
                  //       ),
                  //     ),
                  //   ),
                  // ),
                ],
              ),

              SizedBox(height: 20.h),
              SizedBox(
                height: 40.h,
                width: 200.w,
                child: ElevatedButton(
                  // width: 200.w,
                  onPressed: () async {
                   Provider.of<RegulaService>(context,listen: false).reInitializeSDK();

                    print("................cleared ${value.statusMessage}");
                  },

                  child: Text("Reset Scan"),
                ),
              ),
              SizedBox(height: 20.h),
              // Results display
              if (value.isScanningPassport)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16.h),
                        Text("Scanning document..."),
                      ],
                    ),
                  ),
                )
              else if (value.documentData.isNotEmpty)
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Document images
                        if (value.documentImage != null &&
                            value.documentImage!.isNotEmpty)
                          Column(
                            children: value.documentImage!.asMap().entries.map((
                                entry,
                                ) {
                              return Column(
                                children: [
                                  Text(
                                    "Document Page ${entry.key + 1}",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(height: 8.h),
                                  Image.memory(entry.value, height: 150.h),
                                  SizedBox(height: 12.h),
                                ],
                              );
                            }).toList(),
                          ),

                        value.faceImage != null
                            ? Column(
                          children: [
                            Text(
                              "Document Images",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8.h),

                            Text(
                              "Portrait",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Image.memory(value.faceImage!, height: 150.h),

                            Divider(height: 30.h),
                          ],
                        )
                            : Text(
                          "cant find face image",
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),

                        // Document type info
                        if (value.documentData['documentType'] != null)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Document Type",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              _buildInfoRow(
                                "Type",
                                value.documentData['documentType']['name'] ?? '',
                              ),
                              _buildInfoRow(
                                "Country",
                                value.documentData['documentType']['country'] ?? '',
                              ),
                              _buildInfoRow(
                                "ICAO Code",
                                value.documentData['documentType']['ICAOCode'] ?? '',
                              ),
                              _buildInfoRow(
                                "MRZ",
                                value.documentData['documentType']['isMRZ'] ?? '',
                              ),
                              Divider(height: 30.h),
                            ],
                          ),

                        // Personal data
                        if (value.documentData['personalData'] != null)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Personal Data",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              _buildInfoRow(
                                "Full Name",
                                value.documentData['personalData']['fullName'] ?? '',
                              ),
                              _buildInfoRow(
                                "Document Number",
                                value.documentData['personalData']['documentNumber'] ??
                                    "",
                              ),
                              _buildInfoRow(
                                "Date of Birth",
                                value.documentData['personalData']['dateOfBirth'] ??
                                    '',
                              ),
                              _buildInfoRow(
                                "Nationality",
                                value.documentData['personalData']['nationality'] ??
                                    '',
                              ),
                              _buildInfoRow(
                                "Gender",
                                value.documentData['personalData']['gender'] ?? '',
                              ),
                              _buildInfoRow(
                                "Expiry Date",
                                value.documentData['personalData']['expiryDate'] ??
                                    '',
                              ),
                              _buildInfoRow(
                                "Issue Date",
                                value.documentData['personalData']['issueDate'] ??
                                    '',
                              ),
                              _buildInfoRow(
                                "Address",
                                value.documentData['address'] ?? '',
                              ),
                              Divider(height: 30.h),
                            ],
                          ),

                        // Validation results
                        if (value.documentData['validation'] != null)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Validation Results",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              _buildInfoRow(
                                "Overall Status",
                                _formatStatus(
                                  value.documentData['validation']['overallStatus'] ??
                                      '',
                                ),
                                color: _getStatusColor(
                                  value.documentData['validation']['overallStatus'] ??
                                      '',
                                ),
                              ),
                              _buildInfoRow(
                                "Optical Check",
                                _formatStatus(
                                  value.documentData['validation']['opticalStatus'],
                                ),
                                color: _getStatusColor(
                                  value.documentData['validation']['opticalStatus'],
                                ),
                              ),
                              if (value.documentData['validation']['RFIDStatus'] !=
                                  'N/A')
                                _buildInfoRow(
                                  "RFID Check",
                                  _formatStatus(
                                    value.documentData['validation']['RFIDStatus'],
                                  ),
                                  color: _getStatusColor(
                                    value.documentData['validation']['RFIDStatus'],
                                  ),
                                ),
                            ],
                          ),

                        // All text fields
                        if (value.documentData['textFields'] != null)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Divider(height: 30.h),
                              Text(
                                "All Document Fields",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              ...value.documentData['textFields'].entries
                                  .map(
                                    (entry) => _buildInfoRow(
                                  entry.key,
                                  entry.value['value'],
                                ),
                              )
                                  .toList(),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },)
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? color}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.0.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            flex: 3,
            child: Text(value, style: TextStyle(color: color ?? Colors.black)),
          ),
        ],
      ),
    );
  }

  String _formatStatus(String status) {
    return status.replaceAll("CheckResult.", "").replaceAll("_", " ");
  }

  Color _getStatusColor(String status) {
    if (status.contains("ERROR")) return Colors.red;
    if (status.contains("OK")) return Colors.green;
    return Colors.orange;
  }
}
