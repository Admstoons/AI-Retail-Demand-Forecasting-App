// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:retail_demand/provider/theme_provider.dart';
import 'package:retail_demand/provider/upload_notifier.dart';
import 'package:retail_demand/provider/prediction_notifier.dart';
import 'package:retail_demand/screens/dashboard_screens/price_predictor_screen.dart';
import 'package:retail_demand/models/prediction_state_data.dart';

class UploadDataScreen extends ConsumerStatefulWidget {
  const UploadDataScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _UploadDataScreenState createState() => _UploadDataScreenState();
}

class _UploadDataScreenState extends ConsumerState<UploadDataScreen> {
  File? selectedFile;
  Uint8List? selectedFileBytes;
  String? selectedFileName;

  Future<void> pickFile() async {
    try {
      bool permissionGranted = true;
      if (!kIsWeb && Platform.isAndroid) {
        final status = await Permission.storage.request();
        if (status.isPermanentlyDenied) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Storage permission permanently denied. Please enable in settings.',
              ),
              action: SnackBarAction(
                label: 'Settings',
                onPressed: () => openAppSettings(),
              ),
            ),
          );
          return;
        }
        permissionGranted = status.isGranted;
      }

      if (!permissionGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Storage permission denied')),
        );
        return;
      }

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv', 'json'],
        allowMultiple: false,
        withData: kIsWeb,
      );

      if (result != null) {
        if (kIsWeb) {
          setState(() {
            selectedFileBytes = result.files.single.bytes;
            selectedFileName = result.files.single.name;
          });
        } else {
          final file = File(result.files.single.path!);
          if (!file.existsSync()) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('File not found: ${file.path}')),
            );
            return;
          }
          if (file.lengthSync() > 50 * 1024 * 1024) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('File too large (max 50MB)')),
            );
            return;
          }
          setState(() {
            selectedFile = file;
          });
        }
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('No file selected')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error selecting file: $e')));
    }
  }

  /// Gradient button helper
  Widget _buildGradientButton({
    required String label,
    required IconData icon,
    required VoidCallback? onPressed,
    required bool showLoading,
    required bool disabled,
    required List<Color> gradientColors,
  }) {
    final labelColor = Theme.of(context).colorScheme.onPrimary;
    final buttonHeight = 55.0;
    final BorderRadius borderRadius = BorderRadius.circular(12);
    final colors =
        disabled
            ? [
              const Color.fromARGB(255, 197, 174, 255),
              const Color.fromARGB(255, 29, 29, 29),
            ]
            : gradientColors;

    return SizedBox(
      width: double.infinity,
      height: buttonHeight,
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: colors,
              begin: Alignment.topRight,
              end: Alignment.bottomRight,
            ),
            borderRadius: borderRadius,
            boxShadow: [
              BoxShadow(
                color: colors.first.withOpacity(0.55),
                offset: const Offset(1, 2),
                blurRadius: 5,
              ),
            ],
          ),
          child: InkWell(
            borderRadius: borderRadius,
            onTap: (disabled || onPressed == null) ? null : onPressed,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (showLoading)
                      SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.3,
                          valueColor: AlwaysStoppedAnimation<Color>(labelColor),
                        ),
                      )
                    else
                      Icon(icon, color: labelColor),
                    const SizedBox(width: 10),
                    Text(
                      label,
                      style: TextStyle(
                        color: labelColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uploadState = ref.watch(uploadNotifierProvider);
    final uploadNotifier = ref.read(uploadNotifierProvider.notifier);

    final predictionStateData = ref.watch(predictionNotifierProvider);
    final predictionNotifier = ref.read(predictionNotifierProvider.notifier);

    final Color primary = Theme.of(context).colorScheme.primary;
    final Color secondary = Theme.of(context).colorScheme.secondary;
    final List<Color> gradientColors = [primary, secondary];

    final bool uploadDisabled =
        (selectedFile == null && selectedFileBytes == null) ||
        uploadState == UploadState.uploading;
    final bool predictDisabled =
        uploadState != UploadState.success ||
        predictionStateData.status == PredictionState.loading;

    final themeMode = ref.watch(themeProvider);

    final backgroundColor =
        themeMode == ThemeMode.light
            ? Colors.white
            : Colors.white.withOpacity(0.25);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text("Upload Sales Data"),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildGradientButton(
                  label: "Select CSV or JSON File",
                  icon: Icons.upload_file,
                  onPressed: pickFile,
                  showLoading: false,
                  disabled: false,
                  gradientColors: gradientColors,
                ),
                const SizedBox(height: 10),

                if (kIsWeb && selectedFileName != null)
                  Text(
                    "Selected File:\n$selectedFileName",
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  )
                else if (!kIsWeb && selectedFile != null)
                  Text(
                    "Selected File:\n${selectedFile!.path.split('/').last}",
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                const SizedBox(height: 20),

                // Upload button
                _buildGradientButton(
                  label:
                      uploadState == UploadState.uploading
                          ? "Uploading..."
                          : "Upload to Supabase",
                  icon: Icons.cloud_upload,
                  onPressed:
                      uploadDisabled
                          ? null
                          : () async {
                            try {
                              if (kIsWeb &&
                                  selectedFileBytes != null &&
                                  selectedFileName != null) {
                                await uploadNotifier.uploadFileFromBytes(
                                  selectedFileBytes!,
                                  selectedFileName!,
                                );
                              } else if (selectedFile != null) {
                                await uploadNotifier.uploadFile(selectedFile!);
                              }

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('File uploaded successfully'),
                                ),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Upload failed: ${uploadNotifier.errorMessage}',
                                  ),
                                ),
                              );
                            }
                          },
                  showLoading: uploadState == UploadState.uploading,
                  disabled: uploadDisabled,
                  gradientColors: gradientColors,
                ),
                const SizedBox(height: 10),

                // Prediction button
                _buildGradientButton(
                  label:
                      predictionStateData.status == PredictionState.loading
                          ? "Predicting..."
                          : "Run Prediction",
                  icon: Icons.analytics,
                  onPressed:
                      predictDisabled
                          ? null
                          : () async {
                            try {
                              await predictionNotifier.predictFromFileURL(
                                uploadNotifier.fileURL,
                              );
                              await uploadNotifier.deleteUploadedFile();

                              final latestState = ref.read(
                                predictionNotifierProvider,
                              );

                              if (latestState.status ==
                                      PredictionState.success &&
                                  latestState.result.isNotEmpty &&
                                  mounted) {
                                // ✅ Show success before navigating
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      '✅ Prediction successful! Redirecting...',
                                    ),
                                    duration: Duration(seconds: 2),
                                  ),
                                );

                                await Future.delayed(
                                  const Duration(seconds: 2),
                                );

                                if (!mounted) return;
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) => const PricePredictorScreen(),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Prediction returned empty result or failed.',
                                    ),
                                  ),
                                );
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Prediction failed: $e'),
                                ),
                              );
                            }
                          },
                  showLoading:
                      predictionStateData.status == PredictionState.loading,
                  disabled: predictDisabled,
                  gradientColors: gradientColors,
                ),

                const SizedBox(height: 20),
                if (uploadState == UploadState.success)
                  Text(
                    "✅ Upload successful!\nFile URL:\n${uploadNotifier.fileURL}",
                    style: const TextStyle(color: Colors.green),
                    textAlign: TextAlign.center,
                  ),
                if (uploadState == UploadState.error)
                  Text(
                    "❌ Upload failed: ${uploadNotifier.errorMessage}",
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
