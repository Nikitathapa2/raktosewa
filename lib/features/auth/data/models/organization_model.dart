import 'package:hive/hive.dart';
import '../../domain/entities/organization.dart';

part 'organization_model.g.dart';

@HiveType(typeId: 1)
class OrganizationModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String email;

  @HiveField(3)
  final String phone;

  @HiveField(4)
  final String address;

  @HiveField(5)
  final String password;

  OrganizationModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.password,
  });

  factory OrganizationModel.fromEntity(Organization organization) {
    return OrganizationModel(
      id: organization.id,
      name: organization.name,
      email: organization.email,
      phone: organization.phone,
      address: organization.address,
      password: organization.password,
    );
  }

  Organization toEntity() {
    return Organization(
      id: id,
      name: name,
      email: email,
      phone: phone,
      address: address,
      password: password,
    );
  }
}
