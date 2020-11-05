abstract class ImageInput {
  const ImageInput();

  bool get supportSync;

  int get length;

  Future<int> get lengthAsync async => length;

  List<int> getRange(int start, int end);

  Future<List<int>> getRangeAsync(int start, int end) async {
    return getRange(start, end);
  }

  bool exists();

  Future<bool> existsAsync() async {
    return exists();
  }
}
