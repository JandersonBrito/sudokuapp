import '../../../../core/network/dio_client.dart';
import '../models/item_model.dart';

abstract class HomeRemoteDataSource {
  Future<List<ItemModel>> getItems();
  Future<ItemModel> getItemById(String id);
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final DioClient dioClient;
  HomeRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<List<ItemModel>> getItems() async {
    final response = await dioClient.get('/items');
    final data = response.data as List<dynamic>;
    return data.map((json) => ItemModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<ItemModel> getItemById(String id) async {
    final response = await dioClient.get('/items/$id');
    return ItemModel.fromJson(response.data as Map<String, dynamic>);
  }
}
