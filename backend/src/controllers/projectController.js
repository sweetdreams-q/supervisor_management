const { readCSV, writeCSV } = require('../utils/csvHelper');

const staffFileName = 'staff.csv';
const projectsFileName = 'projects.csv';
const projectsHeaders = ['id', 'staffId', 'title', 'description', 'tags'];

const normalizeProject = (project) => ({
  id: String(project.id),
  staffId: String(project.staffId),
  title: project.title ?? '',
  description: project.description ?? '',
  tags: project.tags ?? '',
});

const staffExists = async (staffId) => {
  const staff = await readCSV(staffFileName);
  return staff.some((member) => String(member.id) === String(staffId));
};

const getProjectsByStaffId = async (req, res) => {
  try {
    const [staff, projects] = await Promise.all([readCSV(staffFileName), readCSV(projectsFileName)]);
    const foundStaff = staff.find((member) => String(member.id) === String(req.params.id));

    if (!foundStaff) {
      return res.status(404).json({ success: false, message: 'Staff member not found.' });
    }

    const staffProjects = projects
      .filter((project) => String(project.staffId) === String(req.params.id))
      .map(normalizeProject);

    return res.json({ success: true, data: staffProjects });
  } catch (error) {
    return res.status(500).json({ success: false, message: 'Failed to fetch staff projects.' });
  }
};

const createProject = async (req, res) => {
  try {
    const { staffId = '', title = '', description = '', tags = '' } = req.body;

    if (!String(staffId).trim() || !String(title).trim() || !String(description).trim() || !String(tags).trim()) {
      return res.status(400).json({
        success: false,
        message: 'staffId, title, description, and tags are required.',
      });
    }

    const validStaff = await staffExists(staffId);

    if (!validStaff) {
      return res.status(404).json({ success: false, message: 'Staff member not found.' });
    }

    const projects = await readCSV(projectsFileName);
    const newProject = {
      id: String(Date.now()),
      staffId: String(staffId).trim(),
      title: String(title).trim(),
      description: String(description).trim(),
      tags: String(tags).trim(),
    };

    projects.push(newProject);
    await writeCSV(projectsFileName, projects, projectsHeaders);

    return res.status(201).json({ success: true, message: 'Project created.', data: newProject });
  } catch (error) {
    return res.status(500).json({ success: false, message: 'Failed to create project.' });
  }
};

const updateProject = async (req, res) => {
  try {
    const projects = await readCSV(projectsFileName);
    const projectIndex = projects.findIndex((project) => String(project.id) === String(req.params.id));

    if (projectIndex === -1) {
      return res.status(404).json({ success: false, message: 'Project not found.' });
    }

    const currentProject = projects[projectIndex];
    const nextStaffId = req.body.staffId !== undefined ? String(req.body.staffId).trim() : String(currentProject.staffId);
    const nextTitle = req.body.title !== undefined ? String(req.body.title).trim() : String(currentProject.title);
    const nextDescription =
      req.body.description !== undefined ? String(req.body.description).trim() : String(currentProject.description);
    const nextTags = req.body.tags !== undefined ? String(req.body.tags).trim() : String(currentProject.tags);

    if (!nextStaffId || !nextTitle || !nextDescription || !nextTags) {
      return res.status(400).json({
        success: false,
        message: 'staffId, title, description, and tags cannot be empty.',
      });
    }

    const validStaff = await staffExists(nextStaffId);

    if (!validStaff) {
      return res.status(404).json({ success: false, message: 'Staff member not found.' });
    }

    const updatedProject = {
      id: String(currentProject.id),
      staffId: nextStaffId,
      title: nextTitle,
      description: nextDescription,
      tags: nextTags,
    };

    projects[projectIndex] = updatedProject;
    await writeCSV(projectsFileName, projects, projectsHeaders);

    return res.json({ success: true, message: 'Project updated.', data: updatedProject });
  } catch (error) {
    return res.status(500).json({ success: false, message: 'Failed to update project.' });
  }
};

const deleteProject = async (req, res) => {
  try {
    const projects = await readCSV(projectsFileName);
    const filteredProjects = projects.filter((project) => String(project.id) !== String(req.params.id));

    if (filteredProjects.length === projects.length) {
      return res.status(404).json({ success: false, message: 'Project not found.' });
    }

    await writeCSV(projectsFileName, filteredProjects, projectsHeaders);

    return res.json({ success: true, message: 'Project deleted.' });
  } catch (error) {
    return res.status(500).json({ success: false, message: 'Failed to delete project.' });
  }
};

module.exports = {
  getProjectsByStaffId,
  createProject,
  updateProject,
  deleteProject,
};
