const { readCSV, writeCSV } = require('../utils/csvHelper');

const staffFileName = 'staff.csv';
const staffHeaders = ['id', 'name', 'email', 'department', 'bio'];

const normalizeStaff = (staff) => ({
  id: String(staff.id),
  name: staff.name ?? '',
  email: staff.email ?? '',
  department: staff.department ?? '',
  bio: staff.bio ?? '',
});

const getAllStaff = async (_req, res) => {
  try {
    const staff = await readCSV(staffFileName);
    return res.json({ success: true, data: staff.map(normalizeStaff) });
  } catch (error) {
    return res.status(500).json({ success: false, message: 'Failed to fetch staff records.' });
  }
};

const getStaffById = async (req, res) => {
  try {
    const staff = await readCSV(staffFileName);
    const foundStaff = staff.find((member) => String(member.id) === String(req.params.id));

    if (!foundStaff) {
      return res.status(404).json({ success: false, message: 'Staff member not found.' });
    }

    return res.json({ success: true, data: normalizeStaff(foundStaff) });
  } catch (error) {
    return res.status(500).json({ success: false, message: 'Failed to fetch staff member.' });
  }
};

const createStaff = async (req, res) => {
  try {
    const { name = '', email = '', department = '', bio = '' } = req.body;

    if (!name.trim() || !email.trim() || !department.trim() || !bio.trim()) {
      return res.status(400).json({
        success: false,
        message: 'name, email, department, and bio are required.',
      });
    }

    const staff = await readCSV(staffFileName);
    const newStaff = {
      id: String(Date.now()),
      name: name.trim(),
      email: email.trim(),
      department: department.trim(),
      bio: bio.trim(),
    };

    staff.push(newStaff);
    await writeCSV(staffFileName, staff, staffHeaders);

    return res.status(201).json({ success: true, message: 'Staff member created.', data: newStaff });
  } catch (error) {
    return res.status(500).json({ success: false, message: 'Failed to create staff member.' });
  }
};

const updateStaff = async (req, res) => {
  try {
    const staff = await readCSV(staffFileName);
    const staffIndex = staff.findIndex((member) => String(member.id) === String(req.params.id));

    if (staffIndex === -1) {
      return res.status(404).json({ success: false, message: 'Staff member not found.' });
    }

    const currentStaff = staff[staffIndex];
    const updatedStaff = {
      id: String(currentStaff.id),
      name: req.body.name !== undefined ? String(req.body.name).trim() : currentStaff.name,
      email: req.body.email !== undefined ? String(req.body.email).trim() : currentStaff.email,
      department:
        req.body.department !== undefined ? String(req.body.department).trim() : currentStaff.department,
      bio: req.body.bio !== undefined ? String(req.body.bio).trim() : currentStaff.bio,
    };

    if (!updatedStaff.name || !updatedStaff.email || !updatedStaff.department || !updatedStaff.bio) {
      return res.status(400).json({
        success: false,
        message: 'name, email, department, and bio cannot be empty.',
      });
    }

    staff[staffIndex] = updatedStaff;
    await writeCSV(staffFileName, staff, staffHeaders);

    return res.json({ success: true, message: 'Staff member updated.', data: updatedStaff });
  } catch (error) {
    return res.status(500).json({ success: false, message: 'Failed to update staff member.' });
  }
};

const deleteStaff = async (req, res) => {
  try {
    const staff = await readCSV(staffFileName);
    const filteredStaff = staff.filter((member) => String(member.id) !== String(req.params.id));

    if (filteredStaff.length === staff.length) {
      return res.status(404).json({ success: false, message: 'Staff member not found.' });
    }

    await writeCSV(staffFileName, filteredStaff, staffHeaders);

    return res.json({ success: true, message: 'Staff member deleted.' });
  } catch (error) {
    return res.status(500).json({ success: false, message: 'Failed to delete staff member.' });
  }
};

module.exports = {
  getAllStaff,
  getStaffById,
  createStaff,
  updateStaff,
  deleteStaff,
};
