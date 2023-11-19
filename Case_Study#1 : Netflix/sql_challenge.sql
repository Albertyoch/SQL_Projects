-- basic queries 

-- retrieve users data that has joined before certain date
SELECT 
	*
FROM 
	[dbo].[users]
WHERE
	join_date < '01-01-22' --without function

SELECT 
	*
FROM 
	[dbo].[users]
WHERE 
	YEAR(join_date) < '2022' --with function
ORDER BY
	join_date ASC

-- Find the busiest (when people join the most) month of the year?
SELECT 
	MONTH(join_date) as month_of_the_year,
	COUNT(user_id) as total_new_subscribers
FROM
	[dbo].[users]
GROUP BY
	MONTH(join_date)
ORDER BY
	total_new_subscribers DESC

-- retrieve users data under a certain subscription type

SELECT 
	us.*,
	st.subscription_type
FROM
	[dbo].[users] us
	JOIN 
	[dbo].[subscription_types] st 
	ON
	us.subscription_id = st.subscription_id
	AND 
	st.subscription_type = 'Premium'

SELECT 
	us.*,
	st.subscription_type
FROM
	[dbo].[users] us
	JOIN 
	[dbo].[subscription_types] st 
	ON
	us.subscription_id = st.subscription_id
WHERE
	st.subscription_type IN ('Premium', 'Basic')

-- Aggregation and Joins

-- Find the average age of our users based on their country
SELECT 
	co.country,
	AVG(age) as age_average
FROM 
	[dbo].[users] us
	JOIN
	[dbo].[countries] co
	ON
	us.country_id = co.country_id
GROUP BY
	co.country

-- Find the country with the highest number of users
--most optimized method
SELECT 
	co.country as country,
	COUNT(us.user_id) as total_users
FROM
	[dbo].[users] us
	JOIN
	[dbo].[countries] co
	ON
	us.country_id = co.country_id
GROUP BY
	co.country
ORDER BY
	total_users DESC

WITH ct1 as ( 
	SELECT
		co.country as country,
		COUNT(us.user_id) as total_users,
		DENSE_RANK() OVER (ORDER BY COUNT(us.user_id) DESC) AS ranking
	FROM 
		[dbo].[users] us
		JOIN
		[dbo].[countries] co
		ON
		us.country_id = co.country_id
	GROUP BY
		co.country)
SELECT 
	country,
	total_users
FROM 
	ct1
WHERE
	ranking = 1

-- Finding the country with lowest number of users

WITH total_num_users as (
	SELECT 
		co.country,
		COUNT(us.user_id) as total_users
	FROM 
		[dbo].[users] us
		JOIN
		[dbo].[countries] co
		ON 
		us.country_id = co.country_id
	GROUP BY
		co.country)

SELECT 
	country,
	total_users
FROM 
	total_num_users
WHERE
	total_users= (SELECT MIN(total_users) FROM total_num_users)


	SELECT 
		co.country,
		COUNT(us.user_id) as total_users
	FROM 
		[dbo].[users] us
		JOIN
		[dbo].[countries] co
		ON 
		us.country_id = co.country_id
	WHERE
	COUNT(us.user_id)= (SELECT MIN(total_users) FROM total_num_users)
	GROUP BY
		co.country


-- Which subscription type is the most popular option for users from each country?

WITH rank_subs as (
	SELECT
		co.country,
		sub.subscription_type,
		COUNT(us.user_id) as total_users,
		DENSE_RANK() OVER(PARTITION BY co.country ORDER BY COUNT(us.user_id) DESC) as total_users_ranking
	FROM 
		[dbo].[users] us
		JOIN
		[dbo].[countries] co
		ON
		us.country_id = co.country_id
		JOIN
		[dbo].[subscription_types] sub
		ON
		us.subscription_id = sub.subscription_id
	GROUP BY
		co.country, sub.subscription_type)
SELECT 
	country,
	subscription_type as favorite_subscription,
	total_users
FROM 
	rank_subs
WHERE
	total_users_ranking = 1
ORDER BY
	total_users DESC

-- What is user's favorite streaming device based on country? GOOD ANALYSIS FOR MARKETING PURPOSE

WITH rank_device as (
	SELECT
		co.country,
		dev.device,
		COUNT(us.user_id) as total_users,
		DENSE_RANK() OVER(PARTITION BY co.country ORDER BY COUNT(us.user_id) DESC) as total_users_ranking
	FROM 
		[dbo].[users] us
		JOIN
		[dbo].[countries] co
		ON
		us.country_id = co.country_id
		JOIN
		[dbo].[device_types] dev
		ON
		us.device_id = dev.device_id
	GROUP BY
		co.country, dev.device)
SELECT 
	country,
	device as favorite_device,
	total_users
FROM 
	rank_device
WHERE
	total_users_ranking = 1
ORDER BY
	total_users DESC

-- Find the gender distribution among countries, their age average, and how much they drive the revenue?

WITH gender_pattern as(	
	SELECT 
		co.country,
		us.gender,
		dev.device,
		SUM(monthly_revenue) as sales_revenue,
		AVG(age) as average_age,
		DENSE_RANK() OVER(PARTITION BY co.country, us.gender ORDER BY COUNT(us.user_id) DESC) as total_users_ranking
	FROM 
		[dbo].[users] us
		JOIN
		[dbo].[device_types] dev
		ON
		us.device_id = dev.device_id
		JOIN
		[dbo].[countries] co
		ON
		us.country_id = co.country_id
	GROUP BY
		co.country,
		us.gender,
		dev.device)

SELECT 
		country,
		gender,
		device as favorite_device,
		CONCAT('$' , sales_revenue) as revenue,
		average_age
FROM 
	gender_pattern
WHERE
	total_users_ranking = 1

-- Find top 5 users who are the biggest contributors to total revenue during the whole period
SELECT TOP 10
	us.user_id,
	sub.subscription_type,
	us.join_date,
	DATEADD(dd, 28, us.last_payment_date) AS latest_date_of_membership,
	CONCAT(DATEDIFF(dd, us.join_date, DATEADD(dd, 28, us.last_payment_date)) / 28 , ' ', 'Months') AS membership_period,
	CONCAT('$' , CAST((DATEDIFF(dd, us.join_date, DATEADD(dd, 28, us.last_payment_date)) / 28 * monthly_revenue) AS integer)) AS revenue_generated
FROM 
	[dbo].[users] us
	JOIN
	[dbo].[subscription_types] sub
	ON
	us.subscription_id = sub.subscription_id
ORDER BY
	revenue_generated DESC


SELECT TOP 5
	us.user_id,
	sub.subscription_type,
	us.join_date,
	DATEADD(dd, 28, us.last_payment_date) AS latest_date_of_membership,
	CONCAT(DATEDIFF(dd, us.join_date, DATEADD(dd, 28, us.last_payment_date)) / 28 , ' ', 'Months') AS membership_period,
	DATEDIFF(dd, us.join_date, DATEADD(dd, 28, us.last_payment_date)) / 28 * monthly_revenue  AS revenue_generated
FROM 
	[dbo].[users] us
	JOIN
	[dbo].[subscription_types] sub
	ON
	us.subscription_id = sub.subscription_id
ORDER BY
	revenue_generated DESC	


-- Find users who already spend more $150 and then find their fav device 

WITH age_class AS (
	SELECT
		us.user_id,
		us.age,
		sub.subscription_type,
		us.monthly_revenue,
		CASE 
			WHEN us.age <= 23 AND (sub.subscription_type = 'Premium' OR sub.subscription_type = 'Standard') THEN us.monthly_revenue * 0.8
			WHEN us.age >= 45 AND (sub.subscription_type = 'Premium' OR sub.subscription_type = 'Standard') THEN us.monthly_revenue * 0.7
			ELSE us.monthly_revenue
		END new_monthly_revenue,
		DATEDIFF(dd, us.join_date, DATEADD(dd, 28, us.last_payment_date)) / 28 AS membership_period
	FROM 
		[dbo].[users] us
		JOIN
		[dbo].[subscription_types] sub
		ON
		us.subscription_id = sub.subscription_id),

	new_revenue as (
		SELECT 
			*,
			new_monthly_revenue * membership_period as new_total_revenue,
			monthly_revenue * membership_period as old_total_revenue
		FROM 
			age_class)
SELECT 
	SUM(new_total_revenue) - SUM(old_total_revenue) as 
FROM new_revenue









			























	









