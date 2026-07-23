const fs = require('fs');
const path = require('path');
const { parse, format } = require('fast-csv');
const { logError } = require('./errorHelpers');

const dataDirectory = path.resolve(__dirname, '../../data');

class CsvOperationError extends Error {
  constructor(operation, fileName, cause) {
    super(`Unable to ${operation} ${fileName}.`);
    this.name = 'CsvOperationError';
    this.operation = operation;
    this.fileName = fileName;
    this.userMessage = 'Data storage is temporarily unavailable. Please try again later.';
    this.cause = cause;
  }
}

const readCSV = (fileName) =>
  new Promise((resolve, reject) => {
    const records = [];
    const filePath = path.join(dataDirectory, fileName);

    fs.createReadStream(filePath)
      .on('error', (error) => {
        const wrappedError = new CsvOperationError('read', fileName, error);
        logError(`csvHelper.readCSV:${fileName}`, wrappedError);
        reject(wrappedError);
      })
      .pipe(parse({ headers: true, ignoreEmpty: true }))
      .on('error', (error) => {
        const wrappedError = new CsvOperationError('read', fileName, error);
        logError(`csvHelper.readCSV:${fileName}`, wrappedError);
        reject(wrappedError);
      })
      .on('data', (row) => {
        records.push(row);
      })
      .on('end', () => {
        resolve(records);
      });
  });

const writeCSV = (fileName, rows, headers) =>
  new Promise((resolve, reject) => {
    const filePath = path.join(dataDirectory, fileName);
    const output = fs.createWriteStream(filePath);
    const csvStream = format({ headers });

    csvStream
      .on('error', (error) => {
        const wrappedError = new CsvOperationError('write', fileName, error);
        logError(`csvHelper.writeCSV:${fileName}`, wrappedError);
        reject(wrappedError);
      })
      .pipe(output)
      .on('finish', resolve)
      .on('error', (error) => {
        const wrappedError = new CsvOperationError('write', fileName, error);
        logError(`csvHelper.writeCSV:${fileName}`, wrappedError);
        reject(wrappedError);
      });

    rows.forEach((row) => {
      csvStream.write(row);
    });

    csvStream.end();
  });

module.exports = {
  readCSV,
  writeCSV,
  CsvOperationError,
};
