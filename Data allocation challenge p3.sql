/*
For this multi-part challenge question - you have been requested to generate the 
following data elements to help the Data Bank team estimate how much data will need to be provisioned for each option:

    running customer balance column that includes the impact each transaction
    customer balance at the end of each month
    minimum, average and maximum values of the running balance for each customer

Using all of the data available - how much data would have been required for each option on a monthly basis?
*/
# option 1:
with deposit_amt as(select date_format(txn_date,'%y-%m') year_months, sum(txn_amount) as deposit_balance 
from customer_transactions where txn_type = 'deposit' group by year_months order by year_months),

purchase_amt as(select date_format(txn_date,'%y-%m') year_months, sum(txn_amount) as purchase_balance 
from customer_transactions where txn_type = 'purchase' group by year_months order by year_months),

withdrawal_amt as(select date_format(txn_date,'%y-%m') year_months, sum(txn_amount) as withdrawal_balance 
from customer_transactions where txn_type = 'withdrawal' group by year_months order by year_months)

select da.year_months,(coalesce(da.deposit_balance,0) - coalesce(pa.purchase_balance,0) - coalesce(wa.withdrawal_balance,0)) as end_month_bal 
from deposit_amt da left join purchase_amt pa on da.year_months = pa.year_months 
left join withdrawal_amt wa on da.year_months = wa.year_months order by year_months;

# option 2:
select txn_date,
round(avg(txn_amount) over(partition by customer_id order by txn_date range interval 30 day preceding),2) as average_balance
from  customer_transactions;

# option 3:
with running_balance as(select customer_id,txn_date,sum(case when txn_type = 'deposit' then txn_amount 
when txn_type in('purchase','withdrawal','fees') then -txn_amount else 0 end ) as balance
from customer_transactions group by customer_id,txn_date)

select customer_id,max(balance) maximum_balance,min(balance) 
minimum_balance,round(avg(balance),2) average_balance from running_balance group by customer_id;
