import 'package:dio/dio.dart';
import 'package:untitled17/user_model.dart';

class ApiService {
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: 'http://10.0.2.2:8000/api',
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  );

  Future<Response> register(User user) async {
    try {
      final response = await dio.post(
        '/register',
        data: user.toJson(),
      );
      return response;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
          'Server error: ${e.response?.statusCode} - ${e.response?.data}',
        );
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }
}