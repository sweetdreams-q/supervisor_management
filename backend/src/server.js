const app = require('./app');
const { logError } = require('./utils/errorHelpers');

const PORT = process.env.PORT || 5000;

process.on('unhandledRejection', (error) => logError('server.unhandledRejection', error));
process.on('uncaughtException', (error) => logError('server.uncaughtException', error));

app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});
