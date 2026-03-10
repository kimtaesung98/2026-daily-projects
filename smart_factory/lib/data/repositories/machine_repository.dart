// lib/data/repositories/machine_repository.dart
import '../datasources/machine_remote_datasource.dart';
import '../models/machine_model.dart';

class MachineRepository {
  final MachineRemoteDataSource _dataSource;
  MachineRepository(this._dataSource);

  Future<List<MachineModel>> getMachineStatuses() async {
    try {
      // 데이터 소스에서 날것의 데이터를 가져옴
      final List<Map<String, dynamic>> rawData = await _dataSource.fetchRawFactoryData();
      
      // JSON(Map) 데이터를 MachineModel 객체로 변환 (Mapping)
      return rawData.map((json) => MachineModel.fromJson(json)).toList();
    } catch (e) {
      // 여기서 에러를 기록하거나, 앱 특화 에러로 변환하여 던집니다.
      throw Exception("데이터를 불러오는 중 오류가 발생했습니다: $e");
    }
  }
}