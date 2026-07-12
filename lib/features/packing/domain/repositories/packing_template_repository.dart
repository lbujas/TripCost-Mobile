import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_template.dart';

abstract class PackingTemplateRepository {
  Future<List<PackingTemplate>> getSystemTemplates();

  Future<List<PackingTemplate>> getUserTemplates();

  Future<List<PackingTemplate>> getAllTemplates();

  Future<PackingTemplate?> getTemplateById(String id);

  Future<void> saveUserTemplate(PackingTemplate template);

  Future<void> softDeleteUserTemplate(String id);

  Future<void> restoreUserTemplate(String id);
}
