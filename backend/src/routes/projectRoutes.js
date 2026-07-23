const express = require('express');
const {
  getProjectsByStaffId,
  createProject,
  updateProject,
  deleteProject,
} = require('../controllers/projectController');

const router = express.Router();

router.get('/:id/projects', getProjectsByStaffId);
router.post('/project', createProject);
router.put('/project/:id', updateProject);
router.delete('/project/:id', deleteProject);

module.exports = router;
