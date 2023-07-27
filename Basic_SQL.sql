USE parch_and_posey;

/*total number of sales rep per region*/
SELECT r.name as region, COUNT(region_id) as total_sales_rep
FROM region r
JOIN sales_reps s 
    ON r.id=s.region_id
GROUP BY 1
ORDER BY 2 DESC;


/*total number of channel and the number of times used*/
SELECT channel, COUNT(channel) AS total_used_case
FROM web_events
GROUP BY 1
ORDER BY 2 DESC;


/*total number of order per year*/
SELECT YEAR(occurred_at) as year, SUM(total) as total_order
FROM orders
GROUP BY 1
ORDER BY 1
;

/*what month has the highest total order placed in the year 2016*/
SELECT MONTH(occurred_at) as month, SUM(total) as total_order
FROM orders
WHERE YEAR(occurred_at)='2016'
GROUP BY 1
ORDER BY 1 DESC
LIMIT 1;

/*total number of order each year for the three types of paper*/
SELECT YEAR(occurred_at) as year, SUM(standard_qty) as standard_qty, SUM(gloss_qty) as gloss_qty, 
SUM(poster_qty) as poster_qty, SUM(total) as total_qty
FROM orders
GROUP BY 1 
ORDER BY 1;


/*when was the first order placed and which channel was used*/
SELECT occurred_at
FROM orders
ORDER BY 1 ASC
LIMIT 1;


/*total sales made per region*/


