import '../configs/enums.dart';

UserRole mapRole(String roleId) {
  switch (roleId) {
    case 'role-admin':
      return UserRole.admin;
    case 'role-venue-admin':
      return UserRole.venueAdmin;
    default:
      return UserRole.customer;
  }
}
