import { readFile } from 'node:fs/promises';
import { Client } from 'pg';

async function readAndParseCSV(filePath) {
    const contents = await readFile(filePath, { encoding: 'utf8' });
    const header = contents.split(/\r?\n/)[0];
    const columns = header.split(',').map(col => col.trim());
    const dataLines = contents.split(/\r?\n/).slice(1).filter(line => line.trim() !== '');
    return { dataLines, columns };

}

async function getFirstStudentThatNeedsCertificate(pgClient) {

}

async function refreshStudentTableFromCSV(pgClient, studentLinesArray, columns) {
    await pgClient.query("DELETE FROM aida.alumnos");
    for (const line of studentLinesArray) {
        const values = line.split(',');
        const query = `
        INSERT INTO aida.alumnos (${columns.join(', ')}) VALUES 
            (${values.map((value) => value == '' ? 'null' : `'` + value + `'`).join(', ')})
    `;
        console.log(query)
        const res = await pgClient.query(query)
        console.log(res.command, res.rowCount)
    }
}

async function main() {
    const pgClient = new Client()
    const filePath = `resources/alumnos.csv`;

    await pgClient.connect()

    var { dataLines: studentLineArray, columns } = await readAndParseCSV(filePath)
    await refreshStudentTableFromCSV(pgClient, studentLineArray, columns)
    await pgClient.end()
}

main();