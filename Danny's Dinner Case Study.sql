CREATE TABLE sales (
  customer_id VARCHAR(1),
  order_date DATE,
  product_id INTEGER
);

INSERT INTO sales
  (customer_id, order_date, product_id)
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

CREATE TABLE menu (
  product_id INTEGER,
  product_name VARCHAR(5),
  price INTEGER
);

INSERT INTO menu
  (product_id, product_name, price)
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  customer_id VARCHAR(1),
  join_date DATE
);

INSERT INTO members
  (customer_id, join_date)
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
  
-- 1. What is the total amount each customer spent at the restaurant?
select * from members;

select * from menu;

select * from sales;

select sales.customer_id ,sum(menu.price) as amount_spent
from  menu join sales on menu.product_id = sales.product_id
group by sales.customer_id;

-- 2.How many days has each customer visited the restaurant?
select * from sales;

select customer_id,  count(distinct order_date) as no_of_visits from sales
group by customer_id;

-- 3. What was the first item from the menu purchased by each customer?
with sales_info  as (select *,rank() over(partition by customer_id order by order_date ) as rk from sales)
select s.*,m.product_name from sales_info s join menu m on s.product_id = m.product_id where rk=1;

--  What is the most purchased item on the menu and how many times was 
-- it purchased by all customers?

select product_id from 
(select  product_id,count(product_id) no_purchased_item from sales group by product_id)t
;
select * from menu;
select product_id,product_name,no_of_purchased_item from (
select product_id,count(product_id) no_of_purchased_item from sales group by product_id order by count(product_id) desc limit 1) t
inner join menu m using (product_id) ;


select * from sales;


select t.product_id,t.most_purchased_iteam,menu.product_name from 
(select product_id , count(product_id) as most_purchased_iteam  from sales group by product_id order by count(product_id) desc limit 1) t
join menu on t.product_id = menu.product_id;

-- 5. Which item was the most popular for each customer?
select * from sales;

with customer_info as 
(select customer_id,product_id,count(customer_id
) as repeted from sales group by customer_id,product_id),
details as (
select *, rank() over(partition by customer_id order by repeted desc) as rn from customer_info)
select d.*,product_name from details d inner join menu using (product_id) where rn=1;

  
  with cust_info as (
select customer_id,product_id,count(customer_id) as repeated from sales group by customer_id,product_id),
detailed as (select *,rank() over(partition by customer_id order by repeated desc) as rn from cust_info)
select d.*, product_name from detailed d inner join menu using (product_id) where rn=1;

-- 6. Which item was the most popular for each customer?

with cust_info as (select customer_id ,product_id ,count(customer_id) as r from sales group by customer_id,product_id),
details as (select *, rank() over(partition by customer_id order by r desc) as rnk from cust_info )
select d.*,product_name from details d join menu m on m.product_id = d.product_id;

-- 7.Which item was purchased first by the customer after they became a member?
select * from sales;
with cut_info as (select *,rank() over(partition by customer_id order by order_date) as top_food from sales)
select c.*,m.product_name from cut_info c join menu m on m.product_id = c.product_id where top_food=1;

SELECT s.customer_id, m.product_name, MIN(s.order_date) AS first_purchase_date
FROM sales s JOIN
 members b ON s.customer_id = b.customer_id AND s.order_date >= b.join_date
JOIN menu m ON s.product_id = m.product_id
GROUP BY s.customer_id, m.product_name
ORDER BY s.customer_id, first_purchase_date;

select * from members

