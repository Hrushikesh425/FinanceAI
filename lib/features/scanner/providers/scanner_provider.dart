import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finance_ai/core/services/ai_scanner_service.dart';

// IMPORTANT: Replace this with the actual Gemini API key provided by the user.
// In a production app, this should be fetched securely from a backend or remote config.
const String _geminiApiKey = 'YOUR_GEMINI_API_KEY_HERE';

final aiScannerServiceProvider = Provider<AIScannerService>((ref) {
  return AIScannerService(apiKey: _geminiApiKey);
});
