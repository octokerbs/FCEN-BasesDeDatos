package utils

import (
	"encoding/csv"
	"fmt"
	"os"
	"strings"
)

func ReadAndParseCSV(aFilePath string) ([][]string, []string, error) {
	aFile, err := os.Open(aFilePath)
	if err != nil {
		return nil, nil, fmt.Errorf("error opening file: %w", err)
	}
	defer aFile.Close()

	aReader := csv.NewReader(aFile)
	anArrayOfRecords, err := aReader.ReadAll()
	if err != nil {
		return nil, nil, fmt.Errorf("error reading CSV: %w", err)
	}

	if len(anArrayOfRecords) == 0 {
		return nil, nil, fmt.Errorf("CSV file is empty")
	}

	anArrayOfColumnNames := make([]string, len(anArrayOfRecords[0]))
	for i, col := range anArrayOfRecords[0] {
		anArrayOfColumnNames[i] = strings.TrimSpace(col)
	}

	return anArrayOfRecords[1:], anArrayOfColumnNames, nil
}
