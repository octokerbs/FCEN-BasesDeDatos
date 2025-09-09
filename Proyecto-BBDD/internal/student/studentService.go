package student

import (
	"database/sql"
	"fmt"
	"log"
	"os"
	"strings"

	"golang.org/x/net/html"
)

func RefreshStudentTableFromCSV(aDatabase *sql.DB, anArrayOfStudentLines [][]string, anArrayOfColumnNames []string) error {
	_, err := aDatabase.Exec("DELETE FROM aida.alumnos")
	if err != nil {
		return fmt.Errorf("error deleting records: %w", err)
	}

	for _, aStudentLine := range anArrayOfStudentLines {
		if len(aStudentLine) == 0 || (len(aStudentLine) == 1 && strings.TrimSpace(aStudentLine[0]) == "") {
			continue
		}

		anArrayOfPlaceholders := make([]string, len(anArrayOfColumnNames))
		anArrayOfArguments := make([]interface{}, len(aStudentLine))
		for i, aColumnValue := range aStudentLine {
			anArrayOfPlaceholders[i] = fmt.Sprintf("$%d", i+1)
			if strings.TrimSpace(aColumnValue) == "" {
				anArrayOfArguments[i] = nil
			} else {
				anArrayOfArguments[i] = strings.TrimSpace(aColumnValue)
			}
		}

		aSqlQuery := fmt.Sprintf(
			"INSERT INTO aida.alumnos (%s) VALUES (%s)",
			strings.Join(anArrayOfColumnNames, ", "),
			strings.Join(anArrayOfPlaceholders, ", "),
		)

		if _, err := aDatabase.Exec(aSqlQuery, anArrayOfArguments...); err != nil {
			log.Printf("Error inserting record: %v", err)
			continue
		}
	}

	return nil
}

func GetFirstStudentThatNeedsCertificate(aDatabase *sql.DB) (*Student, error) {
	aSqlQuery := `SELECT *
	FROM aida.alumnos
	WHERE titulo IS NOT NULL AND titulo_en_tramite IS NOT NULL
	ORDER BY egreso
	LIMIT 1`

	var aStudent Student
	aStudentRow := aDatabase.QueryRow(aSqlQuery)

	err := aStudentRow.Scan(
		&aStudent.LU,
		&aStudent.Apellido,
		&aStudent.Nombre,
		&aStudent.Titulo,
		&aStudent.TituloEnTramite,
		&aStudent.Egreso,
	)

	if err != nil {
		if err == sql.ErrNoRows {
			return nil, nil
		}
		return nil, fmt.Errorf("error querying database: %w", err)
	}

	return &aStudent, nil
}

func replacePlaceholder(anHTMLNode *html.Node, aPlaceholder, aNewStringValue string) {
	if anHTMLNode.Type == html.TextNode && strings.TrimSpace(anHTMLNode.Data) == aPlaceholder {
		anHTMLNode.Data = aNewStringValue
	}

	for c := anHTMLNode.FirstChild; c != nil; c = c.NextSibling {
		replacePlaceholder(c, aPlaceholder, aNewStringValue)
	}
}

func GenerateStudentCertificate(aTemplatePath string, aStudent *Student) error {
	anHTMLFile, err := os.Open(aTemplatePath)
	if err != nil {
		log.Fatal(err)
		return err
	}
	defer anHTMLFile.Close()

	anHTMLNode, err := html.Parse(anHTMLFile)
	if err != nil {
		log.Fatal(err)
		return err
	}

	// Hardcoded, I don't like reflections.
	replacePlaceholder(anHTMLNode, "[#lu]", aStudent.LU.String)
	replacePlaceholder(anHTMLNode, "[#apellido] [#nombres]", aStudent.Apellido.String+" "+aStudent.Nombre.String)
	replacePlaceholder(anHTMLNode, "[#titulo]", aStudent.Titulo.String)
	replacePlaceholder(anHTMLNode, "[#titulo_en_tramite]", aStudent.TituloEnTramite.Time.String())
	replacePlaceholder(anHTMLNode, "[#egreso]", aStudent.Egreso.Time.Format(
		"02/01/2006",
	))

	aNewHTMLFile, err := os.Create("resources/certificado-para-imprimir.html")
	if err != nil {
		return err
	}
	defer aNewHTMLFile.Close()

	if err := html.Render(aNewHTMLFile, anHTMLNode); err != nil {
		return err
	}

	log.Printf("Certificate generated successfully for student: %s \n.", aStudent.LU.String)

	return nil
}
