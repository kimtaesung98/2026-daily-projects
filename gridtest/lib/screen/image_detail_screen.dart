import 'package:flutter/material.dart';
import 'models.dart';

class ImageDetailScreen extends StatelessWidget {
  final ImageNode node;
  const ImageDetailScreen({super.key, required this.node});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(node.title)),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 이미지 로딩 처리 및 출력
              Image.network(
                node.imageUrl,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const CircularProgressIndicator();
                },
                errorBuilder: (context, error, stackTrace) => 
                  const Icon(Icons.broken_image, size: 100),
              ),
              const SizedBox(height: 20),
              Text("SOURCE: ${node.imageUrl}", style: const TextStyle(fontSize: 10)),
            ],
          ),
        ),
      ),
    );
  }
}