-- Inspecting Data

USE SalesDB

select * from [dbo].[sales_data_kaggle]


 -- Checking Unique Values
select distinct status from dbo.sales_data_kaggle --Nice to plot
select distinct YEAR_ID from dbo.sales_data_kaggle
select distinct PRODUCTLINE from dbo.sales_data_kaggle --Nice to plot
select distinct COUNTRY from dbo.sales_data_kaggle --Nice to plot
select distinct DEALSIZE from dbo.sales_data_kaggle --Nice to plot
select distinct TERRITORY from dbo.sales_data_kaggle --Nice to plot
select distinct ORDERNUMBER from dbo.sales_data_kaggle --Nice to plot
select * from dbo.sales_data_kaggle --Nice to plot



select distinct CUSTOMERNAME,COUNT(CUSTOMERNAME) AS FREQUENCY 
from dbo.sales_data_kaggle 
--where YEAR_ID = 2005
GROUP BY CUSTOMERNAME
ORDER BY 2 DESC

-- Hence, know that we have complete data for 2003 and 2004, but for 2005 only first five months
select distinct MONTH_ID from dbo.sales_data_kaggle
where YEAR_ID = 2004



-- Analysis
-- let's start by grouping sales by productline
select PRODUCTLINE, sum(sales) AS Revenue
from SalesDB.dbo.sales_data_kaggle
group by PRODUCTLINE
order by 2 DESC

-- let's start by grouping sales by YEAR
select YEAR_ID, sum(sales) AS Revenue
from SalesDB.dbo.sales_data_kaggle
group by YEAR_ID
order by 2 DESC


-- let's start by grouping sales by DEALSIZE
select DEALSIZE, sum(sales) AS Revenue
from SalesDB.dbo.sales_data_kaggle
group by DEALSIZE
order by 2 DESC


-- What was the best month for sales in a specific year? How much was earned that month?
select MONTH_ID, SUM(SALES) AS REVENUE, COUNT(ORDERNUMBER) AS FREQUENCY
from SalesDB.dbo.sales_data_kaggle
where YEAR_ID = 2004 -- Change year to see the rest
group by MONTH_ID
order by 1 DESC


-- Beaking down into months and deal size
select MONTH_ID,DEALSIZE, SUM(SALES) AS REVENUE, COUNT(ORDERNUMBER) AS FREQUENCY
from SalesDB.dbo.sales_data_kaggle
where YEAR_ID = 2004 -- Change year to see the rest
group by MONTH_ID, DEALSIZE
order by 1, 3 DESC


-- So we know that November is the best month for sales, What products do they sell in November?
select MONTH_ID, PRODUCTLINE, SUM(SALES) AS REVENUE, COUNT(ORDERNUMBER) AS FREQUENCY
from SalesDB.dbo.sales_data_kaggle
where YEAR_ID = 2004 AND MONTH_ID = 11 -- Change year to see the rest
group by MONTH_ID, PRODUCTLINE
order by 3 DESC


-- Who is the best customer? (This could be best answered with RFM (Recency-Frequency-Monetary))
--TEMP TABLE
DROP TABLE IF EXISTS #RFM
;with rfm as
	(
	select CUSTOMERNAME, sum(SALES) AS MonetaryValue, avg(SALES) AS AvgMonetaryValue, 
	COUNT(ORDERNUMBER) AS Frequency, MAX(ORDERDATE) AS Last_order_date,
	(select MAX(ORDERDATE) from [dbo].[sales_data_kaggle]) AS Max_order_date,
	-- Date Difference for the recency
	DATEDIFF(DD, MAX(ORDERDATE), (select MAX(ORDERDATE) from [dbo].[sales_data_kaggle])) AS Recency
	from [dbo].[sales_data_kaggle]
	
	group by CUSTOMERNAME
	--Order by 4 DESC
),
rfm_calc AS 
(
	select r.*,
		NTILE(4) over (order by Recency DESC) as RFM_Recency, --Minimum recency(last_order_date is close to max_order_date) give RFM_Recency 4 and Max recency gives RFM_Recency 1
		NTILE(4) over (order by Frequency) as RFM_Frequency, -- Max Frequency gives RFM_Frequency 4 and Min Frequency gives RFM_Frequency 1
		NTILE(4) over (order by MonetaryValue) as RFM_Monetary -- Max AvgMonetary gives RFM_Monetary 4 and Min Monetary gives RFM_Monetary 1
	from rfm as r
)
select 
	c.*, RFM_Recency+ RFM_Frequency+ RFM_Monetary AS RFM_total,
	cast(RFM_Recency AS VARCHAR) + cast(RFM_Frequency AS VARCHAR)+cast(RFM_Monetary AS VARCHAR) AS RFM_Sequence
INTO #RFM
from rfm_calc AS c

--Viewing Temp Table
SELECT DISTINCT RFM_Sequence FROM #RFM


select CUSTOMERNAME , rfm_recency, rfm_frequency, rfm_monetary,
	-- Samples Cases
	case 
		when RFM_Sequence in (111, 112 , 121, 122, 123, 132, 211, 212, 114, 141) then 'lost_customers'  --lost customers
		when RFM_Sequence in (133, 134, 143, 244, 334, 343, 344, 144) then 'slipping away, cannot lose' -- (Big spenders who haven’t purchased lately) slipping away
		when RFM_Sequence in (311, 411, 331) then 'new customers'
		when RFM_Sequence in (222, 223, 233, 322) then 'potential churners'
		when RFM_Sequence in (323, 333,321, 422, 332, 432) then 'active' --(Customers who buy often & recently, but at low price points)
		when RFM_Sequence in (433, 434, 443, 444) then 'loyal'
	end rfm_segment

from #rfm


-- What Products are most often sold together?

SELECT DISTINCT ORDERNUMBER, STUFF(

	(SELECT ',' + PRODUCTCODE
	FROM [dbo].[sales_data_kaggle] AS initial_product_codes
	WHERE ORDERNUMBER IN
	(
		SELECT ORDERNUMBER
		FROM(
			SELECT ORDERNUMBER, COUNT(ORDERNUMBER) AS order_counts
			FROM [dbo].[sales_data_kaggle]
			WHERE STATUS = 'Shipped'
			GROUP BY ORDERNUMBER
			--ORDER By 2
		) AS Test
		WHERE order_counts = 2
	) AND initial_product_codes.ORDERNUMBER = filter_product_codes.ORDERNUMBER
	FOR XML PATH (''))
	,1,1,'') AS Product_Codes

FROM [dbo].[sales_data_kaggle] AS filter_product_codes
ORDER BY 2 DESC

