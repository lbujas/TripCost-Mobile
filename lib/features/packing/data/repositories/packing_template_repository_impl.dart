import 'package:travel_cost_planner_europe/features/packing/data/sources/system_packing_template_source.dart';
import 'package:travel_cost_planner_europe/features/packing/data/sources/user_packing_template_local_source.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_template.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/repositories/packing_template_repository.dart';

class PackingTemplateRepositoryImpl implements PackingTemplateRepository {
  PackingTemplateRepositoryImpl(this._systemSource, this._userSource);

  final SystemPackingTemplateSource _systemSource;
  final UserPackingTemplateLocalSource _userSource;

  @override
  Future<List<PackingTemplate>> getSystemTemplates() {
    return _systemSource.getAll();
  }

  @override
  Future<List<PackingTemplate>> getUserTemplates() {
    return _userSource.getAll(includeDeleted: false);
  }

  @override
  Future<List<PackingTemplate>> getAllTemplates() async {
    final system = await getSystemTemplates();
    final user = await getUserTemplates();
    return [...system, ...user];
  }

  @override
  Future<PackingTemplate?> getTemplateById(String id) async {
    final systemTemplates = await _systemSource.getAll();
    for (final template in systemTemplates) {
      if (template.id == id) {
        return template;
      }
    }

    final userTemplate = await _userSource.getById(id);
    if (userTemplate == null || userTemplate.deletedAt != null) {
      return null;
    }

    return userTemplate;
  }

  @override
  Future<void> saveUserTemplate(PackingTemplate template) async {
    if (template.isSystem) {
      throw StateError('System templates are read-only');
    }

    final existing = await _userSource.getById(template.id);
    final now = DateTime.now().toUtc();

    await _userSource.put(
      PackingTemplate(
        id: template.id,
        customName: template.customName,
        customDescription: template.customDescription,
        iconKey: template.iconKey,
        isSystem: false,
        items: template.items,
        createdAt: existing?.createdAt ?? template.createdAt ?? now,
        updatedAt: now,
        deletedAt: null,
      ),
    );
  }

  @override
  Future<void> softDeleteUserTemplate(String id) async {
    final existing = await _requireUserTemplate(id);
    final now = DateTime.now().toUtc();

    await _userSource.put(
      PackingTemplate(
        id: existing.id,
        customName: existing.customName,
        customDescription: existing.customDescription,
        iconKey: existing.iconKey,
        isSystem: false,
        items: existing.items,
        createdAt: existing.createdAt,
        updatedAt: now,
        deletedAt: now,
      ),
    );
  }

  @override
  Future<void> restoreUserTemplate(String id) async {
    final existing = await _requireUserTemplate(id);
    final now = DateTime.now().toUtc();

    await _userSource.put(
      PackingTemplate(
        id: existing.id,
        customName: existing.customName,
        customDescription: existing.customDescription,
        iconKey: existing.iconKey,
        isSystem: false,
        items: existing.items,
        createdAt: existing.createdAt,
        updatedAt: now,
      ),
    );
  }

  Future<PackingTemplate> _requireUserTemplate(String id) async {
    final template = await _userSource.getById(id);
    if (template == null) {
      throw StateError('User template not found: $id');
    }

    if (template.isSystem) {
      throw StateError('System templates are read-only');
    }

    return template;
  }
}
