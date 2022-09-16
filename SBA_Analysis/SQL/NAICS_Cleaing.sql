/****** Script for SelectTopNRows command from SSMS  ******/

SELECT * FROM [dbo].[SBA_industry_standards]

--MAIN QUERY STARTS
SELECT *
INTO sba_naics_sector_standards_description
FROM
(
	SELECT 
		NAICS_Industry_Description,
		IIF(NAICS_Industry_Description LIKE '%–%' ,SUBSTRING(NAICS_Industry_Description, 8 , 2), '') AS LookUp_Codes, --Extracting Sector Number From NAICS_Industry_Description
		--CASE WHEN NAICS_Industry_Description LIKE '%–%' THEN SUBSTRING(NAICS_Industry_Description, 8 , 2) END AS LookUp_Codes_Case --Alternative method for Extracting Sector Number From NAICS_Industry_Description
		IIF(NAICS_Industry_Description LIKE '%–%' ,LTRIM(SUBSTRING(NAICS_Industry_Description, CHARINDEX('–', NAICS_Industry_Description) + 1 , LEN(NAICS_Industry_Description))), '') AS Sector_Name -- Extracting the Name of the Sector from NAICS_Industry_Description
	FROM [dbo].[SBA_industry_standards]
	WHERE NAICS_Codes = ''
) AS MAIN
WHERE LookUp_Codes != ''
-- MAIN QUERY ENDS


SELECT * FROM  [dbo].[sba_naics_sector_standards_description]

UPDATE [dbo].[sba_naics_sector_standards_description]
SET Sector_Name = 'Manufacturing'
WHERE Sector_Name = '33 – Manufacturing'


INSERT INTO [dbo].[sba_naics_sector_standards_description]
VALUES ('Sector 31 – 33 – Manufacturing', 32, 'Manufacturing'),
	   ('Sector 31 – 33 – Manufacturing', 33, 'Manufacturing'),
	   ('Sector 44 - 45 – Retail Trade', 45, 'Retail Trade'),
	   ('Sector 48 - 49 – Transportation and Warehousing', 49, 'Transportation and Warehousing')
