# Case Study#2: Global Happiness Index and Life Expectancy 🌏

## Table Of Contents: 📚 

* [Introduction](#introduction) 
* [Data Wrangling](#data-wrangling)
* [Data Description](#data-description)
* [Entity Relationship Diagram](#entity-relationship-diagram)
* [SQL Analysis](#sql-analysis)

### Introduction 
In this episode of SQL case study, I will explore the dataset I obtained from public sources. Essentially, we will harness SQL language to uncover the correlation between life expectancy and happiness index among countries. 

### Data Wrangling 
1. Managing Nulls = 
In this dataset, I applied statistical methods to deal with nulls. First, I discovered the total percentage of nulls in the columns, then I categorized columns as necessary or droppable if the null percentage was too high.
2. Data Manipulation =
I use Pandas libraries to transform tables, from column renaming to dropping unnecessary columns, and so on. I also utilised the python library to extract continents out of the corresponding country column so I could have a common region column for two datasets.
3. Data Normalization =
Still, with Python, I turn the dataset into a database-like format for SQL analysis.

### Data Description 
- country = Countries
- continent = Continents
- income_group = Different income brackets for countries
- year = years
- undernourishment = the prevalence of undernourishment in a country
- health expenditure = government's spending for the health sector
- unemployment = unemployment rate
- happiness_rank = country rank in happiness index
- happiness_score = score that represents a country's overall happiness from different factors and sorts country in a certain rank
- GDP = nation's annual GDP
- freedom = freedom index within a country
- government_trust =  nation's level of trust in government
- generosity = average of charitable donations as a percentage of gross income in each country. 

### Entity Relationship Diagram
![erd_case2](https://github.com/Albertyoch/SQL_Projects/assets/117698723/cb72f598-dccc-4ab9-9196-ec4da74ba44e)


### SQL Analysis

1. ***Find top 5 countries with highest average life expectancy throughout the dataset***
``````
SELECT TOP 5 
	country,
	AVG(life_expectancy) AS average_life_expectancy
FROM 
	life_expectancy le INNER JOIN
	country_dim cd ON le.country_id = cd.country_id
WHERE 
	life_expectancy IS NOT NULL AND life_expectancy <> ''
GROUP BY 
	country
ORDER BY
	average_life_expectancy DESC
``````

**Steps:** 
- Select Relevant Columns: Choose the columns you want in the result - country and the average of life_expectancy.

- Specify Tables and Join Conditions: Identify the tables (life_expectancy and country_dim) and specify how they are related (joined on country_id).

- Filter Data: Use the WHERE clause to exclude rows where life_expectancy is NULL or an empty string.

- Group Data: Group the results by the country column to calculate the average life expectancy per country.

- Order Results: Order the grouped results by the average life expectancy in descending order.

- Limit Rows: Use TOP 5 to select only the top 5 rows.

**Answer:**

| country     	| average_life_expectancy 	|
|-------------	|-------------------------	|
| Japan       	| 82.8915532734275        	|
| Switzerland 	| 82.2125802310655        	|
| Iceland     	| 81.8991014120668        	|
| Italy       	| 81.8717586649551        	|
| Spain       	| 81.7098844672657        	|


2. ***Rank continents based on the highest average of life expectancy***
`````` 
SELECT 
	continent,
	avg(life_expectancy) as average_life_expectancy
FROM 
	life_expectancy le INNER JOIN
	region_dim re ON le.continent_id = re.continent_id 
GROUP BY 
	continent
ORDER BY
	average_life_expectancy DESC
``````

**Steps:**
- Select Relevant Columns: Choose the columns you want in the result - continent and the average of life_expectancy.

- Specify Tables and Join Conditions: Identify the tables (life_expectancy and region_dim) and specify how they are related (joined on continent_id).

- Group Data: Group the results by the continent column to calculate the average life expectancy per continent.

- Calculate Average: Use the AVG function to calculate the average life expectancy for each continent.

- Order Results: Order the grouped results by the average life expectancy in descending order.

**Answer:**
| continent     	| average_life_expectancy 	|
|---------------	|-------------------------	|
| South America 	| 73.3766267942584        	|
| Asia          	| 72.1688518544218        	|
| Europe        	| 71.6529340706363        	|
| North America 	| 71.1974586299451        	|
| Africa        	| 59.0644282734275        	|
| Unknown       	| 53.1694736842105        	|
| Oceania       	| 44.9757668485237        	|

3. ***Find the average growth of life_expectancy for each country***
``````
WITH cte AS 
	(SELECT 
		country,
		life_expectancy,
		lag(life_expectancy, 1) OVER (PARTITION BY country ORDER BY year) AS lag_life_expectancy,
		CAST(life_expectancy - lag(life_expectancy, 1) OVER (PARTITION BY country ORDER BY year) as decimal(10,2)) AS life_expectancy_growth,
		CASE
			WHEN 
				LAG(life_expectancy, 1) OVER (PARTITION BY country ORDER BY year) IS NOT NULL and
				LAG(life_expectancy, 1) OVER (PARTITION BY country ORDER BY year) <> 0 AND 
				life_expectancy IS NOT NULL and life_expectancy <> 0
			THEN  
				CAST((life_expectancy - LAG(life_expectancy, 1) OVER (PARTITION BY country ORDER BY year))/ 
				lag(life_expectancy, 1) OVER (PARTITION BY country ORDER BY year )  * 100 as decimal(10,3)) 
			ELSE 
				NULL
		END AS life_expectancy_growth_pct
	FROM 
		life_expectancy le INNER JOIN 
		country_dim cd ON le.country_id = cd.country_id
	)
SELECT 
	country,
	CAST(AVG(life_expectancy_growth) AS decimal(10,2)) AS avg_life_expectancy_growth_per_year,
	CAST(AVG(life_expectancy_growth_pct) AS decimal(10,2)) AS avg_life_expectancy_growth_per_year_pct
FROM 
	cte
GROUP BY
	country
ORDER BY 
	avg_life_expectancy_growth_per_year
``````
**Steps:**
- Step 1: Calculate Life Expectancy Growth and Percentage with CTE
In this initial step, a Common Table Expression (CTE) named cte is created. This CTE calculates the growth in life expectancy and the corresponding percentage growth for each country. It involves comparing the life expectancy in a given year with the previous year for each country. Conditions are applied to ensure valid calculations, and the results are stored in the CTE.

- Step 2: Aggregate Results in the Main Query
Moving on to the main query, it begins with a SELECT statement that retrieves the top 5 records based on certain criteria. The specific criteria are not provided in the original query, so you may want to customize this part based on your needs. 

1. The SELECT clause then lists the selected columns for the final result:

2. country: Represents the country for which the calculations were performed.

3. avg_life_expectancy_growth_per_year: This is the average life expectancy growth per year for each country. It is calculated based on the values obtained in the CTE.

4. avg_life_expectancy_growth_per_year_pct: Similarly, this column represents the average life expectancy growth percentage per year for each country.

4. The FROM clause references the previously defined CTE, and the GROUP BY clause groups the results by country. Finally, the ORDER BY clause sorts the results in descending order based on the average life expectancy growth, ensuring that countries with the highest growth appear at the top.

**Sample Answer: Highest Growth**

| country      	| avg_life_expectancy_growth_per_year 	| avg_life_expectancy_growth_per_year_pct 	|
|--------------	|-------------------------------------	|-----------------------------------------	|
| Botswana     	| 1.07                                	| 1.83                                    	|
| Zambia       	| 1.07                                	| 2.02                                    	|
| Malawi       	| 1.06                                	| 1.98                                    	|
| Rwanda       	| 1.06                                	| 1.82                                    	|
| Zimbabwe     	| 0.97                                	| 1.89                                    	|
| Uganda       	| 0.90                                	| 1.65                                    	|
| Kenya        	| 0.87                                	| 1.49                                    	|
| Sierra Leone 	| 0.80                                	| 1.70                                    	|
| Eswatini     	| 0.80                                	| 1.55                                    	|
| Ethiopia     	| 0.78                                	| 1.32                                    	|




4. ***Based on previous findings, extend the steps to find life expentancy growth among income groups***
``````
with cte as 
	(SELECT 
		country,
		life_expectancy,
		lag(life_expectancy, 1) OVER (PARTITION BY country ORDER BY year) AS lag_life_expectancy,
		cast(life_expectancy - lag(life_expectancy, 1) OVER (PARTITION BY country ORDER BY year) as decimal(10,2)) AS life_expectancy_growth,
		CASE
			WHEN 
				lag(life_expectancy, 1) OVER (PARTITION BY country ORDER BY year) IS NOT NULL and
				lag(life_expectancy, 1) OVER (PARTITION BY country ORDER BY year) <> 0 AND 
				life_expectancy IS NOT NULL and life_expectancy <> 0
			THEN 
				cast((life_expectancy - lag(life_expectancy, 1) OVER (PARTITION BY country ORDER BY year))/ 
				lag(life_expectancy, 1) OVER (PARTITION BY country ORDER BY year )  * 100 as decimal(10,3)) 
			ELSE 
				NULL
		END AS life_expectancy_growth_pct
	FROM 
		life_expectancy le INNER JOIN 
		country_dim cd ON le.country_id = cd.country_id
	),
	cte2 as 
	(SELECT 
		country,
		cast(avg(life_expectancy_growth) AS decimal(10,2)) AS avg_life_expectancy_growth_per_year,
		cast(avg(life_expectancy_growth_pct) AS decimal(10,2)) AS avg_life_expectancy_growth_per_year_pct
	FROM 
		cte
	GROUP BY
		country
	)
SELECT 
	income_group,
	cast(avg(avg_life_expectancy_growth_per_year) AS decimal(10,2)) AS avg_life_expectancy_growth_per_year,
	cast(avg(avg_life_expectancy_growth_per_year_pct) AS decimal(10,2)) AS avg_life_expectancy_growth_per_year_pct
FROM
	cte2 c2 INNER JOIN 
	country_dim cd ON c2.country = cd.country INNER JOIN
	life_expectancy le ON cd.country_id = le.country_id INNER JOIN 
	income_dim id ON le.income_group_id = id.income_group_id
GROUP BY
	income_group
ORDER BY 
	avg_life_expectancy_growth_per_year
``````
**Steps**
1. Step 1: Calculate Life Expectancy Growth and Growth Percentage
This step involves:

Calculating the growth in life expectancy and the corresponding percentage growth for each country using the LAG() function to get the previous year's life expectancy.
Handling cases where certain values are null or zero to avoid potential calculation errors.
Storing the results in a Common Table Expression (CTE) named cte.

2. Step 2: Aggregate Results for Each Country
In this step, you're calculating the average life expectancy growth and growth percentage per year for each country and storing the results in another CTE named cte2.

3. Step 3: Aggregate Results for Each Income Group
The final step involves aggregating the data by income group. You're joining the CTE cte2 with other tables (country_dim, life_expectancy, income_dim) based on their respective IDs (such as country IDs and income group IDs).

Selecting the income group column for the final result.
Calculating the average of the average life expectancy growth and growth percentage per year for each income group.
Grouping the results by income group.
Ordering the results by the average life expectancy growth per year in ascending order.

**Summary**

The query performs a series of calculations and aggregations to determine the average life expectancy growth and growth percentage per year for different income groups, considering the data from countries and their respective life expectancy values. It generates insights into how life expectancy changes over time within different income groups.

**Answer:**
| income_group        	| avg_life_expectancy_growth_per_year 	| avg_life_expectancy_growth_per_year_pct 	|
|---------------------	|-------------------------------------	|-----------------------------------------	|
| High income         	| 0.19                                	| 0.27                                    	|
| Upper middle income 	| 0.22                                	| 0.37                                    	|
| Lower middle income 	| 0.39                                	| 0.64                                    	|
| Low income          	| 0.63                                	| 1.14                                    	|

It can be easily concluded that the living standard in lower income countries has gotten so much better throughout the years.

5. ***Use SQL query to calculate the 75th percentile of the average life expectancy across all countries***
``````
SELECT TOP 1
    cast(PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY avg_life_expectancy) OVER () as decimal(10,3)) AS high_life_expectancy_threshold
FROM (
    SELECT 
        country_id,
        AVG(life_expectancy) OVER (PARTITION BY country_id) AS avg_life_expectancy
    FROM 
        life_expectancy
) AS subquery
``````

**Steps:**
1. Inner Subquery:

SELECT country_id, AVG(life_expectancy) OVER (PARTITION BY country_id) AS avg_life_expectancy:

This subquery calculates the average life expectancy for each country using the AVG window function. The OVER (PARTITION BY country_id) clause ensures that the average is calculated for each country separately.

2. Outer Query:

SELECT cast(PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY avg_life_expectancy) OVER () as decimal(10,3)) AS high_life_expectancy_threshold:
The outer query calculates the 75th percentile (PERCENTILE_CONT(0.75)) of the average life expectancy across all countries. The WITHIN GROUP (ORDER BY avg_life_expectancy) clause specifies the order for calculating the percentile. The result is then cast to a decimal with a precision of 10 and a scale of 3.

6. ***Find continents where the average CO2 emissions per capita is higher than the global average CO2 emissions per capita for the year 2001***
``````
WITH GlobalAverageCO2 AS (
    SELECT
        AVG(le.CO2) AS global_avg_co2
    FROM
        life_expectancy le
    WHERE
        le.year = 2001
)

SELECT
    rd.continent,
    AVG(le.CO2) AS avg_co2_per_capita
FROM
    life_expectancy le
JOIN
    region_dim rd ON le.continent_id = rd.continent_id
JOIN
    GlobalAverageCO2 gac ON 1=1 -- Cross join to get global average CO2
WHERE
    le.year = 2001
GROUP BY
    rd.continent, gac.global_avg_co2
HAVING
    AVG(le.CO2) > gac.global_avg_co2;

``````

**Steps:**
- Create a Common Table Expression (CTE) named GlobalAverageCO2 to calculate the global average CO2 emissions per capita for the year 2001 from the life_expectancy table.

- Retrieve continent-wise average CO2 emissions for the year 2001 by joining the life_expectancy and happiness_rank tables based on the country ID. Use the GlobalAverageCO2 CTE for a global comparison.

- Group the results by continent ID and the global average CO2.

- Apply a HAVING clause to filter the results, including only those continents where the average CO2 emissions per capita are higher than the global average CO2 emissions per capita for the year 2001.

**Answer:**
| continent     	| avg_co2_per_capita 	|
|---------------	|--------------------	|
| Asia          	| 204834.054054054   	|
| North America 	| 354898.947368421   	|




