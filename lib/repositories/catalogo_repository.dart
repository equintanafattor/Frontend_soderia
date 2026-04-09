import 'package:drift/drift.dart' show Value;
import '../data/local/app_database.dart';
import '../data/remote/catalogo_api.dart';

class CatalogoRepository {
  final AppDatabase db;
  final CatalogoApi api;

  CatalogoRepository({required this.db, required this.api});

  Future<void> bootstrapCatalogo({int? idListaInicial}) async {
    final listasResp = await api.listarListas();
    final listas = List<Map<String, dynamic>>.from(listasResp.data ?? const []);

    final listasActivas = listas.where((l) {
      return (l['estado'] ?? '').toString().toLowerCase().trim() == 'activo';
    }).toList();

    final idLista =
        idListaInicial ??
        (listasActivas.isNotEmpty
            ? (listasActivas.first['id_lista'] as num).toInt()
            : null);

    final mediosResp = await api.listarMediosPago();
    final medios = List<Map<String, dynamic>>.from(mediosResp.data ?? const []);

    List<Map<String, dynamic>> items = [];
    if (idLista != null) {
      final itemsResp = await api.listarItemsDeLista(idLista);
      items = List<Map<String, dynamic>>.from(itemsResp.data ?? const []);
    }

    await db.transaction(() async {
      await db.delete(db.listasPreciosLocales).go();
      await db.delete(db.precioItemsLocales).go();
      await db.delete(db.mediosPagoLocales).go();

      for (final l in listas) {
        await db
            .into(db.listasPreciosLocales)
            .insert(
              ListasPreciosLocalesCompanion(
                idLista: Value((l['id_lista'] as num).toInt()),
                nombre: Value((l['nombre'] ?? '').toString()),
                estado: Value(l['estado']?.toString()),
                updatedAt: Value(DateTime.now()),
              ),
            );
      }

      for (final i in items) {
        await db
            .into(db.precioItemsLocales)
            .insert(
              PrecioItemsLocalesCompanion(
                tipo: Value((i['tipo'] ?? '').toString()),
                idItem: Value((i['id_item'] as num).toInt()),
                nombre: Value((i['nombre'] ?? '').toString()),
                precio: Value(_toDouble(i['precio'])),
                estado: Value(i['estado']?.toString()),
              ),
            );
      }

      for (final mp in medios) {
        await db
            .into(db.mediosPagoLocales)
            .insert(
              MediosPagoLocalesCompanion(
                idMedioPago: Value((mp['id_medio_pago'] as num).toInt()),
                nombre: Value((mp['nombre'] ?? '').toString()),
              ),
            );
      }
    });
  }

  Future<List<ListasPreciosLocale>> obtenerListasLocales() {
    return db.select(db.listasPreciosLocales).get();
  }

  Future<List<PrecioItemsLocale>> obtenerItemsDeListaLocal() {
    return db.select(db.precioItemsLocales).get();
  }

  Future<List<MediosPagoLocale>> obtenerMediosPagoLocales() {
    return db.select(db.mediosPagoLocales).get();
  }

  double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }
}
