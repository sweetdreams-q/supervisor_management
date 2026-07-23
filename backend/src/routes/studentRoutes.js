const express = require('express');
const { getStudentStaffView } = require('../controllers/studentController');

const router = express.Router();

router.get('/staff', getStudentStaffView);

module.exports = router;
