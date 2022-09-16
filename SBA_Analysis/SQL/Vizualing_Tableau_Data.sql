CREATE VIEW ppp_main AS

SELECT 
	d.Sector_Name,  
	YEAR(DateApproved) AS year_approved,
	MONTH(DateApproved) AS month_Approved,
	OriginatingLender, 	
	BorrowerState,
	Race,
	Gender,
	Ethnicity,

	COUNT(LoanNumber) AS Number_of_Approved,

	sum(CurrentApprovalAmount) AS Current_Approved_Amount,
	avg (CurrentApprovalAmount) AS Current_Average_loan_size,
	sum(ForgivenessAmount) AS Amount_Forgiven,


	sum(InitialApprovalAmount) AS Approved_Amount,
	avg (InitialApprovalAmount) AS Average_loan_size

FROM 
	[SBA_Analysis].[dbo].[SBA_public_data] p
	inner join [SBA_Analysis].[dbo].[sba_naics_sector_standards_description] d
		on left(p.NAICSCode, 2) = d.LookUp_Codes
group by 
	d.Sector_Name,  
	year(DateApproved),
	month(DateApproved),
	OriginatingLender, 	
	BorrowerState,
	Race,
	Gender,
	Ethnicity
