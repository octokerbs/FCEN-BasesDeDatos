package student

import "database/sql"

type Student struct {
	LU              sql.NullString `db:"lu"`
	Apellido        sql.NullString `db:"apellido"`
	Nombre          sql.NullString `db:"nombre"`
	Titulo          sql.NullString `db:"titulo"`
	TituloEnTramite sql.NullTime   `db:"titulo_en_tramite"`
	Egreso          sql.NullTime   `db:"egreso"`
}
