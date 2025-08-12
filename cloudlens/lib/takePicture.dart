import 'package:flutter/material.dart';

// 로그인 화면을 구성하는 위젯 (페이지 역할을 함)
// 이 위젯은 MaterialApp을 반환하지 않고, Scaffold를 반환합니다.
class Takepicture extends StatelessWidget {
  const Takepicture({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login", style: TextStyle(fontFamily: 'sbAgroB')),
        leading: IconButton(
          onPressed: () {
            // 이전 화면으로 돌아가기
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Center(
        child: Image.network(
          "https://firebase.google.com/static/images/brand-guidelines/logo-vertical.png",
        ),
      ),
    );
  }
}
