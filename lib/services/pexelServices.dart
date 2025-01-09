import 'dart:convert';
import 'package:http/http.dart' as http;

class PexelsService {
  static const String _baseUrl = 'https://api.unsplash.com/photos';
  static const String _apiKey = 'cU_tciD7JnRM3sOk165nk85rigyWE0VCiarJLCqphIc';

  Future<List<dynamic>> fetchPhotos(int page, int perPage) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/curated?page=$page&per_page=$perPage'),
      headers: {'Authorization': _apiKey},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['photos'];
    } else {
      throw Exception('Failed to load photos');
    }
  }
}