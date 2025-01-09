import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:machine_test/models/photo_model.dart';

class PhotoProvider with ChangeNotifier {
  final String _apiKey = 'cU_tciD7JnRM3sOk165nk85rigyWE0VCiarJLCqphIc';
  final String _baseUrl = 'https://api.unsplash.com/photos';
  final List<Welcome> _photos = [];
  int _page = 1;
  bool _isLoading = false;

  List<Welcome> get photos => _photos;
  bool get isLoading => _isLoading;
  Future<void> fetchPhotos() async {
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      final url = Uri.parse('$_baseUrl?page=$_page&per_page=20');
      final response = await http.get(url, headers: {
        'Authorization': 'Client-ID $_apiKey',
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List<dynamic>;
        final List<Welcome> loadedPhotos = [];

        for (var item in data) {
          try {
            loadedPhotos.add(Welcome.fromJson(item));
          } catch (e) {
            print('Error parsing photo: $e');

            continue;
          }
        }

        _photos.addAll(loadedPhotos);
        _page++;
      } else {
        throw Exception('Failed to load photos');
      }
    } catch (e) {
      print('Error fetching photos: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
