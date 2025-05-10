
-- This script creates and populates hospital shift scheduling data
-- Date range: past 30 days from May 7, 2025

-- Shift times, solo tenemos 5 en intervalos de 8 o 12 horas
INSERT INTO shift_times (name, start_time, end_time) VALUES
('Morning', '07:00', '15:00'),
('Afternoon', '15:00', '23:00'),
('Overnight', '23:00', '07:00'),
('Long Day', '07:00', '19:00'),
('Long Night', '19:00', '07:00');

-- Shifts por cada dia, usamos una funcion para insertar 30 dias
-- de shifts
INSERT INTO shifts (shift_time_id, date)
SELECT st.id, current_date - i
FROM generate_series(0, 29) AS i
JOIN shift_times st ON TRUE;

-- Roles, vamos a definir medicos, enfermeros y residentes 
-- Fun fact, los residentes NO pueden hacer tiempo
-- extra 'legalmente' entonces solo se registran sus turnos
-- y se quedan en el hospital sin pago obligatoriamente.
INSERT INTO roles (name, on_call_allowed, overtime_allowed) VALUES
('Resident', false, false),
('Nurse', false, true),
('Doctor', true, true);

INSERT INTO departments (name) VALUES
('Emergency Medicine'),
('Internal Medicine'),
('Cardiology'),
('Pediatrics'),
('Obstetrics and Gynecology'),
('Neurology'),
('General Surgery'),
('Orthopedics'),
('Anesthesiology'),
('Radiology'),
('Pathology'),
('Psychiatry'),
('Dermatology'),
('Oncology'),
('Endocrinology'),
('Urology'),
('Nephrology'),
('Gastroenterology'),
('Hematology'),
('Ophthalmology'),
('Rheumatology'),
('Otolaryngology'),
('Plastic Surgery'),
('Pulmonology'),
('Infectious Diseases');

INSERT INTO staff (name, role_id, email, phone) VALUES
-- Doctors (role_id = 3) - 40 entries
('James Wilson', 3, 'james.wilson@hospital.org', '(212) 555-1001'),
('Lisa Chen', 3, 'lisa.chen@hospital.org', '(212) 555-1002'),
('Robert Smith', 3, 'robert.smith@hospital.org', '(212) 555-1003'),
('Sarah Johnson', 3, 'sarah.johnson@hospital.org', '(212) 555-1004'),
('David Rodriguez', 3, 'david.rodriguez@hospital.org', '(212) 555-1005'),
('Emily Patel', 3, 'emily.patel@hospital.org', '(212) 555-1006'),
('Michael Wong', 3, 'michael.wong@hospital.org', '(212) 555-1007'),
('Jennifer Kim', 3, 'jennifer.kim@hospital.org', '(212) 555-1008'),
('Richard Martinez', 3, 'richard.martinez@hospital.org', '(212) 555-1009'),
('Olivia Thompson', 3, 'olivia.thompson@hospital.org', '(212) 555-1010'),
('Thomas Lee', 3, 'thomas.lee@hospital.org', '(212) 555-1011'),
('Katherine Davis', 3, 'katherine.davis@hospital.org', '(212) 555-1012'),
('Daniel Nguyen', 3, 'daniel.nguyen@hospital.org', '(212) 555-1013'),
('Rebecca Brown', 3, 'rebecca.brown@hospital.org', '(212) 555-1014'),
('Christopher Taylor', 3, 'christopher.taylor@hospital.org', '(212) 555-1015'),
('Samantha Garcia', 3, 'samantha.garcia@hospital.org', '(212) 555-1016'),
('Alexander Mitchell', 3, 'alexander.mitchell@hospital.org', '(212) 555-1017'),
('Michelle Robinson', 3, 'michelle.robinson@hospital.org', '(212) 555-1018'),
('Jonathan Williams', 3, 'jonathan.williams@hospital.org', '(212) 555-1019'),
('Elizabeth Scott', 3, 'elizabeth.scott@hospital.org', '(212) 555-1020'),
('Andrew Chang', 3, 'andrew.chang@hospital.org', '(212) 555-1021'),
('Laura Fernandez', 3, 'laura.fernandez@hospital.org', '(212) 555-1022'),
('William Parker', 3, 'william.parker@hospital.org', '(212) 555-1023'),
('Patricia Gonzalez', 3, 'patricia.gonzalez@hospital.org', '(212) 555-1024'),
('Kevin Washington', 3, 'kevin.washington@hospital.org', '(212) 555-1025'),
('Sophia Henderson', 3, 'sophia.henderson@hospital.org', '(212) 555-1026'),
('Brian Sullivan', 3, 'brian.sullivan@hospital.org', '(212) 555-1027'),
('Amanda Carter', 3, 'amanda.carter@hospital.org', '(212) 555-1028'),
('Charles Lewis', 3, 'charles.lewis@hospital.org', '(212) 555-1029'),
('Natalie Wright', 3, 'natalie.wright@hospital.org', '(212) 555-1030'),
('Gregory Mills', 3, 'gregory.mills@hospital.org', '(212) 555-1031'),
('Hannah Reed', 3, 'hannah.reed@hospital.org', '(212) 555-1032'),
('Tyler Reyes', 3, 'tyler.reyes@hospital.org', '(212) 555-1033'),
('Rachel Simmons', 3, 'rachel.simmons@hospital.org', '(212) 555-1034'),
('Brandon Cooper', 3, 'brandon.cooper@hospital.org', '(212) 555-1035'),
('Caroline Hughes', 3, 'caroline.hughes@hospital.org', '(212) 555-1036'),
('Benjamin Ross', 3, 'benjamin.ross@hospital.org', '(212) 555-1037'),
('Megan Foster', 3, 'megan.foster@hospital.org', '(212) 555-1038'),
('Nathan Sanders', 3, 'nathan.sanders@hospital.org', '(212) 555-1039'),
('Victoria Bennett', 3, 'victoria.bennett@hospital.org', '(212) 555-1040'),

-- Nurses (role_id = 2) - 70 entries
('Maria Lopez', 2, 'maria.lopez@hospital.org', '(212) 555-1041'),
('John Anderson', 2, 'john.anderson@hospital.org', '(212) 555-1042'),
('Grace Kim', 2, 'grace.kim@hospital.org', '(212) 555-1043'),
('Paul Thomas', 2, 'paul.thomas@hospital.org', '(212) 555-1044'),
('Linda Hernandez', 2, 'linda.hernandez@hospital.org', '(212) 555-1045'),
('Steven White', 2, 'steven.white@hospital.org', '(212) 555-1046'),
('Cynthia Jackson', 2, 'cynthia.jackson@hospital.org', '(212) 555-1047'),
('Mark Harris', 2, 'mark.harris@hospital.org', '(212) 555-1048'),
('Deborah Clark', 2, 'deborah.clark@hospital.org', '(212) 555-1049'),
('Joseph Allen', 2, 'joseph.allen@hospital.org', '(212) 555-1050'),
('Karen Young', 2, 'karen.young@hospital.org', '(212) 555-1051'),
('Edward Hall', 2, 'edward.hall@hospital.org', '(212) 555-1052'),
('Susan Adams', 2, 'susan.adams@hospital.org', '(212) 555-1053'),
('George Nelson', 2, 'george.nelson@hospital.org', '(212) 555-1054'),
('Nancy Baker', 2, 'nancy.baker@hospital.org', '(212) 555-1055'),
('Donald Green', 2, 'donald.green@hospital.org', '(212) 555-1056'),
('Helen Rivera', 2, 'helen.rivera@hospital.org', '(212) 555-1057'),
('Frank Campbell', 2, 'frank.campbell@hospital.org', '(212) 555-1058'),
('Carol Evans', 2, 'carol.evans@hospital.org', '(212) 555-1059'),
('Raymond Kelly', 2, 'raymond.kelly@hospital.org', '(212) 555-1060'),
('Alice Peterson', 2, 'alice.peterson@hospital.org', '(212) 555-1061'),
('Matthew Phillips', 2, 'matthew.phillips@hospital.org', '(212) 555-1062'),
('Sandra Turner', 2, 'sandra.turner@hospital.org', '(212) 555-1063'),
('Jerry Murphy', 2, 'jerry.murphy@hospital.org', '(212) 555-1064'),
('Donna Roberts', 2, 'donna.roberts@hospital.org', '(212) 555-1065'),
('Timothy Sanchez', 2, 'timothy.sanchez@hospital.org', '(212) 555-1066'),
('Ruth Morris', 2, 'ruth.morris@hospital.org', '(212) 555-1067'),
('Jason Rogers', 2, 'jason.rogers@hospital.org', '(212) 555-1068'),
('Diane Reed', 2, 'diane.reed@hospital.org', '(212) 555-1069'),
('Jeffrey Cook', 2, 'jeffrey.cook@hospital.org', '(212) 555-1070'),
('Julie Bailey', 2, 'julie.bailey@hospital.org', '(212) 555-1071'),
('Gary Bell', 2, 'gary.bell@hospital.org', '(212) 555-1072'),
('Teresa Cooper', 2, 'teresa.cooper@hospital.org', '(212) 555-1073'),
('Henry Richardson', 2, 'henry.richardson@hospital.org', '(212) 555-1074'),
('Joyce Cox', 2, 'joyce.cox@hospital.org', '(212) 555-1075'),
('Earl Howard', 2, 'earl.howard@hospital.org', '(212) 555-1076'),
('Melissa Ward', 2, 'melissa.ward@hospital.org', '(212) 555-1077'),
('Wayne Torres', 2, 'wayne.torres@hospital.org', '(212) 555-1078'),
('Heather Watson', 2, 'heather.watson@hospital.org', '(212) 555-1079'),
('Eugene Brooks', 2, 'eugene.brooks@hospital.org', '(212) 555-1080'),
('Janice Gray', 2, 'janice.gray@hospital.org', '(212) 555-1081'),
('Peter James', 2, 'peter.james@hospital.org', '(212) 555-1082'),
('Catherine Ramirez', 2, 'catherine.ramirez@hospital.org', '(212) 555-1083'),
('Bruce Perry', 2, 'bruce.perry@hospital.org', '(212) 555-1084'),
('Evelyn Price', 2, 'evelyn.price@hospital.org', '(212) 555-1085'),
('Walter Sanders', 2, 'walter.sanders@hospital.org', '(212) 555-1086'),
('Gloria Powell', 2, 'gloria.powell@hospital.org', '(212) 555-1087'),
('Alan Long', 2, 'alan.long@hospital.org', '(212) 555-1088'),
('Judy Hughes', 2, 'judy.hughes@hospital.org', '(212) 555-1089'),
('Lawrence Butler', 2, 'lawrence.butler@hospital.org', '(212) 555-1090'),
('Cheryl Foster', 2, 'cheryl.foster@hospital.org', '(212) 555-1091'),
('Ralph Barnes', 2, 'ralph.barnes@hospital.org', '(212) 555-1092'),
('Martha Russell', 2, 'martha.russell@hospital.org', '(212) 555-1093'),
('Louis Coleman', 2, 'louis.coleman@hospital.org', '(212) 555-1094'),
('Sharon Simmons', 2, 'sharon.simmons@hospital.org', '(212) 555-1095'),
('Gerald Ellis', 2, 'gerald.ellis@hospital.org', '(212) 555-1096'),
('Frances Stewart', 2, 'frances.stewart@hospital.org', '(212) 555-1097'),
('Jack Fisher', 2, 'jack.fisher@hospital.org', '(212) 555-1098'),
('Bonnie Harrison', 2, 'bonnie.harrison@hospital.org', '(212) 555-1099'),
('Carl Gibson', 2, 'carl.gibson@hospital.org', '(212) 555-1100'),
('Jean Dixon', 2, 'jean.dixon@hospital.org', '(212) 555-1101'),
('Alexander Warren', 2, 'alexander.warren@hospital.org', '(212) 555-1102'),
('Marilyn Marshall', 2, 'marilyn.marshall@hospital.org', '(212) 555-1103'),
('Vincent Owen', 2, 'vincent.owen@hospital.org', '(212) 555-1104'),
('Anne Murray', 2, 'anne.murray@hospital.org', '(212) 555-1105'),
('Edwin Ford', 2, 'edwin.ford@hospital.org', '(212) 555-1106'),
('Kathryn Sullivan', 2, 'kathryn.sullivan@hospital.org', '(212) 555-1107'),
('Ricardo Mendez', 2, 'ricardo.mendez@hospital.org', '(212) 555-1108'),
('Theresa Alvarez', 2, 'theresa.alvarez@hospital.org', '(212) 555-1109'),
('Harold Morgan', 2, 'harold.morgan@hospital.org', '(212) 555-1110'),

-- Residents (role_id = 1) - 40 entries
('Zoe Richards', 1, 'zoe.richards@hospital.org', '(212) 555-1111'),
('Adrian Pena', 1, 'adrian.pena@hospital.org', '(212) 555-1112'),
('Lily Martinez', 1, 'lily.martinez@hospital.org', '(212) 555-1113'),
('Jacob Chen', 1, 'jacob.chen@hospital.org', '(212) 555-1114'),
('Sofia Williams', 1, 'sofia.williams@hospital.org', '(212) 555-1115'),
('Ethan Nguyen', 1, 'ethan.nguyen@hospital.org', '(212) 555-1116'),
('Madison Johnson', 1, 'madison.johnson@hospital.org', '(212) 555-1117'),
('Noah Garcia', 1, 'noah.garcia@hospital.org', '(212) 555-1118'),
('Isabella Rodriguez', 1, 'isabella.rodriguez@hospital.org', '(212) 555-1119'),
('Liam Park', 1, 'liam.park@hospital.org', '(212) 555-1120'),
('Ava Thompson', 1, 'ava.thompson@hospital.org', '(212) 555-1121'),
('Mason Lee', 1, 'mason.lee@hospital.org', '(212) 555-1122'),
('Charlotte Davis', 1, 'charlotte.davis@hospital.org', '(212) 555-1123'),
('Lucas Brown', 1, 'lucas.brown@hospital.org', '(212) 555-1124'),
('Amelia Taylor', 1, 'amelia.taylor@hospital.org', '(212) 555-1125'),
('Oliver Martin', 1, 'oliver.martin@hospital.org', '(212) 555-1126'),
('Mia Hernandez', 1, 'mia.hernandez@hospital.org', '(212) 555-1127'),
('Elijah Wilson', 1, 'elijah.wilson@hospital.org', '(212) 555-1128'),
('Harper Anderson', 1, 'harper.anderson@hospital.org', '(212) 555-1129'),
('William Thomas', 1, 'william.thomas@hospital.org', '(212) 555-1130'),
('Abigail Jackson', 1, 'abigail.jackson@hospital.org', '(212) 555-1131'),
('Benjamin White', 1, 'benjamin.white@hospital.org', '(212) 555-1132'),
('Emily Harris', 1, 'emily.harris@hospital.org', '(212) 555-1133'),
('James Clark', 1, 'james.clark@hospital.org', '(212) 555-1134'),
('Avery Allen', 1, 'avery.allen@hospital.org', '(212) 555-1135'),
('Henry Young', 1, 'henry.young@hospital.org', '(212) 555-1136'),
('Evelyn Adams', 1, 'evelyn.adams@hospital.org', '(212) 555-1137'),
('Alexander Hall', 1, 'alexander.hall@hospital.org', '(212) 555-1138'),
('Elizabeth Nelson', 1, 'elizabeth.nelson@hospital.org', '(212) 555-1139'),
('Daniel Baker', 1, 'daniel.baker@hospital.org', '(212) 555-1140'),
('Sofia Green', 1, 'sofia.green@hospital.org', '(212) 555-1141'),
('Matthew Rivera', 1, 'matthew.rivera@hospital.org', '(212) 555-1142'),
('Camila Campbell', 1, 'camila.campbell@hospital.org', '(212) 555-1143'),
('David Evans', 1, 'david.evans@hospital.org', '(212) 555-1144'),
('Victoria Kelly', 1, 'victoria.kelly@hospital.org', '(212) 555-1145'),
('Joseph Peterson', 1, 'joseph.peterson@hospital.org', '(212) 555-1146'),
('Scarlett Phillips', 1, 'scarlett.phillips@hospital.org', '(212) 555-1147'),
('John Turner', 1, 'john.turner@hospital.org', '(212) 555-1148'),
('Aria Murphy', 1, 'aria.murphy@hospital.org', '(212) 555-1149'),
('Christopher Roberts', 1, 'christopher.roberts@hospital.org', '(212) 555-1150');

-- Staff-Department Assignments - updated for 30-day window
INSERT INTO staff_departments (staff_id, department_id, start_date, end_date) VALUES
-- Doctors (typically one active assignment)
(1, 1, '2025-04-15', NULL), -- Emergency Medicine
(2, 3, '2025-04-10', NULL), -- Cardiology
(3, 7, '2025-04-22', NULL), -- General Surgery
(4, 4, '2025-04-12', NULL), -- Pediatrics
(5, 2, '2025-04-15', NULL), -- Internal Medicine
(6, 5, '2025-04-12', NULL), -- Obstetrics and Gynecology
(7, 6, '2025-04-12', NULL), -- Neurology
(8, 8, '2025-04-15', NULL), -- Orthopedics
(9, 9, '2025-04-18', NULL), -- Anesthesiology
(10, 10, '2025-04-15', NULL), -- Radiology
(11, 2, '2025-04-20', NULL), -- Internal Medicine
(12, 12, '2025-04-15', NULL), -- Psychiatry
(13, 13, '2025-04-15', NULL), -- Dermatology
(14, 14, '2025-04-18', NULL), -- Oncology
(15, 15, '2025-04-10', NULL), -- Endocrinology
(16, 5, '2025-04-12', NULL), -- Obstetrics and Gynecology
(17, 16, '2025-04-15', NULL), -- Urology
(18, 17, '2025-04-15', NULL), -- Nephrology
(19, 18, '2025-04-20', NULL), -- Gastroenterology
(20, 19, '2025-04-18', NULL), -- Hematology
(21, 20, '2025-04-10', NULL), -- Ophthalmology
(22, 21, '2025-04-15', NULL), -- Rheumatology
(23, 22, '2025-04-15', NULL), -- Otolaryngology
(24, 23, '2025-04-19', NULL), -- Plastic Surgery
(25, 24, '2025-04-10', NULL), -- Pulmonology
(26, 25, '2025-04-18', NULL), -- Infectious Diseases
(27, 7, '2025-04-12', NULL), -- General Surgery
(28, 1, '2025-04-15', NULL), -- Emergency Medicine
(29, 3, '2025-04-15', NULL), -- Cardiology
(30, 4, '2025-04-15', NULL), -- Pediatrics
(31, 2, '2025-04-15', NULL), -- Internal Medicine
(32, 6, '2025-04-15', NULL), -- Neurology
(33, 8, '2025-04-18', NULL), -- Orthopedics
(34, 11, '2025-04-19', NULL), -- Pathology
(35, 14, '2025-04-15', NULL), -- Oncology
(36, 18, '2025-04-15', NULL), -- Gastroenterology
(37, 24, '2025-04-17', NULL), -- Pulmonology
(38, 25, '2025-04-12', NULL), -- Infectious Diseases
(39, 1, '2025-04-15', NULL), -- Emergency Medicine
(40, 3, '2025-04-18', NULL), -- Cardiology

-- Nurses with one department
(41, 1, '2025-04-15', NULL), -- Emergency Medicine
(42, 2, '2025-04-15', NULL), -- Internal Medicine
(43, 3, '2025-04-20', NULL), -- Cardiology
(44, 4, '2025-04-10', NULL), -- Pediatrics
(45, 5, '2025-04-15', NULL), -- Obstetrics and Gynecology
(46, 6, '2025-04-15', NULL), -- Neurology
(47, 7, '2025-04-15', NULL), -- General Surgery
(48, 8, '2025-04-15', NULL), -- Orthopedics
(49, 9, '2025-04-18', NULL), -- Anesthesiology
(50, 10, '2025-04-12', NULL), -- Radiology
(51, 11, '2025-04-10', NULL), -- Pathology
(52, 12, '2025-04-18', NULL), -- Psychiatry
(53, 13, '2025-04-12', NULL), -- Dermatology
(54, 14, '2025-04-18', NULL), -- Oncology
(55, 15, '2025-04-12', NULL), -- Endocrinology

-- Nurses with two departments
(56, 1, '2025-04-15', NULL), -- Emergency Medicine
(56, 7, '2025-04-20', NULL), -- Also General Surgery
(57, 2, '2025-04-20', NULL), -- Internal Medicine
(57, 15, '2025-04-15', NULL), -- Also Endocrinology
(58, 3, '2025-04-12', NULL), -- Cardiology
(58, 24, '2025-04-15', NULL), -- Also Pulmonology
(59, 4, '2025-04-12', NULL), -- Pediatrics
(59, 12, '2025-04-21', NULL), -- Also Psychiatry
(60, 5, '2025-04-10', NULL), -- Obstetrics and Gynecology
(60, 13, '2025-04-20', NULL), -- Also Dermatology
(61, 6, '2025-04-18', NULL), -- Neurology
(61, 25, '2025-04-15', NULL), -- Also Infectious Diseases
(62, 16, '2025-04-15', NULL), -- Urology
(62, 17, '2025-04-20', NULL), -- Also Nephrology
(63, 18, '2025-04-18', NULL), -- Gastroenterology
(63, 19, '2025-04-20', NULL), -- Also Hematology
(64, 20, '2025-04-15', NULL), -- Ophthalmology
(64, 22, '2025-04-20', NULL), -- Also Otolaryngology
(65, 21, '2025-04-20', NULL), -- Rheumatology
(65, 14, '2025-04-15', NULL), -- Also Oncology

-- Nurses with three departments
(66, 1, '2025-04-15', NULL), -- Emergency Medicine
(66, 2, '2025-04-15', NULL), -- Also Internal Medicine
(66, 3, '2025-04-11', NULL), -- Also Cardiology
(67, 4, '2025-04-10', NULL), -- Pediatrics
(67, 5, '2025-04-15', NULL), -- Also Obstetrics and Gynecology
(67, 12, '2025-04-15', NULL), -- Also Psychiatry
(68, 7, '2025-04-15', NULL), -- General Surgery
(68, 8, '2025-04-20', NULL), -- Also Orthopedics
(68, 9, '2025-04-20', NULL), -- Also Anesthesiology
(69, 14, '2025-04-15', NULL), -- Oncology
(69, 24, '2025-04-20', NULL), -- Also Pulmonology
(69, 25, '2025-04-15', NULL), -- Also Infectious Diseases
(70, 6, '2025-04-15', NULL), -- Neurology
(70, 20, '2025-04-20', NULL), -- Also Ophthalmology
(70, 21, '2025-04-20', NULL), -- Also Rheumatology

-- More nurses with single assignments (71-110)
(71, 1, '2025-04-15', NULL), -- Emergency Medicine
(72, 2, '2025-04-15', NULL), -- Internal Medicine
(73, 3, '2025-04-20', NULL), -- Cardiology
(74, 4, '2025-04-15', NULL), -- Pediatrics
(75, 5, '2025-04-15', NULL), -- Obstetrics and Gynecology
(76, 6, '2025-04-21', NULL), -- Neurology
(77, 7, '2025-04-20', NULL), -- General Surgery
(78, 8, '2025-04-20', NULL), -- Orthopedics
(79, 9, '2025-04-15', NULL), -- Anesthesiology
(80, 10, '2025-04-20', NULL), -- Radiology
(81, 11, '2025-04-10', NULL), -- Pathology
(82, 12, '2025-04-15', NULL), -- Psychiatry
(83, 13, '2025-04-20', NULL), -- Dermatology
(84, 14, '2025-04-20', NULL), -- Oncology
(85, 15, '2025-04-15', NULL), -- Endocrinology
(86, 16, '2025-04-20', NULL), -- Urology
(87, 17, '2025-04-15', NULL), -- Nephrology
(88, 18, '2025-04-15', NULL), -- Gastroenterology
(89, 19, '2025-04-20', NULL), -- Hematology
(90, 20, '2025-04-15', NULL), -- Ophthalmology
(91, 21, '2025-04-20', NULL), -- Rheumatology
(92, 22, '2025-04-15', NULL), -- Otolaryngology
(93, 23, '2025-04-15', NULL), -- Plastic Surgery
(94, 24, '2025-04-20', NULL), -- Pulmonology
(95, 25, '2025-04-15', NULL), -- Infectious Diseases
(96, 1, '2025-04-20', NULL), -- Emergency Medicine
(97, 2, '2025-04-15', NULL), -- Internal Medicine
(98, 3, '2025-04-15', NULL), -- Cardiology
(99, 4, '2025-04-20', NULL), -- Pediatrics
(100, 5, '2025-04-10', NULL), -- Obstetrics and Gynecology
(101, 6, '2025-04-15', NULL), -- Neurology
(102, 7, '2025-04-15', NULL), -- General Surgery
(103, 8, '2025-04-15', NULL), -- Orthopedics
(104, 9, '2025-04-15', NULL), -- Anesthesiology
(105, 10, '2025-04-15', NULL), -- Radiology
(106, 11, '2025-04-18', NULL), -- Pathology
(107, 12, '2025-04-20', NULL), -- Psychiatry
(108, 13, '2025-04-15', NULL), -- Dermatology
(109, 14, '2025-04-20', NULL), -- Oncology
(110, 15, '2025-04-11', NULL), -- Endocrinology

-- Residents with rotations (both completed and active)
-- Resident 1: Current in Emergency Medicine, previous in Internal Medicine
(111, 2, '2025-04-01', '2025-04-15'), -- Past rotation in Internal Medicine
(111, 1, '2025-04-16', NULL), -- Current rotation in Emergency Medicine

-- Resident 2: Current in Cardiology, previous in Internal Medicine
(112, 2, '2025-04-01', '2025-04-15'), -- Past rotation in Internal Medicine
(112, 3, '2025-04-16', NULL), -- Current rotation in Cardiology

-- Resident 3: Current in Pediatrics, previous in Obstetrics
(113, 5, '2025-04-01', '2025-04-15'), -- Past rotation in Obstetrics
(113, 4, '2025-04-16', NULL), -- Current rotation in Pediatrics

-- More residents with rotations
(114, 7, '2025-04-01', '2025-04-14'), -- Past rotation in General Surgery
(114, 8, '2025-04-15', NULL), -- Current rotation in Orthopedics

(115, 9, '2025-04-01', '2025-04-15'), -- Past rotation in Anesthesiology
(115, 7, '2025-04-16', NULL), -- Current rotation in General Surgery

(116, 11, '2025-04-01', '2025-04-14'), -- Past rotation in Pathology
(116, 13, '2025-04-15', NULL), -- Current rotation in Dermatology

(117, 15, '2025-04-01', '2025-04-15'), -- Past rotation in Endocrinology
(117, 19, '2025-04-16', NULL), -- Current rotation in Hematology

(118, 18, '2025-04-01', '2025-04-15'), -- Past rotation in Gastroenterology
(118, 17, '2025-04-16', NULL), -- Current rotation in Nephrology

(119, 20, '2025-04-01', '2025-04-14'), -- Past rotation in Ophthalmology
(119, 22, '2025-04-15', NULL), -- Current rotation in Otolaryngology

(120, 25, '2025-04-01', '2025-04-10'), -- Past rotation in Infectious Diseases
(120, 2, '2025-04-11', NULL), -- Current rotation in Internal Medicine

-- More resident rotations
(121, 1, '2025-04-01', '2025-04-14'), -- Past rotation in Emergency Medicine
(121, 3, '2025-04-15', NULL), -- Current rotation in Cardiology

(122, 4, '2025-04-01', '2025-04-15'), -- Past rotation in Pediatrics
(122, 12, '2025-04-16', NULL), -- Current rotation in Psychiatry

(123, 13, '2025-04-01', '2025-04-14'), -- Past rotation in Dermatology
(123, 14, '2025-04-15', NULL), -- Current rotation in Oncology

(124, 7, '2025-04-01', '2025-04-15'), -- Past rotation in General Surgery
(124, 8, '2025-04-16', NULL), -- Current rotation in Orthopedics

(125, 9, '2025-04-01', '2025-04-15'), -- Past rotation in Anesthesiology
(125, 10, '2025-04-16', NULL), -- Current rotation in Radiology

(126, 2, '2025-04-01', '2025-04-14'), -- Past rotation in Internal Medicine
(126, 15, '2025-04-15', NULL), -- Current rotation in Endocrinology

(127, 17, '2025-04-01', '2025-04-15'), -- Past rotation in Nephrology
(127, 18, '2025-04-16', NULL), -- Current rotation in Gastroenterology

(128, 19, '2025-04-01', '2025-04-14'), -- Past rotation in Hematology
(128, 20, '2025-04-15', NULL), -- Current rotation in Ophthalmology

(129, 21, '2025-04-01', '2025-04-15'), -- Past rotation in Rheumatology
(129, 22, '2025-04-16', NULL), -- Current rotation in Otolaryngology

(130, 24, '2025-04-01', '2025-04-14'), -- Past rotation in Pulmonology
(130, 25, '2025-04-15', NULL), -- Current rotation in Infectious Diseases

-- Remaining residents with simpler rotation patterns
(131, 1, '2025-04-15', NULL), -- Emergency Medicine
(132, 2, '2025-04-15', NULL), -- Internal Medicine
(133, 3, '2025-04-10', NULL), -- Cardiology
(134, 4, '2025-04-15', NULL), -- Pediatrics
(135, 5, '2025-04-15', NULL), -- Obstetrics and Gynecology
(136, 6, '2025-04-15', NULL), -- Neurology
(137, 7, '2025-04-15', NULL), -- General Surgery
(138, 8, '2025-04-15', NULL), -- Orthopedics
(139, 9, '2025-04-15', NULL), -- Anesthesiology
(140, 10, '2025-04-15', NULL), -- Radiology
(141, 11, '2025-04-15', NULL), -- Pathology
(142, 12, '2025-04-11', NULL), -- Psychiatry
(143, 13, '2025-04-12', NULL), -- Dermatology
(144, 14, '2025-04-15', NULL), -- Oncology
(145, 15, '2025-04-21', NULL), -- Endocrinology
(146, 16, '2025-04-11', NULL), -- Urology
(147, 17, '2025-04-15', NULL), -- Nephrology
(148, 18, '2025-04-15', NULL), -- Gastroenterology
(149, 19, '2025-04-15', NULL), -- Hematology
(150, 20, '2025-04-15', NULL); -- Ophthalmology

-- STAFF SHIFT PREFERENCES
-- Staff typically indicate which shifts they prefer to work when possible
INSERT INTO staff_shift_preferences (shift_time_id, staff_id) VALUES
-- Doctors (role_id = 3) - typical preferences
(1, 1), -- Morning shift (Emergency Medicine doctor)
(4, 2), -- Long Day (Cardiology doctor)
(1, 3), -- Morning shift (Surgery doctor)
(4, 4), -- Long Day (Pediatrics doctor)
(1, 5), -- Morning shift (Internal Medicine doctor)
(4, 6), -- Long Day (OB/GYN doctor)
(1, 7), -- Morning shift (Neurology doctor)
(1, 8), -- Morning shift (Orthopedics doctor)
(4, 9), -- Long Day (Anesthesiology doctor)
(1, 10), -- Morning shift (Radiology doctor)
(1, 11), -- Morning shift (Internal Medicine doctor)
(4, 12), -- Long Day (Psychiatry doctor)
(1, 13), -- Morning shift (Dermatology doctor)
(4, 14), -- Long Day (Oncology doctor)
(1, 15), -- Morning shift (Endocrinology doctor)
(1, 16), -- Morning shift (OB/GYN doctor)
(4, 17), -- Long Day (Urology doctor)
(1, 18), -- Morning shift (Nephrology doctor)
(4, 19), -- Long Day (Gastroenterology doctor)
(1, 20), -- Morning shift (Hematology doctor)

-- Some doctors have multiple preferences
(1, 21), (4, 21), -- Morning and Long Day (Ophthalmology doctor)
(1, 22), (2, 22), -- Morning and Afternoon (Rheumatology doctor)
(4, 23), (5, 23), -- Long Day and Long Night (Otolaryngology doctor)
(1, 24), (4, 24), -- Morning and Long Day (Plastic Surgery doctor)

-- More doctor preferences (continuing pattern)
(1, 25), (1, 26), (1, 27), (1, 28), (1, 29), (1, 30),
(2, 31), (2, 32), (2, 33), (2, 34), (2, 35), (2, 36),
(4, 37), (4, 38), (4, 39), (4, 40),

-- Nurses (role_id = 2) with varied shift preferences
(1, 41), -- Morning preference (ER nurse)
(2, 42), -- Afternoon preference (Internal Medicine nurse)
(3, 43), -- Overnight preference (Cardiology nurse)
(4, 44), -- Long Day preference (Pediatrics nurse)
(5, 45), -- Long Night preference (OB/GYN nurse)
(1, 46), -- Morning preference (Neurology nurse)
(2, 47), -- Afternoon preference (Surgery nurse)
(3, 48), -- Overnight preference (Orthopedics nurse)
(4, 49), -- Long Day preference (Anesthesiology nurse)
(5, 50), -- Long Night preference (Radiology nurse)

-- Many nurses have multiple preferences
(1, 51), (2, 51), -- Morning and Afternoon preferences
(2, 52), (3, 52), -- Afternoon and Overnight preferences
(3, 53), (5, 53), -- Overnight and Long Night preferences
(1, 54), (4, 54), -- Morning and Long Day preferences
(2, 55), (5, 55), -- Afternoon and Long Night preferences

-- More nurse preferences with distributions across all shift types
(1, 56), (1, 57), (1, 58), (1, 59), (1, 60), -- Morning preference
(2, 61), (2, 62), (2, 63), (2, 64), (2, 65), -- Afternoon preference
(3, 66), (3, 67), (3, 68), (3, 69), (3, 70), -- Overnight preference
(4, 71), (4, 72), (4, 73), (4, 74), (4, 75), -- Long Day preference
(5, 76), (5, 77), (5, 78), (5, 79), (5, 80), -- Long Night preference
(1, 81), (2, 82), (3, 83), (4, 84), (5, 85), -- Mixed preferences
(1, 86), (2, 87), (3, 88), (4, 89), (5, 90),
(1, 91), (2, 92), (3, 93), (4, 94), (5, 95),
(1, 96), (2, 97), (3, 98), (4, 99), (5, 100),
(1, 101), (2, 102), (3, 103), (4, 104), (5, 105),
(1, 106), (2, 107), (3, 108), (4, 109), (5, 110),

-- Residents (role_id = 1) - typically get assigned less desirable shifts
(3, 111), -- Overnight preference (resident in Emergency Medicine)
(5, 112), -- Long Night preference (resident in Cardiology)
(3, 113), -- Overnight preference (resident in Pediatrics)
(5, 114), -- Long Night preference (resident in Orthopedics)
(3, 115), -- Overnight preference (resident in Surgery)
(3, 116), -- Overnight preference (resident in Dermatology)
(5, 117), -- Long Night preference (resident in Hematology)
(3, 118), -- Overnight preference (resident in Nephrology)
(5, 119), -- Long Night preference (resident in Otolaryngology)
(3, 120), -- Overnight preference (resident in Internal Medicine)

-- More resident preferences with concentration on overnight/night shifts
(3, 121), (3, 122), (3, 123), (3, 124), (3, 125), -- Overnight preferences
(5, 126), (5, 127), (5, 128), (5, 129), (5, 130), -- Long Night preferences

-- Some residents also available for day shifts
(1, 131), (1, 132), (1, 133), (1, 134), (1, 135), -- Morning preferences
(2, 136), (2, 137), (2, 138), (2, 139), (2, 140), -- Afternoon preferences
(3, 141), (3, 142), (3, 143), (3, 144), (3, 145), -- Overnight preferences
(5, 146), (5, 147), (5, 148), (5, 149), (5, 150); -- Long Night preferences

-- LEAVE REQUESTS - updated for 30-day window
INSERT INTO leave_requests (staff_id, start_date, end_date, status) VALUES
-- Approved leaves (past)
(3, '2025-04-20', '2025-04-22', 'approved'),  -- Doctor - Surgery
(15, '2025-04-25', '2025-04-28', 'approved'), -- Doctor - Endocrinology
(24, '2025-04-30', '2025-05-02', 'approved'), -- Doctor - Plastic Surgery
(42, '2025-04-22', '2025-04-25', 'approved'), -- Nurse - Internal Medicine
(56, '2025-04-15', '2025-04-17', 'approved'), -- Nurse - Emergency Medicine
(73, '2025-04-24', '2025-04-25', 'approved'), -- Nurse - Cardiology

-- Approved leaves (current/ongoing during May 2025)
(8, '2025-05-05', '2025-05-07', 'approved'),  -- Doctor - Orthopedics
(19, '2025-05-01', '2025-05-07', 'approved'), -- Doctor - Gastroenterology
(41, '2025-04-30', '2025-05-05', 'approved'), -- Nurse - Emergency Medicine
(88, '2025-05-02', '2025-05-05', 'approved'), -- Nurse - Gastroenterology
(108, '2025-05-05', '2025-05-07', 'approved'), -- Nurse - Dermatology
(135, '2025-05-03', '2025-05-06', 'approved'), -- Resident - OB/GYN

-- Approved leaves (future)
(5, '2025-05-20', '2025-05-22', 'approved'),  -- Doctor - Internal Medicine
(11, '2025-05-25', '2025-05-30', 'approved'), -- Doctor - Internal Medicine
(22, '2025-05-15', '2025-05-17', 'approved'), -- Doctor - Rheumatology
(45, '2025-05-20', '2025-05-22', 'approved'), -- Nurse - OB/GYN
(67, '2025-05-15', '2025-05-18', 'approved'), -- Nurse - Pediatrics
(94, '2025-05-25', '2025-05-28', 'approved'), -- Nurse - Pulmonology
(111, '2025-05-15', '2025-05-18', 'approved'), -- Resident - Emergency Medicine
(124, '2025-05-20', '2025-05-22', 'approved'), -- Resident - Orthopedics

-- Pending leave requests
(2, '2025-05-20', '2025-05-22', 'pending'),  -- Doctor - Cardiology
(16, '2025-05-25', '2025-05-27', 'pending'), -- Doctor - OB/GYN
(27, '2025-05-15', '2025-05-17', 'pending'), -- Doctor - Surgery
(38, '2025-05-18', '2025-05-20', 'pending'), -- Doctor - Infectious Diseases
(49, '2025-05-20', '2025-05-22', 'pending'), -- Nurse - Anesthesiology
(60, '2025-05-25', '2025-05-27', 'pending'), -- Nurse - OB/GYN
(71, '2025-05-15', '2025-05-17', 'pending'), -- Nurse - Emergency Medicine
(82, '2025-05-20', '2025-05-22', 'pending'), -- Nurse - Psychiatry
(93, '2025-05-25', '2025-05-27', 'pending'), -- Nurse - Plastic Surgery
(104, '2025-05-18', '2025-05-20', 'pending'), -- Nurse - Anesthesiology
(115, '2025-05-20', '2025-05-22', 'pending'), -- Resident - Surgery
(126, '2025-05-25', '2025-05-27', 'pending'), -- Resident - Endocrinology
(137, '2025-05-15', '2025-05-17', 'pending'), -- Resident - Surgery
(148, '2025-05-20', '2025-05-22', 'pending'), -- Resident - Gastroenterology

-- Denied leave requests
(7, '2025-04-20', '2025-04-22', 'denied'),   -- Doctor - Neurology
(18, '2025-04-15', '2025-04-17', 'denied'),  -- Doctor - Nephrology
(29, '2025-04-25', '2025-04-27', 'denied'),  -- Doctor - Cardiology
(40, '2025-04-20', '2025-04-22', 'denied'),  -- Doctor - Cardiology
(51, '2025-04-25', '2025-04-27', 'denied'),  -- Nurse - Pathology
(62, '2025-04-22', '2025-04-24', 'denied'),  -- Nurse - Urology
(73, '2025-04-18', '2025-04-20', 'denied'),  -- Nurse - Cardiology
(84, '2025-04-24', '2025-04-27', 'denied'),  -- Nurse - Oncology
(95, '2025-04-20', '2025-04-22', 'denied'),  -- Nurse - Infectious Diseases
(106, '2025-04-21', '2025-04-23', 'denied'), -- Nurse - Pathology
(117, '2025-04-23', '2025-04-25', 'denied'), -- Resident - Hematology
(128, '2025-04-22', '2025-04-24', 'denied'), -- Resident - Ophthalmology
(139, '2025-04-25', '2025-04-27', 'denied'), -- Resident - Anesthesiology
(150, '2025-04-18', '2025-04-20', 'denied'), -- Resident - Ophthalmology

-- Some indefinite medical leaves (end_date is NULL)
(13, '2025-04-20', NULL, 'approved'),        -- Doctor on extended medical leave
(35, '2025-04-25', NULL, 'approved'),        -- Doctor on extended medical leave
(57, '2025-04-28', NULL, 'approved'),        -- Nurse on extended medical leave
(78, '2025-04-25', NULL, 'pending'),         -- Nurse with pending indefinite leave
(99, '2025-05-01', NULL, 'pending'),         -- Nurse with pending indefinite leave
(120, '2025-04-20', NULL, 'approved');       -- Resident on extended medical leave

-- shift_assignments.sql - Fixed version
-- This script generates shift assignments for all staff members 
-- for the 30-day period ending on May 7, 2025

-- First, clear any existing shift assignments to avoid conflicts
TRUNCATE TABLE shift_assignments CASCADE;

-- Create a temporary function to generate shift assignments more efficiently
CREATE OR REPLACE FUNCTION generate_shift_assignments()
RETURNS void AS $$
DECLARE
    period_start_date DATE := '2025-04-07';  -- 30 days before current date
    period_end_date DATE := '2025-05-07';    -- current date
    staff_rec RECORD;
    dept_rec RECORD;
    shift_rec RECORD;
    leave_days INT[];
    assigned_shifts INT[];
    dow_pattern INT[];
    shift_id INT;
    assignment_count INT;
    pref_shift_type_id INT;
    workday_count INT;
    should_skip BOOLEAN;
BEGIN
    -- Process each staff member
    FOR staff_rec IN 
        SELECT s.id, s.name, r.id AS role_id, r.name AS role_name, 
               r.on_call_allowed, r.overtime_allowed
        FROM staff s
        JOIN roles r ON s.role_id = r.id
        ORDER BY s.id
    LOOP
        -- Skip staff that are on indefinite medical leave
        SELECT EXISTS (
            SELECT 1 FROM leave_requests lr
            WHERE lr.staff_id = staff_rec.id 
            AND lr.status = 'approved' 
            AND lr.end_date IS NULL
            AND lr.start_date <= period_end_date
        ) INTO should_skip;
        
        IF should_skip THEN
            CONTINUE;
        END IF;
        
        -- Get leave days for this staff member
        leave_days := ARRAY(
            SELECT EXTRACT(DAY FROM date_series)::INT 
            FROM generate_series(period_start_date, period_end_date, '1 day'::interval) AS date_series
            WHERE EXISTS (
                SELECT 1 FROM leave_requests lr
                WHERE lr.staff_id = staff_rec.id
                AND lr.status = 'approved'
                AND date_series BETWEEN lr.start_date AND COALESCE(lr.end_date, '2099-12-31')
            )
        );
        
        -- Get preferred shift type ID (default to role-appropriate if none found)
        SELECT shift_time_id INTO pref_shift_type_id
        FROM staff_shift_preferences
        WHERE staff_id = staff_rec.id
        ORDER BY RANDOM()
        LIMIT 1;
        
        -- Default preferences based on role if none found
        IF pref_shift_type_id IS NULL THEN
            IF staff_rec.role_id = 1 THEN -- Residents
                pref_shift_type_id := 3; -- Overnight
            ELSIF staff_rec.role_id = 2 THEN -- Nurses
                pref_shift_type_id := CASE WHEN RANDOM() < 0.5 THEN 1 ELSE 2 END; -- Morning or Afternoon
            ELSE -- Doctors
                pref_shift_type_id := 1; -- Morning
            END IF;
        END IF;
        
        -- Initialize assigned shifts array
        assigned_shifts := '{}';
        assignment_count := 0;
        
        -- For each department the staff member belongs to
        FOR dept_rec IN 
            SELECT sd.department_id, d.name AS dept_name
            FROM staff_departments sd
            JOIN departments d ON sd.department_id = d.id
            WHERE sd.staff_id = staff_rec.id
            AND (sd.end_date IS NULL OR sd.end_date >= period_start_date)
            AND sd.start_date <= period_end_date
        LOOP
            -- Create day of week pattern based on staff role and department
            -- This ensures staff work different patterns in different departments
            -- Doctors typically work 3-5 days per week
            -- Nurses typically work 3-4 days per week
            -- Residents typically work 2-3 days per week
            IF staff_rec.role_id = 3 THEN -- Doctors
                workday_count := FLOOR(3 + 2 * RANDOM());
                IF workday_count = 3 THEN
                    dow_pattern := ARRAY[1, 3, 5]; -- Mon, Wed, Fri
                ELSIF workday_count = 4 THEN
                    dow_pattern := ARRAY[1, 2, 3, 4]; -- Mon-Thu
                ELSE
                    dow_pattern := ARRAY[1, 2, 3, 4, 5]; -- Mon-Fri
                END IF;
                
                -- Add weekend coverage for some doctors (20% chance)
                IF RANDOM() < 0.2 THEN
                    dow_pattern := dow_pattern || ARRAY[0, 6]; -- Add weekend
                END IF;
            ELSIF staff_rec.role_id = 2 THEN -- Nurses
                workday_count := FLOOR(3 + RANDOM());
                IF workday_count = 3 THEN
                    IF RANDOM() < 0.5 THEN
                        dow_pattern := ARRAY[0, 2, 4, 6]; -- Sun, Tue, Thu, Sat
                    ELSE
                        dow_pattern := ARRAY[1, 3, 5]; -- Mon, Wed, Fri
                    END IF;
                ELSE
                    IF RANDOM() < 0.5 THEN
                        dow_pattern := ARRAY[1, 2, 3, 4]; -- Mon-Thu
                    ELSE
                        dow_pattern := ARRAY[0, 2, 4, 6]; -- Sun, Tue, Thu, Sat
                    END IF;
                END IF;
            ELSE -- Residents
                workday_count := FLOOR(2 + RANDOM());
                IF workday_count = 2 THEN
                    dow_pattern := ARRAY[2, 4]; -- Tue, Thu
                ELSE
                    dow_pattern := ARRAY[1, 3, 5]; -- Mon, Wed, Fri
                END IF;
                
                -- Add weekend coverage for some residents (40% chance)
                IF RANDOM() < 0.4 THEN
                    dow_pattern := dow_pattern || ARRAY[0, 6]; -- Add weekend
                END IF;
            END IF;
            
            -- Find appropriate shifts based on preferred shift type and day of week pattern
            FOR shift_rec IN 
                SELECT s.id, s.date, s.shift_time_id, EXTRACT(DOW FROM s.date)::INT AS dow
                FROM shifts s
                WHERE s.date BETWEEN period_start_date AND period_end_date
                AND EXTRACT(DOW FROM s.date)::INT = ANY(dow_pattern)
                AND s.shift_time_id = pref_shift_type_id
                AND NOT (EXTRACT(DAY FROM s.date)::INT = ANY(leave_days))
                ORDER BY s.date
            LOOP
                -- Check if shift is already assigned to this staff member
                IF shift_rec.id = ANY(assigned_shifts) THEN
                    CONTINUE;
                END IF;
                
                -- Make sure we don't assign too many shifts
                -- Doctors - max 15 shifts per month (roughly 3-4 per week)
                -- Nurses - max 20 shifts per month (roughly 4-5 per week)
                -- Residents - max 22 shifts per month (roughly 5-6 per week)
                IF (staff_rec.role_id = 3 AND assignment_count >= 15) OR
                   (staff_rec.role_id = 2 AND assignment_count >= 20) OR
                   (staff_rec.role_id = 1 AND assignment_count >= 22) THEN
                    CONTINUE;
                END IF;
                
                -- Insert the shift assignment
                INSERT INTO shift_assignments (shift_id, department_id, staff_id, shift_type)
                VALUES (shift_rec.id, dept_rec.department_id, staff_rec.id, 
                       CASE WHEN staff_rec.on_call_allowed AND RANDOM() < 0.2 THEN 'on-call' ELSE 'regular' END);
                
                -- Update tracking variables
                assigned_shifts := assigned_shifts || shift_rec.id;
                assignment_count := assignment_count + 1;
            END LOOP;
            
            -- Try to assign a secondary shift type if not enough shifts were assigned
            -- This ensures better coverage and that every staff member gets shifts
            IF assignment_count < 10 THEN
                -- Pick a different shift type
                IF pref_shift_type_id = 1 THEN
                    pref_shift_type_id := 2; -- Afternoon if Morning was preferred
                ELSIF pref_shift_type_id = 2 THEN
                    pref_shift_type_id := 3; -- Overnight if Afternoon was preferred
                ELSE
                    pref_shift_type_id := 1; -- Morning if other was preferred
                END IF;
                
                -- Find additional shifts
                FOR shift_rec IN 
                    SELECT s.id, s.date, s.shift_time_id, EXTRACT(DOW FROM s.date)::INT AS dow
                    FROM shifts s
                    WHERE s.date BETWEEN period_start_date AND period_end_date
                    AND EXTRACT(DOW FROM s.date)::INT = ANY(dow_pattern)
                    AND s.shift_time_id = pref_shift_type_id
                    AND NOT (EXTRACT(DAY FROM s.date)::INT = ANY(leave_days))
                    ORDER BY s.date
                    LIMIT (10 - assignment_count)
                LOOP
                    -- Check if shift is already assigned to this staff member
                    IF shift_rec.id = ANY(assigned_shifts) THEN
                        CONTINUE;
                    END IF;
                    
                    -- Insert the shift assignment
                    INSERT INTO shift_assignments (shift_id, department_id, staff_id, shift_type)
                    VALUES (shift_rec.id, dept_rec.department_id, staff_rec.id, 'regular');
                    
                    -- Update tracking variables
                    assigned_shifts := assigned_shifts || shift_rec.id;
                    assignment_count := assignment_count + 1;
                END LOOP;
            END IF;
        END LOOP;
        
        -- Make sure every staff member has at least one shift unless on extended leave
        IF array_length(assigned_shifts, 1) IS NULL THEN
            -- Find any valid shift for this staff member
            SELECT s.id INTO shift_id
            FROM shifts s
            CROSS JOIN staff_departments sd
            WHERE s.date BETWEEN period_start_date AND period_end_date
            AND sd.staff_id = staff_rec.id
            AND (sd.end_date IS NULL OR sd.end_date >= period_start_date)
            AND sd.start_date <= period_end_date
            AND NOT (EXTRACT(DAY FROM s.date)::INT = ANY(leave_days))
            ORDER BY RANDOM()
            LIMIT 1;
            
            IF shift_id IS NOT NULL THEN
                -- Insert at least one shift assignment
                INSERT INTO shift_assignments (shift_id, department_id, staff_id, shift_type)
                SELECT shift_id, department_id, staff_rec.id, 'regular'
                FROM staff_departments
                WHERE staff_id = staff_rec.id
                AND (end_date IS NULL OR end_date >= period_start_date)
                AND start_date <= period_end_date
                ORDER BY RANDOM()
                LIMIT 1;
            END IF;
        END IF;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Run the function to generate shift assignments
SELECT generate_shift_assignments();

-- Drop the temporary function
DROP FUNCTION generate_shift_assignments();

-- Generate shift logs for all shift assignments
INSERT INTO shift_logs (assignment_id, check_in, check_out)
SELECT 
    sa.id,
    -- Check-in times with variations by staff role and individual patterns
    CASE 
        -- Doctors: mix of early, on time, and occasionally late
        WHEN s.role_id = 3 THEN
            CASE 
                WHEN random() < 0.60 THEN (sh.date + st.start_time - interval '5 minutes')::timestamp
                WHEN random() < 0.85 THEN (sh.date + st.start_time)::timestamp
                WHEN random() < 0.95 THEN (sh.date + st.start_time + interval '7 minutes')::timestamp
                ELSE NULL -- Very rarely miss a shift (no check-in)
            END
        -- Nurses: mostly on time, occasionally early or late
        WHEN s.role_id = 2 THEN
            CASE 
                WHEN random() < 0.40 THEN (sh.date + st.start_time - interval '10 minutes')::timestamp
                WHEN random() < 0.80 THEN (sh.date + st.start_time)::timestamp
                WHEN random() < 0.98 THEN (sh.date + st.start_time + interval '12 minutes')::timestamp
                ELSE NULL -- Rarely miss a shift
            END
        -- Residents: almost always early, occasionally very early
        ELSE
            CASE
                WHEN random() < 0.70 THEN (sh.date + st.start_time - interval '15 minutes')::timestamp
                WHEN random() < 0.90 THEN (sh.date + st.start_time - interval '5 minutes')::timestamp
                WHEN random() < 0.99 THEN (sh.date + st.start_time)::timestamp
                ELSE NULL -- Very rarely miss a shift
            END
    END,
    
    -- Check-out times with variations by staff role
    CASE
        -- If no check-in, then no check-out
        WHEN CASE 
                WHEN s.role_id = 3 THEN
                    CASE 
                        WHEN random() < 0.60 THEN (sh.date + st.start_time - interval '5 minutes')::timestamp
                        WHEN random() < 0.85 THEN (sh.date + st.start_time)::timestamp
                        WHEN random() < 0.95 THEN (sh.date + st.start_time + interval '7 minutes')::timestamp
                        ELSE NULL
                    END
                WHEN s.role_id = 2 THEN
                    CASE 
                        WHEN random() < 0.40 THEN (sh.date + st.start_time - interval '10 minutes')::timestamp
                        WHEN random() < 0.80 THEN (sh.date + st.start_time)::timestamp
                        WHEN random() < 0.98 THEN (sh.date + st.start_time + interval '12 minutes')::timestamp
                        ELSE NULL
                    END
                ELSE
                    CASE
                        WHEN random() < 0.70 THEN (sh.date + st.start_time - interval '15 minutes')::timestamp
                        WHEN random() < 0.90 THEN (sh.date + st.start_time - interval '5 minutes')::timestamp
                        WHEN random() < 0.99 THEN (sh.date + st.start_time)::timestamp
                        ELSE NULL
                    END
            END IS NULL THEN NULL
        
        -- Doctors: often stay late
        WHEN s.role_id = 3 THEN
            CASE 
                WHEN random() < 0.05 THEN (sh.date + st.end_time - interval '20 minutes')::timestamp
                WHEN random() < 0.30 THEN (sh.date + st.end_time)::timestamp
                ELSE (sh.date + st.end_time + interval '30 minutes')::timestamp
            END
            
        -- Nurses: mix of on time and slightly late
        WHEN s.role_id = 2 THEN
            CASE 
                WHEN random() < 0.10 THEN (sh.date + st.end_time - interval '15 minutes')::timestamp
                WHEN random() < 0.60 THEN (sh.date + st.end_time)::timestamp
                ELSE (sh.date + st.end_time + interval '20 minutes')::timestamp
            END
            
        -- Residents: almost always stay late, sometimes very late
        ELSE
            CASE
                WHEN random() < 0.02 THEN (sh.date + st.end_time)::timestamp
                WHEN random() < 0.40 THEN (sh.date + st.end_time + interval '30 minutes')::timestamp
                ELSE (sh.date + st.end_time + interval '60 minutes')::timestamp
            END
    END
FROM 
    shift_assignments sa
    JOIN shifts sh ON sa.shift_id = sh.id
    JOIN shift_times st ON sh.shift_time_id = st.id
    JOIN staff s ON sa.staff_id = s.id;

-- Record overtime for eligible staff who stayed past their scheduled end time
INSERT INTO overtimes (shift_assignment_id, duration)
SELECT 
    sl.assignment_id,
    (sl.check_out - (sh.date + st.end_time)::timestamp) AS duration
FROM 
    shift_logs sl
    JOIN shift_assignments sa ON sl.assignment_id = sa.id
    JOIN shifts sh ON sa.shift_id = sh.id
    JOIN shift_times st ON sh.shift_time_id = st.id
    JOIN staff s ON sa.staff_id = s.id
    JOIN roles r ON s.role_id = r.id
WHERE 
    r.overtime_allowed = true -- Only roles allowed overtime
    AND sl.check_out IS NOT NULL -- Only when checkout is recorded
    AND sl.check_out > (sh.date + st.end_time)::timestamp -- Only when staying late
    AND (sl.check_out - (sh.date + st.end_time)::timestamp) <= interval '4 hours' -- Within max allowed
    -- Probability factors by role
    AND (
        (s.role_id = 3 AND random() < 0.8) -- Doctors: high probability of getting overtime approved
        OR (s.role_id = 2 AND random() < 0.6) -- Nurses: moderate probability
    );
