-- ANALYSIS JOURNAL SCRIPT--
USE tx_electricians_db;
-- Preview the cleaned dataset. 
SELECT *
FROM activeelectricians;

SELECT *
FROM all_lic;

-- Query to get the number of current licenses vs expired licenses in total with data of analysis being 2022-9-25.
SELECT  
	COUNT(DISTINCT(lic_number)) AS CurrentLicenses
	,( SELECT COUNT(DISTINCT(lic_number)) 
    FROM all_lic 
    WHERE lic_expiration_date < '2022-9-25'
    ) AS ExpiredLicenses
FROM all_lic
WHERE lic_expiration_date >= '2022-9-25';

-- Following query was the same but narrowing down to the license types of the case study. 
SELECT  
	COUNT(DISTINCT(lic_number)) AS CurrentLicenses
	,(SELECT COUNT(DISTINCT(lic_number)) 
	FROM all_lic WHERE lic_expiration_date < '2022-9-25') 
AS ExpiredLicenses
FROM all_lic
WHERE lic_type IN(
	'APPRENTICE ELECTRICIAN'
	,'RESIDENTIAL WIREMAN'
	,'JOURNEYMAN ELECTRICIAN'
	,'MASTER ELECTRICIAN'
	,'ELECTRICAL CONTRACTOR')
AND lic_expiration_date >= '2022-9-25';

-- For further observation in the expired licenses we can look at how many of them expired and didn't renew by year to visualize in another chart. 
CREATE TABLE ExpiredLicByYear 
	(
        SELECT 
			lic_type
			,EXTRACT(YEAR FROM lic_expiration_date) AS 'Year'
			,COUNT(DISTINCT(lic_number)) AS 'Expired Licenses'
		FROM all_lic
		WHERE lic_type IN(
			'APPRENTICE ELECTRICIAN'
			,'RESIDENTIAL WIREMAN'
			,'JOURNEYMAN ELECTRICIAN'
			,'MASTER ELECTRICIAN'
			,'ELECTRICAL CONTRACTOR')
		AND lic_expiration_date <= '2022-9-25'
		GROUP BY EXTRACT(YEAR FROM lic_expiration_date), lic_type
	);
-- **create visual in power bi for the analysis
SELECT *
FROM ExpiredLicByYear;

-- Looking at the yrs of experience as a main attribute, we can see where are all the experienced electricians by having the term "Experienced" meaning over 10 years in the trade. 
CREATE TABLE ExpElecByCounty( 
WITH AllTechs AS (
	SELECT business_county_code AS MailingCode
			,county AS CountyName
			,COUNT(DISTINCT(lic_number)) AS AllTechs
	FROM activeelectricians
    WHERE yrs_experience >= 10
	GROUP BY county
	ORDER BY 3 DESC
	)
, Apprentices AS (
		SELECT business_county_code AS MailingCode
			,county AS CountyName
			,COUNT(DISTINCT(lic_number)) AS Apprentices
		FROM activeelectricians
		WHERE lic_type= 'APPRENTICE ELECTRICIAN'
		AND  yrs_experience >= 10
		GROUP BY county
		ORDER BY 3 DESC
		)
, ResidentialWireman AS (
		SELECT business_county_code AS MailingCode
			,county AS CountyName
			,COUNT(DISTINCT(lic_number)) AS ResidentialWireman
		FROM activeelectricians
		WHERE lic_type= 'RESIDENTIAL WIREMAN'
		AND  yrs_experience >= 10
		GROUP BY county
		ORDER BY 3 DESC
		)
, Journeyman AS (
		SELECT business_county_code AS MailingCode
			,county AS CountyName
			,COUNT(DISTINCT(lic_number)) AS Journeyman
		FROM activeelectricians
		WHERE lic_type= 'JOURNEYMAN ELECTRICIAN'
		AND  yrs_experience >= 10
		GROUP BY county
		ORDER BY 3 DESC
		)
, MasterElectricians AS (
		SELECT business_county_code AS MailingCode
			,county AS CountyName
			,COUNT(DISTINCT(lic_number)) AS Masters
		FROM activeelectricians
		WHERE lic_type= 'MASTER ELECTRICIAN'
		AND  yrs_experience >= 10
		GROUP BY county
		ORDER BY 3 DESC
		)
, ElectricalContractors AS (
		SELECT business_county_code AS MailingCode
			,county AS CountyName
			,COUNT(DISTINCT(lic_number)) AS ElectricalContractors
		FROM activeelectricians
		WHERE lic_type= 'ELECTRICAL CONTRACTOR'
		AND  yrs_experience >= 10
		GROUP BY county
		ORDER BY 3 DESC
		)
SELECT 
	alltechs.MailingCode
    , alltechs.CountyName
    , alltechs.AllTechs
    , a.Apprentices
    , rw.ResidentialWireman
    , j.Journeyman
    , me.Masters
    , ec.ElectricalContractors
FROM 
	alltechs
LEFT JOIN	Apprentices a
ON	alltechs.CountyName=a.CountyName
LEFT JOIN	ResidentialWireman rw
ON	alltechs.CountyName=rw.CountyName
LEFT JOIN	Journeyman j
ON	alltechs.CountyName= j.CountyName
LEFT JOIN	MasterElectricians me
ON	alltechs.CountyName=me.CountyName
LEFT JOIN	ElectricalContractors ec
ON	alltechs.CountyName=ec.CountyName
GROUP BY	alltechs.CountyName
);

UPDATE expelecbycounty
SET Apprentices = 0
	,ResidentialWireman = 0
    ,Journeyman = 0
    ,Masters = 0
    ,ElectricalContractors = 0
WHERE 
	Apprentices IS NULL
OR
	ResidentialWireman IS NULL
OR
	Journeyman IS NULL
OR
	Masters IS NULL
OR
	ElectricalContractors IS NULL;

SELECT * 
FROM ExpElecByCounty;
-- View the electricians by county and the types of electricians in each county. Ordering by the most populated to the least. 
-- Trying to create a table with multiple CTE's in one query and then joining those ctes together.
CREATE TABLE ElectriciansByCounty( 
WITH AllTechs AS (
	SELECT business_county_code AS MailingCode
			,county AS CountyName
			,COUNT(DISTINCT(lic_number)) AS AllTechs
	FROM activeelectricians
	GROUP BY county
	ORDER BY 3 DESC
	)
, Apprentices AS (
		SELECT business_county_code AS MailingCode
			,county AS CountyName
			,COUNT(DISTINCT(lic_number)) AS Apprentices
		FROM activeelectricians
		WHERE lic_type= 'APPRENTICE ELECTRICIAN'
		GROUP BY county
		ORDER BY 3 DESC
		)
, ResidentialWireman AS (
		SELECT business_county_code AS MailingCode
			,county AS CountyName
			,COUNT(DISTINCT(lic_number)) AS ResidentialWireman
		FROM activeelectricians
		WHERE lic_type= 'RESIDENTIAL WIREMAN'
		GROUP BY county
		ORDER BY 3 DESC
		)
, Journeyman AS (
		SELECT business_county_code AS MailingCode
			,county AS CountyName
			,COUNT(DISTINCT(lic_number)) AS Journeyman
		FROM activeelectricians
		WHERE lic_type= 'JOURNEYMAN ELECTRICIAN'
		GROUP BY county
		ORDER BY 3 DESC
		)
, MasterElectricians AS (
		SELECT business_county_code AS MailingCode
			,county AS CountyName
			,COUNT(DISTINCT(lic_number)) AS Masters
		FROM activeelectricians
		WHERE lic_type= 'MASTER ELECTRICIAN'
		GROUP BY county
		ORDER BY 3 DESC
		)
, ElectricalContractors AS (
		SELECT business_county_code AS MailingCode
			,county AS CountyName
			,COUNT(DISTINCT(lic_number)) AS ElectricalContractors
		FROM activeelectricians
		WHERE lic_type= 'ELECTRICAL CONTRACTOR'
		GROUP BY county
		ORDER BY 3 DESC
		)
SELECT 
	alltechs.MailingCode
    , alltechs.CountyName
    , alltechs.AllTechs
    , a.Apprentices
    , rw.ResidentialWireman
    , j.Journeyman
    , me.Masters
    , ec.ElectricalContractors
FROM 
	alltechs
LEFT JOIN	Apprentices a
ON	alltechs.CountyName=a.CountyName
LEFT JOIN	ResidentialWireman rw
ON	alltechs.CountyName=rw.CountyName
LEFT JOIN	Journeyman j
ON	alltechs.CountyName= j.CountyName
LEFT JOIN	MasterElectricians me
ON	alltechs.CountyName=me.CountyName
LEFT JOIN	ElectricalContractors ec
ON	alltechs.CountyName=ec.CountyName
GROUP BY	alltechs.CountyName
);

UPDATE electriciansbycounty 
SET Apprentices = 0
	,ResidentialWireman = 0
    ,Journeyman = 0
    ,Masters = 0
    ,ElectricalContractors = 0
WHERE 
	Apprentices IS NULL
OR
	ResidentialWireman IS NULL
OR
	Journeyman IS NULL
OR
	Masters IS NULL
OR
	ElectricalContractors IS NULL;

SELECT * FROM electriciansbycounty;