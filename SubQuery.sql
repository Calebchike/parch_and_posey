/*what quantity of gloss paper was ordered on the first order made in 2016 */
SELECT gloss_qty
FROM orders
WHERE occurred_at=(SELECT occurred_at
FROM orders
WHERE YEAR(occurred_at)="2016"
        ORDER BY 1 ASC
        LIMIT 1);

