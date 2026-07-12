import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_template.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/repositories/packing_template_repository.dart';

class FakePackingTemplateRepository implements PackingTemplateRepository {
  FakePackingTemplateRepository({
    List<PackingTemplate>? systemTemplates,
    List<PackingTemplate>? userTemplates,
    this.systemLoadError,
    this.userLoadError,
  }) : systemTemplates = List<PackingTemplate>.from(
         systemTemplates ?? const [],
       ),
       userTemplates = List<PackingTemplate>.from(userTemplates ?? const []);

  List<PackingTemplate> systemTemplates;
  List<PackingTemplate> userTemplates;
  Object? systemLoadError;
  Object? userLoadError;

  int getSystemTemplatesCallCount = 0;
  int getUserTemplatesCallCount = 0;

  @override
  Future<List<PackingTemplate>> getAllTemplates() async {
    final system = await getSystemTemplates();
    final user = await getUserTemplates();
    return [...system, ...user];
  }

  @override
  Future<PackingTemplate?> getTemplateById(String id) async {
    for (final template in [...systemTemplates, ...userTemplates]) {
      if (template.id == id) {
        return template;
      }
    }
    return null;
  }

  @override
  Future<List<PackingTemplate>> getSystemTemplates() async {
    getSystemTemplatesCallCount++;
    if (systemLoadError != null) {
      throw systemLoadError!;
    }
    return List<PackingTemplate>.from(systemTemplates);
  }

  @override
  Future<List<PackingTemplate>> getUserTemplates() async {
    getUserTemplatesCallCount++;
    if (userLoadError != null) {
      throw userLoadError!;
    }
    return userTemplates
        .where((template) => template.deletedAt == null)
        .toList();
  }

  @override
  Future<void> restoreUserTemplate(String id) async {}

  @override
  Future<void> saveUserTemplate(PackingTemplate template) async {}

  @override
  Future<void> softDeleteUserTemplate(String id) async {}
}
