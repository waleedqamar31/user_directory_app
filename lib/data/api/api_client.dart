import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const String _baseUrl = 'https://dummyjson.com';
  static const Duration _timeout = Duration(seconds: 10);

  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final uri = Uri.parse(
        '$_baseUrl$endpoint',
      ).replace(queryParameters: queryParameters);

      final response = await _client
          .get(uri, headers: const {'Accept': 'application/json'})
          .timeout(_timeout);

      return _handleResponse(response);
    } on SocketException {
      throw const NetworkException(
        'No Internet Connection. Please check you connection and try again.',
      );
    }
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
        final decodedBody = jsonDecode(response.body);
        if (decodedBody is! Map<String, dynamic>) {
          throw const DataParsingException('Unexcepted response format');
        }
        return decodedBody;
      case 404:
        throw const NotFoundException('The request resource was not found.');
      case 500:
      case 502:
      case 503:
        throw const ServerException(
          'Server is currently unavailable.. Please Try again later',
        );
      default:
        throw ApiException(
          'Request failed with status code ${response.statusCode}',
        );
    }
  }

  void dispose() {
    _client.close();
  }
}

class ApiException implements Exception {
  const ApiException(this.message);
  final String message;

  @override
  String toString() => message;
}

class NetworkException extends ApiException {
  const NetworkException(super.message);
}

class DataParsingException extends ApiException {
  const DataParsingException(super.message);
}

class NotFoundException extends ApiException {
  const NotFoundException(super.message);
}

class ServerException extends ApiException {
  const ServerException(super.message);
}
