package utils

import (
	"encoding/csv"
	"fmt"
	"os"
	"strings"
)

func ReadAndParseCSV(filePath string) ([][]string, []string, error) {
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

	return records[1:], columns, nil
}
