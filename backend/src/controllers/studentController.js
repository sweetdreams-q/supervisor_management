const { readCSV } = require('../utils/csvHelper');

const staffFileName = 'staff.csv';
const interestsFileName = 'interests.csv';
const projectsFileName = 'projects.csv';

const normalizeStaff = (staff) => ({
  id: String(staff.id),
  name: staff.name ?? '',
  email: staff.email ?? '',
  department: staff.department ?? '',
  bio: staff.bio ?? '',
});

const normalizeInterest = (interest) => ({
  id: String(interest.id),
  staffId: String(interest.staffId),
  title: interest.title ?? '',
  description: interest.description ?? '',
});

const normalizeProject = (project) => ({
  id: String(project.id),
  staffId: String(project.staffId),
  title: project.title ?? '',
  description: project.description ?? '',
  tags: project.tags ?? '',
});

const getStudentStaffView = async (_req, res) => {
  try {
    const [staff, interests, projects] = await Promise.all([
      readCSV(staffFileName),
      readCSV(interestsFileName),
      readCSV(projectsFileName),
    ]);

    const mergedData = staff.map((member) => {
      const staffId = String(member.id);

      return {
        staffProfile: normalizeStaff(member),
        areasOfInterest: interests
          .filter((interest) => String(interest.staffId) === staffId)
          .map(normalizeInterest),
        projectIdeas: projects
          .filter((project) => String(project.staffId) === staffId)
          .map(normalizeProject),
      };
    });

    return res.json({ success: true, data: mergedData });
  } catch (error) {
    return res.status(500).json({ success: false, message: 'Failed to fetch student staff data.' });
  }
};

module.exports = {
  getStudentStaffView,
};
