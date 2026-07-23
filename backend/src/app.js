const express = require('express');
const cors = require('cors');
const staffRoutes = require('./routes/staffRoutes');
const interestRoutes = require('./routes/interestRoutes');

const app = express();

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use('/staff', staffRoutes);
app.use('/staff', interestRoutes);

module.exports = app;
