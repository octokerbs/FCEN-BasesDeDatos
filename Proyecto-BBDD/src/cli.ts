import { readFile } from 'node:fs/promises';
import { Client } from 'pg';

async function readAndParseCSV(filePath) {
    const contents = await readFile(filePath, { encoding: 'utf8' });
    const header = contents.split(/\r?\n/)[0];
    const columns = header.split(',').map(col => col.trim());
    const dataLines = contents.split(/\r?\n/).slice(1).filter(line => line.trim() !== '');
    return { dataLines, columns };
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

async function getFirstStudentThatNeedsCertificate(pgClient) {
    const sql = `SELECT *
    FROM aida.alumnos
    WHERE titulo IS NOT NULL AND titulo_en_tramite IS NOT NULL
    ORDER BY egreso
	LIMIT 1`;
    const res = await pgClient.query(sql)
    if (res.rows.length > 0) {
        return res.rows[0];
    } else {
        return null;
    }
}

async function generateStudentCertificate(pgClient, student) {
    console.log('student', student);
}

async function main() {
    const pgClient = new Client()
    const filePath = `resources/alumnos.csv`;
    await pgClient.connect()

    var { dataLines: studentLineArray, columns } = await readAndParseCSV(filePath)
    await refreshStudentTableFromCSV(pgClient, studentLineArray, columns)

    var student = await getFirstStudentThatNeedsCertificate(pgClient)

    if (student == null) {
        console.log('No hay estudiantes que necesiten certificado')
    } else {
        await generateStudentCertificate(pgClient, student)
    }
    await pgClient.end()
}

main();