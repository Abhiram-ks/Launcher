import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:minilauncher/core/common/custom_appbar.dart';
import 'package:minilauncher/core/service/app_usage_service.dart';
import 'package:minilauncher/core/themes/app_colors.dart';
import 'package:minilauncher/features/model/data/app_usage_prefs.dart';

/// Test screen to verify usage monitoring is working
/// Add this to your settings or debug menu
class UsageMonitoringTestScreen extends StatefulWidget {
  const UsageMonitoringTestScreen({super.key});

  @override
  State<UsageMonitoringTestScreen> createState() => _UsageMonitoringTestScreenState();
}

class _UsageMonitoringTestScreenState extends State<UsageMonitoringTestScreen> {
  bool _hasPermission = false;
  bool _isMonitoring = false;
  int _timeLimit = 1; // 1 minute for testing
  String? _currentApp;
  List<String> _notifiedApps = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _checkStatus();
    
    // Auto-refresh every 5 seconds
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 5));
      if (mounted) {
        _checkStatus(silent: true);
        return true;
      }
      return false;
    });
  }

  Future<void> _checkStatus({bool silent = false}) async {
    if (!silent) setState(() => _loading = true);

    try {
      final hasPermission = await AppUsageService.hasUsagePermission();
      final isMonitoring = await AppUsageService.isMonitoringRunning();
      final timeLimit = await AppUsagePrefs().getTimeLimit();
      final currentApp = await AppUsageService.getCurrentForegroundApp();
      final notifiedApps = await AppUsagePrefs().getNotifiedApps();

      if (mounted) {
        setState(() {
          _hasPermission = hasPermission;
          _isMonitoring = isMonitoring;
          _timeLimit = timeLimit;
          _currentApp = currentApp;
          _notifiedApps = notifiedApps;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        _showError('Error: $e');
      }
    }
  }

  Future<void> _startMonitoring() async {
    try {
      if (!_hasPermission) {
        await AppUsageService.requestUsagePermission();
        await Future.delayed(const Duration(seconds: 2));
        await _checkStatus();
        if (!_hasPermission) {
          _showError('Permission not granted');
          return;
        }
      }

      await AppUsagePrefs().setTimeLimit(_timeLimit);
      await AppUsageService.startMonitoring(_timeLimit);
      await AppUsagePrefs().setMonitoringEnabled(true);

      _showSuccess('Monitoring started with $_timeLimit min limit');
      await _checkStatus();
    } catch (e) {
      _showError('Failed to start: $e');
    }
  }

  Future<void> _stopMonitoring() async {
    try {
      await AppUsageService.stopMonitoring();
      await AppUsagePrefs().setMonitoringEnabled(false);
      _showSuccess('Monitoring stopped');
      await _checkStatus();
    } catch (e) {
      _showError('Failed to stop: $e');
    }
  }

  Future<void> _resetNotifications() async {
    try {
      await AppUsagePrefs().clearNotifiedApps();
      _showSuccess('Notifications reset');
      await _checkStatus();
    } catch (e) {
      _showError('Failed to reset: $e');
    }
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppPalette.greenColor,
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Usage Monitoring Test',
        isTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildStatusCard(),
                const SizedBox(height: 16),
                _buildTimeLimitCard(),
                const SizedBox(height: 16),
                _buildCurrentAppCard(),
                const SizedBox(height: 16),
                _buildNotifiedAppsCard(),
                const SizedBox(height: 16),
                _buildControlButtons(),
                const SizedBox(height: 24),
                _buildInstructions(),
              ],
            ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      color: AppPalette.greyColor.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'System Status',
              style: GoogleFonts.roboto(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppPalette.whiteColor,
              ),
            ),
            const SizedBox(height: 12),
            _buildStatusRow(
              'Permission Granted',
              _hasPermission,
              _hasPermission ? CupertinoIcons.check_mark_circled_solid : CupertinoIcons.xmark_circle_fill,
            ),
            const SizedBox(height: 8),
            _buildStatusRow(
              'Monitoring Running',
              _isMonitoring,
              _isMonitoring ? CupertinoIcons.play_circle_fill : CupertinoIcons.pause_circle_fill,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, bool isActive, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: isActive ? AppPalette.greenColor : AppPalette.orengeColor,
          size: 24,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.roboto(
              fontSize: 16,
              color: AppPalette.whiteColor.withValues(alpha: 0.9),
            ),
          ),
        ),
        Text(
          isActive ? 'ON' : 'OFF',
          style: GoogleFonts.roboto(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isActive ? AppPalette.greenColor : AppPalette.orengeColor,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeLimitCard() {
    return Card(
      color: AppPalette.greyColor.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Time Limit',
              style: GoogleFonts.roboto(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppPalette.whiteColor,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: _timeLimit.toDouble(),
                    min: 1,
                    max: 10,
                    divisions: 9,
                    label: '$_timeLimit min',
                    activeColor: AppPalette.orengeColor,
                    onChanged: (value) {
                      setState(() => _timeLimit = value.toInt());
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppPalette.orengeColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$_timeLimit min',
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppPalette.orengeColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentAppCard() {
    return Card(
      color: AppPalette.greyColor.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  CupertinoIcons.device_phone_portrait,
                  color: AppPalette.whiteColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Current Foreground App',
                  style: GoogleFonts.roboto(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppPalette.whiteColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppPalette.orengeColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _currentApp ?? 'None detected',
                style: GoogleFonts.robotoMono(
                  fontSize: 14,
                  color: AppPalette.whiteColor.withValues(alpha: 0.9),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotifiedAppsCard() {
    return Card(
      color: AppPalette.greyColor.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  CupertinoIcons.bell_fill,
                  color: AppPalette.whiteColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Notified Apps Today',
                    style: GoogleFonts.roboto(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppPalette.whiteColor,
                    ),
                  ),
                ),
                Text(
                  '${_notifiedApps.length}',
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppPalette.orengeColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_notifiedApps.isEmpty)
              Text(
                'No apps notified yet',
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  color: AppPalette.whiteColor.withValues(alpha: 0.6),
                ),
              )
            else
              ..._notifiedApps.map((app) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        const Icon(
                          CupertinoIcons.check_mark_circled,
                          color: AppPalette.greenColor,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            app,
                            style: GoogleFonts.robotoMono(
                              fontSize: 12,
                              color: AppPalette.whiteColor.withValues(alpha: 0.8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButtons() {
    return Column(
      children: [
        if (!_isMonitoring)
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _startMonitoring,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppPalette.greenColor,
                foregroundColor: AppPalette.whiteColor,
              ),
              child: Text(
                'Start Monitoring',
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          )
        else
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _stopMonitoring,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: AppPalette.whiteColor,
              ),
              child: Text(
                'Stop Monitoring',
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton(
            onPressed: _resetNotifications,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppPalette.orengeColor),
              foregroundColor: AppPalette.orengeColor,
            ),
            child: Text(
              'Reset Notified Apps',
              style: GoogleFonts.roboto(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton(
            onPressed: () => _checkStatus(),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppPalette.whiteColor.withValues(alpha: 0.5)),
              foregroundColor: AppPalette.whiteColor,
            ),
            child: Text(
              'Refresh Status',
              style: GoogleFonts.roboto(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInstructions() {
    return Card(
      color: AppPalette.orengeColor.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  CupertinoIcons.info_circle_fill,
                  color: AppPalette.orengeColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Test Instructions',
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppPalette.orengeColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInstructionStep('1', 'Set time limit to 1 minute (for testing)'),
            _buildInstructionStep('2', 'Grant usage permission if needed'),
            _buildInstructionStep('3', 'Start monitoring'),
            _buildInstructionStep('4', 'Open Instagram/WhatsApp/any app'),
            _buildInstructionStep('5', 'Use it for 1+ minutes'),
            _buildInstructionStep('6', 'You should receive a notification!'),
            const SizedBox(height: 12),
            Text(
              '💡 The service checks every 30 seconds. Logs are visible in Android Logcat (filter: UsageMonitorService)',
              style: GoogleFonts.roboto(
                fontSize: 12,
                color: AppPalette.whiteColor.withValues(alpha: 0.7),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppPalette.orengeColor.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: GoogleFonts.roboto(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppPalette.orengeColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.roboto(
                fontSize: 14,
                color: AppPalette.whiteColor.withValues(alpha: 0.9),
              ),
            ),
          ),
        ],
      ),
    );
  }
}