import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  static const apiKey = 'AIzaSyDw9o6y-1mK72_MXFnpsYNZKLPrR45dgh4';
  late final GenerativeModel _model;

  GeminiService() {
    _model = GenerativeModel(
      model: 'gemini-pro',
      apiKey: apiKey,
    );
  }

  Future<String> getChatResponse(String prompt) async {
    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      return response.text ?? 'Sorry, I could not generate a response.';
    } catch (e) {
      return 'Error: $e';
    }
  }
}