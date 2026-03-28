use project;

select * from order_details;
select * from orders;
select * from pizza_types;
select * from pizzas;

select count(distinct(order_id)) as total_orders from orders;

select round(sum(sales), 2) as total_revenue_generated from 
(select order_id, quantity, price, quantity*price as sales from order_details t1 inner join pizzas t2
on t1.pizza_id = t2.pizza_id)t;

select name, category, pizza_id, size, price from pizzas t1 inner join pizza_types t2
on t1.pizza_type_id = t2.pizza_type_id
where price = (select max(price) from pizzas);

select size, count(order_id) no_of_orders from order_details t1 inner join pizzas t2
on t1.pizza_id = t2.pizza_id
group by size
order by no_of_orders desc
limit 1;

select name, sum(quantity) as quantity from order_details t1 inner join pizzas t2
on t1.pizza_id = t2.pizza_id inner join pizza_types t3
on t2.pizza_type_id = t3.pizza_type_id
group by name
order by quantity desc
limit 5;

select category, sum(quantity) as quantity from order_details t1 inner join pizzas t2
on t1.pizza_id = t2.pizza_id inner join pizza_types t3
on t2.pizza_type_id = t3.pizza_type_id
group by category;

select category, round(sum(sales),2) as Revenue, sum(quantity) as Quantity, count(distinct(order_id)) as "No	_of_orders" from
(select name, category, quantity, t1.order_id, quantity*price as sales from order_details t1 inner join pizzas t2
on t1.pizza_id = t2.pizza_id inner join pizza_types t3
on t2.pizza_type_id = t3.pizza_type_id)t
group by category
order by sum(sales) desc;

select hour, count(order_id) from 
(select *, hour(time)+1 as "hour" from orders)t
group by hour
order by hour;

select sum(quantity)/count(date) as Average_no_of_pizzas from
(select date, count(distinct(t1.order_id)) as order1, sum(quantity) as quantity from order_details t1 inner join orders t2
on t1.order_id = t2.order_id
group by date)t;

select name, sum(revenue) as revenue from
(select name, quantity*price as revenue from order_details t1 inner join pizzas t2
on t1.pizza_id = t2.pizza_id inner join pizza_types t3
on t2.pizza_type_id = t3.pizza_type_id)t
group by name
order by revenue desc
limit 3;

with cte as
(select name, sum(quantity*price) as revenue1 from order_details t1 inner join pizzas t2
on t1.pizza_id = t2.pizza_id inner join pizza_types t3
on t2.pizza_type_id = t3.pizza_type_id
group by name),
total_revenue as
(select round(sum(sales), 2) as total_revenue_generated from 
(select order_id, quantity, price, quantity*price as sales from order_details t1 inner join pizzas t2
on t1.pizza_id = t2.pizza_id)t)
select name, round((revenue1/(select total_revenue_generated from total_revenue))*100 ,2) as percent_distribution from cte
order by percent_distribution desc;

with main_cte as
(
select date, round(sum(quantity*price),2) as revenue
from order_details t1 inner join pizzas t2
on t1.pizza_id = t2.pizza_id inner join orders t3
on t1.order_id = t3.order_id
group by date order by date
)
select date, round(sum(revenue) over (order by date),2) as cummulative_revenue from main_cte;

with main as
(
select name, category, sum(quantity*price) as revenue, dense_rank() over (partition by category order by sum(quantity*price) desc) as ranking
from order_details t1 inner join pizzas t2
on t1.pizza_id = t2.pizza_id inner join pizza_types t3
on t2.pizza_type_id = t3.pizza_type_id
group by name, category
order by category, revenue desc
)
select name, category, ranking from main where ranking in (1,2,3)
