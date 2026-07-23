const logError = (scope, error) => {
  const details = error instanceof Error ? error.stack || error.message : error;
  console.error(`[${scope}]`, details);
};

const sendError = (res, statusCode, userMessage, error, scope) => {
  logError(scope, error);
  return res.status(statusCode).json({
    success: false,
    message: userMessage,
  });
};

module.exports = {
  logError,
  sendError,
};