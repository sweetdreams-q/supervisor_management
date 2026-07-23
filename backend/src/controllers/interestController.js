const { readCSV, writeCSV } = require('../utils/csvHelper');

const staffFileName = 'staff.csv';
const interestsFileName = 'interests.csv';
const interestsHeaders = ['id', 'staffId', 'title', 'description'];

const normalizeInterest = (interest) => ({
  id: String(interest.id),
  staffId: String(interest.staffId),
  title: interest.title ?? '',
  description: interest.description ?? '',
});

const staffExists = async (staffId) => {
  const staff = await readCSV(staffFileName);
  return staff.some((member) => String(member.id) === String(staffId));
};

const getInterestsByStaffId = async (req, res) => {
  try {
    const [staff, interests] = await Promise.all([readCSV(staffFileName), readCSV(interestsFileName)]);
    const foundStaff = staff.find((member) => String(member.id) === String(req.params.id));

    if (!foundStaff) {
      return res.status(404).json({ success: false, message: 'Staff member not found.' });
    }

    const staffInterests = interests
      .filter((interest) => String(interest.staffId) === String(req.params.id))
      .map(normalizeInterest);

    return res.json({ success: true, data: staffInterests });
  } catch (error) {
    return res.status(500).json({ success: false, message: 'Failed to fetch staff interests.' });
  }
};

const createInterest = async (req, res) => {
  try {
    const { staffId = '', title = '', description = '' } = req.body;

    if (!String(staffId).trim() || !String(title).trim() || !String(description).trim()) {
      return res.status(400).json({
        success: false,
        message: 'staffId, title, and description are required.',
      });
    }

    const validStaff = await staffExists(staffId);

    if (!validStaff) {
      return res.status(404).json({ success: false, message: 'Staff member not found.' });
    }

    const interests = await readCSV(interestsFileName);
    const newInterest = {
      id: String(Date.now()),
      staffId: String(staffId).trim(),
      title: String(title).trim(),
      description: String(description).trim(),
    };

    interests.push(newInterest);
    await writeCSV(interestsFileName, interests, interestsHeaders);

    return res.status(201).json({ success: true, message: 'Interest created.', data: newInterest });
  } catch (error) {
    return res.status(500).json({ success: false, message: 'Failed to create interest.' });
  }
};

const updateInterest = async (req, res) => {
  try {
    const interests = await readCSV(interestsFileName);
    const interestIndex = interests.findIndex((interest) => String(interest.id) === String(req.params.id));

    if (interestIndex === -1) {
      return res.status(404).json({ success: false, message: 'Interest not found.' });
    }

    const currentInterest = interests[interestIndex];
    const nextStaffId = req.body.staffId !== undefined ? String(req.body.staffId).trim() : String(currentInterest.staffId);
    const nextTitle = req.body.title !== undefined ? String(req.body.title).trim() : String(currentInterest.title);
    const nextDescription =
      req.body.description !== undefined ? String(req.body.description).trim() : String(currentInterest.description);

    if (!nextStaffId || !nextTitle || !nextDescription) {
      return res.status(400).json({
        success: false,
        message: 'staffId, title, and description cannot be empty.',
      });
    }

    const validStaff = await staffExists(nextStaffId);

    if (!validStaff) {
      return res.status(404).json({ success: false, message: 'Staff member not found.' });
    }

    const updatedInterest = {
      id: String(currentInterest.id),
      staffId: nextStaffId,
      title: nextTitle,
      description: nextDescription,
    };

    interests[interestIndex] = updatedInterest;
    await writeCSV(interestsFileName, interests, interestsHeaders);

    return res.json({ success: true, message: 'Interest updated.', data: updatedInterest });
  } catch (error) {
    return res.status(500).json({ success: false, message: 'Failed to update interest.' });
  }
};

const deleteInterest = async (req, res) => {
  try {
    const interests = await readCSV(interestsFileName);
    const filteredInterests = interests.filter((interest) => String(interest.id) !== String(req.params.id));

    if (filteredInterests.length === interests.length) {
      return res.status(404).json({ success: false, message: 'Interest not found.' });
    }

    await writeCSV(interestsFileName, filteredInterests, interestsHeaders);

    return res.json({ success: true, message: 'Interest deleted.' });
  } catch (error) {
    return res.status(500).json({ success: false, message: 'Failed to delete interest.' });
  }
};

module.exports = {
  getInterestsByStaffId,
  createInterest,
  updateInterest,
  deleteInterest,
};
