package postgres

import (
	"database/sql"
	"fmt"
	"os"

	_ "github.com/lib/pq"
)

func Connect() (*sql.DB, error) {
	aUsername := os.Getenv("PGUSER")
	aPassword := os.Getenv("PGPASSWORD")
	aHostAddress := os.Getenv("PGHOST")
	aPortNumber := os.Getenv("PGPORT")
	aDatabaseName := os.Getenv("PGDATABASE")

	aConnectionString := fmt.Sprintf("user=%s password=%s host=%s port=%s dbname=%s sslmode=disable",
		aUsername, aPassword, aHostAddress, aPortNumber, aDatabaseName)

	return sql.Open("postgres", aConnectionString)
}
