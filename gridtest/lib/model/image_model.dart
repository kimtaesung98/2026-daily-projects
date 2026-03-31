import 'package:flutter/material.dart';
import 'base_node.dart';
import '../screen/image_detail_screen.dart';

class ImageNode extends BaseNode {
  @override
  final String title;

  // 이미지 소스 데이터 (네트워크 URL 또는 로컬 경로)
  final String imageUrl;

  ImageNode({
    required this.title,
    // 기반 묘사를 위한 디폴트 이미지 (Placeholder)
    this.imageUrl = "https://picsum.photos/800/600", 
  });

  @override
  Widget buildDetailScreen(BuildContext context) {
    // 본인의 모델 데이터를 가지고 전용 스크린을 생성
    return ImageDetailScreen(node: this);
  }
}