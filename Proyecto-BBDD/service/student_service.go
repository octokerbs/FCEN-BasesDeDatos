package service

import (
	"database/sql"
	"fmt"
	"log"
	"strings"

	"github.com/octokerbs/Proyecto-BBDD/models"
)

func RefreshStudentTableFromCSV(db *sql.DB, studentLines [][]string, columns []string) error {
	_, err := db.Exec("DELETE FROM aida.alumnos")
	if err != nil {
		return fmt.Errorf("error deleting records: %w", err)
	}

	for _, line := range studentLines {
		if len(line) == 0 || (len(line) == 1 && strings.TrimSpace(line[0]) == "") {
			continue
		}

		placeholders := make([]string, len(columns))
		args := make([]interface{}, len(line))
		for i, value := range line {
			placeholders[i] = fmt.Sprintf("$%d", i+1)
			if strings.TrimSpace(value) == "" {
				args[i] = nil
			} else {
				args[i] = strings.TrimSpace(value)
			}
		}

		query := fmt.Sprintf(
			"INSERT INTO aida.alumnos (%s) VALUES (%s)",
			strings.Join(columns, ", "),
			strings.Join(placeholders, ", "),
		)

		if _, err := db.Exec(query, args...); err != nil {
			log.Printf("Error inserting record: %v", err)
			continue
		}
	}

	return nil
}

func GetFirstStudentThatNeedsCertificate(db *sql.DB) (*models.Student, error) {
	query := `SELECT *
	FROM aida.alumnos
	WHERE titulo IS NOT NULL AND titulo_en_tramite IS NOT NULL
	ORDER BY egreso
	LIMIT 1`

	var alumno models.Student
	row := db.QueryRow(query)

	err := row.Scan(
		&alumno.LU,
		&alumno.Apellido,
		&alumno.Nombre,
		&alumno.Titulo,
		&alumno.TituloEnTramite,
		&alumno.Egreso,
	)

	if err != nil {
		if err == sql.ErrNoRows {
			return nil, nil
		}
		return nil, fmt.Errorf("error querying database: %w", err)
	}

	return &alumno, nil
}

func GenerateStudentCertificate(student *models.Student) error {
	fmt.Printf("student: %+v\n", student)
	return nil
}
