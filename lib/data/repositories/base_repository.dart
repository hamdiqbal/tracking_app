import 'package:get/get.dart';

abstract class BaseRepository<T> extends GetxService {
  Future<List<T>> getAll();
  Future<T?> getById(String id);
  Future<String> create(T item);
  Future<bool> update(T item);
  Future<bool> delete(String id);
  Future<void> clear();
}
