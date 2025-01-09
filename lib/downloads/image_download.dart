import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

Future<void> DownloadPhoto(String url, BuildContext context) async {
  try {
    print('Starting download process...');
    print('URL to download: $url');

    if (Platform.isAndroid) {
      print('Checking Android version and permissions...');
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      final androidVersion = int.parse(androidInfo.version.release);

      if (androidVersion >= 13) {
        print('Android 13+ detected, requesting specific permissions...');
        final photos = await Permission.photos.request();
        final videos = await Permission.videos.request();

        if (photos.isDenied || videos.isDenied) {
          print('Media permissions denied');
          throw 'Media permissions required';
        }
      } else {
        print('Android 12 or below detected, requesting storage permission...');
        final storage = await Permission.storage.request();
        if (storage.isDenied) {
          print('Storage permission denied');
          throw 'Storage permission required';
        }
      }
      print('Required permissions granted');
    }

    Directory? directory;
    if (Platform.isAndroid) {
      print('Setting up Android download directory...');
      directory = Directory('/storage/emulated/0/Download');
      print('Android directory path: ${directory.path}');
    } else {
      print('Setting up iOS documents directory...');
      directory = await getApplicationDocumentsDirectory();
      print('iOS directory path: ${directory.path}');
    }

    print('Checking if directory exists...');
    final directoryExists = await directory.exists();
    print('Directory exists: $directoryExists');

    if (!directoryExists) {
      print('Creating directory...');
      await directory.create(recursive: true);
      print('Directory created successfully');
    }

    print('Starting file download...');
    final dio = Dio();
    final response = await dio.get(
      url,
      options: Options(responseType: ResponseType.bytes),
    );
    print('Download completed. Response status: ${response.statusCode}');
    print('Downloaded data size: ${response.data.length} bytes');

    final fileName = 'image_${DateTime.now().millisecondsSinceEpoch}.png';
    final filePath = '${directory.path}${Platform.pathSeparator}$fileName';
    print('File will be saved as: $filePath');

    final file = File(filePath);
    await file.writeAsBytes(response.data);
    print('File written successfully');

    final fileExists = await file.exists();
    print('Verifying file exists: $fileExists');
    if (fileExists) {
      final fileSize = await file.length();
      print('Saved file size: $fileSize bytes');
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Image saved to: ${directory.path}'),
        duration: const Duration(seconds: 2),
      ),
    );
    print('Process completed successfully');
  } catch (e) {
    print('Error occurred during download process: $e');
    print('Stack trace: ${StackTrace.current}');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  }
}
