-- DATA PROCESSING AND CLEANING SQL SCRIPT --

SHOW DATABASES;

CREATE DATABASE tx_electricians_db;

USE tx_electricians_db;

SELECT DATABASE();

-- creating the table with the same column names as the csv file before importing.
CREATE TABLE all_lic
	(
		lic_type VARCHAR(75) NOT NULL
		,lic_number VARCHAR(15) NOT NULL
		,lic_issued_date date NOT NULL
		,lic_expiration_date date NOT NULL
		,county	VARCHAR(25)
		,licensee_name VARCHAR(50)
		,city VARCHAR(35)
		,st VARCHAR(5)
		,zip VARCHAR(5)
		,business_name VARCHAR(75)
		,business_adress1 VARCHAR(35)
		,business_addr2 VARCHAR(35)
		,business_city VARCHAR(20)
		,business_county_name VARCHAR(20)
		,business_county_code VARCHAR(10)
		,business_st VARCHAR(5)
		,business_zip VARCHAR(5)
    );
-- verify all columns match with csv file opened in excel 
DESC all_lic;

-- ready to import csv data into the table created above
LOAD DATA LOCAL INFILE 
	'C:\\Users\\netofloresjr\\Desktop\\GitHubRepos\\Electricians_In_Texas\\all_tx_electricians.csv' 
INTO TABLE all_lic 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '\"' 
LINES TERMINATED BY '\r\n' 
IGNORE 1 ROWS;

SELECT * FROM all_lic;

-- Verify all rows were imported by doing a count.
SELECT COUNT(*) FROM all_lic;

-- First thing to do is to check for duplicate values inside the dataset. 
SELECT 
	lic_type
    ,lic_number
    , lic_issued_date
    , lic_expiration_date
    , licensee_name
    , COUNT(*)
FROM 
	all_lic
GROUP BY 
	lic_type
    ,lic_number
    , lic_issued_date
    , lic_expiration_date
    , licensee_name
HAVING COUNT(*)>1
ORDER BY COUNT(*) DESC;

-- Using row_number window function to find duplicate values before deleting
SELECT 
	lic_type
    ,lic_number
    , lic_issued_date
    , lic_expiration_date
    , licensee_name
FROM (
	SELECT *, 
    ROW_NUMBER() OVER (PARTITION BY lic_type, lic_number, lic_issued_date, lic_expiration_date, licensee_name)
    AS rownum
    FROM all_lic
	) AS d
WHERE rownum >1
ORDER BY rownum DESC;

-- deleting duplicate values with row_number window function. 
DELETE FROM all_lic
WHERE (lic_type, lic_number, lic_issued_date, lic_expiration_date, licensee_name) IN (
	SELECT 
	lic_type
    ,lic_number
    , lic_issued_date
    , lic_expiration_date
    , licensee_name
FROM (
	SELECT *, 
    ROW_NUMBER() OVER (PARTITION BY lic_type, lic_number, lic_issued_date, lic_expiration_date, licensee_name)
    AS rownum
    FROM all_lic
	) AS d
WHERE rownum >1
ORDER BY rownum DESC);
-- How many licenses that are currently active for all electrical license types. 
SELECT lic_type, COUNT(*) AS CurrentLicenses
FROM all_lic
WHERE lic_expiration_date >=current_date()
GROUP BY lic_type
ORDER BY CurrentLicenses DESC;

-- Same query as above but narrowed down to the focus types on this case study. 
SELECT lic_type, COUNT(*) AS CurrentLicenses
FROM all_lic
WHERE lic_type IN('APPRENTICE ELECTRICIAN','RESIDENTIAL WIREMAN', 'JOURNEYMAN ELECTRICIAN', 'MASTER ELECTRICIAN', 'ELECTRICAL CONTRACTOR')
AND lic_expiration_date >=current_date()
GROUP BY lic_type
ORDER BY CurrentLicenses DESC;

-- gets a count on all the active licenses and expired licenses based on license type. 
SELECT  
	COUNT(DISTINCT(lic_number)) AS CurrentLicenses
	,(SELECT COUNT(DISTINCT(lic_number)) FROM all_lic WHERE lic_expiration_date < CURRENT_DATE()) AS ExpiredLicenses
FROM all_lic
WHERE lic_type IN('APPRENTICE ELECTRICIAN','RESIDENTIAL WIREMAN', 'JOURNEYMAN ELECTRICIAN', 'MASTER ELECTRICIAN', 'ELECTRICAL CONTRACTOR')
AND lic_expiration_date >= CURRENT_DATE();

-- View all data but with the addition of a column showing years of experience on all the active licenses. 
CREATE TABLE ActiveElectricians AS 
(SELECT 
	lic_type
	,lic_number 
	,lic_issued_date 
	,lic_expiration_date 
    ,timestampdiff(YEAR,lic_issued_date,lic_expiration_date) AS yrs_experience
	,county	
	,licensee_name
	,city
	,st 
	,zip 
	,business_name 
	,business_adress1 
	,business_addr2
	,business_city 
	,business_county_name 
	,business_county_code 
	,business_st 
	,business_zip
FROM all_lic
WHERE lic_type IN('APPRENTICE ELECTRICIAN','RESIDENTIAL WIREMAN', 'JOURNEYMAN ELECTRICIAN', 'MASTER ELECTRICIAN', 'ELECTRICAL CONTRACTOR')
AND lic_expiration_date >=current_date()
AND st IN( 'TX','')
AND business_st IN( 'TX','')
ORDER BY 
	lic_issued_date);
-- View the data from above query to explore
SELECT * FROM activeelectricians;
-- I realized that there was no need for business_address1 & business_addr2 columns in the dataset and decided to drop them from the table. 
-- Also, since we already filtered out that the st and business_st to be Texas, the business_st column could also be dropped. 
ALTER TABLE activeelectricians
DROP business_adress1, 
DROP business_addr2, 
DROP business_st;
-- I want to use the UPDATE JOIN to fill in the blanks in the county and business_county_name columns.
-- But before I do that I need to import the file that has the information on the  
-- Start by creating a table for that data to land in. 
CREATE TABLE TexasZipCodes
	(
		zip varchar(5) NOT NULL
        ,city varchar(25) NOT NULL
        ,county varchar(25) NOT NULL
    );
DESC texaszipcodes;
-- Next step is to input the following query in the command terminal to import the data. 
LOAD DATA LOCAL INFILE 'C:\\Users\\netofloresjr\\Desktop\\GitHubRepos\\Electricians_In_Texas\\TexasZipCodes.csv' 
INTO TABLE  tx_electricians_db.TexasZipCodes
FIELDS TERMINATED BY ',' 
ENCLOSED BY '\"' 
LINES TERMINATED BY '\r\n' 
IGNORE 1 ROWS;
-- Preview imported data
SELECT * FROM TexasZipCodes;
-- Now to do the same for the file that contains the GIS info with county names and mailing codes. 
CREATE TABLE Texas_Counties_GIS_Data_Final
	(
		County VARCHAR(25) NOT NULL
		,Code_Mailing VARCHAR(4) NOT NULL
		,Code_Number VARCHAR(4) NOT NULL
		,FIPS VARCHAR(5) NOT NULL
		,X_Latitude DECIMAL(10,8) NOT NULL
		,Y_Longitude DECIMAL(11,8) NOT NULL
		,Centroid_Location VARCHAR(45) NOT NULL
		,Shape_Length int NOT NULL
		,Shape_Area INT NOT NULL
    );
DESC Texas_Counties_GIS_Data_Final;
-- Next step is to input the following query in the command terminal to import the data. 
LOAD DATA LOCAL INFILE 'C:\\Users\\netofloresjr\\Desktop\\GitHubRepos\\Electricians_In_Texas\\Texas_Counties_GIS_Data_Final.csv' 
INTO TABLE  tx_electricians_db.Texas_Counties_GIS_Data_Final
FIELDS TERMINATED BY ',' 
ENCLOSED BY '\"' 
LINES TERMINATED BY '\r\n' 
IGNORE 1 ROWS;
-- preview the imported data
SELECT * FROM Texas_Counties_GIS_Data_Final;
-- need to set all the text in the dataset to all caps to keep uniformity to other tables in the database. 
UPDATE Texas_Counties_GIS_Data_Final
SET County = UPPER(County);
-- Now that we have the data in the new table we can perform some update joins to fill in the blanks.
-- We'll start with filling in the county name based on the existing zip code in the business zip column. 
UPDATE activeelectricians ae
JOIN texaszipcodes tzc
ON ae.business_zip = tzc.zip
SET ae.county = tzc.county;
-- update the zip column by filling in the blank spots with the corresponding business_zip data. 
UPDATE activeelectricians ae
JOIN activeelectricians ae2
ON ae.county = ae2.business_county_name
SET ae.zip = ae2.business_zip
WHERE ae.zip='';
-- Following query updates the city column by referencing the same table but values from the business_city. Basically filling in the blank cells in that column. 
UPDATE activeelectricians ae
JOIN activeelectricians ae2
ON ae.county = ae2.business_county_name
SET ae.city = ae2.business_city
WHERE ae.city='';
-- The following query updates the blanks in the county codes column with data from gis table based on county name. 
UPDATE activeelectricians ae
JOIN Texas_Counties_GIS_Data_Final gis
ON ae.business_county_name = gis.County
SET ae.business_county_code = gis.Code_Mailing;
-- perform query again but to update the city column based on zip code. 
UPDATE activeelectricians ae
JOIN Texas_Counties_GIS_Data_Final gis
ON ae.business_county_name = gis.County
SET ae.business_county_code = gis.Code_Mailing;

UPDATE activeelectricians
SET county = LTRIM(rtrim(county));

UPDATE activeelectricians ae
JOIN Texas_Counties_GIS_Data_Final gis
ON ae.county = gis.County
SET ae.business_county_code = gis.Code_Mailing;

UPDATE activeelectricians 
SET st = 'TX'
WHERE st = '';

SELECT * FROM activeelectricians
WHERE business_county_code='';

-- Delete the rows that don't have enough info to help populate into other fields. 
DELETE FROM activeelectricians
WHERE county= ''
AND city=''
and st=''
and zip=''
and business_city=''
and business_county_name=''
and business_county_code=''
and business_zip='';

SELECT * FROM activeelectricians;
-- drop the columns that are no longer needed since the values were populated in the corresponding columns. 
ALTER TABLE activeelectricians
DROP COLUMN business_city,
DROP COLUMN business_county_name,
DROP COLUMN business_zip;

-- Preview that all data is now clean. 
SELECT * FROM activeelectricians
WHERE county=''
OR licensee_name=''
OR city=''
OR st=''
OR zip=''
OR business_name=''
OR business_county_code='';

SELECT * FROM activeelectricians;
-- Data is now clean and no missing values in the table exist. 