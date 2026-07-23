class ApiConstants {
  static String baseUrl = 'http://localhost:5000';

  static String staffList = '/staff';
  static String staffById(String id) => '/staff/$id';
  static String addStaff = '/staff';
  static String updateStaff(String id) => '/staff/$id';
  static String deleteStaff(String id) => '/staff/$id';
  static String studentsStaff = '/students/staff';
  static String staffInterests(String staffId) => '/staff/$staffId/interests';
  static String staffProjects(String staffId) => '/staff/$staffId/projects';

  static String addInterest = '/staff/interest';
  static String updateInterest(String id) => '/staff/interest/$id';
  static String deleteInterest(String id) => '/staff/interest/$id';

  static String addProject = '/staff/project';
  static String updateProject(String id) => '/staff/project/$id';
  static String deleteProject(String id) => '/staff/project/$id';
}
