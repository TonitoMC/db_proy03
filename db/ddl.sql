-- Tabla de roles, define si algunos roles pueden hacer tiempo extra
-- o estar en un turno tipo 'on-call' donde unicamente llegan si es
-- necesario.
CREATE TABLE IF NOT EXISTS roles (
  id SERIAL PRIMARY KEY,
  name VARCHAR UNIQUE NOT NULL,
  on_call_allowed BOOL NOT NULL,
  overtime_allowed BOOL NOT NULL
);

-- Tabla de staff, registra todas las personas que trabajan para el hospital,
-- uniques / not nulls para todo. Unicamente un telefono, lo normal para el
-- personal medico en un hospital es estar MUY pendiente de su telefono. No
-- le vi punto en poner multiples.
CREATE TABLE IF NOT EXISTS staff (
  id SERIAL PRIMARY KEY,
  name VARCHAR NOT NULL,
  role_id INT NOT NULL REFERENCES roles(id),
  email VARCHAR UNIQUE NOT NULL,
  phone VARCHAR UNIQUE NOT NULL
);

-- Tabla de leave requests, registra las vacaciones que pide / se le dan al
-- personal del hospital. End date es nullable porque puede haber
-- 'indefinite leaves', estos requests pueden estar pendientes aprobados
-- o rechazados
CREATE TABLE IF NOT EXISTS leave_requests (
  id SERIAL PRIMARY KEY,
  staff_id INT NOT NULL REFERENCES staff(id),
  start_date DATE NOT NULL,
  end_date DATE,
  status VARCHAR NOT NULL DEFAULT 'pending' CHECK (status in ('approved', 'pending', 'denied'))
);

-- Tabla de shift times, los turnos en un hospital se dividen en turnos de 8
-- horas o de 12 horas que empiezan a horas estandar. Entonces podemos crear
-- 'Morning', 'Afternoon', 'Overnight', 'Long Day' y 'Long Night' para 
-- representar todos los turnos disponibles y unicamente almacenar la informacion
-- aqui.
CREATE TABLE IF NOT EXISTS shift_times (
  id SERIAL PRIMARY KEY,
  name VARCHAR UNIQUE NOT NULL,
  start_time TIME NOT NULL,
  end_time TIME NOT NULL,
  UNIQUE (start_time, end_time)
);

-- Tabla de preferencias de shifts, para este proyecto principalmente se usa 
-- para analiticas de ver quienes son los 'consentidos' pero en un sistema
-- mas practico se puede dar un weighed preference para asignar los turnos
-- y mantener felices a todos :).
CREATE TABLE IF NOT EXISTS staff_shift_preferences (
  id SERIAL PRIMARY KEY,
  shift_time_id INT NOT NULL REFERENCES shift_times(id),
  staff_id INT NOT NULL REFERENCES staff(id)
);

-- Tabla de shifts, ya que teniendo los tiempos de inicio y fin todavia
-- debemos definir el dia. Nos aseguramos que no haya multiples 'Day Shifts'
-- el mismo dia para evitar informacion redundante.
CREATE TABLE IF NOT EXISTS shifts (
  id SERIAL PRIMARY KEY,
  shift_time_id INT NOT NULL REFERENCES shift_times(id),
  date date NOT NULL,
  UNIQUE(shift_time_id, date)
);

-- Tabla de departamentos, esta se explica solita creo
CREATE TABLE IF NOT EXISTS departments (
  id SERIAL PRIMARY KEY,
  name VARCHAR UNIQUE NOT NULL
);

-- Tabla de cruce de staff con departamentos, indica a que departmentos se
-- puede asignar cada persona. Tiene tiempos para cuando son asignaciones
-- temporaneas como los residentes, pueden pasar 1 mes en pediatria pero
-- luego cuando estan en cardiologia ya tiene que ser invalido el assignment
-- anterior. End_date es null ya que los doctores normalmente se quedan en el mismo
CREATE TABLE IF NOT EXISTS staff_departments (
  id SERIAL PRIMARY KEY,
  staff_id INT NOT NULL REFERENCES staff (id),
  department_id INT NOT NULL REFERENCES departments(id),
  start_date DATE NOT NULL,
  end_date DATE
);

-- Tabla de shift_assignments, tabla de cruce para manejar el staff que va
-- a cumplir con ciertas hora en un departmaneto.
CREATE TABLE IF NOT EXISTS shift_assignments (
  id SERIAL PRIMARY KEY,
  shift_id INT NOT NULL REFERENCES shifts(id),
  department_id INT NOT NULL REFERENCES departments(id),
  staff_id INT NOT NULL REFERENCES staff(id),
  shift_type varchar NOT NULL DEFAULT 'regular' CHECK (shift_type in ('regular', 'on-call')),
    UNIQUE (staff_id, shift_id)
);

-- Tabla de logs del shift, indica check in / out. Esto nos sirve para la reporteria
-- para saber quienes llegaron / salieron tarde / temprano. Usamos timestamp para
-- los turnos que se llevan a cabo 'entre dias', y check_in / check_out son nullable
-- porque puede que alguien simplemente no llegue
CREATE TABLE IF NOT EXISTS shift_logs (
  id SERIAL PRIMARY KEY,
  assignment_id INT NOT NULL REFERENCES shift_assignments(id),
  check_in timestamp,
  check_out timestamp
);

-- Maneja tiempos extra, la manera que funciona con los shift logs es que ya oficialmente
-- 'se van' al terminar su turno (marcado en la otra tabla) y luego se ve la duracion
-- de su overtime.
CREATE TABLE IF NOT EXISTS overtimes (
  id SERIAL PRIMARY KEY,
  shift_assignment_id INT NOT NULL REFERENCES shift_assignments(id),
  duration INTERVAL NOT NULL
);

-- Trigger para evitar asignar turnos a personas que no se encuentran disponibles
CREATE OR REPLACE FUNCTION check_leave_conflict()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM leave_requests lr
        JOIN shifts s ON NEW.shift_id = s.id
        WHERE lr.staff_id = NEW.staff_id
        AND lr.status = 'approved'
        AND (
            (lr.end_date IS NULL AND s.date >= lr.start_date) OR
            (s.date BETWEEN lr.start_date AND lr.end_date)
        )
    ) THEN
        RAISE EXCEPTION 'Cannot assign shift: Staff member is on approved leave during this period';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER prevent_leave_conflict
BEFORE INSERT OR UPDATE ON shift_assignments
FOR EACH ROW EXECUTE FUNCTION check_leave_conflict();

-- Trigger para verificar que alguien si pueda estar on-call
CREATE OR REPLACE FUNCTION validate_on_call_assignment()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.shift_type = 'on-call' AND NOT EXISTS (
        SELECT 1 FROM staff s
        JOIN roles r ON s.role_id = r.id
        WHERE s.id = NEW.staff_id
        AND r.on_call_allowed = TRUE
    ) THEN
        RAISE EXCEPTION 'Staff member''s role does not permit on-call assignments';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER validate_on_call_assignment
BEFORE INSERT OR UPDATE ON shift_assignments
FOR EACH ROW EXECUTE FUNCTION validate_on_call_assignment();
