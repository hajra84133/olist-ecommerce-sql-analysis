-- Q1: Revenue & Order Trends by Month
SELECT EXTRACT(YEAR FROM order_purchase_timestamp) AS year, EXTRACT(MONTH FROM order_purchase_timestamp) AS month, COUNT(DISTINCT o.order_id) AS total_orders, ROUND(SUM(p.payment_value)::numeric, 2) AS total_revenue FROM orders o JOIN order_payments p ON o.order_id = p.order_id WHERE order_status = 'delivered' GROUP BY year, month ORDER BY year, month;

-- Q2: Top 10 Product Categories by Revenue
SELECT t.product_category_name_english AS category, COUNT(DISTINCT oi.order_id) AS total_orders, ROUND(SUM(oi.price)::numeric, 2) AS total_revenue FROM order_items oi JOIN products p ON oi.product_id = p.product_id JOIN product_category_translation t ON p.product_category_name = t.product_category_name GROUP BY category ORDER BY total_revenue DESC LIMIT 10;

-- Q3: Payment Method Analysis
SELECT payment_type, COUNT(DISTINCT order_id) AS total_orders, ROUND(AVG(payment_value)::numeric, 2) AS avg_order_value, ROUND(SUM(payment_value)::numeric, 2) AS total_revenue FROM order_payments GROUP BY payment_type ORDER BY total_revenue DESC;

-- Q4: Average Delivery Time
SELECT ROUND(AVG(EXTRACT(EPOCH FROM (order_delivered_customer_date - order_purchase_timestamp))/86400)::numeric, 1) AS avg_delivery_days, ROUND(MIN(EXTRACT(EPOCH FROM (order_delivered_customer_date - order_purchase_timestamp))/86400)::numeric, 1) AS min_delivery_days, ROUND(MAX(EXTRACT(EPOCH FROM (order_delivered_customer_date - order_purchase_timestamp))/86400)::numeric, 1) AS max_delivery_days FROM orders WHERE order_status = 'delivered' AND order_delivered_customer_date IS NOT NULL;

-- Q5: Top Rated Product Categories
SELECT t.product_category_name_english AS category, ROUND(AVG(r.review_score)::numeric, 2) AS avg_rating, COUNT(r.review_id) AS total_reviews FROM order_reviews r JOIN order_items oi ON r.order_id = oi.order_id JOIN products p ON oi.product_id = p.product_id JOIN product_category_translation t ON p.product_category_name = t.product_category_name GROUP BY category HAVING COUNT(r.review_id) > 100 ORDER BY avg_rating DESC LIMIT 10;

-- Q6: Repeat Customer Rate
SELECT COUNT(*) AS total_customers, SUM(CASE WHEN order_count > 1 THEN 1 ELSE 0 END) AS repeat_customers, ROUND(SUM(CASE WHEN order_count > 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS repeat_rate_percent FROM (SELECT customer_unique_id, COUNT(o.order_id) AS order_count FROM customers c JOIN orders o ON c.customer_id = o.customer_id GROUP BY customer_unique_id) customer_orders;

-- Q7: Late Delivery Rate
SELECT COUNT(*) AS total_delivered, SUM(CASE WHEN order_delivered_customer_date > order_estimated_delivery_date THEN 1 ELSE 0 END) AS late_orders, ROUND(SUM(CASE WHEN order_delivered_customer_date > order_estimated_delivery_date THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS late_delivery_percent FROM orders WHERE order_status = 'delivered' AND order_delivered_customer_date IS NOT NULL AND order_estimated_delivery_date IS NOT NULL;

-- Q8: Impact of Late Delivery on Reviews
SELECT CASE WHEN order_delivered_customer_date > order_estimated_delivery_date THEN 'Late' ELSE 'On Time' END AS delivery_status, ROUND(AVG(r.review_score)::numeric, 2) AS avg_review_score, COUNT(*) AS total_orders FROM orders o JOIN order_reviews r ON o.order_id = r.order_id WHERE order_status = 'delivered' AND order_delivered_customer_date IS NOT NULL GROUP BY delivery_status;

-- Q9: Top 10 Sellers by Revenue
SELECT s.seller_id, s.seller_city, s.seller_state, COUNT(DISTINCT oi.order_id) AS total_orders, ROUND(SUM(oi.price)::numeric, 2) AS total_revenue FROM order_items oi JOIN sellers s ON oi.seller_id = s.seller_id GROUP BY s.seller_id, s.seller_city, s.seller_state ORDER BY total_revenue DESC LIMIT 10;

-- Q10: Revenue by Customer State
SELECT c.customer_state, COUNT(DISTINCT o.order_id) AS total_orders, ROUND(SUM(p.payment_value)::numeric, 2) AS total_revenue FROM orders o JOIN customers c ON o.customer_id = c.customer_id JOIN order_payments p ON o.order_id = p.order_id WHERE o.order_status = 'delivered' GROUP BY c.customer_state ORDER BY total_revenue DESC LIMIT 10;