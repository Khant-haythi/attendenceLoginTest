// api_client.dart
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  static final Dio dio = Dio(BaseOptions(
    baseUrl: 'http://172.20.214.75:7007/api/',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  static final FlutterSecureStorage storage = const FlutterSecureStorage();

  static void setup() {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await storage.read(key: 'accessToken');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          final refreshToken = await storage.read(key: 'refreshToken');
          if (error.response?.statusCode == 401 && refreshToken != null) {
            try {
              final response = await Dio().post(
                'http://172.20.214.75:7007/api/accounts/refresh',
                data: {'refreshToken': refreshToken},
              );

              final newAccessToken = response.data['accessToken'];
              final newRefreshToken = response.data['refreshToken'];

              await storage.write(key: 'accessToken', value: newAccessToken);
              await storage.write(key: 'refreshToken', value: newRefreshToken);

              final clonedRequest = error.requestOptions;
              clonedRequest.headers['Authorization'] = 'Bearer $newAccessToken';

              final retryResponse = await Dio().fetch(clonedRequest);
              return handler.resolve(retryResponse);
            } catch (e) {
              return handler.next(error);
            }
          } else {
            return handler.next(error);
          }
        },
      ),
    );
  }
}
