# Cleaning Report
A descriptive report of cleaning and manipulations performed on the datasets.

## Areas of Concern:
* Unneccessary Data
* Null data cells
* Duplications

### Unneccessary Data

***Note**: For the purposes of this case study I did omit the columns that contained personal mailing addresses and phone numbers as they are not required in this analysis for the data from TDLR (Texas Department of Licensing & Regulations) on concerns regarding privacy even though that data is available on the state website.* 

Opening the dataset containing the licensing information in Microsoft Excel allowed me to perform some exploratory analysis in its raw form. For the purposes of this case study, we will be focusing on the main electrical licenses being 
 **Apprentice, Residential Wireman, Journeyman, Master Electrician/Electrical Contractor**

Before importing the dataset into MySQL workbench, I performed the following changes in Microsoft Excel.

* Raw data file was in the .xlsx *(Microsoft Excel Worksheet)* format. Using the (File>Save As) shortcut key **[F12]** method I was able to create a copy of the dataset and convert the new file to a .csv *(comma delimited)* format entitled *"all_tx_electricians.csv"*.

* [CTRL+H] Find and Replace was used to replace the "spaces" in all the column headers with "_" (underscores) and used the =lower() function to lowercase all of the values in the headers row. 

* Deleted the columns that weren't necessary for our analysis and also had a lot of null values. (address1, address2, phone_number, business_phone_number)

|Remaining Column Names |
|---|
|`lic_type`
|`lic_number`
|`lic_issued_date`
|`lic_expiration_date`
|`county`
|`city`
|`st`
|`zip`
|`business_name`
|`business_address1`
|`business_addr2`
|`business_city`
|`business_county_name`
|`business_county_code`
|`business_st`
|`business_zip`

I did notice that there were some cells that had "Out Of State" in the `county` and `business_county` columns so utilizing the find and replace feature, 21,418 cells were found and each respective row removed from dataset.  

### Nulls
Multiple null cells found in:
  |Column Names |
|---|
|`county`
|`city`
|`st`
|`zip`
|`business_county_name`
|`business_county_code`
|`business_st`
|`business_zip`

Utilizing the Find and Replace feature, I replaced all "Nulls" with blank cells before importing to MySQL to avoid those cells being read as a text string especially in the zip code columns and county codes columns. 

("All done. We made 1,179,543 replacements") 

As for the blank spaces, in an attempt to fill in the cities, counties, and zip code columns I have sourced [Zip Codes In Texas Dataset](https://worldpopulationreview.com/zips/texas).

Through the use of the =XLOOKUP() function, I was able to populate the county information for every row that contained City information. Unfortunately, because there are multiple counties listed in the lookup_array when trying the opposite I was not able to populate the city column by searching county with xlookup. This resulted in some cells staying blank. 

The last item to be done in Excel before importing into MySQL Workbench was to change the dates in the columns `lic_issued_date` and `lic_expiration_date` from MM/DD/YYYY to YYYY-MM-DD as it seems to be the best format for MySQL. 

## MySQL Workbench

In MySQL Workbench, Database "tx_electricians_db" was created. When trying to use the Table Data Import wizard to import the .csv into the database it was extremely slow and even leaving the pc overnight of the 221,990 rows of data, only about 4000 were imported. I cancelled the import and went a different route by utilizing the LOAD DATA LOCAL INFILE. But before doing so I had to create a table for the data to be imported into that consisted of the same column names and notated the datatypes.

```SQL
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
```
After the table was created and sat waiting for the import, I entered the following query using the command terminal. 
```SQL
LOAD DATA LOCAL INFILE 
'C:\\Users\\<user>\\Desktop\\Electricians_In_Texas\\all_tx_electricians.csv' 
INTO TABLE all_lic 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '\"' 
LINES TERMINATED BY '\r\n' 
IGNORE 1 ROWS;
```
Which resulted in a message of 
`221990 row(s) affected Records:221990 Deleted:0 Skipped:0 Warnings:0`
### Duplications
Quering to find duplicates:
```SQL
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
HAVING COUNT(*)>1;
``` 
Query returned with duplicated data that had some entries with up to 4 duplicates in the table. 
To delete the data in the table, the row_number window function was used to assign a row number and have a clause where the row number greater than 1 would be deleted. 

```SQL
DELETE FROM all_lic
WHERE (lic_type, lic_number, lic_issued_date, lic_expiration_date, licensee_name) 
	IN (
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
```
### Missing Values
After removing the duplicates, I created a table with only the focus license types titled `activeelectricians` which can be found [**here**](https://docs.google.com/spreadsheets/d/1wMgW1W1mr96zrO7m_tjfZC_qTgEsaQxyfGONG1QFjQ4/edit?usp=sharing) if you would like to explore it.*(The query for it can be found in the analytics journal)* During the exploration phase of the dataset, I found that there were numerous blanks/null values in the city, zip, and counties columns for both personal and business side. 

To update the tables, I needed to create a table with the same headers and datatypes as the file that had the zip codes by cities and counties along with another table that had the GIS data and county codes. 
```SQL
CREATE TABLE TexasZipCodes
	(
		zip varchar(5) NOT NULL
        ,city varchar(25) NOT NULL
        ,county varchar(25) NOT NULL
    );
DESC texaszipcodes;
-- Next step is to input the following query in the command terminal to import the data. 
LOAD DATA LOCAL INFILE 'C:\\Users\\<User>\\Desktop\\GitHubRepos\\Electricians_In_Texas\\TexasZipCodes.csv' 
INTO TABLE  tx_electricians_db.TexasZipCodes
FIELDS TERMINATED BY ',' 
ENCLOSED BY '\"' 
LINES TERMINATED BY '\r\n' 
IGNORE 1 ROWS;

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

-- Next step is to input the following query in the command terminal to import the data. 
LOAD DATA LOCAL INFILE 'C:\\Users\\<User>\\Desktop\\GitHubRepos\\Electricians_In_Texas\\Texas_Counties_GIS_Data_Final.csv' 
INTO TABLE  tx_electricians_db.Texas_Counties_GIS_Data_Final
FIELDS TERMINATED BY ',' 
ENCLOSED BY '\"' 
LINES TERMINATED BY '\r\n' 
IGNORE 1 ROWS;
```
 *(For whatever reason, the following query was only working when typed into the Command Terminal after updating the my.ini file setting the local_infile=ON)*



The following query was used multiple times to fill in those blank values utilizing the UPDATE feature with a JOIN query from both the same table itself and from the other data sources that were acquired. 

```SQL
UPDATE activeelectricians ae
JOIN texaszipcodes tzc
ON ae.business_zip = tzc.zip
SET ae.county = tzc.county;
```
A self join was used inside the update feature with the following query by aliasing the table as "ae" and "ae2" amd then joining on itself to allocate the business_city to the city column, business_county to county column, and finally the business_zip to the zip column. 
```SQL
UPDATE activeelectricians ae
JOIN activeelectricians ae2
ON ae.county = ae2.business_county_name
SET ae.city = ae2.business_city
WHERE ae.city = '';
```
Then the last way to fill in the blank values in the county codes column is by updating activeelectricians by joining with the Texas GIS data column matching on county name. 
```SQL
UPDATE activeelectricians ae
JOIN Texas_Counties_GIS_Data_Final gis
ON ae.county = gis.County
SET ae.business_county_code = gis.Code_Mailing;
```
I was running into an issue where the above query was not filling in the county code values when trying to correspond with the county name from the activeelectricians. After spending quite some time exploring the dataset and not coming up with anything I realized the only thing that it could have been was a trailing or leading "space". So I then performed the following query to remove the spaces on the county column. 

```SQL
UPDATE activeelectricians
SET county = LTRIM(rtrim(county));
```
Results from the above query indicated that 9,899 rows were effected and changed. After exploring the table again I realized that there were a couple licenses that had blanks in more than 5 columns. So I performed the following query to remove them. 
The good thing is I only had to remove 2 rows with the query below and it was only because they were missing values in 8 columns. 
```SQL
DELETE FROM activeelectricians
WHERE county= ''
AND city=''
and st=''
and zip=''
and business_city=''
and business_county_name=''
and business_county_code=''
and business_zip='';
```
To confirm that all blanks were removed from the data set I performed the following query that was similar to the above query but changing the DELETE to a SELECT to view the data and replacing the "AND" with "ORS". 

```SQL
SELECT * FROM activeelectricians
WHERE county=''
OR licensee_name=''
OR city=''
OR st=''
OR zip=''
OR business_name=''
OR business_county_code='';
```
0 rows returned indicating that there are no blanks left in the table.

Lastly, realizing that there were columns with the same values correlating to city, county, and zip on the business and personal side, I decided to drop the columns from the business side to tidy up the dataset from having redundancy. 

```SQL
ALTER TABLE activeelectricians
DROP COLUMN business_city,
DROP COLUMN business_county_name,
DROP COLUMN business_zip;
```
### Cleaning Summary
- The table has been rid of duplicate rows

- The necessary license types were queried utilizing SQL

- All blank cells in dataset have been filled utilizing corresponding values. 

- Since the county, city, and state columns ended up matching, those same columns that had "business" preceding them were removed except for business_name and business_county_code.

We are now ready to start analyzing the dataset. 

You can view details in the [Analytics Journal](https://github.com/)