import '../../../../core/auth/token_storage.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login({required String email, required String password});
  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient dioClient;
  final TokenStorage tokenStorage;

  AuthRemoteDataSourceImpl({
    required this.dioClient,
    required this.tokenStorage,
  });

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
      final user = UserModel.fromJson(response.data as Map<String, dynamic>);
      await tokenStorage.saveTokens(
        accessToken: user.accessToken,
        refreshToken: user.refreshToken,
      );
      return user;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> logout() async {
    try {
      await dioClient.post('/auth/logout');
    } finally {
      await tokenStorage.clearTokens();
    }
  }
}
