/*what quantity of gloss paper was ordered on the first order made in 2016 */
SELECT gloss_qty
FROM orders
WHERE occurred_at=(SELECT occurred_at
FROM orders
WHERE YEAR(occurred_at)="2016"
        ORDER BY 1 ASC
        LIMIT 1);
/*the total quantity of gloss paper that was ordered on the first order made was 44 */

/*total sales by region */
WITH t1 AS (SELECT sales_rep_id, region_id, SUM(total_amt_usd) as total_sales_usd
            FROM orders o
            JOIN accounts a
                ON a.id=o.account_id
            JOIN sales_reps s 
                ON s.id=a.sales_rep_id
            GROUP BY 1,2)

SELECT name as region, ROUND(SUM(total_sales_usd)) as total_region_sales_usd
FROM t1
JOIN region r
    ON t1.region_id=r.id
GROUP BY 1
ORDER BY 2 DESC;
/*Northeast had the highest sales of 7744405 followed by southeast(6458497), west(5925123) and midwest(	
3013487) */


/*in terms of the total sales, how did the west region perform over the years */
WITH t1 AS (SELECT sales_rep_id, region_id, YEAR(occurred_at) as year, SUM(total_amt_usd) as total_sales_usd
            FROM orders o
            JOIN accounts a
                ON a.id=o.account_id
            JOIN sales_reps s 
                ON s.id=a.sales_rep_id
            GROUP BY 1,2,3)

SELECT year, name as region, ROUND(SUM(total_sales_usd)) as total_region_sales_usd
FROM t1
JOIN region r
    ON t1.region_id=r.id
WHERE name="West"
GROUP BY 1,2 
ORDER BY 1,3 DESC;
/*in the first year(2013) the west recorded the lowest sales of 56968 in 2014 it increased to 860045
in 2015(1375147), 2016(3608646) and in the first month of 2017 it had (24317) */



/*who were the top 5 sales rep in the first year  */
WITH t1 AS (SELECT sales_rep_id, region_id,  SUM(total_amt_usd) as total_sales_usd
            FROM orders o
            JOIN accounts a
                ON a.id=o.account_id
            JOIN sales_reps s 
                ON s.id=a.sales_rep_id
            WHERE YEAR(occurred_at)=2013
            GROUP BY 1,2
            )

SELECT s.name as name, SUM(total_sales_usd) total_sales
FROM sales_reps s
JOIN t1
    ON t1.sales_rep_id=s.id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;
/* in the first year the top 5 sales rep were 	
Cliff Meints,Earlie Schleusner,Maren Musto,Sibyl Lauria,Nelle Meaux */


/*who were the top 5 sales rep of all time */
WITH t1 AS (SELECT sales_rep_id, region_id,  SUM(total_amt_usd) as total_sales_usd
            FROM orders o
            JOIN accounts a
                ON a.id=o.account_id
            JOIN sales_reps s 
                ON s.id=a.sales_rep_id
            GROUP BY 1,2
            )

SELECT s.name as name, SUM(total_sales_usd) total_sales
FROM sales_reps s
JOIN t1
    ON t1.sales_rep_id=s.id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;
/*the top 5 sales rep of all time are 	
Earlie Schleusner,Tia Amato,Vernita Plump,Georgianna Chisholm,	
and Arica Stoltzfus */

/*which sales rep made the very first sale*/
SELECT occurred_at,s.name,total as total_sales,total_amt_usd
FROM orders o
JOIN accounts a
    ON a.id=o.account_id
JOIN sales_reps s 
    ON s.id=a.sales_rep_id
WHERE occurred_at= (SELECT MIN(occurred_at) as first_order_date
                    FROM orders o);
 /*the first sale was made on 2013-12-04 by Dorotha Seawell with a 
 total quantity of 81 and total amount in usd of 627.48*/   
 
 
/*what date was the highest order ever placed, by which company and which sales rep made the sales*/
SELECT occurred_at, a.name as company,s.name as sales_rep,total as total_sales,total_amt_usd
FROM orders o
JOIN accounts a
    ON a.id=o.account_id
JOIN sales_reps s 
    ON s.id=a.sales_rep_id
WHERE total_amt_usd= (SELECT MAX(total_amt_usd) as highest_sales
                    FROM orders o);
/*the highest order made was on 2016-12-26,placed by Pacific Life with a total order 
of 28799 and total_amt_usd of 232207.07.Dawna Agnew was the sales rep that made the sales */


/*Provide the name of the sales_rep in each region with the largest amount of total_amt_usd sales*/
WITH t1 as (SELECT s.name as sales_rep, r.name as region,SUM(total_amt_usd) as total_amt_usd
            FROM orders o
            JOIN accounts a
                ON a.id=o.account_id
            JOIN sales_reps s 
                ON s.id=a.sales_rep_id
            JOIN region r 
                ON r.id=s.region_id
            GROUP BY 1,2),
    t2 as (SELECT region, MAX(total_amt_usd) as highest_sales
            FROM t1
            GROUP BY 1)
SELECT sales_rep, region, total_amt_usd
FROM t1
WHERE total_amt_usd IN (SELECT highest_sales
                        FROM t2)
ORDER BY 3 DESC;
/*the sales rep with the largest amt usd are in the southeast - Earlie Schleusner(1098137.72), 
in the northeast - Tia Amato(1010690.60), in the west - Georgianna Chisholm(886244.12), 
in the midwest - Charles Bidwell(675637.19)*/

/*For the region with the largest sales total_amt_usd, how many total orders were placed?*/
WITH t1 AS (SELECT r.name as region, ROUND(SUM(total_amt_usd)) as total_region_sales_usd
            FROM orders o
            JOIN accounts a
                ON a.id=o.account_id
            JOIN sales_reps s 
                ON s.id=a.sales_rep_id
            JOIN region r
                ON r.id=s.region_id
            GROUP BY 1
            ORDER BY 2 DESC
            LIMIT 1)
SELECT COUNT(o.id) as total_order
FROM orders o
JOIN accounts a
    ON a.id=o.account_id
JOIN sales_reps s 
    ON s.id=a.sales_rep_id
JOIN region r
    ON r.id=s.region_id
WHERE r.name = (SELECT region
                FROM t1);
/*For the region with the largest sales total_amt_usd, 2357 orders were placed*/

/*How many accounts had more total purchases than the account name which has bought 
the most standard_qty paper throughout their lifetime as a customer?*/
WITH t1 AS (SELECT a.name as account_name, SUM(standard_qty) as total_standard_qty, 
            SUM(total) as total_purchase
            FROM orders o
            JOIN accounts a 
                ON a.id=o.account_id
            GROUP BY 1
            ORDER BY 2 DESC
            LIMIT 1),
    t2 AS (SELECT a.name as account_name, SUM(total) as total_purchase
            FROM orders o
            JOIN accounts a 
                ON a.id=o.account_id
            GROUP BY 1
            HAVING SUM(total) > (SELECT total_purchase
                                    FROM t1))
SELECT COUNT(*) as total_accounts
FROM t2;
/*3 accounts had more total purchases than the account name which has bought 
the most standard_qty paper throughout their lifetime as a customer?*/


/*For the customer that spent the most (in total over their lifetime as a customer) 
total_amt_usd, how many web_events did they have for each channel?*/
WITH t1 AS (SELECT a.name as account_name, a.id as account_id, SUM(total_amt_usd) as total_amt_usd
            FROM orders o
            JOIN accounts a 
                ON a.id=o.account_id
            GROUP BY 1,2
            ORDER BY 3 DESC
            LIMIT 1)
SELECT channel, COUNT(channel) as total_channel
FROM web_events w
JOIN t1
    USING(account_id)
GROUP BY 1 
ORDER BY 2 DESC;
/*For the customer that spent the most (in total over their lifetime as a customer) 
total_amt_usd, the total order by channel are direct=44, organic=13, adwords=12, 
facebook=11, twitter=5, banner=4 */


/*What is the lifetime average amount spent in terms of total_amt_usd for the 
top 10 total spending accounts?*/
WITH t1 AS (SELECT a.name as account_name, a.id as account_id, SUM(total_amt_usd) as total_amt_usd
            FROM orders o
            JOIN accounts a 
                ON a.id=o.account_id
            GROUP BY 1,2
            ORDER BY 3 DESC
            LIMIT 10)
SELECT ROUND(AVG(total_amt_usd),2) as AVG_amount_spent_by_top_10
FROM t1;
/*304846.97 is the average amount spent in terms of total_amt_usd for the top 10 
total spending accounts?*/


                      
