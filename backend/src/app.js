const express = require('express');
const cors = require('cors');
const staffRoutes = require('./routes/staffRoutes');
const interestRoutes = require('./routes/interestRoutes');
const projectRoutes = require('./routes/projectRoutes');
const studentRoutes = require('./routes/studentRoutes');

const app = express();

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use('/staff', staffRoutes);
app.use('/staff', interestRoutes);
app.use('/staff', projectRoutes);
app.use('/students', studentRoutes);

module.exports = app;
