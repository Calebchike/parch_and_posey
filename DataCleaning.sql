
use parch_and_posey;
/*Use the accounts table to pull the first letter of each company name to see the distribution of company 
names that begin with each letter (or number).*/
SELECT LOWER(LEFT(name,1)) as company_initial,COUNT(LOWER(LEFT(name,1))) as total_count
FROM accounts
GROUP BY 1
ORDER BY 2 DESC;
/*"a" and "c" had the highest distribution with 37 companies each
this is followed by "p"-27,"m"-22 etc*/

/*Use the accounts table and a CASE statement to create two groups: 
one group of company names that start with a number and a 
second group of those company names that start with a letter. 
What proportion of company names start with a letter?*/
WITH t1 as (SELECT name, (CASE 
                    WHEN LOWER(LEFT(name,1)) IN ("1","2","3","4","5","6","7","8","9","0") THEN "number"  
                    WHEN LOWER(LEFT(name,1)) IN ("a","b","c","d","e","f","g","h","i","j",
                    "k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z") THEN "alphabet"
                    ELSE  "others"
                    END) as data_type
            FROM accounts)
SELECT data_type, COUNT(data_type) as total
FROM t1
GROUP BY 1;
/*350 company has an initial with an alphabet why 1 company has a number as initial. 
which gives a ratio of 350/351 that is 99.7% of companies starts with an alphabet*/

/*Consider vowels as a, e, i, o, and u. What proportion of company names start with 
a vowel, and what percent start with anything else?*/
WITH t1 as (SELECT name, (CASE 
                        WHEN LOWER(LEFT(name,1)) IN ("a","e","i","o","u") THEN "vowel"  
                        ELSE  "others"
                        END) as data_type
            FROM accounts)
SELECT data_type, COUNT(data_type) as total
FROM t1
GROUP BY 1;
/*80 companies starts with a vowel and 271 starts with others. 22.8% vowel and 77.2% others*/


/*Use the accounts table to create first and 
last name columns that hold the first and last names for the primary_poc.*/
SELECT LEFT(primary_poc, POSITION(" " IN primary_poc)-1) as first_name, 
RIGHT(primary_poc, LENGTH(primary_poc)-POSITION(" " IN primary_poc)) as last_name
FROM accounts;

/*Use the salesreps table to create first and 
last name columns that hold the first and last names for the sales reps.*/
SELECT LEFT(name, POSITION(" " IN name)-1) as first_name, 
RIGHT(name, LENGTH(name)-POSITION(" " IN name)) as last_name
FROM sales_reps;


/*Each company in the accounts table wants to create an email address for each 
primary_poc. The email address should be the first name of the primary_poc . 
last name primary_poc @ company name .com.*/
SELECT CONCAT(LOWER(first_name),".",LOWER(last_name),"@",new_name,".com") as primary_poc_email
FROM(SELECT LEFT(primary_poc, POSITION(" " IN primary_poc)-1) as first_name, 
    RIGHT(primary_poc, LENGTH(primary_poc)-POSITION(" " IN primary_poc)) as last_name,
    REPLACE(LOWER(name)," ","") as new_name
    FROM accounts) as t1;
/*to achieve a cleaner result i used the REPlACE function to remove all 
the spaces that are in the company name column*/


/*We would also like to create an initial password, which they will change after their first 
log in. The first password will be the first letter of the primary_poc's first name (lowercase), 
then the last letter of their first name (lowercase), the first letter of their last name 
(lowercase), the last letter of their last name (lowercase), the number of letters in their 
first name, the number of letters in their last name, and then the name of the company they are 
working with, all capitalized with no spaces.*/
SELECT CONCAT(LOWER(first_name),".",LOWER(last_name),"@",new_name,".com") as primary_poc_email, 
    CONCAT(LOWER(LEFT(primary_poc,1)),LOWER(RIGHT(first_name,1)),LOWER(LEFT(last_name,1)),
    LOWER(RIGHT(last_name,1)),LENGTH(last_name),UPPER(new_name))as initial_password
FROM(SELECT primary_poc,LEFT(primary_poc, POSITION(" " IN primary_poc)-1) as first_name, 
    RIGHT(primary_poc, LENGTH(primary_poc)-POSITION(" " IN primary_poc)) as last_name,
    REPLACE(LOWER(name)," ","") as new_name
    FROM accounts) as t1;

