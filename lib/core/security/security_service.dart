import 'package:enhanced_jailbreak_root_detection/enhanced_jailbreak_root_detection.dart';
import 'package:snug_logger/snug_logger.dart';

// Three booleans the rest of the app cares about — no raw detection types leak out.
class SecurityResult {
  final bool isCompromised;
  final bool isEmulator;
  final List<String> detectedIssues;

  const SecurityResult({
    required this.isCompromised,
    required this.isEmulator,
    required this.detectedIssues,
  });
}

// Single chokepoint for detection. If the package API changes, only this file breaks.
class SecurityService {
  Future<SecurityResult> check() async {
    try {
      final detection = EnhancedJailbreakRootDetection.instance;

      final isJailBroken = await detection.isJailBroken;
      final isNotTrust = await detection.isNotTrust;
      final isRealDevice = await detection.isRealDevice;
      final issues = await detection.checkForIssues;

      final isCompromised = isJailBroken || isNotTrust;
      final isEmulator = !isRealDevice;
      final detectedIssues = issues.map((issue) => issue.name).toList();

      return SecurityResult(
        isCompromised: isCompromised,
        isEmulator: isEmulator,
        detectedIssues: detectedIssues,
      );
    } catch (e, s) {
      snugLog(
        'Security check failed: $e',
        logType: LogType.error,
        stackTrace: s,
      );
      // Fail open — do not block the app on a detection error.
      return const SecurityResult(
        isCompromised: false,
        isEmulator: false,
        detectedIssues: [],
      );
    }
  }
}
