import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../bloc/roster_bloc.dart';
import '../bloc/roster_event.dart';
import '../bloc/roster_state.dart';

class RosterUploadPage extends StatefulWidget {
  const RosterUploadPage({super.key});

  @override
  State<RosterUploadPage> createState() => _RosterUploadPageState();
}

class _RosterUploadPageState extends State<RosterUploadPage> {
  @override
  Widget build(BuildContext context) {
    return const _RosterUploadContent();
  }
}

class _RosterUploadContent extends StatefulWidget {
  const _RosterUploadContent();

  @override
  State<_RosterUploadContent> createState() => _RosterUploadContentState();
}

class _RosterUploadContentState extends State<_RosterUploadContent> {
  File? _selectedFile;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RosterBloc, RosterState>(
      listener: (context, state) {
        print('RosterState changed: ${state.runtimeType}'); // Debug log

        if (state is RosterProcessed) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Roster processed successfully! Found ${state.flights.length} flights.',
              ),
              backgroundColor: const Color(0xFF14B8A6),
            ),
          );
          // Navigate to flight list with processed data
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              context.push(AppRouter.flightList);
            }
          });
        } else if (state is RosterError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        return _buildContent(state);
      },
    );
  }

  Widget _buildContent(RosterState state) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 32),
                      _buildUploadArea(state),
                      const SizedBox(height: 24),
                      if (state is RosterProcessing || state is RosterUploading)
                        _buildProcessingIndicator(state),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.go(AppRouter.home),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'Upload Roster',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upload Your Flight Roster',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Take a photo or upload a document (PDF, Excel, image) of your flight roster. Our AI will extract flight details and analyze sleep & meal opportunities.',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withValues(alpha: 0.7),
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildUploadArea(RosterState state) {
    final isProcessing = state is RosterUploading || state is RosterProcessing;

    if (_selectedFile == null) {
      return _buildUploadOptions(isProcessing);
    } else {
      return _buildFilePreview(isProcessing);
    }
  }

  Widget _buildUploadOptions(bool isProcessing) {
    return Container(
      width: double.infinity,
      height: 350,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF14B8A6).withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.upload_file,
              size: 50,
              color: Color(0xFF14B8A6),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Upload Roster Document',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Take a photo or select document',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildUploadButton(
                icon: Icons.camera_alt,
                label: 'Camera',
                onTap: isProcessing ? null : _takePhoto,
              ),
              _buildUploadButton(
                icon: Icons.folder_open,
                label: 'Documents',
                onTap: isProcessing ? null : _pickDocument,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUploadButton({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF14B8A6).withOpacity(onTap != null ? 0.2 : 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(
              0xFF14B8A6,
            ).withOpacity(onTap != null ? 0.5 : 0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: Color(0xFF14B8A6).withOpacity(onTap != null ? 1.0 : 0.5),
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF14B8A6).withOpacity(onTap != null ? 1.0 : 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilePreview(bool isProcessing) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF14B8A6).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF14B8A6).withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF14B8A6),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(_getFileIcon(), color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedFile!.path.split('/').last,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isProcessing ? 'Processing...' : 'Ready to process',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!isProcessing)
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _selectedFile = null;
                        });
                      },
                      icon: Icon(
                        Icons.close,
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                    ),
                ],
              ),
              if (!isProcessing) ...[
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _processRoster,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF14B8A6),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.analytics, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Process Roster',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProcessingIndicator(RosterState state) {
    String message = 'Processing...';
    if (state is RosterUploading) {
      message = 'Uploading roster image...';
    } else if (state is RosterProcessing) {
      message = 'Extracting flight data using AI...';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B5CF6)),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This may take a few moments...',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _takePhoto() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _selectedFile = File(image.path);
        });
      }
    } catch (e) {
      _showErrorMessage('Failed to take photo: ${e.toString()}');
    }
  }

  Future<void> _pickDocument() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          'pdf',
          'xlsx',
          'xls',
          'doc',
          'docx',
          'jpg',
          'jpeg',
          'png',
        ],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedFile = File(result.files.single.path!);
        });
      }
    } catch (e) {
      _showErrorMessage('Failed to pick document: ${e.toString()}');
    }
  }

  void _processRoster() {
    if (_selectedFile != null) {
      print('Processing roster button pressed'); // Debug log

      // Show immediate feedback
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Starting roster processing...'),
          backgroundColor: Color(0xFF14B8A6),
          duration: Duration(seconds: 2),
        ),
      );

      context.read<RosterBloc>().add(UploadRosterEvent(_selectedFile!));

      // Add a timeout as a safety measure
      Timer(const Duration(seconds: 10), () {
        if (mounted) {
          final currentState = context.read<RosterBloc>().state;
          if (currentState is RosterUploading ||
              currentState is RosterProcessing) {
            print('Processing timeout - showing error'); // Debug log
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Processing timeout. Please try again.'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      });
    }
  }

  IconData _getFileIcon() {
    if (_selectedFile == null) return Icons.description;

    final fileName = _selectedFile!.path.toLowerCase();
    final extension = fileName.split('.').last;

    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'xlsx':
      case 'xls':
        return Icons.table_chart;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}
