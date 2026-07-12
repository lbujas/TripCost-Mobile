import 'package:travel_cost_planner_europe/data/local/hive_service.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_template.dart';

/// Local data source for user-created packing templates stored in Hive.
class UserPackingTemplateLocalSource {
  UserPackingTemplateLocalSource(this._hiveService);

  final HiveService _hiveService;

  Future<List<PackingTemplate>> getAll({required bool includeDeleted}) async {
    return _readAll(includeDeleted: includeDeleted);
  }

  Future<PackingTemplate?> getById(String id) async {
    final raw = _hiveService.packingTemplatesBox.get(id);
    return _parseRecord(raw);
  }

  Future<void> put(PackingTemplate template) async {
    await _hiveService.packingTemplatesBox.put(template.id, template.toJson());
  }

  List<PackingTemplate> _readAll({required bool includeDeleted}) {
    final templates = <PackingTemplate>[];

    for (final key in _hiveService.packingTemplatesBox.keys) {
      final raw = _hiveService.packingTemplatesBox.get(key);
      final template = _parseRecord(raw);
      if (template == null) {
        continue;
      }

      if (!includeDeleted && template.deletedAt != null) {
        continue;
      }

      templates.add(template);
    }

    templates.sort((a, b) {
      final left =
          a.updatedAt ?? a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final right =
          b.updatedAt ?? b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return right.compareTo(left);
    });

    return templates;
  }

  PackingTemplate? _parseRecord(Object? raw) {
    if (raw is! Map) {
      return null;
    }

    try {
      return PackingTemplate.fromJson(Map<String, dynamic>.from(raw));
    } catch (_) {
      return null;
    }
  }
}
