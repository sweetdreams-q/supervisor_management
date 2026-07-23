const fs = require('fs');
const path = require('path');
const { parse, format } = require('fast-csv');

const dataDirectory = path.resolve(__dirname, '../../data');

const readCSV = (fileName) =>
  new Promise((resolve, reject) => {
    const records = [];
    const filePath = path.join(dataDirectory, fileName);

    fs.createReadStream(filePath)
      .on('error', reject)
      .pipe(parse({ headers: true, ignoreEmpty: true }))
      .on('error', reject)
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
      .on('error', reject)
      .pipe(output)
      .on('finish', resolve)
      .on('error', reject);

    rows.forEach((row) => {
      csvStream.write(row);
    });

    csvStream.end();
  });

module.exports = {
  readCSV,
  writeCSV,
};
