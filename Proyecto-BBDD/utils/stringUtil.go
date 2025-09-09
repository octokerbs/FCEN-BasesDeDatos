package utils

import "fmt"

func ValueToString(aValue any) (string, error) {
	switch v := aValue.(type) {
	case string:
		return v, nil
	case int, int64, float64, float32:
		return fmt.Sprintf("%v", v), nil
	default:
		return "", fmt.Errorf("unsupported type %T for value: %v", v, v)
	}
}
