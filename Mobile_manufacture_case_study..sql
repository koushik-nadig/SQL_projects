--SQL Advance Case Study


--Q1--BEGIN------List all the states in which we have customers who have bought cellphones from 2005 till today. 
select state,d.YEAR
from DIM_DATE d 
inner join FACT_TRANSACTIONS ft on d.DATE=ft.Date 
inner join DIM_LOCATION l on ft.IDLocation=l.IDLocation
where d.YEAR > 2005
--Q1--END


--Q2--BEGIN---What state in the US is buying the most 'Samsung' cell phones? 
select top 1 State,Country,sum(quantity)[Total_qty]
from DIM_MANUFACTURER ma
inner join DIM_MODEL mo on ma.IDManufacturer=mo.IDManufacturer
inner join FACT_TRANSACTIONS ft on mo.IDModel=ft.IDModel
inner join DIM_LOCATION l on ft.IDLocation=l.IDLocation
where country='us' and Manufacturer_Name='samsung'
group by Country,State
--Q2--END


--Q3--BEGIN-----Show the number of transactions for each model per zip code per state.    
select l.ZipCode,l.[State],m.Model_Name, count(t.IDCustomer)[no_of_transactions]
from FACT_TRANSACTIONS t inner join DIM_LOCATION l on t.IDLocation=l.IDLocation
inner join DIM_MODEL m on t.IDModel=m.IDModel
group by l.ZipCode,l.[State],m.Model_Name
--Q3--END


--Q4--BEGIN---Show the cheapest cellphone (Output should contain the price also).
select top 1 Model_Name,min(unit_price)[cheap_price]
from DIM_MODEL
group by Model_Name
--Q4--END


--Q5--BEGIN---- List the names of the customers and the average amount spent in 2009, where the average is higher than 500.
select top 5 Model_Name,manufacturer_name,AVG(unit_price)[Avg_Unitprice],sum(quantity)[Sales_Quantity],avg(TotalPrice)[Avg_Totalprice]
from DIM_MANUFACTURER ma inner join DIM_MODEL mo on ma.IDManufacturer=mo.IDManufacturer
inner join FACT_TRANSACTIONS t on mo.IDModel=t.IDModel
group by Model_Name,manufacturer_name
order by sum(quantity) desc,avg(totalprice) desc
--Q5--END


--Q6--BEGIN---List the names of the customers and the average amount spent in 2009, where the average is higher than 500.
select Customer_Name,avg(totalprice)[Avg_amt]
from FACT_TRANSACTIONS t inner join DIM_CUSTOMER c on t.IDCustomer=c.IDCustomer
where year(t.date)='2009'
group by Customer_Name
having avg(totalprice)>500
--Q6--END
	

--Q7--BEGIN ----List if there is any model that was in the top 5 in terms of quantity, simultaneously in 2008, 2009 and 2010.
select * from(select top 5 Model_Name  
from FACT_TRANSACTIONS f1 inner join DIM_MODEL m1  on f1.IDModel = m1.IDModel
where year(date) = 2008
group by Model_Name
order by SUM(Quantity) desc)s

intersect

select * from (select top 5 Model_Name  
from FACT_TRANSACTIONS ft inner join DIM_MODEL mo  on ft.IDModel = mo.IDModel
where year(date) = 2009
group by Model_Name
order by SUM(Quantity) desc)s

intersect

select * from(select top 5 Model_Name  from FACT_TRANSACTIONS ft inner join DIM_MODEL mo  on ft.IDModel = mo.IDModel
where year(date) = 2010
group by Model_Name
order by SUM(Quantity) desc)s	
--Q7--END


--Q8--BEGIN---Show the manufacturer with the 2nd top sales in the year of 2009 and the manufacturer with the 2nd top sales in the year of 2010.
select * from (select  Manufacturer_Name, RANK() over(order by sum(totalprice)desc)[2nd top sale] 
from FACT_TRANSACTIONS ft
inner join DIM_MODEL mo on ft.IDModel = mo.IDModel 
inner join DIM_MANUFACTURER ma on mo.IDManufacturer = ma.IDManufacturer
where YEAR(date) = 2009
group by Manufacturer_Name)s
where [2nd top sale] = '2'

union

select * from (select Manufacturer_Name, rank() over (order by SUM(totalprice) desc)[2nd top sale]
from FACT_TRANSACTIONS ft
inner join DIM_MODEL mo on ft.IDModel = mo.IDModel 
inner join DIM_MANUFACTURER ma on mo.IDManufacturer = ma.IDManufacturer
where YEAR(date) = 2010
group by Manufacturer_Name)s
where [2nd top sale] = '2'
--Q8--END


--Q9--BEGIN--Show the manufacturers that sold cellphones in 2010 but did not in 2009.
select ma.Manufacturer_Name
from DIM_MANUFACTURER ma inner join DIM_MODEL mo on ma.IDManufacturer=mo.IDManufacturer 
inner join FACT_TRANSACTIONS t on mo.IDModel=t.IDModel
where year(t.Date)=2010 
group by ma.Manufacturer_Name
except
select ma.Manufacturer_Name
from DIM_MANUFACTURER ma inner join DIM_MODEL mo on ma.IDManufacturer=mo.IDManufacturer 
inner join FACT_TRANSACTIONS t on mo.IDModel=t.IDModel
where year(t.Date)=2009
group by ma.Manufacturer_Name
--Q9--END


--Q10--BEGIN---Find top 100 customers and their average spend, average quantity by each year.Also find the percentage of change in their spend.-- 
select Customer_Name,[Year],[avg_qty],[avg_spent],([Total Spend] - [lag])*100/[lag] [percentage change]
from(select top 100 Customer_Name,year(date)[Year],AVG(Quantity)[avg_qty],AVG(TotalPrice)[avg_spent],sum(TotalPrice)[Total Spend],lag(sum (TotalPrice))over(Partition by Customer_Name 
order by year(date),AVG(Quantity) desc,AVG(TotalPrice) desc)[lag] 
from FACT_TRANSACTIONS ft inner join DIM_CUSTOMER c on ft.IDCustomer = c.IDCustomer
group by year(Date),Customer_Name)t1
--Q10--END
