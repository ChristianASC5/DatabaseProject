DROP DATABASE IF EXISTS `Gradebook`;
CREATE DATABASE `Gradebook`;
USE `Gradebook`;

-- 2. Create tables and insert values
CREATE TABLE courses (
    course_id INT NOT NULL AUTO_INCREMENT,
    course_department VARCHAR(50) NOT NULL,
    course_number VARCHAR(10) NOT NULL,
    course_name VARCHAR(100) NOT NULL,
    course_semester VARCHAR(20) NOT NULL,
    course_year INTEGER NOT NULL,
    PRIMARY KEY (course_id)
);

CREATE TABLE categories (
    category_id INT NOT NULL AUTO_INCREMENT,
    category_name VARCHAR(50) NOT NULL,
    category_weight DECIMAL(5,2) NOT NULL,
    course_id INT NOT NULL,
    PRIMARY KEY (category_id),
    FOREIGN KEY (course_id) REFERENCES courses(course_id)
);

CREATE TABLE assignments (
    assignment_id INT NOT NULL AUTO_INCREMENT,
    assignment_name VARCHAR(100) NOT NULL,
    category_id INT NOT NULL,
    assignment_total_points INTEGER NOT NULL,
    assignment_due_date DATE,
    PRIMARY KEY (assignment_id),
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

CREATE TABLE students (
    student_id INT NOT NULL AUTO_INCREMENT,
    student_first_name VARCHAR(50) NOT NULL,
    student_last_name VARCHAR(50) NOT NULL,
    student_email VARCHAR(100) NOT NULL,
    PRIMARY KEY (student_id)
);

CREATE TABLE grades (
    grade_id INT NOT NULL AUTO_INCREMENT,
    student_id INT NOT NULL,
    assignment_id INT NOT NULL,
    grade_score INT NOT NULL,
    grade_submission_date DATE,
    PRIMARY KEY (grade_id),
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (assignment_id) REFERENCES assignments(assignment_id)
);

INSERT INTO courses (course_department, course_number, course_name, course_semester, course_year)
VALUES ('CSE', '101', 'Introduction to Computer Science', 'Fall', 2022),
       ('MATH', '202', 'Calculus II', 'Spring', 2023);

INSERT INTO categories (category_name, category_weight, course_id)
VALUES ('Participation', 0.10, 1),
       ('Homework', 0.20, 1),
       ('Tests', 0.50, 1),
       ('Projects', 0.20, 1),
       ('Attendance', 0.05, 2),
       ('Homework', 0.20, 2),
       ('Tests', 0.45, 2),
       ('Quizzes', 0.30, 2);

INSERT INTO assignments (assignment_name, category_id, assignment_total_points, assignment_due_date)
VALUES ('Participation 1', 1, 10, '2022-09-15'),
       ('Homework 1', 2, 20, '2022-09-22'),
       ('Test 1', 3, 100, '2022-10-01'),
       ('Project 1', 4, 50, '2022-11-01'),
       ('Attendance 1', 5, 1, '2022-09-15'),
       ('Homework 1', 6, 20, '2022-09-22'),
       ('Test 1', 7, 100, '2022-10-01'),
       ('Quiz 1', 8, 50, '2022-11-01');

INSERT INTO students (student_first_name, student_last_name, student_email)
VALUES ('Dorey', 'Winley', 'dwinley0@ask.com'),
       ('Dale', 'Queen', 'dcolles2@addthis.com'),
       ('Hirch', 'Warrack', 'hwarrack1@acquirethisname.com');

INSERT INTO grades (student_id, assignment_id, grade_score, grade_submission_date)
VALUES (1, 1, 8, '2022-09-17'),
       (1, 2, 18, '2022-09-24'),
       (1, 3, 87, '2022-10-02'),
       (1, 4, 45, '2022-11-02'),
       (1, 5, 0, '2022-09-17'),
       (1, 6, 15, '2022-09-24'),
       (1, 7, 90, '2022-10-02'),
       (1, 8, 45, '2022-11-02'),
       (2, 1, 9, '2022-09-17'),
       (2, 2, 20, '2022-09-24'),
       (2, 3, 92, '2022-10-02'),
	   (2, 4, 48, '2022-11-02'),
	   (3, 5, 1, '2022-09-17'),
       (3, 6, 18, '2022-09-24'),
       (3, 7, 88, '2022-10-02'),
       (3, 8, 40, '2022-11-02');
       
-- 3. Show tables with contents
SELECT * FROM courses;
SELECT * FROM categories;
SELECT * FROM assignments;
SELECT * FROM students;
SELECT * FROM grades;

-- 4. Compute average/highest/lowest score of an assignment
SELECT assignment_id, AVG(grade_score) AS average_score, MAX(grade_score) AS highest_score, MIN(grade_score) AS lowest_score
FROM grades
WHERE assignment_id = 1
GROUP BY assignment_id;

-- 5. List all of the students in a given course
SELECT *
FROM students
WHERE student_id IN (
  SELECT student_id
  FROM grades
  WHERE assignment_id IN (
    SELECT assignment_id
    FROM assignments
    WHERE category_id IN (
      SELECT category_id
      FROM categories
      WHERE course_id = 2
    )
  )
);

-- 6. List all of the students in a course and all of their scores on every assignment
SELECT students.student_id, student_first_name, student_last_name, assignment_name, grade_score
FROM students
JOIN grades ON students.student_id = grades.student_id
JOIN assignments ON grades.assignment_id = assignments.assignment_id
JOIN categories ON assignments.category_id = categories.category_id
WHERE categories.course_id = 2
ORDER BY students.student_id, assignments.assignment_id;

-- 7. Add an assignment to a course
INSERT INTO assignments (assignment_name, category_id, assignment_total_points, assignment_due_date)
VALUES ('Homework 2', 2, 20, '2022-09-29');

INSERT INTO grades (student_id, assignment_id, grade_score, grade_submission_date)
VALUES (1, 9, 20, '2022-09-17');

-- 8. Change the percentages of the categories for a course
UPDATE categories
SET category_weight = 0.60
WHERE course_id = 1 AND category_name = 'Tests';

UPDATE categories
SET category_weight = 0.15
WHERE course_id = 1 AND category_name = 'Homework';

UPDATE categories
SET category_weight = 0.15
WHERE course_id = 1 AND category_name = 'Projects';

-- 9. Add 2 points to the score of each student on an assignment
UPDATE grades
SET grade_score = grade_score + 2
WHERE assignment_id = 3;

-- 10. Add 2 points just to those students whose last name contains a 'Q'
UPDATE grades
SET grade_score = grade_score + 2
WHERE assignment_id = 3 AND student_id IN (
  SELECT student_id
  FROM students
  WHERE student_last_name LIKE '%Q%'
);

-- 11. Compute the grade for a student
SELECT student_first_name, student_last_name, course_name, SUM(crs_grades.weighted_grade * 100) AS Course_Avg
FROM(
	SELECT a.category_id, s.student_first_name, s.student_last_name, crs.course_name, crs.course_id, c.category_weight, AVG(g.grade_score / a.assignment_total_points * c.category_weight) as weighted_grade
	FROM grades g
	JOIN students s ON s.student_id = g.student_id
	JOIN assignments a ON g.assignment_id = a.assignment_id
	JOIN categories c ON c.category_id = a.category_id
	JOIN courses crs ON c.course_id = crs.course_id
	WHERE g.student_id = 1 and c.course_id = 2
	GROUP BY a.category_id
) AS crs_grades
GROUP BY student_first_name;

