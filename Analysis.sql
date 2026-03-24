-- Visualize the table
SELECT * FROM `students-project-489823.students_dropout_project.students_table`;


-- Quality checks


-- Look for missing values 
SELECT * FROM `students-project-489823.students_dropout_project.students_table` 
WHERE `students-project-489823.students_dropout_project.students_table` IS NULL;
-- There're not missing values

-- Look for duplicates values
SELECT student_id, COUNT(*) FROM `students-project-489823.students_dropout_project.students_table` 
GROUP BY student_id 
HAVING COUNT(*) > 1;
-- There're not duplicates values

-- Look for unaccpted values
SELECT * FROM `students-project-489823.students_dropout_project.students_table` 
WHERE label_name 
NOT IN('active', 'at-risk', 'dropped');
-- All values in the dataset are accepted

-- Verify functional rules
SELECT * FROM `students-project-489823.students_dropout_project.students_table` 
WHERE courses_enrolled <= 0;
-- All data is functional, there're no students without enrolled courses

-- Look for outliers
SELECT * FROM `students-project-489823.students_dropout_project.students_table` 
WHERE last_activity_days_ago <=0 
OR last_activity_days_ago >70;
-- There're no students whith more than 70 days of inactivity

-- Look for Datatype errors
SELECT * FROM `students-project-489823.students_dropout_project.students_table` 
WHERE SAFE_CAST(age AS INTEGER) IS NULL;
-- There're no Datatype erros

-- Students by year
SELECT 
  DATE_TRUNC(enroll_date, YEAR) AS year,
  COUNT(*) AS students
FROM `students-project-489823.students_dropout_project.students_table`
GROUP BY year
ORDER BY year;
-- From this query we can see all data is from 2024


-- Exploratory Data Analysis


-- Students by month
SELECT 
  DATE_TRUNC(enroll_date, MONTH) AS month,
  COUNT(*) AS students
FROM `students-project-489823.students_dropout_project.students_table`
GROUP BY month
ORDER BY month;
-- Shows the enrolled students by month

-- Students by region
SELECT DISTINCT region FROM `students-project-489823.students_dropout_project.students_table`;
-- There are students from 10 diferent regions

-- Divide students by label
SELECT label_name, COUNT(label_name) FROM `students-project-489823.students_dropout_project.students_table` 
GROUP BY label_name;
-- The difference between active, at-risk and dropped students is almost balanced 

-- Summary students age
SELECT 
  MIN(age) AS min_age,
  MAX(age) AS max_age,
  ROUND(AVG(age),2) AS avg_age,
FROM `students-project-489823.students_dropout_project.students_table`;
-- Students go from 17 years old to 40 being 23 years te average age,

-- Number of students by region
SELECT region, COUNT(region) AS students_per_region FROM `students-project-489823.students_dropout_project.students_table` 
GROUP BY region 
ORDER BY students_per_region DESC;
-- Order the regions by number of students

-- Dropout by region
SELECT
  region,
  COUNT(*) AS total_students,
  SUM(CASE WHEN label_name = 'dropped' THEN 1 ELSE 0 END) AS dropped_students,
  ROUND(
    SUM(CASE WHEN label_name = 'dropped' THEN 1 ELSE 0 END) / COUNT(*),
    3
  ) AS dropout_rate
FROM `students-project-489823.students_dropout_project.students_table`
GROUP BY region
ORDER BY dropout_rate DESC;
-- There's no high difference students dropping out between regions however Beirut, Casablanca and Doha are the top three regions

-- Average student per label
SELECT label_name,
  ROUND(AVG(exam_season),2) AS avg_exam_season,
  ROUND(AVG(courses_enrolled),2) AS avg_courses_enrolled,
  ROUND(AVG(completed_assignments),2) AS avg_completed_assignments,
  ROUND(AVG(completion_rate),2) AS avg_completion_rate,
  ROUND(AVG(login_frequency),2) AS avg_login_frequency,
  ROUND(AVG(last_activity_days_ago),2) AS avg_last_activity_days_ago,
  ROUND(AVG(forum_posts_count),2) AS avg_forum_posts_count,
  ROUND(AVG(dropout_score),2)AS avg_dropout_score,
FROM `students-project-489823.students_dropout_project.students_table` 
GROUP BY label_name;
-- The students who dropped out have a higher exam season, were enrolled in more courses but their rate in completed less assignments, login frequency and forum post is lower than the other students and theirs period of last activity is longer.

-- Summary students engagement
SELECT
  label_name,
  ROUND(AVG(login_frequency),2) AS avg_login,
  ROUND(AVG(forum_posts_count),2) AS avg_forum_posts,
  ROUND(AVG(completion_rate),2) AS avg_completion
FROM `students-project-489823.students_dropout_project.students_table`
GROUP BY label_name
ORDER BY avg_login DESC;
-- Students who log in more often, participate more in forums, and have a higher completion rate are the ones who stay.

-- Categorize students by age
WITH students_by_age AS (
  SELECT *,
    CASE
      WHEN age < 20 THEN 'under 20'
      WHEN age BETWEEN 20 AND 24 THEN 'early 20s'
      WHEN age BETWEEN 25 AND 29 THEN 'late 20s'
      WHEN age BETWEEN 30 AND 34 THEN 'early 30s'
      WHEN age BETWEEN 35 AND 40 THEN 'late 30s'
      ELSE '+40'
    END AS age_group
  FROM `students-project-489823.students_dropout_project.students_table`
)

SELECT
  age_group,
  COUNT(*) AS total_students,
  SUM(CASE WHEN label_name = 'dropped' THEN 1 ELSE 0 END) AS dropped_students,
  ROUND(
    SUM(CASE WHEN label_name = 'dropped' THEN 1 ELSE 0 END) / COUNT(*),
    3
  ) AS dropout_rate
FROM students_by_age
GROUP BY age_group
ORDER BY age_group;
-- Almost all age categories have a similar dropout rate, only those under 20 having a slightly higher rate.
