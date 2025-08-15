import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';


class CheckImage extends StatefulWidget {
  final XFile imageFile;

  const CheckImage({super.key, required this.imageFile});

  @override
  State<CheckImage> createState() => _CheckImageState();
}

class _CheckImageState extends State<CheckImage> {
  String _analysisResult = "사진 분석을 시작하려면 버튼을 눌러주세요.";
  bool _isLoading = false;

  Future<void> _analyzeImage() async {
    setState(() {
      _isLoading = true;
      _analysisResult = "분석 중입니다...";
    });

    try {
      Uint8List imageBytes = await widget.imageFile.readAsBytes();
      String base64Image = base64Encode(imageBytes);

      final apiKey = dotenv.env['GeminiApi'];
      final apiUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-preview-05-20:generateContent?key=$apiKey';

      final chatHistory = [
        {
          "role": "user",
          "parts": [
            {"text": "이 사진을 보고 대기 현상(구름 종류, 기상 상태, 대기 오염 여부 등)을 상세하게 분석해 줘. 한글로 대답해 줘."},
            {
              "inlineData": {
                "mimeType": "image/png",
                "data": base64Image
              }
            }
          ]
        }
      ];

      final payload = {
        "contents": chatHistory,
      };

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        final text = result['candidates'][0]['content']['parts'][0]['text'];
        setState(() {
          _analysisResult = text;
        });
      } else {
        setState(() {
          _analysisResult = "API 호출 중 오류가 발생했습니다: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        _analysisResult = "오류: $e";
      });
      print(e);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("사진 분석"),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FutureBuilder<Uint8List>(
                future: widget.imageFile.readAsBytes(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                    return Center(
                      child: Image.memory(snapshot.data!),
                    );
                  } else if (snapshot.hasError) {
                    return Center(child: Text('이미지 로드 중 오류: ${snapshot.error}'));
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _analyzeImage,
                child: const Text('AI로 사진 분석하기'),
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          _analysisResult,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    ),
              const SizedBox(height: 20),
              if (!_isLoading)
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('완료'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}