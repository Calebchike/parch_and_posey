
/*create a table that contains the total quantity and its running total,
the total_amt_usd and its running total of all the account id. partitioned ADD
by account id and ordered by data*/
SELECT account_id, occurred_at, total as total_qty,
        SUM(total) OVER (PARTITION BY account_id ORDER BY occurred_at ) as running_total_qty,
        total_amt_usd,
        SUM(total_amt_usd) OVER (PARTITION BY account_id ORDER BY occurred_at) as running_total_usd
FROM orders
ORDER BY 2 ASC;


/*use the lead function to determine the differences between the present row and next row*/
SELECT occurred_at, total_amt_usd,
       LEAD(total_amt_usd) OVER lead_window AS lead_,
       LEAD(total_amt_usd) OVER lead_window - total_amt_usd AS lead_difference
FROM(SELECT occurred_at, SUM(total_amt_usd) total_amt_usd
    FROM orders 
    GROUP BY 1) sub
WINDOW lead_window AS (ORDER BY occurred_at);


/*create a column that ranks each accounts quantity of all papers ordered*/
SELECT account_id, standard_qty,  
        DENSE_RANK() OVER (PARTITION BY account_id ORDER BY standard_qty DESC) AS standard_qty_rank,
        gloss_qty,
        DENSE_RANK() OVER (PARTITION BY account_id ORDER BY gloss_qty DESC) AS gloss_qty_rank,
        poster_qty,
        DENSE_RANK() OVER (PARTITION BY account_id ORDER BY poster_qty DESC) AS poster_qty_rank
FROM orders;

/*what is the rank of the sales rep based on their overall total sales*/
WITH t1 as (SELECT s.name as sales_rep,ROUND(SUM(total_amt_usd)) as total_amt_usd
            FROM orders o
            JOIN accounts a
                ON a.id=o.account_id
            JOIN sales_reps s 
                ON s.id=a.sales_rep_id
            JOIN region r 
                ON r.id=s.region_id
            GROUP BY 1)
SELECT sales_rep, total_amt_usd,
RANK() OVER (ORDER BY total_amt_usd DESC) as sales_rep_rank
FROM t1;

/*what is the yearly rank of the sales rep based on their total sales*/
WITH t1 as (SELECT s.name as sales_rep,YEAR(occurred_at) as year,
                ROUND(SUM(total_amt_usd)) as total_amt_usd
            FROM orders o
            JOIN accounts a
                ON a.id=o.account_id
            JOIN sales_reps s 
                ON s.id=a.sales_rep_id
            JOIN region r 
                ON r.id=s.region_id
            GROUP BY 1,2
            ORDER BY 2)
SELECT year,sales_rep,total_amt_usd,
        RANK() OVER(PARTITION BY year ORDER BY total_amt_usd DESC) as sales_rep_yearly_rank
FROM t1;


/*what is the rank of the companies based on their overall total sales and overall total order*/
WITH t1 as (SELECT a.name as company,
                ROUND(SUM(total_amt_usd)) as total_amt_usd,
                ROUND(SUM(total)) as total_order
            FROM orders o
            JOIN accounts a
                ON a.id=o.account_id
            JOIN sales_reps s 
                ON s.id=a.sales_rep_id
            JOIN region r 
                ON r.id=s.region_id
            GROUP BY 1
            ORDER BY 2 DESC)
SELECT company,total_order,total_amt_usd,
        RANK() OVER (ORDER BY total_order DESC) as rank_total_order,
        RANK() OVER(ORDER BY total_amt_usd DESC) as rank_total_amt_usd   
FROM t1;


/*what is the month rank in 2016 based of the overall total order placed*/
SELECT MONTHNAME(occurred_at) as month,
        ROUND(SUM(total)) as total_order,
        RANK() OVER(ORDER BY ROUND(SUM(total)) DESC) as month_rank
FROM orders o
JOIN accounts a
        ON a.id=o.account_id
JOIN sales_reps s 
        ON s.id=a.sales_rep_id
JOIN region r 
        ON r.id=s.region_id
WHERE YEAR(occurred_at)="2016"
GROUP BY 1;


  /*what overall percentage of the total sales did each region get */      
  WITH total_sales AS (SELECT r.name as region, ROUND(SUM(total_amt_usd)) as total_amt_usd
                        FROM orders o
                        JOIN accounts a 
                            ON o.account_id=a.id
                        JOIN sales_reps s 
                            ON s.id=a.sales_rep_id
                        JOIN region r
                            ON r.id=s.region_id
                        GROUP BY 1
                        )
SELECT region, total_amt_usd, ROUND((total_amt_usd/SUM(total_amt_usd) OVER())*100) as percentage_sales
FROM total_sales
ORDER BY 2 DESC;


 /*what monthly percentage of the total sales did the top 3 month get */ 
WITH total_sales AS(SELECT MONTHNAME(occurred_at) as month, MONTH(occurred_at) as month_number, ROUND(SUM(total_amt_usd)) as total_amt_usd
                    FROM orders o
                    JOIN accounts a 
                        ON o.account_id=a.id
                    JOIN sales_reps s 
                        ON s.id=a.sales_rep_id
                    JOIN region r                            
                        ON r.id=s.region_id
                    WHERE YEAR(occurred_at)="2015"
                    GROUP BY 1,2
                    ORDER BY 2)
SELECT month, total_amt_usd, ROUND((total_amt_usd/SUM(total_amt_usd) 
OVER())*100) as monthly_percentage_sales
FROM total_sales 
ORDER BY total_amt_usd DESC
LIMIT 3;
/* the top 3 months(November-12%, December-11%, October-10%) had a total 
sales percent of 33% of while the remaining 9 months shared 67%. */ 


 /*using lag function what is the monthly percentage difference of the total sales in year 2016*/ 
WITH total_sales AS (SELECT MONTHNAME(occurred_at) as month, MONTH(occurred_at) as month_number, 
                        ROUND(SUM(total_amt_usd)) as total_amt_usd
                    FROM orders o
                    JOIN accounts a 
                        ON o.account_id=a.id
                    JOIN sales_reps s 
                        ON s.id=a.sales_rep_id
                    JOIN region r
                        ON r.id=s.region_id
                    WHERE YEAR(occurred_at)="2016"
                    GROUP BY 1,2
                    ORDER BY 2)
SELECT month, total_amt_usd, 
ROUND(((total_amt_usd-LAG(total_amt_usd, 1) OVER() )/(LAG(total_amt_usd, 1) OVER() ))*100, 2) as monthly_percentage_difference
FROM total_sales ;