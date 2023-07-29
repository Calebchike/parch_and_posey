USE parch_and_posey;

/*when was the first order placed */
SELECT occurred_at
FROM orders o
ORDER BY 1 ASC
LIMIT 1;
/*Alternatively*/
SELECT MIN(occurred_at) as first_order_date
FROM orders o;
/*2013-12-04 was the date the first order was placed*/


/*total number of sales rep per region*/
SELECT r.name as region, COUNT(region_id) as total_sales_rep
FROM region r
JOIN sales_reps s 
    ON r.id=s.region_id
GROUP BY 1
ORDER BY 2 DESC;
/*northeast have 21 sales rep followed by southeast(10),west(10) and midwest(9)*/


/*total number of channel and the number of times used*/
SELECT channel, COUNT(channel) AS total_used_case
FROM web_events
GROUP BY 1
ORDER BY 2 DESC;
/*direct channel had the highest order placed followed by facebook,organic,adwords,banner, and twitter*/

/*what is the total sales made by each channel*/
SELECT channel, ROUND(SUM(total_amt_usd)) as total_sales
FROM orders o 
JOIN web_events w 
    USING(account_id)
GROUP BY 1
ORDER BY 2 DESC;
/*direct channel had the highest sales followed by facebook,organic,adwords,twitter, and banner*/

/*total number of order per year*/
SELECT YEAR(occurred_at) as year, SUM(total) as total_order
FROM orders
GROUP BY 1
ORDER BY 1;
/*beginning from 2013, there have been an increasing  number of order placed*/

/*what month has the highest total order placed in the year 2016*/
SELECT MONTH(occurred_at) as month, SUM(total) as total_order
FROM orders
WHERE YEAR(occurred_at)='2016'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;
/*December(12) had the highest total order placed*/

/*total number of order each year for the three types of paper*/
SELECT YEAR(occurred_at) as year, SUM(standard_qty) as standard_qty, SUM(gloss_qty) as gloss_qty, 
SUM(poster_qty) as poster_qty, SUM(total) as total_qty
FROM orders
GROUP BY 1 
ORDER BY 1;
/*2016 recorded the highest order placed on all three paper types*/

/*top 5 months with the highest total order placed*/
SELECT MONTH(occurred_at) as month, SUM(total) as total_order
FROM orders
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;
/*months 12,10,11,9,7*/

/*what are the 5 month with the lowest total order placed of all year*/
SELECT MONTH(occurred_at) as month, SUM(total) as total_order
FROM orders
GROUP BY 1
ORDER BY 2 ASC
LIMIT 5;
/*months 2,1,5,4,3*/

/*how many company placed order with parch and posey*/
SELECT COUNT(DISTINCT name) as total_customers
FROM accounts;
/*351 companies placed order on at least one paper type*/

/*how many company placed order on all the paper type*/
SELECT COUNT(DISTINCT name) as total_customers
FROM accounts a 
JOIN orders o
    ON a.id=o.account_id
WHERE standard_qty !=0 AND gloss_qty !=0 AND poster_qty !=0;
/*339 companies placed order on all paper type*/


/*which company have the highest sales in usd*/
SELECT name, SUM(total_amt_usd) as total_amt_usd
FROM accounts a 
JOIN orders o 
    ON a.id=o.account_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;
/*'EOG Resources' have the highest sales in usd*/



/*which company have the highest order*/
SELECT name, SUM(total) as total_order
FROM accounts a 
JOIN orders o 
    ON a.id=o.account_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;
/*'EOG Resources' have the highest order*/


/*what is the average quantity ordered of all the paper types*/
SELECT AVG(standard_qty) as AVG_standard_qty, AVG(gloss_qty) as AVG_gloss_qty,AVG(poster_qty) as AVG_poster_qty
FROM accounts a 
JOIN orders o 
    ON a.id=o.account_id;
/* the average order is standard_qty(280.4320), gloss_qty(146.6685) and poster_qty(104.6942)*/


/*what is the average quantity ordered by each company for all the paper types*/
SELECT name,AVG(standard_qty) as AVG_standard_qty, AVG(gloss_qty) as AVG_gloss_qty,AVG(poster_qty) as AVG_poster_qty
FROM accounts a 
JOIN orders o 
    ON a.id=o.account_id
GROUP BY 1
ORDER BY 1;

/*what is the total number of sales rep each year that made sales */
SELECT  YEAR(occurred_at) as year, COUNT(DISTINCT sales_rep_id) as total_sales_rep
FROM orders o
JOIN accounts a
    ON a.id=o.account_id
JOIN sales_reps s 
    ON s.id=a.sales_rep_id
GROUP BY 1
ORDER BY 1;
/*in 2013 the total sales rep was 35. in 2014 it was 42, 2015 it was 45, 2016 it was 
50 and in 2017 13 sales rep */