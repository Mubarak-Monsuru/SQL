--- Examine data
SELECT *
FROM netflix_table

--- Convert column 'date_added' to date type and add a new column for it
SElECT date_added, CONVERT(date, date_added)
FROM netflix_table

ALTER TABLE netflix_table
ADD date_added_new date;

UPDATE netflix_table
SET date_added_new = CONVERT(date, date_added)

--- Generate more columns from the new date column such as weekday, year, month etc.
SELECT date_added_new, DATENAME(weekday, date_added_new) week_day,
	DATENAME(year, date_added_new) year_added,
	DATENAME(MONTH, date_added_new) month_of_year,
	DATENAME(DAY, date_added_new) date_of_month,
	DATENAME(WEEK, date_added_new) week_of_year
FROM netflix_table


SELECT duration, COUNT(duration)
FROM netflix_table
WHERE duration LIKE '%Season%'
GROUP BY duration

--- Seperate 'duration' column into two columns for movies which durations are in'Season/Seasons' and the ones duration are in 'min'
SELECT duration,
CASE
	WHEN duration LIKE '%Season%' THEN duration
	ELSE ''
END
FROM netflix_table


SELECT duration,
CASE
	WHEN duration LIKE '%min%' THEN duration
	ELSE ''
END
FROM netflix_table

ALTER TABLE netflix_table
ADD season nvarchar(255),
	duration_min nvarchar(255)

UPDATE netflix_table
SET season = CASE
	WHEN duration LIKE '%Season%' THEN duration
	ELSE ''
END
FROM netflix_table

UPDATE netflix_table
SET duration_min = CASE
	WHEN duration LIKE '%min%' THEN duration
	ELSE ''
END
FROM netflix_table

--- Remove 'Season/Seasons' from column 'season' and convert it to int type
SELECT season, REPLACE(season, 'Seasons', '')
FROM netflix_table

UPDATE netflix_table
SET season = REPLACE(season, 'Seasons', '')

UPDATE netflix_table
SET season = REPLACE(season, 'Season', '')

UPDATE netflix_table
SET season = CONVERT(int, season)

--- Remove 'minrom column 'duration_min' and convert it to int type
SELECT duration_min, CONVERT(int, REPLACE(duration_min, 'min', ''))
FROM netflix_table

UPDATE netflix_table
SET duration_min = CONVERT(int, REPLACE(duration_min, 'min', ''))

--- Convert both columns to INT
ALTER TABLE netflix_table
ALTER COLUMN season INT;

ALTER TABLE netflix_table
ALTER COLUMN duration_min INT;

SELECT SUM(season), SUM(duration_min)
FROM netflix_table
WHERE duration_min <> 0

--- Split column 'listed_in' into 3 new columns, separated by ','
WITH SplitData AS (
    SELECT 
        show_id,
        value AS listed_value,
        ROW_NUMBER() OVER (PARTITION BY show_id ORDER BY (SELECT 1)) AS value_num
    FROM 
        netflix_table
    CROSS APPLY 
        STRING_SPLIT(listed_in, ',')
	-- WHERE listed_in <> ''
)
SELECT 
    show_id,
    MAX(CASE WHEN value_num = 1 THEN listed_value END) AS listed_in_1,
    MAX(CASE WHEN value_num = 2 THEN listed_value END) AS listed_in_2,
    MAX(CASE WHEN value_num = 3 THEN listed_value END) AS listed_in_3
FROM 
    SplitData
GROUP BY 
    show_id;

ALTER TABLE netflix_table
ADD listed_in_1 NVARCHAR(255), -- Adjust size if needed
    listed_in_2 NVARCHAR(255),
    listed_in_3 NVARCHAR(255);

WITH SplitData AS (
    SELECT 
        show_id,
        value AS listed_value,
        ROW_NUMBER() OVER (PARTITION BY show_id ORDER BY (SELECT 1)) AS value_num
    FROM 
        netflix_table
    CROSS APPLY 
        STRING_SPLIT(listed_in, ',')
)
UPDATE netflix_table
SET 
    listed_in_1 = SplitData.listed_in_1,
    listed_in_2 = SplitData.listed_in_2,
    listed_in_3 = SplitData.listed_in_3
FROM (
    SELECT 
        show_id,
        MAX(CASE WHEN value_num = 1 THEN listed_value END) AS listed_in_1,
        MAX(CASE WHEN value_num = 2 THEN listed_value END) AS listed_in_2,
        MAX(CASE WHEN value_num = 3 THEN listed_value END) AS listed_in_3
    FROM 
        SplitData
    GROUP BY 
        show_id
) AS SplitData
WHERE netflix_table.show_id = SplitData.show_id;