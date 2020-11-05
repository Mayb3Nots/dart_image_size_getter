import 'image_size_getter.dart';
import 'dart:io';

class IONetImageInput extends ImageInput {
  final String url;

  IONetImageInput(this.url);

  HttpHeaders headers;

  int length;

  bool supportPartRequest;

  @override
  bool exists() {
    throw UnimplementedError();
  }

  @override
  List<int> getRange(int start, int end) {
    throw UnimplementedError();
  }

  @override
  Future<bool> existsAsync() async {
    final client = HttpClient();
    final request = await client.headUrl(Uri.parse(url));
    final response = await request.close();
    this.headers = response.headers;

    length = headers.contentLength;

    final result = response.statusCode >= 200 && response.statusCode < 300;

    final partTest = await client.headUrl(Uri.parse(url));
    partTest.headers.add('Range', 'bytes=0-2');
    final partResponse = await partTest.close();
    supportPartRequest = partResponse.statusCode == 206;

    client.close();

    return result;
  }

  @override
  Future<List<int>> getRangeAsync(int start, int end) {
    if (supportPartRequest) {
      return _partRequest(start, end);
    }
    return null;
  }

  Future<List<int>> _partRequest(int start, int end) async {
    final client = HttpClient();

    final request = await client.headUrl(Uri.parse(url));
    request.headers.add('Range', 'bytes=$start-$end');
    final response = await request.close();

    final all = await response.toList();
    List<int> buffer = <int>[];
    all.forEach((element) {
      buffer.addAll(element);
    });

    client.close();

    return buffer;
  }

  @override
  bool get supportSync => false;
}
