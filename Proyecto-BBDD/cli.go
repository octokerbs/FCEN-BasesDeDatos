package main

import (
	"fmt"
	"log"
	"os"
	"os/exec"

	"github.com/octokerbs/Proyecto-BBDD/database"
	"github.com/octokerbs/Proyecto-BBDD/service"
	"github.com/octokerbs/Proyecto-BBDD/utils"
)

func main() {
	args := os.Args[1:]
	log.Printf("%d Arguments: %v\n", len(args), args)

	conn, err := database.Connect()
	if err != nil {
		log.Fatal("Error connecting to database:", err)
	}
	defer conn.Close()

	studentLines, columns, err := utils.ReadAndParseCSV("resources/alumnos.csv")
	if err != nil {
		log.Fatal("Error reading CSV:", err)
	}

	if err := service.RefreshStudentTableFromCSV(conn, studentLines, columns); err != nil {
		log.Fatal("Error refreshing student table:", err)
	}

	student, err := service.GetFirstStudentThatNeedsCertificate(conn)
	if err != nil {
		log.Fatal("Error getting student:", err)
	}

	if student == nil {
		fmt.Println("No hay estudiantes que necesiten certificado")
	} else {
		if err := service.GenerateStudentCertificate("resources/plantilla-certificado.html", student); err != nil {
			log.Fatal("Error generating certificate:", err)
		}
	}

	cmd := exec.Command("xdg-open", "resources/certificado-para-imprimir.html")
	err = cmd.Start() // Use Start instead of Run to not block
	if err != nil {
		log.Fatal(err)
	}
}
