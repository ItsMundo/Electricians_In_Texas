# Analytics Journal
Methodology and observations during analysis.

### Business Task
* Where are the majority of electricians in Texas? 
* Where are the experienced electricians?
* For a newly licensed Master Electrician about to open up a contracting business, what would be the best locations to start a company in regards to competition (other Master Electricians/Electrical Contractors) and availability of Journeyman electricians (*workforce*)? 
* What is the electrical trade looking like as a whole in regards to recurring licensees/recertifications? 
* Will this be a reliable business venture?

Before attempting to provide insights to the business tasks at hand, an important first step is to get faimiliar with the data and try to examine the attributes available.

Significant attributes appear to be:
* Expired Licenses vs Current Licenses 
* Current Licenses by Type
* Identifying the experience levels of each current licensed technician.
* Finding the number of active technicians per county.   

The original dataset has licenses of all electrical workers with licensed issued dates ranging from 2004-2022. Keeping in mind that this case study is only focusing on the 5 types of electrical licenses that have to deal with electricians in Texas, further manipulattion of the data needed to be done. 

## *Expired licenses vs Current Licenses*
In order to get an overview of active/expired licenses the following queries were performed for both the total electrical licenses and for the 5 types for this project. 

```SQL
SELECT  
	,COUNT(DISTINCT(lic_number)) AS CurrentLicenses
	,(SELECT COUNT(DISTINCT(lic_number)) FROM all_lic WHERE lic_expiration_date < CURRENT_DATE()) AS ExpiredLicenses
FROM all_lic
WHERE lic_expiration_date >= CURRENT_DATE();
```
As the licenses recertify, their information is populated in the table more than once with the only thing changing is the expiration date. Using the distinct(count()) function allowed for the data to be accurate when counting the number of licenses.  The query above had the following results.
| CurrentLicenses | ExpiredLicenses |
|---|---|
| 138768 | 77748 |

At the time of this case study, there has been a total of 77,748 licenses that have expired indicating the technicians either have not recertified for the upcoming year or did not stick to any electrical trade as a career path. 

*(One thing to note is that in the queries where the function CURRENT_DATE() was used, the date of analysis was 2022-9-25.)*

## *Current Licenses by Type*
The following query narrows down the license types to that of the 5 electrical licenses that I am examining for this project. 
```SQL
SELECT  
	COUNT(DISTINCT(lic_number)) AS CurrentLicenses
	,(
		SELECT COUNT(DISTINCT(lic_number)) 
		FROM all_lic 
		WHERE lic_expiration_date < CURRENT_DATE()
	) AS ExpiredLicenses
FROM all_lic
WHERE lic_type IN(
	'APPRENTICE ELECTRICIAN'
	,'RESIDENTIAL WIREMAN'
	,'JOURNEYMAN ELECTRICIAN'
	,'MASTER ELECTRICIAN'
	,'ELECTRICAL CONTRACTOR')
AND lic_expiration_date >= CURRENT_DATE();
```
Results:
| Current Licenses | Expired Licenses |
|---|---|
| 132625 | 77748 |

The difference between the active licenses from all electrical workers and the 5 types is very minimal which means that **95.6%** of all the active electrical licenses are made up of the license types that are the focal point of this case study. 

Taking a closer look at how the expired licenses looked throughout the years I performed the following query below. 

```SQL
CREATE TABLE ExpiredLicByYear (
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
		GROUP BY EXTRACT(YEAR FROM lic_expiration_date), lic_type);
```

Did the same query but to pull the data for all of the licenses issued. 

```SQL
CREATE TABLE IssuedLicByYear (
		SELECT 
			lic_type
			,EXTRACT(YEAR FROM lic_issued_date) AS 'Year'
			,COUNT(DISTINCT(lic_number)) AS 'Expired Licenses'
		FROM all_lic
		WHERE lic_type IN(
			'APPRENTICE ELECTRICIAN'
			,'RESIDENTIAL WIREMAN'
			,'JOURNEYMAN ELECTRICIAN'
			,'MASTER ELECTRICIAN'
			,'ELECTRICAL CONTRACTOR')
		AND lic_issued_date <= '2022-9-25'
		GROUP BY EXTRACT(YEAR FROM lic_issued_date), lic_type);
```

With the dataset above regarding the expired/issued licenses, there were a total of 29,620 Apprentices in 2021 that decided to give up on the trade of who signed up in 2019, with the following 2022 year being 39,633 number licenses expiring. 

## *Identifying the experience levels of each current licensed individual*
 
To see the experience levels of each of the electricians with active licenses I utilized the expiration date and issue date columns and used the TIMESTAMPDIFF() function to populate another column with the experience level by years with the expiration date being greater than or equal to the date of analysis.

```SQL
CREATE TABLE ActiveElectricians AS 
(SELECT 
	lic_type
	,lic_number 
	,lic_issued_date 
	,lic_expiration_date 
    ,TIMESTAMPDIFF(YEAR,lic_issued_date,lic_expiration_date) AS yrs_experience
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
WHERE lic_type IN
	('APPRENTICE ELECTRICIAN'
	,'RESIDENTIAL WIREMAN'
	, 'JOURNEYMAN ELECTRICIAN'
	, 'MASTER ELECTRICIAN'
	, 'ELECTRICAL CONTRACTOR')
AND lic_expiration_date >=current_date()
AND st IN( 'TX','')
AND business_st IN( 'TX','')
ORDER BY lic_issued_date);
```
Exploring the dataset with years of experiance column populated showed that there are electricians who are still going strong in the trade since 2004 with 19 years of experience. 

The following query was performed to see all of the technicians that both have an active license and have more than 10 years experience. One thing I noticed is that there are a large number of apprentices that have never moved on from that level but are still working. Most electricians stay at the Journeyman Level unless they have a desire to own their own business which is when they move on to test out for the Masters Licenses. 

## *Finding the number of active technicians per county*
The following query creates a table that shows the electricians by county and by license type. Similar to the query above but includes all active licenses.  
```SQL
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
```
Due to there being NULL values after the join for every county that did not have a specific licensed type residing in it I had to perform the following query to replace the NULL values in each respective column with a zero. 
```SQL
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
```
## Observations:

Once the data was cleaned and analyzed with Excel and SQL, I connected to the MySQL database with Microsoft Power BI for further analysis and to begin visualizing the data. 

![image](https://raw.githubusercontent.com/ItsMundo/Electricians_In_Texas/main/Images/ActiveElectriciansDonut.PNG?token=GHSAT0AAAAAABZW3QAJEXAICODUGMLFI4ZIY2CQJUA)  
*(Chart portraying an overview of Electricians with Active Licenses in Texas up to 09/25/22)*
  
### Thoughts:
When thinking of the hierarchy of electrical licenses, the easiest to obtain and to begin the journey of being an electrician is the apprentice license which shows to be dominating in regards to volume of licensed individuals. Residential Wireman on the other hand, being the smallest in number. In my experience working with electricians for the past 5 years, a lot of the technicians feel as though there is no point in obtaining the residential wireman license if they will almost immediately "test out" for the Journeyman license in 2 more years. 

![image](https://raw.githubusercontent.com/ItsMundo/Electricians_In_Texas/main/Images/ActiveElectriciansByCountyMap.PNG?token=GHSAT0AAAAAABZW3QAIY6KYKFQVL6SGMLEWY2CQKTA)  
*(Heat Map showing the active electricians spread out in Texas up to 09/25/22 by county, viewing the [dashboard](https://app.powerbi.com/view?r=eyJrIjoiMmM2MWNkODQtMDhkNi00YWJjLTkxNzctYmM4YmJlNzRhMTMxIiwidCI6ImY4NWQ0YzRjLTRlZDktNDM3Yi04ZGE2LWQ2YjFkMzYxZTM2NiJ9
) in Power Bi and hovering over each respective county will show you more details and a breakdown the licenses in each county.)*

![image](https://raw.githubusercontent.com/ItsMundo/Electricians_In_Texas/main/Images/Top10CountiesByLicenseType.PNG?token=GHSAT0AAAAAABZW3QAJCKI66BHFIHZFWCDUY2CQL3Q)  
*(Pivot table showing the most populated counties with Actively Licensed Electricians)*

### Thoughts:

The bulk of the licensed technicians seem to be in the counties where major Texas Cities exist such as Houston, San Antonio, Dallas, El Paso, and Austin to name a few. With Harris County being the largest and more concentrated location of apprentice electricians it indicates that there is a greater chance of breaking into the field within that and surrounding counties. 

![image](https://raw.githubusercontent.com/ItsMundo/Electricians_In_Texas/main/Images/10yrExperiencedElectricians.PNG?token=GHSAT0AAAAAABZW3QAJBJ6RVNBYWXS4O6TUY2CQNLQ)  
*(Heat Map showing the counties with electricians that have over 10 year experience and the total number of each type of license with over 10 years experience)*

![image](https://raw.githubusercontent.com/ItsMundo/Electricians_In_Texas/main/Images/10yrTop10Counties.PNG?token=GHSAT0AAAAAABZW3QAINV3P2O3JNO2RDCFQY2CQLRA)  
*(Another Pivot Table showing the top 10 counties that have experienced electricians by type.)*

### *Thoughts:*

The heat map is very similar to the one above with minor differences but one thing that stands out is the number of apprentice licenses with over 10 years of experience. If the Apprentice License is only designed to be 4 years before moving on to the Journeyman License where the majority of Electricians make the most income I'm curious to find out why such a high number. In my time I have met quite a few of the technicians who were just content with being helpers and some others that were just afraid of taking the state exams to advance forward in their licensure. Even then, without advancing to the next level of licensing, the technicians are only hindering there power to request a higher pay scale when being employed to perform electrical work. 

![image](https://raw.githubusercontent.com/ItsMundo/Electricians_In_Texas/main/Images/TotalExpiredvsIssued.PNG?token=GHSAT0AAAAAABZW3QAIHGBP7AN7223EIEAQY2CQOTQ)  
*(Chart that shows the differences between Expired Licenses and the Issued Licenses for New Technicians throughout the year.)*

### *Thoughts:* 

One thing to note, The issued dates are not only apprentice licenses being issued to new technicians but also as the technicians advance and test out to the next level, a new type and license number is issued, adding a value to this chart above. The number of issued licenses has always been greater than the licenses expired except with the sudden jump in the year of 2019-2022. The spike in the recent years required a further analysis. 

![image](https://raw.githubusercontent.com/ItsMundo/Electricians_In_Texas/main/Images/ApprenticeIssuedvsExpired.PNG?token=GHSAT0AAAAAABZW3QAIR5MXOBGBYVXFJAHEY2CQPZA)  
*(Chart showing Apprentice Licenses issued and expired by the year.)*

![image](https://raw.githubusercontent.com/ItsMundo/Electricians_In_Texas/main/Images/ResidentialWiremanIssuedvsExpired.PNG?token=GHSAT0AAAAAABZW3QAJA7NO5MAWQMRBJOOIY2CQO4Q)  
*(Chart showing Residential Wireman Licenses issued and expired by the year.)*

![image](https://raw.githubusercontent.com/ItsMundo/Electricians_In_Texas/main/Images/JourneymanIssuedvsExpired.PNG?token=GHSAT0AAAAAABZW3QAJOUAIGEVLRDLKOXDEY2CQPNQ)  
*(Chart showing Journeyman Licenses issued and expired by the year.)*

![image](https://raw.githubusercontent.com/ItsMundo/Electricians_In_Texas/main/Images/MasterIssuedvsExpired.PNG?token=GHSAT0AAAAAABZW3QAJO55IWK3U7LFDGYN6Y2CQPAA)  
*(Chart showing Master Electrician Licenses issued and expired by the year.)*

![image](https://raw.githubusercontent.com/ItsMundo/Electricians_In_Texas/main/Images/ElectricalContractorIssuedVSExpired.PNG?token=GHSAT0AAAAAABZW3QAJ6GIE3PHGWRK3N4NMY2CQPUQ)  
*(Chart showing Electrical Contractor Licenses issued and expired by the year.Not sure what the issue was in Power BI but I could not get the data to visualize for the years between 2014 and 2020, but the values are within the dataset.)*

### *Thoughts:*

The bulk of the jump in licenses were with the apprentice licenses. My theory is that it was in relation to the pandemic that hit the US around 2019. My theory is as to why there was a noticable jump in the number of technicians in the year 2021 and 2022 likely due to Electricians being considered "Essential Workers" and being one of the highest paying trades available today in the workforce when the pandemic hit the United States in 2019-2020. According to the CDC's timeline found [here](https://www.cdc.gov/museum/timeline/covid19.html#:~:text=January%2010%2C%202020,%2DnCoV) around march of 2019 is when the US government entities were in the processs of shutting down businesses considered non essential leaving an unemployment rate of *"14.7%-the highest since the Great Depression."* With this in mind, A lot of the people who lost their jobs from layoffs as a result of the Coronavirus have decided to try and become an electrician. 


![image](https://raw.githubusercontent.com/ItsMundo/Electricians_In_Texas/main/Images/JourneymanAVGSalary.PNG?token=GHSAT0AAAAAABZW3QAI6NB4FK7O5RGMQN76Y2CQTJQ)  
*(Table from Salary.com about Journeyman Electricians Income.)*

### *Thoughts:*

According to this [report](https://www.salary.com/research/salary/alternate/electrician-journeyman-salary/dallas-tx) on Salary.com the average salary being reported for Journeyman Electricians in the Dallas/Fort Worth area ranges from $49,516 to $81,230. This alone most likely was an incentive for someone who was affected by the pandemic to put a tool belt on and strive for this career path.