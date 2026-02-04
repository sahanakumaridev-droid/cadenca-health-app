import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

import '../../../../core/theme/app_theme.dart';
import '../bloc/roster_bloc.dart';
import '../bloc/roster_event.dart';
import '../bloc/roster_state.dart';
import '../widgets/flight_plan_card.dart';
import '../widgets/upload_roster_button.dart';

class RosterPage extends StatefulWidget {
  const RosterPage({super.key});

  @override
  State<RosterPage> createState() => _RosterPageState();
}

class _RosterPageState extends State<RosterPage> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  final PageController _pageController = PageController();
  int _currentFlightIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    // Load any existing roster data
    context.read<RosterBloc>().add(LoadRosterDataEvent());
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.cadencaBrandVerticalGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 16),

              // Header
              FadeTransition(opacity: _fadeAnimation, child: _buildHeader()),

              const SizedBox(height: 24),

              // Content
              Expanded(
                child: BlocBuilder<RosterBloc, RosterState>(
                  builder: (context, state) {
                    if (state is RosterUploading) {
                      return _buildUploadingState();
                    } else if (state is RosterProcessed &&
                        state.flights.isNotEmpty) {
                      return _buildFlightPlansView(state);
                    } else if (state is RosterError) {
                      return _buildErrorState(state.message);
                    } else {
                      return _buildEmptyState();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.flight, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Flight Roster',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Upload and manage your flight schedules',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.upload_file_outlined,
                    size: 48,
                    color: AppTheme.primaryGreen,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'No Flight Plans Yet',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.darkText,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Upload your roster to see your flight plans and get personalized recommendations',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: AppTheme.lightText),
                ),
                const SizedBox(height: 24),
                _buildUploadOptions(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadOptions() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _pickImageFromCamera,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.camera_alt_outlined),
            label: const Text(
              'Take Photo',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _pickImageFromGallery,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppTheme.primaryGreen,
              side: const BorderSide(color: AppTheme.primaryGreen),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.photo_library_outlined),
            label: const Text(
              'Choose Photo',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _pickFile,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppTheme.primaryGreen,
              side: const BorderSide(color: AppTheme.primaryGreen),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.attach_file_outlined),
            label: const Text(
              'Upload File',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUploadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
          SizedBox(height: 16),
          Text(
            'Processing your roster...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 48,
                  color: AppTheme.mutedRed,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Upload Failed',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.darkText,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: AppTheme.lightText),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      context.read<RosterBloc>().add(ClearRosterDataEvent());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Try Again',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlightPlansView(RosterProcessed state) {
    final flights = state.flights;
    final today = DateTime.now();

    // Separate flights into past, today, and future
    final pastFlights = flights
        .where((f) => f.departureTime.isBefore(today))
        .toList();
    final todayFlights = flights
        .where(
          (f) =>
              f.departureTime.day == today.day &&
              f.departureTime.month == today.month &&
              f.departureTime.year == today.year,
        )
        .toList();

    return Column(
      children: [
        // Navigation controls
        if (flights.isNotEmpty) _buildNavigationControls(flights.length),

        const SizedBox(height: 16),

        // Flight cards
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentFlightIndex = index;
              });
            },
            itemCount: flights.length,
            itemBuilder: (context, index) {
              final flight = flights[index];
              final isPast = pastFlights.contains(flight);
              final isToday = todayFlights.contains(flight);

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: FlightPlanCard(
                  flight: flight,
                  isPast: isPast,
                  isToday: isToday,
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 16),

        // Upload roster button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: UploadRosterButton(
            onPressed: () {
              _showUploadOptions();
            },
          ),
        ),

        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildNavigationControls(int totalFlights) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: _currentFlightIndex > 0
                ? () {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                : null,
            icon: const Icon(Icons.chevron_left, color: Colors.white),
          ),

          ElevatedButton(
            onPressed: _goToToday,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text('Today'),
          ),

          IconButton(
            onPressed: _currentFlightIndex < totalFlights - 1
                ? () {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                : null,
            icon: const Icon(Icons.chevron_right, color: Colors.white),
          ),
        ],
      ),
    );
  }

  void _goToToday() {
    final state = context.read<RosterBloc>().state;
    if (state is RosterProcessed) {
      final today = DateTime.now();
      final todayIndex = state.flights.indexWhere(
        (f) =>
            f.departureTime.day == today.day &&
            f.departureTime.month == today.month &&
            f.departureTime.year == today.year,
      );

      if (todayIndex != -1) {
        _pageController.animateToPage(
          todayIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  void _showUploadOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Upload New Roster',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppTheme.darkText,
              ),
            ),
            const SizedBox(height: 20),
            _buildUploadOptions(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImageFromCamera() async {
    Navigator.of(context).pop(); // Close bottom sheet
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      final file = File(pickedFile.path);
      context.read<RosterBloc>().add(UploadRosterEvent(file));
    }
  }

  Future<void> _pickImageFromGallery() async {
    Navigator.of(context).pop(); // Close bottom sheet
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final file = File(pickedFile.path);
      context.read<RosterBloc>().add(UploadRosterEvent(file));
    }
  }

  Future<void> _pickFile() async {
    Navigator.of(context).pop(); // Close bottom sheet
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      context.read<RosterBloc>().add(UploadRosterEvent(file));
    }
  }
}
