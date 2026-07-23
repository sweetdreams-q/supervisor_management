const express = require('express');
const cors = require('cors');
const staffRoutes = require('./routes/staffRoutes');
const interestRoutes = require('./routes/interestRoutes');
const projectRoutes = require('./routes/projectRoutes');
const studentRoutes = require('./routes/studentRoutes');
const { logError } = require('./utils/errorHelpers');

const app = express();

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use('/staff', staffRoutes);
app.use('/staff', interestRoutes);
app.use('/staff', projectRoutes);
app.use('/students', studentRoutes);

app.use((error, _req, res, _next) => {
	if (error instanceof SyntaxError && error.status === 400 && 'body' in error) {
		logError('app.invalidJson', error);
		return res.status(400).json({
			success: false,
			message: 'Invalid JSON payload. Please review your request and try again.',
		});
	}

	logError('app.unhandledError', error);
	return res.status(500).json({
		success: false,
		message: 'The server encountered an unexpected error.',
	});
});

module.exports = app;
