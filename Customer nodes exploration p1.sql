# Q1. How many unique nodes are there on the Data Bank system?
select count(distinct node_id) total_nodes from customer_nodes;

# Q2. What is the number of nodes per region?
select rn.region_name,count(distinct cn.node_id) total_nodes from customer_nodes cn join regions rn 
on cn.region_id = rn.region_id group by rn.region_name;

# Q3. How many customers are allocated to each region?
select rn.region_name,count(distinct cn.customer_id) total_customer 
from customer_nodes cn join regions rn on cn.region_id = rn.region_id group by rn.region_name;

# 4. How many days on average are customers reallocated to a different node?
select rn.region_name,round(avg(datediff(cn.end_date,cn.start_date)),2) average_date from customer_nodes cn join regions rn 
on cn.region_id=rn.region_id group by rn.region_name;

select round(avg(datediff(end_date,start_date)),2) average_reallocation from customer_nodes;

# 5.  What is the median, 80th and 95th percentile for this same reallocation days metric for each region?
/*
Query does not support system!
SELECT 
    rn.region_name,
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP  (ORDER BY DATEDIFF(cn.end_date, cn.start_date)), 2) AS median_days,
    ROUND(PERCENTILE_CONT(0.8) WITHIN GROUP (ORDER BY DATEDIFF(cn.end_date, cn.start_date)), 2) AS p80_days,
    ROUND(PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY DATEDIFF(cn.end_date, cn.start_date)), 2) AS p95_days
FROM 
    customer_nodes cn
JOIN 
    regions rn ON cn.region_id = rn.region_id
GROUP BY 
    rn.region_name;
*/

select rn.region_name,  
substring_index(
substring_index(
group_concat(datediff(cn.end_date,cn.start_date) order by datediff(cn.end_date,cn.start_date)),
',',ceil(count(*)*0.5)),
',',-1) as median_days,

substring_index(
substring_index(
group_concat(datediff(cn.end_date,cn.start_date) order by datediff(cn.end_date,cn.start_date)),',',ceil(count(*) * 0.8)),
',',-1) as 80th_percentile,

substring_index(
substring_index(
group_concat(datediff(cn.end_date,cn.start_date) order by datediff(cn.end_date,cn.start_date)),',',ceil(count(*) * 0.95)),
',',-1) as 95th_percentile
from customer_nodes cn join regions rn on cn.region_id = rn.region_id group by rn.region_name;

