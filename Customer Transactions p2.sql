# Q1. What is the unique count and total amount for each transaction type?
select txn_type,count(*) unique_count,sum(txn_amount) total_amount from customer_transactions group by txn_type;

# Q2. What is the average total historical deposit counts and amounts for all customers?
with deposit_data as(select customer_id,count(*) total_deposit,sum(txn_amount) deposit_amount
from customer_transactions where txn_type='deposit' group by customer_id order by customer_id)

select round(avg(total_deposit),2) as average_deposit, 
round(avg(deposit_amount),2) as average_deposit_amount 
from deposit_data;

# Q3. For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?
with filter_data as(select customer_id,monthname(txn_date) Month_wise,count( case when txn_type = 'deposit' then 1 end) as deposit_count, 
count(case when txn_type = 'purchase'or txn_type = 'withdrawal' then 1 end) withdrawal_count
 from customer_transactions group by customer_id,Month_wise)
 
 select Month_wise,count(*) total_customer from filter_data fd where withdrawal_count>=1 and deposit_count>1 
 group by Month_wise ;


# Q4. What is the closing balance for each customer at the end of the month?
/*
with deposit_data as(select customer_id ,monthname(txn_date) as Months,sum(txn_amount) deposit_balance 
from customer_transactions where txn_type = 'deposit' group by customer_id,Months ),

purchase_data as(select customer_id,monthname(txn_date) as Months,sum(txn_amount) purchase_balance 
from customer_transactions where txn_type = 'purchase' group by customer_id,Months ),

withdrawal_data as(select customer_id, monthname(txn_date) as Months,sum(txn_amount) withdrawal_balance 
from customer_transactions where txn_type = 'withdrawal' group by customer_id, Months ),

total_balance as( select sum(txn_amount) total_balance from customer_transactions)

select ct.customer_id,sum((select total_balance from total_balance) + dp.deposit_balance - purchase_balance - withdrawal_balance)
 as closing_amount
 from customer_transactions ct join deposit_data dp on ct.customer_id = dp.customer_id join purchase_data pd  on 
dp.customer_id = pd.customer_id join withdrawal_data wd on pd.customer_id = wd.customer_id  group by ct.customer_id ; */

select customer_id, date_format(txn_date, '%y-%m') year_months,
sum(case when txn_type = 'deposit' then txn_amount
     when txn_type in('purchase','withdrawal','fees') then -txn_amount else 0 end) closing_balance
 from customer_transactions group by customer_id,year_months order by customer_id ;
 

# Q5. What is the percentage of customers who increase their closing balance by more than 5%?

with filter_data as(select customer_id, date_format(txn_date,'%y-%m') as year_months,
sum(case when txn_type = 'deposit' then txn_amount 
          when txn_type in('purchase','withdrawal','fees') then -txn_amount else 0 end) as balance
 from customer_transactions group by customer_id,year_months order by customer_id),

balance_lag as(select customer_id,year_months,balance, lag(balance) over(partition by customer_id order by year_months) as previus_balance 
from filter_data),

growth_calculate as(select customer_id,year_months,balance,previus_balance,
(case when previus_balance is not null  then round(((balance-previus_balance)/previus_balance)*100,2)
 else 0 end)as growth_percent
 from balance_lag),
 
customer_above_5 as (select distinct customer_id from growth_calculate where growth_percent > 5)
 
 select (count(*)*100/(select count(distinct customer_id) 
 from customer_transactions)) percent_customer_above_5 from customer_above_5;





 