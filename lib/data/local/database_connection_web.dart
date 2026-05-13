import 'package:drift/drift.dart';
import 'package:drift/web.dart';

QueryExecutor constructDbConnection() {
  return WebDatabase('reparto_offline_web');
}