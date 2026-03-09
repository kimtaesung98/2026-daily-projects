import '../../models/machine_model.dart';
import '../datasources/machine_remote_datasource.dart';

class MachineRepository {

  final MachineRemoteDataSource _dataSource;

  MachineRepository(this._dataSource);

  Future<List<MachineModel>> getMachineStatuses() async {

    try {

      final rawData = await _dataSource.fetchRawFactoryData();

      return rawData
          .map((json) => MachineModel.fromJson(json))
          .toList();

    } catch (e) {

      print("Repository Error: $e");
      rethrow;

    }
  }
}