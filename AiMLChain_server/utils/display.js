const Table = require("cli-table");

const defaultTable = new Table({
  style: { head: ["cyanBright"] },
  head: ["Request Id", "Challenge", "Difficulty"],
  colWidths: [12, 75, 15],
});

function displayTable({ id, challenge, difficulty }) {
  defaultTable.pop();
  defaultTable.push([id, challenge, difficulty]);
  console.log(defaultTable.toString());
}

const defaultTable2 = new Table({
  style: { head: ["cyanBright"] },
  head: ["Request Id", "Prediction", "Operation Hash"],
  colWidths: [12, 12, 60],
});

function displayTablePredResult({ id, prediction, ophash }) {
  defaultTable2.pop();
  defaultTable2.push([id, prediction, ophash]);
  console.log(defaultTable2.toString());
}

module.exports = {displayTable, displayTablePredResult};
