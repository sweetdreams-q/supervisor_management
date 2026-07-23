const express = require('express');
const {
  getInterestsByStaffId,
  createInterest,
  updateInterest,
  deleteInterest,
} = require('../controllers/interestController');

const router = express.Router();

router.get('/:id/interests', getInterestsByStaffId);
router.post('/interest', createInterest);
router.put('/interest/:id', updateInterest);
router.delete('/interest/:id', deleteInterest);

module.exports = router;
