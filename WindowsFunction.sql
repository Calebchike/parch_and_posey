
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



