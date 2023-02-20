select * from dbo.Cleaned_Weather_data

-- 1. Give the count of the minimum number of days for the time when temperature reduced

SELECT COUNT(*) as min_days
FROM (
  SELECT Date, Avg_Temperature, 
    LAG(Avg_Temperature, 1) OVER (ORDER BY Date) as prev_temp
  FROM dbo.Cleaned_Weather_data
) as temp_table
WHERE Avg_Temperature < prev_temp;



-- 2. Find the temperature as Cold / hot by using the case and avg of values of the given data set

WITH CTE1 AS 
	(SELECT Date,
			Avg_temperature 
	 FROM dbo.Cleaned_Weather_data)
SELECT Date, Avg_temperature,
CASE 
    WHEN Avg_temperature >= AVG(CAST(Avg_Temperature AS decimal(4,1))) OVER() THEN 'Hot'
    ELSE 'Cold'
END AS 'temp_status'
FROM CTE1
ORDER BY Date
;


-- 3. Can you check for all 4 consecutive days when the temperature was below 30 Fahrenheit

WITH Temp_below_30 as(
	SELECT * 
	FROM dbo.Cleaned_Weather_data
	WHERE TRY_CAST(Avg_Temperature AS decimal(4, 1)) < 30
) 
SELECT DISTINCT t1.Date,t1.Avg_Temperature,t2.Date,t2.Avg_Temperature,t3.Date,t3.Avg_Temperature,t4.Date,t4.Avg_Temperature
FROM Temp_below_30 t1
JOIN Temp_below_30 t2 on t2.Date = DATEADD(day, 1, t1.date) 
JOIN Temp_below_30 t3 on t3.Date = DATEADD(day, 2, t1.date) 
JOIN Temp_below_30 t4 on t4.Date = DATEADD(day, 3, t1.date) 
WHERE CAST(t1.Avg_Temperature AS decimal(4, 1)) < 30 
  and CAST(t2.Avg_Temperature AS decimal(4, 1)) < 30 
  and CAST(t3.Avg_Temperature AS decimal(4, 1)) < 30 
  and CAST(t4.Avg_Temperature AS decimal(4, 1)) < 30;


-- 4. Can you find the maximum number of days for which temperature dropped

WITH cte as (
	SELECT DATE, Avg_Temperature,
		CASE WHEN Avg_Temperature < LAG(Avg_Temperature) OVER(ORDER BY date) THEN 1 ELSE 0 END AS Temp_Drop
	FROM dbo.Cleaned_Weather_data
)
SELECT SUM(Temp_Drop) as Max_No_Of_Days_Temp_dropped
FROM cte


-- 5. Can you find the average of average humidity from the dataset ( NOTE: should contain the following clauses: group by, order by, date )

SELECT AVG(Average__Humidity) as AvgOFAvgHumidity
FROM (
	SELECT Date,AVG(CAST(Avg_Humidity AS decimal(4,1))) AS Average__Humidity
	FROM dbo.Cleaned_Weather_data
	GROUP BY Date
) as Temp
;

-- 6.Use the GROUP BY clause on the Date column and make a query to fetch details for average windspeed ( which is now windspeed done in task 3 )

SELECT AVG(Average_windspeed) as AvgOFAvgWindspeed
FROM (
	SELECT Date,AVG(CAST(Avg_windspeed AS decimal(4,1))) AS Average_windspeed
	FROM dbo.Cleaned_Weather_data
	GROUP BY Date
) as Temp
;


-- 8. If the maximum gust speed increases from 55mph, fetch the details for the next 4 days

SELECT TOP 4 Date, CAST(Max_gust_speed AS decimal(4,1))
FROM dbo.Cleaned_Weather_data
WHERE Date > (SELECT MAX(Date) FROM dbo.Cleaned_Weather_data WHERE ISNUMERIC(Max_gust_speed) = 1 AND CAST(Max_gust_speed AS decimal(4,1)) > 55)
ORDER BY Date;


-- 9.Find the number of days when the temperature went below 0 degrees Celsius 

SELECT COUNT(*) as Day_when_Temp_below_0_degree
FROM dbo.Cleaned_Weather_data
WHERE CAST(Avg_Temperature AS decimal(4,1)) < 0
;

--10. Create another table with a “Foreign key” relation with the existing given data set.

CREATE TABLE dailypredictions (
id INT NOT NULL PRIMARY KEY,
date_id DATE,
season VARCHAR(50),
snowfall varchar(50),
rain varchar(50),
sun varchar(50),
FOREIGN KEY (date_id) REFERENCES dbo.Cleaned_Weather_data(Date)
);




















-- 7.Please add the data in the dataset for 2034 and 2035 as well as forecast predictions for these years ( NOTE: data consistency and uniformity should be maintained )