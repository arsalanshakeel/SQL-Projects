USE SBA_Analysis

SELECT *
  FROM [SBA_Analysis].[dbo].[SBA_public_data]
  WHERE ProcessingMethod IS NULL
-- What is the summary of all the approved PPP loans

SELECT ProcessingMethod, COUNT(ProcessingMethod)
FROM [dbo].[SBA_public_data]
GROUP BY ProcessingMethod


--What is the summary of all the Approved loans
SELECT 
	COUNT(DISTINCT LoanNumber) AS Number_of_Approved,
	SUM(InitialApprovalAmount) AS Amount_Approved,
	AVG(InitialApprovalAmount) AS Average_Amount_Approved
FROM [dbo].[SBA_public_data]



--What is the summary of all the Approved loans in 2020 and 2021?
SELECT 
	year(DateApproved) AS Year_Approved,
	COUNT(DISTINCT LoanNumber) AS Number_of_Approved,
	SUM(InitialApprovalAmount) AS Amount_Approved,
	AVG(InitialApprovalAmount) AS Average_Amount_Approved
FROM [dbo].[SBA_public_data]
WHERE 
	year(DateApproved) = 2020
GROUP BY
	year(DateApproved)
UNION

SELECT 
	year(DateApproved) AS Year_Approved,
	COUNT(DISTINCT LoanNumber) AS Number_of_Approved,
	SUM(InitialApprovalAmount) AS Amount_Approved,
	AVG(InitialApprovalAmount) AS Average_Amount_Approved
FROM [dbo].[SBA_public_data]
WHERE 
	year(DateApproved) = 2021
GROUP BY
	year(DateApproved)


-- By Months
SELECT 
	MONTH(DateApproved) AS Month_Approved,
	COUNT(DISTINCT LoanNumber) AS Number_of_Approved,
	SUM(InitialApprovalAmount) AS Amount_Approved,
	AVG(InitialApprovalAmount) AS Average_Amount_Approved
FROM [dbo].[SBA_public_data]
GROUP BY
	Month(DateApproved)
ORDER BY Month_Approved


-- Summary of OriginatingLender

SELECT 
	year(DateApproved) AS Year_Approved,
	COUNT(DISTINCT OriginatingLender) AS OriginatingLender,
	COUNT(DISTINCT LoanNumber) AS Number_of_Approved,
	SUM(InitialApprovalAmount) AS Amount_Approved,
	AVG(InitialApprovalAmount) AS Average_Amount_Approved
FROM [dbo].[SBA_public_data]
WHERE 
	year(DateApproved) = 2020
GROUP BY
	year(DateApproved)
UNION

SELECT 
	year(DateApproved) AS Year_Approved,
	COUNT(DISTINCT OriginatingLender) AS OriginatingLender,
	COUNT(DISTINCT LoanNumber) AS Number_of_Approved,
	SUM(InitialApprovalAmount) AS Amount_Approved,
	AVG(InitialApprovalAmount) AS Average_Amount_Approved
FROM [dbo].[SBA_public_data]
WHERE 
	year(DateApproved) = 2021
GROUP BY
	year(DateApproved)

-- Top 15 Originating Lenders by Loan Count, Total Amount and Average in 2020 and 2021
SELECT 
	TOP 15
	OriginatingLender,
	COUNT(DISTINCT LoanNumber) AS Number_of_Approved,
	SUM(InitialApprovalAmount) AS Amount_Approved,
	AVG(InitialApprovalAmount) AS Average_Amount_Approved
FROM [dbo].[SBA_public_data]
WHERE 
	year(DateApproved) = 2021
GROUP BY
	OriginatingLender
ORDER BY 3 DESC


--TOp 20 Industries that received the Loans in 2020 and 2021.
SELECT 
	TOP 20
	D.Sector_Name,
	year(DateApproved) AS YEAR_Approved,
	COUNT(DISTINCT LoanNumber) AS Number_of_Approved,
	SUM(InitialApprovalAmount) AS Amount_Approved,
	AVG(InitialApprovalAmount) AS Average_Amount_Approved
FROM [dbo].[SBA_public_data] AS P
INNER JOIN 
	[dbo].[sba_naics_sector_standards_description] AS D
ON
	LEFT(P.NAICSCode, 2) = D.LookUp_Codes 
WHERE 
	year(DateApproved) = 2020
GROUP BY
	D.Sector_Name,year(DateApproved)
--ORDER BY 3 DESC

UNION

SELECT 
	TOP 20
	D.Sector_Name,
	year(DateApproved) AS YEAR_Approved,
	COUNT(DISTINCT LoanNumber) AS Number_of_Approved,
	SUM(InitialApprovalAmount) AS Amount_Approved,
	AVG(InitialApprovalAmount) AS Average_Amount_Approved
FROM [dbo].[SBA_public_data] AS P
INNER JOIN 
	[dbo].[sba_naics_sector_standards_description] AS D
ON
	LEFT(P.NAICSCode, 2) = D.LookUp_Codes 
WHERE 
	year(DateApproved) = 2021
GROUP BY
	D.Sector_Name,year(DateApproved)
ORDER BY 2,4 DESC



--TOp 20 Industries that received the Loans in 2020 and 2021 By Percentage.
;WITH CTE AS
(
SELECT 
	TOP 20
	D.Sector_Name,
	COUNT(DISTINCT LoanNumber) AS Number_of_Approved,
	SUM(InitialApprovalAmount) AS Amount_Approved,
	AVG(InitialApprovalAmount) AS Average_Amount_Approved
FROM [dbo].[SBA_public_data] AS P
INNER JOIN 
	[dbo].[sba_naics_sector_standards_description] AS D
ON
	LEFT(P.NAICSCode, 2) = D.LookUp_Codes 
WHERE 
	year(DateApproved) = 2020
GROUP BY
	D.Sector_Name
--ORDER BY 3 DESC
)
SELECT 
	Sector_Name, Number_of_Approved,Amount_Approved,Average_Amount_Approved,
	Amount_Approved/SUM(Amount_Approved) OVER() * 100 AS Percentage_by_Amount
FROM CTE
ORDER BY Amount_Approved DESC


-- How much of the loans of 2021 have been fully forgiven
SELECT 
	year(DateApproved) AS Year_Number,
	COUNT(LoanNumber) AS Number_of_Approved,
	SUM(CurrentApprovalAmount) AS Current_Amount_Approved,
	AVG(CurrentApprovalAmount) AS Current_Average_Amount_Approved,
	SUM(ForgivenessAmount) AS Forgiven_Amount_Approved,
	AVG(ForgivenessAmount) AS Forgiven_Average_Amount_Approved,
	SUM(ForgivenessAmount)/SUM(CurrentApprovalAmount) *100 AS Percentage_Forgiven
FROM [dbo].[SBA_public_data]
--WHERE 
--	year(DateApproved) = 2021
GROUP BY
	year(DateApproved)
ORDER BY Percentage_Forgiven DESC

--Year,Month with highest PPP Loans
SELECT 
	YEAR(DateApproved) AS Year_Approved,
	MONTH(DateApproved) AS Month_Approved,
	COUNT(LoanNumber) AS Number_of_Approved,
	SUM(InitialApprovalAmount) AS Total_Amount_Approved,
	AVG(InitialApprovalAmount) AS Total_Average_Amount_Approved
FROM [dbo].[SBA_public_data]
GROUP BY
	YEAR(DateApproved),
	MONTH(DateApproved)
ORDER BY
4 DESC

--States and Territories
SELECT BorrowerState AS state, COUNT(LoanNumber) AS Loan_Count, SUM(CurrentApprovalAmount) Net_Dollars
FROM [dbo].[SBA_public_data] main
--where cast(DateApproved as date) < '2021-06-01'
GROUP BY BorrowerState
ORDER BY 1


---Demographics for PPP
SELECT Race, count(LoanNumber) AS Loan_Count, SUM(CurrentApprovalAmount) Net_Dollars
FROM [dbo].[SBA_public_data]
GROUP BY Race
ORDER BY 3 DESC

SELECT Gender, count(LoanNumber) AS Loan_Count, SUM(CurrentApprovalAmount) Net_Dollars
FROM [dbo].[SBA_public_data]
GROUP BY Gender
ORDER BY 3 DESC

SELECT Ethnicity, count(LoanNumber) AS Loan_Count, SUM(CurrentApprovalAmount) Net_Dollars
FROM [dbo].[SBA_public_data]
GROUP BY Ethnicity
ORDER BY 3 DESC

SELECT Veteran, count(LoanNumber) AS Loan_Count, SUM(CurrentApprovalAmount) Net_Dollars
FROM [dbo].[SBA_public_data]
GROUP BY Veteran
ORDER BY 3 DESC