import '../models/user.dart';
import 'base_repository.dart';

class UserRepository implements BaseRepository<User> {
  @override
  Future<User> get(String id) async {
    await Future.delayed(const Duration(seconds: 1));
    return User(
      id: id,
      email: '',
      nickname: '',
      profileImageUrl: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      rentals: [],
    );
  }

  @override
  Future<List<User>> getAll() async {
    await Future.delayed(const Duration(seconds: 1));
    return [];
  }

  @override
  Future<User> create(User user) async {
    await Future.delayed(const Duration(seconds: 1));
    return user;
  }

  @override
  Future<User> update(User user) async {
    await Future.delayed(const Duration(seconds: 1));
    return user;
  }

  @override
  Future<void> delete(String id) async {
    await Future.delayed(const Duration(seconds: 1));
  }

  Future<User> getByEmail(String email) async {
    await Future.delayed(const Duration(seconds: 1));
    return User(
      id: '',
      email: email,
      nickname: '',
      profileImageUrl: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      rentals: [],
    );
  }
}
