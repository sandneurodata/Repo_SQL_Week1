USE magist;

/* Business question

	1. In relation to the products:
		1.1. What categories of tech products does Magist have? */
	
SELECT product_category_name FROM product_category_name_translation
WHERE product_category_name_english IN ("audio", "consoles_games", "electronics","computers_accessories", "pc_gamer", "computers", "tablets_printing_image", "telephony", "fixed_telephony", "cine_photo");

/*      1.2. How many products of these tech categories have been sold (within the time window
              of the database snapshot)? What percentage does that represent from the overall number 
              of products sold? */
 
# Here computed for all the tech categories
SELECT COUNT(oi.product_id) AS tot_num_prod FROM order_items oi, products p, product_category_name_translation pt
WHERE oi.product_id = p.product_id AND p.product_category_name = pt.product_category_name 
AND pt.product_category_name_english IN ("audio", "consoles_games", "electronics","computers_accessories", "pc_gamer", "computers", "tablets_printing_image", "telephony", "fixed_telephony", "cine_photo");

# Here is the % for all tech categories
SELECT (a.tot_num_prod/b.tot_num_prod) * 100 AS perc_tech_prod
FROM (
SELECT COUNT(oi.product_id) AS tot_num_prod FROM order_items oi, products p, product_category_name_translation pt
WHERE oi.product_id = p.product_id AND p.product_category_name = pt.product_category_name 
AND pt.product_category_name_english IN ("audio", "consoles_games", "electronics","computers_accessories", "pc_gamer", "computers", "tablets_printing_image", "telephony", "fixed_telephony", "cine_photo")) AS a, 
(SELECT COUNT(oi.product_id) AS tot_num_prod FROM order_items oi) AS b;

# Here computed per each category in tech category
SELECT COUNT(oi.product_id) AS tot_num_prod, pt.product_category_name_english AS cat_prod FROM order_items oi, products p, product_category_name_translation pt
WHERE oi.product_id = p.product_id AND p.product_category_name = pt.product_category_name
AND pt.product_category_name_english IN ("audio", "consoles_games", "electronics","computers_accessories", "pc_gamer", "computers", "tablets_printing_image", "telephony", "fixed_telephony", "cine_photo")
GROUP BY cat_prod
ORDER BY COUNT(oi.product_id) DESC;

# Here is the % per tech category
SELECT (a.tot_num_prod/b.tot_num_prod) * 100 AS perc_tech_prod , a.cat_prod
FROM
(SELECT COUNT(oi.product_id) AS tot_num_prod, pt.product_category_name_english AS cat_prod FROM order_items oi, products p, product_category_name_translation pt
WHERE oi.product_id = p.product_id AND p.product_category_name = pt.product_category_name
AND pt.product_category_name_english IN ("audio", "consoles_games", "electronics","computers_accessories", "pc_gamer", "computers", "tablets_printing_image", "telephony", "fixed_telephony", "cine_photo")
GROUP BY cat_prod
ORDER BY COUNT(oi.product_id) DESC) AS a, 
(SELECT COUNT(oi.product_id) AS tot_num_prod FROM order_items oi) AS b
ORDER BY perc_tech_prod DESC;

#		1.3. What’s the average price of the products being sold?

# Average price of the product being sold for all categories 
SELECT AVG(price) AS avg_prod_price FROM order_items;

# Average price of the product being sold per category 
SELECT pt.product_category_name_english, COUNT(oi.product_id) AS tot_number, AVG(oi.price) AS avg_price FROM order_items oi, products p, product_category_name_translation pt
WHERE oi.product_id = p.product_id
AND p.product_category_name = pt.product_category_name
GROUP BY pt.product_category_name_english
ORDER BY tot_number DESC;

# Average price of the product being sold for tech categories
SELECT pt.product_category_name_english, COUNT(oi.product_id) AS tot_number, AVG(oi.price) AS avg_price FROM order_items oi, products p, product_category_name_translation pt
WHERE oi.product_id = p.product_id AND p.product_category_name = pt.product_category_name 
AND pt.product_category_name_english IN ("audio", "consoles_games", "electronics","computers_accessories", "pc_gamer", "computers", "tablets_printing_image", "telephony", "fixed_telephony", "cine_photo")
GROUP BY pt.product_category_name_english
ORDER BY AVG(oi.price) DESC;

# Average price of the product being sold for all tech categories
SELECT AVG(oi.price) AS avg_price_tech, COUNT(oi.product_id) AS tot_num_prod FROM order_items oi, products p, product_category_name_translation pt
WHERE oi.product_id = p.product_id AND p.product_category_name = pt.product_category_name 
AND pt.product_category_name_english IN ("audio", "consoles_games", "electronics","computers_accessories", "pc_gamer", "computers", "tablets_printing_image", "telephony", "fixed_telephony", "cine_photo");

# Average price of the product being sold for all categories but tech
SELECT AVG(oi.price) AS avg_price_tech, COUNT(oi.product_id) AS tot_num_prod FROM order_items oi, products p, product_category_name_translation pt
WHERE oi.product_id = p.product_id AND p.product_category_name = pt.product_category_name 
AND pt.product_category_name_english NOT IN ("audio", "consoles_games", "electronics","computers_accessories", "pc_gamer", "computers", "tablets_printing_image", "telephony", "fixed_telephony", "cine_photo");  

#      1.4. Are expensive tech products popular? (look at CASE WHEN function for this)

# AVG price of tech product
WITH previous AS (
SELECT AVG(oi.price) AS avg_price_tech, COUNT(oi.product_id) AS tot_num_prod, MIN(oi.price) AS min_price, MAX(oi.price) AS max_price, STDDEV(oi.price) AS price_sdev FROM order_items oi, products p, product_category_name_translation pt
WHERE oi.product_id = p.product_id AND p.product_category_name = pt.product_category_name 
AND pt.product_category_name_english IN ("audio", "consoles_games", "electronics","computers_accessories", "pc_gamer", "computers", "tablets_printing_image", "telephony", "fixed_telephony", "cine_photo"))
SELECT COUNT(oi.product_id) AS num_prod, CASE
	WHEN oi.price<= avg_price_tech*0.5 THEN "Cheap"
	WHEN oi.price > avg_price_tech*0.5 AND oi.price <= min_price + avg_price_tech THEN "Somewhat Cheap"
    WHEN oi.price > min_price+avg_price_tech AND oi.price <= min_price + 1.5* avg_price_tech THEN "Somewhat Expensive"
    ELSE "Expensive"
END AS price_cat
FROM previous, order_items AS oi
GROUP BY price_cat
ORDER BY num_prod DESC;

# Or simplified version with only 2 category: price below the average and price above
WITH previous AS (
SELECT AVG(oi.price) AS avg_price_tech, COUNT(oi.product_id) AS tot_num_prod, MIN(oi.price) AS min_price, MAX(oi.price) AS max_price, STDDEV(oi.price) AS price_sdev FROM order_items oi, products p, product_category_name_translation pt
WHERE oi.product_id = p.product_id AND p.product_category_name = pt.product_category_name 
AND pt.product_category_name_english IN ("audio", "consoles_games", "electronics","computers_accessories", "pc_gamer", "computers", "tablets_printing_image", "telephony", "fixed_telephony", "cine_photo"))
SELECT COUNT(oi.product_id) AS num_prod, CASE
	WHEN oi.price<= avg_price_tech THEN "Cheap"
    ELSE "Expensive"
END AS price_cat
FROM previous, order_items AS oi
GROUP BY price_cat
ORDER BY num_prod DESC;




/*    2. In relation to the sellers:
		2.1. How many sellers are they? */

SELECT COUNT(DISTINCT seller_id) AS num_seller FROM sellers;
 # or
SELECT COUNT(DISTINCT seller_id) AS num_seller FROM order_items;

#       2.2. What's the average monthly revenue of Magist sellers?

# Monthly revenue for all sellers
WITH avg_rev_per_seller AS(
SELECT DISTINCT oi.seller_id, SUM(oi.price) AS sum_rev_per_month, YEAR(o.order_purchase_timestamp) AS year_, MONTH(o.order_purchase_timestamp) AS month_ 
FROM order_items AS oi, orders AS o
WHERE o.order_id = oi.order_id
GROUP BY oi.seller_id, year_, month_
ORDER BY year_, month_)
SELECT AVG(sum_rev_per_month) AS monthly_avg FROM avg_rev_per_seller;

# Monthly revenue for tech sellers
WITH avg_rev_per_seller AS(
SELECT DISTINCT oi.seller_id, SUM(oi.price) AS sum_rev_per_month, YEAR(o.order_purchase_timestamp) AS year_, MONTH(o.order_purchase_timestamp) AS month_ 
FROM order_items oi, orders o, products p, product_category_name_translation pt
WHERE o.order_id = oi.order_id
AND oi.product_id = p.product_id
AND p.product_category_name = pt.product_category_name
AND pt.product_category_name_english IN ("audio", "consoles_games", "electronics","computers_accessories", "pc_gamer", "computers", "tablets_printing_image", "telephony", "fixed_telephony", "cine_photo") 
GROUP BY oi.seller_id, year_, month_
ORDER BY year_, month_)
SELECT AVG(sum_rev_per_month) AS monthly_avg FROM avg_rev_per_seller;

# Total revenue per year
WITH previous AS (
SELECT DISTINCT oi.seller_id, SUM(oi.price) AS sum_per_year, YEAR(o.order_purchase_timestamp) AS year_
FROM order_items AS oi, orders AS o
WHERE o.order_id = oi.order_id
GROUP BY oi.seller_id, year_
ORDER BY year_)
SELECT SUM(sum_per_year), year_ FROM previous
GROUP BY year_;

#	    2.3. What's the average revenue of sellers that sell tech products?

# Per year
WITH previous AS (
SELECT DISTINCT oi.seller_id, SUM(oi.price) AS sum_per_year, YEAR(o.order_purchase_timestamp) AS year_
FROM order_items AS oi, orders AS o, product_category_name_translation AS pt, products AS p
WHERE o.order_id = oi.order_id
AND oi.product_id = p.product_id
AND p.product_category_name = pt.product_category_name
AND pt.product_category_name_english NOT IN ("audio", "consoles_games", "electronics","computers_accessories", "pc_gamer", "computers", "tablets_printing_image", "telephony", "fixed_telephony", "cine_photo")
GROUP BY oi.seller_id, year_
ORDER BY year_)
SELECT AVG(sum_per_year) AS avg_revenue FROM previous
GROUP BY year_;

# Across the whole data set time
WITH previous AS (
SELECT DISTINCT oi.seller_id, SUM(oi.price) AS sum_per_year, YEAR(o.order_purchase_timestamp) AS year_
FROM order_items AS oi, orders AS o, product_category_name_translation AS pt, products AS p
WHERE o.order_id = oi.order_id
AND oi.product_id = p.product_id
AND p.product_category_name = pt.product_category_name
AND pt.product_category_name_english NOT IN ("audio", "consoles_games", "electronics","computers_accessories", "pc_gamer", "computers", "tablets_printing_image", "telephony", "fixed_telephony", "cine_photo")
GROUP BY oi.seller_id, year_
ORDER BY year_)
SELECT AVG(sum_per_year) AS avg_revenue FROM previous;

/*    3. In relation to the delivery time:
		3.1 What’s the average time between the order being placed and the product being delivered? */

# Here is the query to calculate the average time between the order and the carrier delivery time

SELECT AVG(DATEDIFF(order_delivered_carrier_date, order_purchase_timestamp)) AS avg_delivery_time FROM orders;

# Here is the query to calculate the average time between the order and the customer delivery time
SELECT AVG(DATEDIFF(order_delivered_customer_date, order_purchase_timestamp)) AS avg_delivery_time FROM orders;

 #      3.2 How many orders are delivered on time vs orders delivered with a delay?
 
 /* This is for all the orders with delivered_carrier_date as a ref
 SELECT COUNT(DISTINCT order_id), "On-time" AS delivery_status FROM orders
 WHERE order_status = "delivered" AND DATEDIFF(order_delivered_carrier_date, order_estimated_delivery_date) <= 0 
 AND order_delivered_carrier_date IS NOT NULL AND order_estimated_delivery_date IS NOT NULL
 UNION
 SELECT COUNT(DISTINCT order_id), "Late" AS delivery_status FROM orders
 WHERE order_status = "delivered" AND DATEDIFF(order_delivered_carrier_date, order_estimated_delivery_date) > 0 
 AND order_delivered_carrier_date IS NOT NULL AND order_estimated_delivery_date IS NOT NULL*/
 
 # This is for all the orders with delivered_customer_date as a ref
 
SELECT COUNT(DISTINCT order_id), "On-time" AS delivery_status FROM orders
WHERE order_status = "delivered" AND DATEDIFF(order_delivered_customer_date, order_estimated_delivery_date) <= 0 
AND order_delivered_customer_date IS NOT NULL AND order_estimated_delivery_date IS NOT NULL
UNION
SELECT COUNT(DISTINCT order_id), "Late" AS delivery_status FROM orders
WHERE order_status = "delivered" AND DATEDIFF(order_delivered_customer_date, order_estimated_delivery_date) > 0 
AND order_delivered_customer_date IS NOT NULL AND order_estimated_delivery_date IS NOT NULL;
 
 /* For orders containing tech products - delivered carrier date
SELECT COUNT(DISTINCT o.order_id) AS num_order, "On-time" AS delivery_status FROM orders o, order_items oi, products p, product_category_name_translation pt
WHERE o.order_status = "delivered" AND DATEDIFF(o.order_delivered_carrier_date, o.order_estimated_delivery_date) <= 0 
AND o.order_delivered_carrier_date IS NOT NULL AND o.order_estimated_delivery_date IS NOT NULL
AND o.order_id = oi.order_id
AND p.product_id = oi.product_id 
AND pt.product_category_name = p.product_category_name
AND pt.product_category_name_english IN ("audio", "consoles_games", "electronics","computers_accessories", "pc_gamer", "computers", "tablets_printing_image", "telephony", "fixed_telephony")
UNION
SELECT COUNT(DISTINCT o.order_id) AS num_order, "Late" AS delivery_status FROM orders o, order_items oi, products p, product_category_name_translation pt
WHERE o.order_status = "delivered" AND DATEDIFF(o.order_delivered_carrier_date, o.order_estimated_delivery_date) > 0 
AND o.order_delivered_carrier_date IS NOT NULL AND o.order_estimated_delivery_date IS NOT NULL
AND o.order_id = oi.order_id
AND p.product_id = oi.product_id 
AND pt.product_category_name = p.product_category_name
AND pt.product_category_name_english IN ("audio", "consoles_games", "electronics","computers_accessories", "pc_gamer", "computers", "tablets_printing_image", "telephony", "fixed_telephony"); */

 # For orders containing tech products - delivered customer date
SELECT COUNT(DISTINCT o.order_id) AS num_order, "On-time" AS delivery_status FROM orders o, order_items oi, products p, product_category_name_translation pt
WHERE o.order_status = "delivered" AND DATEDIFF(o.order_delivered_customer_date, o.order_estimated_delivery_date) <= 0 
AND o.order_delivered_customer_date IS NOT NULL AND o.order_estimated_delivery_date IS NOT NULL
AND o.order_id = oi.order_id
AND p.product_id = oi.product_id 
AND pt.product_category_name = p.product_category_name
AND pt.product_category_name_english IN ("audio", "consoles_games", "electronics","computers_accessories", "pc_gamer", "computers", "tablets_printing_image", "telephony", "fixed_telephony")
UNION
SELECT COUNT(DISTINCT o.order_id) AS num_order, "Late" AS delivery_status FROM orders o, order_items oi, products p, product_category_name_translation pt
WHERE o.order_status = "delivered" AND DATEDIFF(o.order_delivered_customer_date, o.order_estimated_delivery_date) > 0 
AND o.order_delivered_customer_date IS NOT NULL AND o.order_estimated_delivery_date IS NOT NULL
AND o.order_id = oi.order_id
AND p.product_id = oi.product_id 
AND pt.product_category_name = p.product_category_name
AND pt.product_category_name_english NOT IN ("audio", "consoles_games", "electronics","computers_accessories", "pc_gamer", "computers", "tablets_printing_image", "telephony", "fixed_telephony");

 
 #      3.3 Is there any pattern for delayed orders, e.g. big products being delayed more often?

# Relation to the weight - here done only with the customer-delivered_date
SELECT COUNT(oi.order_id) AS nber_order, AVG(p.product_weight_g) AS avg_weight_g, MAX(p.product_weight_g) AS max_weight_g, MIN(p.product_weight_g) AS min_weight_g,
CASE
	WHEN DATEDIFF(o.order_delivered_customer_date, o.order_estimated_delivery_date) <= 0 THEN "On-time"
	ELSE "Delayed"
END AS cat_delivery FROM order_items oi, orders o, products p
WHERE p.product_id = oi.product_id AND o.order_id = oi.order_id 
AND o.order_delivered_customer_date IS NOT NULL AND o.order_estimated_delivery_date IS NOT NULL
AND o.order_status = "delivered"
GROUP BY cat_delivery;

# Related to the length
SELECT COUNT(oi.order_id) AS nber_order, AVG(p.product_length_cm) AS avg_length_cm, MAX(p.product_length_cm) AS max_length_cm, MIN(p.product_length_cm) AS min_length_cm,
CASE
	WHEN DATEDIFF(o.order_delivered_customer_date, o.order_estimated_delivery_date) <= 0 THEN "On-time"
	ELSE "Delayed"
END AS cat_delivery FROM order_items oi, orders o, products p
WHERE p.product_id = oi.product_id AND o.order_id = oi.order_id 
AND o.order_delivered_customer_date IS NOT NULL AND o.order_estimated_delivery_date IS NOT NULL
AND o.order_status = "delivered"
GROUP BY cat_delivery;

# Related to the width
SELECT COUNT(oi.order_id) AS nber_order, AVG(p.product_width_cm) AS avg_width_cm, MAX(p.product_width_cm) AS max_width_cm, MIN(p.product_width_cm) AS min_width_cm,
CASE
	WHEN DATEDIFF(o.order_delivered_customer_date, o.order_estimated_delivery_date) <= 0 THEN "On-time"
	ELSE "Delayed"
END AS cat_delivery FROM order_items oi, orders o, products p
WHERE p.product_id = oi.product_id AND o.order_id = oi.order_id 
AND o.order_delivered_customer_date IS NOT NULL AND o.order_estimated_delivery_date IS NOT NULL
AND o.order_status = "delivered"
GROUP BY cat_delivery;

# Related to the height
SELECT COUNT(oi.order_id) AS nber_order, AVG(p.product_height_cm) AS avg_height_cm, MAX(p.product_height_cm) AS max_height_cm, MIN(p.product_height_cm) AS min_height_cm,
CASE
	WHEN DATEDIFF(o.order_delivered_customer_date, o.order_estimated_delivery_date) <= 0 THEN "On-time"
	ELSE "Delayed"
END AS cat_delivery FROM order_items oi, orders o, products p
WHERE p.product_id = oi.product_id AND o.order_id = oi.order_id 
AND o.order_delivered_customer_date IS NOT NULL AND o.order_estimated_delivery_date IS NOT NULL
AND o.order_status = "delivered"
GROUP BY cat_delivery;

# Relation to the distance - just look if the seller is in the same zip code area than the customer

SELECT COUNT(oi.order_id) AS num_order, 
CASE
	WHEN s.seller_zip_code_prefix - c.customer_zip_code_prefix THEN "Same zip"
    ELSE "Other zip"
END AS cat_location,
CASE
	WHEN DATEDIFF(o.order_delivered_customer_date, o.order_estimated_delivery_date) <= 0 THEN "On-time"
	ELSE "Delayed"
END AS cat_delivery
FROM order_items oi, orders o, customers c, sellers s
WHERE o.order_id = oi.order_id
AND oi.seller_id = s.seller_id
AND o.customer_id = c.customer_id
AND o.order_status = "delivered"
AND o.order_delivered_customer_date IS NOT NULL AND o.order_estimated_delivery_date IS NOT NULL
GROUP BY cat_location, cat_delivery;


/* Extra query

Nbre customer per zip code with states equivalent*/
SELECT COUNT(c.customer_id) AS tot_customer_state, c.customer_zip_code_prefix, g.state FROM customers c, geo g
WHERE c.customer_zip_code_prefix = g.zip_code_prefix
GROUP BY c.customer_zip_code_prefix;

#Perc customer per zip code with state equivalent
SELECT (a.tot_customer_zip/b.tot_customer)*100 AS perc_customer_zip, a.zip, a.state
FROM 
(SELECT COUNT(c.customer_id) AS tot_customer_zip, c.customer_zip_code_prefix AS zip, g.state AS state FROM customers c, geo g
WHERE c.customer_zip_code_prefix = g.zip_code_prefix
GROUP BY c.customer_zip_code_prefix) AS a,
(SELECT COUNT(c.customer_id) AS tot_customer FROM customers c) AS b;

# Total customer per state:
SELECT COUNT(c.customer_id) AS tot_customer_state, g.state FROM customers c, geo g
WHERE c.customer_zip_code_prefix = g.zip_code_prefix AND g.state IS NOT NULL
GROUP BY g.state
ORDER BY 1 DESC;

#Perc customer per state
SELECT (a.tot_customer_state/b.tot_customer)*100 AS perc_customer_state, a.state
FROM 
(SELECT COUNT(c.customer_id) AS tot_customer_state, g.state FROM customers c, geo g, order_items oi, orders o, products p, product_category_name_translation pt
WHERE c.customer_zip_code_prefix = g.zip_code_prefix AND g.state IS NOT NULL
AND o.customer_id = c.customer_id
AND o.order_id = oi.order_id
AND p.product_id = oi.product_id 
AND pt.product_category_name = p.product_category_name
AND pt.product_category_name_english NOT IN ("audio", "consoles_games", "electronics","computers_accessories", "pc_gamer", "computers", "tablets_printing_image", "telephony", "fixed_telephony")
GROUP BY g.state) AS a,
(SELECT COUNT(c.customer_id) AS tot_customer FROM customers c) AS b
ORDER BY perc_customer_state DESC;


# Nbre of sellers per zip code with states equivalent
SELECT COUNT(s.seller_id) AS tot_seller_state, s.seller_zip_code_prefix, g.state FROM sellers s, geo g
WHERE s.seller_zip_code_prefix = g.zip_code_prefix
GROUP BY s.seller_zip_code_prefix;

#Perc seller per zip:
SELECT (a.tot_seller_zip/b.tot_seller)*100 AS perc_seller_zip, a.zip, a.state
FROM 
(SELECT COUNT(s.seller_id) AS tot_seller_zip, s.seller_zip_code_prefix AS zip, g.state AS state FROM sellers s, geo g
WHERE s.seller_zip_code_prefix = g.zip_code_prefix
GROUP BY s.seller_zip_code_prefix) AS a,
(SELECT COUNT(s.seller_id) AS tot_seller FROM sellers s) AS b;

# Total seller per state:
SELECT COUNT(s.seller_id) AS tot_seller_state, g.state FROM sellers s, geo g
WHERE s.seller_zip_code_prefix = g.zip_code_prefix AND g.state IS NOT NULL
GROUP BY g.state
ORDER BY 1 DESC;

#Perc seller per state
SELECT (a.tot_seller_state/b.tot_seller)*100 AS perc_seller_state, a.state
FROM 
(SELECT COUNT(s.seller_id) AS tot_seller_state, g.state FROM sellers s, geo g
WHERE s.seller_zip_code_prefix = g.zip_code_prefix AND g.state IS NOT NULL
GROUP BY g.state
ORDER BY 1 DESC) AS a,
(SELECT COUNT(s.seller_id) AS tot_seller FROM sellers s) AS b
ORDER BY perc_seller_state DESC;

# Review score total:
SELECT COUNT(review_id), review_score FROM order_reviews
GROUP BY review_score
ORDER BY review_score DESC;

SELECT COUNT(review_id) FROM order_reviews;

# Review score total in %:

SELECT (a.num_review/b.num_review)*100 AS perc_num_review , a.score
FROM
(SELECT COUNT(review_id) AS num_review, review_score AS score FROM order_reviews
GROUP BY review_score
ORDER BY review_score DESC) AS a,
(SELECT COUNT(review_id) AS num_review FROM order_reviews) AS b
ORDER BY a.score DESC;

# Review score for tech company:
SELECT COUNT(review_id), review_score FROM order_items oi, order_reviews orev, products p, product_category_name_translation pt
WHERE orev.order_id = oi.order_id
AND oi.product_id = p.product_id
AND pt.product_category_name = p.product_category_name
AND pt.product_category_name_english IN ("audio", "consoles_games", "electronics","computers_accessories", "pc_gamer", "computers", "tablets_printing_image", "telephony", "fixed_telephony")
GROUP BY review_score
ORDER BY review_score DESC;


SELECT (a.num_review/b.num_review)*100 AS perc_num_review , a.score
FROM
(SELECT COUNT(review_id) AS num_review, review_score AS score FROM order_items oi, order_reviews orev, products p, product_category_name_translation pt
WHERE orev.order_id = oi.order_id
AND oi.product_id = p.product_id
AND pt.product_category_name = p.product_category_name
AND pt.product_category_name_english IN ("audio", "consoles_games", "electronics","computers_accessories", "pc_gamer", "computers", "tablets_printing_image", "telephony", "fixed_telephony")
AND review_comment_message IS NOT NULL
AND review_comment_message LIKE "%entrega%"
GROUP BY review_score
ORDER BY review_score DESC) AS a,
(SELECT COUNT(review_id) AS num_review FROM order_items oi, order_reviews orev, products p, product_category_name_translation pt
WHERE orev.order_id = oi.order_id
AND oi.product_id = p.product_id
AND pt.product_category_name = p.product_category_name
AND pt.product_category_name_english IN ("audio", "consoles_games", "electronics","computers_accessories", "pc_gamer", "computers", "tablets_printing_image", "telephony", "fixed_telephony")
AND review_comment_message IS NOT NULL
AND review_comment_message LIKE "%entrega%") AS b
ORDER BY a.score DESC;

# For quality:
SELECT (a.num_review/b.num_review)*100 AS perc_num_review , a.score
FROM
(SELECT COUNT(review_id) AS num_review, review_score AS score FROM order_items oi, order_reviews orev, products p, product_category_name_translation pt
WHERE orev.order_id = oi.order_id
AND oi.product_id = p.product_id
AND pt.product_category_name = p.product_category_name
AND pt.product_category_name_english IN ("audio", "consoles_games", "electronics","computers_accessories", "pc_gamer", "computers", "tablets_printing_image", "telephony", "fixed_telephony")
AND review_comment_message IS NOT NULL
AND review_comment_message LIKE "%qualidade%"
GROUP BY review_score
ORDER BY review_score DESC) AS a,
(SELECT COUNT(review_id) AS num_review FROM order_items oi, order_reviews orev, products p, product_category_name_translation pt
WHERE orev.order_id = oi.order_id
AND oi.product_id = p.product_id
AND pt.product_category_name = p.product_category_name
AND pt.product_category_name_english IN ("audio", "consoles_games", "electronics","computers_accessories", "pc_gamer", "computers", "tablets_printing_image", "telephony", "fixed_telephony")
AND review_comment_message IS NOT NULL
AND review_comment_message LIKE "%qualidade%") AS b
ORDER BY a.score DESC;


# AVG product freight value in total (base a on single product)
SELECT AVG(a.price) AS avg_product_freight
FROM
(SELECT DISTINCT(product_id), price FROM order_items) AS a;


# AVG freight value per products
SELECT product_id, AVG(freight_value) FROM order_items
GROUP BY product_id
ORDER BY AVG(freight_value) DESC;

# AVG freight value per category
SELECT AVG(oi.freight_value) AS avg_freight_cat, p.product_category_name FROM order_items oi, products p, product_category_name_translation pt
WHERE p.product_id = oi.product_id
AND oi.product_id = p.product_id
AND p.product_category_name = pt.product_category_name
AND pt.product_category_name_english IN ("audio", "consoles_games", "electronics","computers_accessories", "pc_gamer", "computers", "tablets_printing_image", "telephony", "fixed_telephony")
GROUP BY p.product_category_name
ORDER BY AVG(oi.freight_value) DESC;

# AVG freight value for tech products

SELECT AVG(a.price) AS avg_product_freight
FROM
(SELECT DISTINCT(oi.product_id), oi.price AS price FROM order_items oi, products p, product_category_name_translation pt
WHERE oi.product_id = p.product_id
AND p.product_category_name = pt.product_category_name
AND pt.product_category_name_english NOT IN ("audio", "consoles_games", "electronics","computers_accessories", "pc_gamer", "computers", "tablets_printing_image", "telephony", "fixed_telephony")) 
AS a;

SELECT COUNT(order_id) AS num_order, AVG(payment_value) AS payment, payment_type FROM order_payments
GROUP BY payment_type
ORDER BY AVG(payment_value) DESC;

# Total customer for tech product
SELECT COUNT(DISTINCT o.customer_id) FROM orders o, order_items oi, products p, product_category_name_translation pt
WHERE oi.product_id = p.product_id
AND o.order_id = oi.order_id
AND p.product_category_name = pt.product_category_name
AND pt.product_category_name_english IN ("audio", "consoles_games", "electronics","computers_accessories", "pc_gamer", "computers", "tablets_printing_image", "telephony", "fixed_telephony");
