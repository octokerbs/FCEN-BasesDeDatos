package main

import (
	"database/sql"
	"encoding/csv"
	"fmt"
	"log"
	"os"
	"strings"

	_ "github.com/lib/pq"
)

type Student struct {
	ID          int    `db:"id"`
	Name        string `db:"nombre"`
	Title       string `db:"titulo"`
	TitleStatus string `db:"titulo_en_tramite"`
	Graduation  string `db:"egreso"`
}

func readAndParseCSV(filePath string) ([][]string, []string, error) {
	file, err := os.Open(filePath)
	if err != nil {
		return nil, nil, fmt.Errorf("error opening file: %w", err)
	}
	defer file.Close()

	reader := csv.NewReader(file)
	records, err := reader.ReadAll()
	if err != nil {
		return nil, nil, fmt.Errorf("error reading CSV: %w", err)
	}

	if len(records) == 0 {
		return nil, nil, fmt.Errorf("CSV file is empty")
	}

	columns := make([]string, len(records[0]))
	for i, col := range records[0] {
		columns[i] = strings.TrimSpace(col)
	}

	dataLines := records[1:]

	return dataLines, columns, nil
}

func refreshStudentTableFromCSV(db *sql.DB, studentLinesArray [][]string, columns []string) error {
	_, err := db.Exec("DELETE FROM aida.alumnos")
	if err != nil {
		return fmt.Errorf("error deleting records: %w", err)
	}

	for _, line := range studentLinesArray {
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

		fmt.Println(query)

		result, err := db.Exec(query, args...)
		if err != nil {
			log.Printf("Error inserting record: %v", err)
			continue
		}

		rowsAffected, _ := result.RowsAffected()
		fmt.Printf("INSERT %d\n", rowsAffected)
	}

	return nil
}

func getFirstStudentThatNeedsCertificate(db *sql.DB) (*Student, error) {
	query := `SELECT *
		FROM aida.alumnos
		WHERE titulo IS NOT NULL AND titulo_en_tramite IS NOT NULL
		ORDER BY egreso
		LIMIT 1`

	rows, err := db.Query(query)
	if err != nil {
		return nil, fmt.Errorf("error querying database: %w", err)
	}
	defer rows.Close()

	if !rows.Next() {
		return nil, nil // No student found
	}

	columns, err := rows.Columns()
	if err != nil {
		return nil, fmt.Errorf("error getting columns: %w", err)
	}

	values := make([]interface{}, len(columns))
	valuePtrs := make([]interface{}, len(columns))
	for i := range values {
		valuePtrs[i] = &values[i]
	}

	if err := rows.Scan(valuePtrs...); err != nil {
		return nil, fmt.Errorf("error scanning row: %w", err)
	}

	student := &Student{}

	for i, col := range columns {
		val := values[i]
		switch strings.ToLower(col) {
		case "id":
			if val != nil {
				if v, ok := val.(int64); ok {
					student.ID = int(v)
				}
			}
		case "nombre":
			if val != nil {
				if v, ok := val.(string); ok {
					student.Name = v
				}
			}
		case "titulo":
			if val != nil {
				if v, ok := val.(string); ok {
					student.Title = v
				}
			}
		case "titulo_en_tramite":
			if val != nil {
				if v, ok := val.(string); ok {
					student.TitleStatus = v
				}
			}
		case "egreso":
			if val != nil {
				if v, ok := val.(string); ok {
					student.Graduation = v
				}
			}
		}
	}

	return student, nil
}

func generateStudentCertificate(db *sql.DB, student *Student) error {
	fmt.Printf("student: %+v\n", student)
	return nil
}

func main() {
	user := os.Getenv("PGUSER")
	password := os.Getenv("PGPASSWORD")
	host := os.Getenv("PGHOST")
	port := os.Getenv("PGPORT")
	dbname := os.Getenv("PGDATABASE")

	connStr := fmt.Sprintf("user=%s password=%s host=%s port=%s dbname=%s sslmode=disable",
		user, password, host, port, dbname)

	db, err := sql.Open("postgres", connStr)
	if err != nil {
		log.Fatal("Error connecting to database:", err)
	}
	defer db.Close()

	filePath := "resources/alumnos.csv"
	studentLineArray, columns, err := readAndParseCSV(filePath)
	if err != nil {
		log.Fatal("Error reading CSV:", err)
	}

	if err := refreshStudentTableFromCSV(db, studentLineArray, columns); err != nil {
		log.Fatal("Error refreshing student table:", err)
	}

	student, err := getFirstStudentThatNeedsCertificate(db)
	if err != nil {
		log.Fatal("Error getting student:", err)
	}

	if student == nil {
		fmt.Println("No hay estudiantes que necesiten certificado")
	} else {
		if err := generateStudentCertificate(db, student); err != nil {
			log.Fatal("Error generating certificate:", err)
		}
	}
}
