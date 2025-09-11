package main

import (
	"fmt"
	"log"
	"os"
	"os/exec"

	"github.com/octokerbs/Proyecto-BBDD/internal/postgres"
	"github.com/octokerbs/Proyecto-BBDD/internal/student"
)

func main() {
	anArrayOfArguments := os.Args[1:]
	log.Printf("%d Arguments: %v\n", len(anArrayOfArguments), anArrayOfArguments)

	aConnection, err := postgres.Connect()
	if err != nil {
		log.Fatal("Error connecting to database:", err)
	}
	defer aConnection.Close()

	anArrayOfStudentLines, anArrayOfColumns, err := ReadAndParseCSV("../resources/alumnos.csv")
	if err != nil {
		log.Fatal("Error reading CSV:", err)
	}

	if err := student.RefreshStudentTableFromCSV(aConnection, anArrayOfStudentLines, anArrayOfColumns); err != nil {
		log.Fatal("Error refreshing student table:", err)
	}

	aStudent, err := student.GetFirstStudentThatNeedsCertificate(aConnection)
	if err != nil {
		log.Fatal("Error getting student:", err)
	}

	if aStudent == nil {
		fmt.Println("No hay estudiantes que necesiten certificado")
	} else {
		if err := student.GenerateStudentCertificate("../resources/plantilla-certificado.html", aStudent); err != nil {
			log.Fatal("Error generating certificate:", err)
		}
	}

	aCommandLineInstruction := exec.Command("xdg-open", "../resources/certificado-para-imprimir.html")
	err = aCommandLineInstruction.Start() // Use Start instead of Run to not block
	if err != nil {
		log.Fatal(err)
	}
}
