import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login({required String email, required String password});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient dioClient;

  AuthRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await dioClient.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      return UserModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
