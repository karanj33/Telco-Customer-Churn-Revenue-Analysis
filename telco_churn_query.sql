create database telco;
use telco;

-- creating duplicate table of exixting table for safity purpose

create table telco_churn like telco_rawdata; 
insert into telco_churn select * from telco_rawdata;

select * from telco_churn;

-- analyzing table structure

describe telco_churn;

-- Finding missing values 
SELECT 
SUM(case when `Customer ID` is null then 1 else 0 end) as NullCustomerID,
SUM(case when `Churn Label` is null then 1 else 0 end) as NullChurn,
SUM(case when `Tenure in Months` is null then 1 else 0 end) as NullTenure,
SUM(case when `Monthly Charge` is null then 1 else 0 end) as NullMonthlyCharges,
SUM(case when `Total Charges` is null then 1 else 0 end) as NullTotalCharges
from telco_churn;

-- checking for duplicate

select `Customer ID`,count(*) 
as duplicates from telco_churn
group by `Customer ID` 
having Count(*) >1;

-- looking for unique values

select 
(select group_concat(distinct`Gender`) from telco_churn )as distintct_gender, 
(select group_concat(distinct`Churn Category`) from telco_churn) as distinct_churn_category,
(select group_concat(distinct`Churn Reason`) from telco_churn) as Distintct_churn_reason;

-- updating empty string with normal value

set sql_safe_updates=0;

update telco_churn
set `Churn Category` = 'not churned'
where `Churn Category`='';

update telco_churn
set `Churn Reason` = 'not churned'
where `Churn Reason`='';

-- distinct values 
select distinct `Churn Reason` from telco_churn;
select distinct `Churn Category` from telco_churn;
select distinct `Churn Label` from telco_churn;

alter table telco_churn
add column churn_flag int;

update telco_churn
set churn_flag =
case
when `churn label`='yes' then 1
else 0
end;

-- overall churn rate

select 
count(*) as total_customers,
sum(churn_flag) as churned_customers,
round(avg(churn_flag)*100,2) as churn_rate_percent
from telco_churn;

-- churn rate by contract type

select `contract`,
count(*) as customers,
sum(churn_flag) as churned,
round(avg(churn_flag)*100,2) as churn_rate
from telco_churn
group by `contract`
order by churn_rate desc;

-- churn by payment method

select `payment method`,
count(*) as customers,
sum(churn_flag) as churned
from telco_churn
group by `payment method`
order by churned desc;

-- cities generating highest revenue

select `city`,
sum(`total revenue`) as total_revenue
from telco_churn
group by `city`
order by total_revenue desc
limit 10;

-- churn by internet service

select `internet service`,
count(*) as customers,
sum(churn_flag) as churned
from telco_churn
group by `internet service`;

-- average monthly charge by churn status

select `Churn Label`,
avg(`monthly charge`) as avg_monthly_charge
from telco_churn
group by `Churn Label`;

-- customers paying above average monthly charge

select `customer id`,`monthly charge`
from telco_churn
where `monthly charge` >
(select avg(`monthly charge`) from telco_churn);

-- top churn reasons

select `churn reason`,
count(*) as reason_count
from telco_churn
where churn_flag=1
group by `churn reason`
order by reason_count desc;

-- top 10  customers by total revenue

select 
`customer id`,
`total revenue`,
rank() over(order by `total revenue` desc) as revenue_rank
from telco_churn limit 10;

-- churn rate by tenure group

select 
case 
when `tenure in months` <12 then 'new'
when `tenure in months` between 12 and 36 then 'mid'
else 'loyal'
end as tenure_group,
count(*) as customers,
sum(churn_flag) as churned
from telco_churn
group by tenure_group;

-- top 10 customers with highest customer lifetime revenue

select 
`customer id`,
`cltv` as `customer lifetime revenue`
from telco_churn
order by `cltv` desc
limit 10;

