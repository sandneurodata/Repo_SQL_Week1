/*
SQL JOIN
------------------------------------------------------------------------------------------------
HOW TO GET THE SCHEMA OF A DATABASE: 
* Windows/Linux: Ctrl + r
* MacOS: Cmd + r
*/
USE publications; 

-- AS 
# Change the column name qty to Quantity into the sales table
# https://www.w3schools.com/sql/sql_alias.asp
SELECT *, qty as 'Quantity'
FROM sales;
# Assign a new name into the table sales, and call the column order number using the table alias
SELECT s.ord_num FROM sales AS s;


-- JOINS
# https://www.w3schools.com/sql/sql_join.asp
-- LEFT JOIN
SELECT * 
FROM stores s 
LEFT JOIN discounts d ON d.stor_id = s.stor_id;

-- RIGHT JOIN
SELECT * 
FROM stores s 
RIGHT JOIN discounts d ON d.stor_id = s.stor_id;
-- INNER JOIN
SELECT * 
FROM stores s 
INNER JOIN discounts d ON d.stor_id = s.stor_id;

-- CHALLENGES: 
# In which cities has "Is Anger the Enemy?" been sold?
# HINT: you can add WHERE function after the joins
SELECT st.city, st.stor_id, sa.stor_id, sa.title_id, t.title, t.title_id
FROM titles AS t, stores AS st, sales AS sa
WHERE st.stor_id = sa.stor_id AND sa.title_id = t.title_id 
AND t.title = "Is Anger the Enemy?";

# Select all the books (and show their title) where the employee
# Howard Snyder had work.
SELECT t.title, CONCAT (e.lname," ",e.fname) AS "employee name"
FROM titles AS t, employee AS e
WHERE t.pub_id = e.pub_id AND CONCAT(e.fname, " ",e.lname) = "Howard Snyder";

# Select all the authors that have work (directly or indirectly)
# with the employee Howard Snyder

SELECT DISTINCT(CONCAT(aut.au_fname, " ", aut.au_lname)) AS "author name"
FROM authors AS aut, employee AS e, titleauthor AS ta, titles as t
WHERE t.title_id = ta.title_id
AND ta.au_id = aut.au_id
AND t.pub_id = e.pub_id
AND CONCAT(e.fname, " ", e.lname) = "Howard Snyder";


# Select the book title with higher number of sales (qty)
SELECT t.title, SUM(sa.qty)
FROM titles AS t, sales AS sa
WHERE t.title_id = sa.title_id
GROUP BY t.title
ORDER BY SUM(sa.qty) DESC
LIMIT 1;

