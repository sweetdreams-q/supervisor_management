const { readCSV } = require('../utils/csvHelper');
const { sendError } = require('../utils/errorHelpers');

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

const matchesInterestQuery = (interest, query) => {
  const normalizedQuery = query.trim().toLowerCase();

  if (!normalizedQuery) {
    return true;
  }

  const title = String(interest.title ?? '').toLowerCase();
  const description = String(interest.description ?? '').toLowerCase();

  return title.includes(normalizedQuery) || description.includes(normalizedQuery);
};

const getStudentStaffView = async (req, res) => {
  try {
    const [staff, interests, projects] = await Promise.all([
      readCSV(staffFileName),
      readCSV(interestsFileName),
      readCSV(projectsFileName),
    ]);

    const interestQuery = String(req.query.interest ?? '').trim();

    const mergedData = staff
      .map((member) => {
        const staffId = String(member.id);
        const staffInterests = interests
          .filter((interest) => String(interest.staffId) === staffId)
          .map(normalizeInterest);
        const matchingInterests = staffInterests.filter((interest) => matchesInterestQuery(interest, interestQuery));

        return {
          staffProfile: normalizeStaff(member),
          areasOfInterest: matchingInterests,
          projectIdeas: projects
            .filter((project) => String(project.staffId) === staffId)
            .map(normalizeProject),
        };
      })
      .filter((entry) => {
        if (!interestQuery) {
          return true;
        }

        return entry.areasOfInterest.length > 0;
      });

    return res.json({ success: true, data: mergedData });
  } catch (error) {
    return sendError(res, 500, error.userMessage || 'Failed to fetch student staff data.', error, 'studentController.getStudentStaffView');
  }
};

module.exports = {
  getStudentStaffView,
};
