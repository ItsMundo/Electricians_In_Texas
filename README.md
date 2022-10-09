# Electricians In Texas
### *Case Study for Google Data Analytics Capstone Project*

## Project Overview
In order to be an Electrician in the state of Texas you need to be licensed through the [Texas Department of Licensing and Regulation](https://www.tdlr.texas.gov/) to perform any electrical work. 

An electrician is a skilled tradesperson working in the construction industry who specializes in the maintenance, repair, installations, and design of power systems. They work in a wide range of sectors such as residential, commercial, and industrial. In this case study the focus is primarily on the individuals that are licensed and not focused on what sector each one is in. 

Below are the 4 levels of licensing for electrical workers in order:
1. Apprentice Electrician
2. Residential Wireman
3. Journeyman Electrician
4. Master Electrician

Each level requires a certain amount of OTJ (On the Job) hours and a state exam before advancing. 
|*License Type*|Apprentice|Residential Wireman|Journeyman|Master|
|---|---|---|---|---|
|*OTJ Hours Required*|0 *-Starting*|2000 *~2yrs*|4000 *~4yrs*|10000 *~10yrs*|

Some requirements for each license:
* Each license valid for only 1 year.
* Requires a state verified 3hr CE (continuing education) course for annual recertification.
* Must be employed under a Master Electrician to have OTJ (On The Job) hours verified. 
* Apprentice Electricians must always perform work under supervision of a Journeyman or Master Electrician. 

## **Ask**
### Business Task


One of the many things I hear working for an electrical contractor is that it is always hard to find reliable and experienced electricians. This case study will tackle the following questions.  
1. Where are the majority of electricians in Texas? Where are the experienced electricians?
2. For a newly licensed Master Electrician about to open up a contracting business, what would be the best counties to start a company in regards to competition (other Master Electricians/Electrical Contractors) and availability of Journeyman electricians (*workforce*)? 
3. What is the electrical trade look like as a whole in regards to recurring licensees/recertifications? Will this be a reliable business venture?

The current task is to analyze the data available at the states licensing website and identify key differences between the various licenses, their geographical locations, and recertifications to provide insights for new electrical contractors, investors, or even any professionals interested in pursuing the career in Texas by answering the questions above. 

## **Prepare**
### Data Sources

The data used in this Case Study were pulled from 3 different sources. 
#### 1. [Texas Department of Licensing and Regulations](https://www.tdlr.texas.gov/LicenseSearch/licfile.asp)
*A request was submitted to the [TDLR Records Center](https://tdlr.govqa.us/WEBAPP/_rs/(S(4irhw5jw0tlwkpgiatupuotf))/SupportHome.aspx) requesting data for the past couple of years.*
#### 2. [Texas Workforce Solutions](https://www.twc.texas.gov/tax-county-codes#countyCodesForEmployersQuarterlyReport) 
*Data from this source had information on state codes by county in regards to mailing addresses.*
#### 3. [Texas Open Data Portal via data.texas.gov](https://data.texas.gov/widgets/ups3-9e8m?mobile_redirect=true)
*Data from this source had information on state counties but also had GIS (geographical data) by county.*
#### 4. [Zip Codes In Texas](https://www.unitedstateszipcodes.org/tx/#zips-list)
*This source was used to fill in blank values in the set received from the TDLR Records Center.*
#### 5. [CDC Covid Timeline](https://www.cdc.gov/museum/timeline/covid19.html#:~:text=January%2010%2C%202020,-nCoV)
*This source was referenced in the analysis portion of the project*
## **Process** 
  
**Using the ROCCC system as taught in the Google Data Analytics Program** I will determine the credibility and integrity of the data. 
* **Reliability**: The data is reliable as it has information verified by the state. 
* **Originality**: The data is original as it is created only when a licensee registers for certification.
* **Comprehensiveness**: The data is comprehensive as it is clear and readily understood of the variables available.
* **Current**: This data is current as of September 2022. The data is updated on a daily basis as licensees recertify and or new licenses are pulled. 
* **Cited**: As stated above in the **Data Sources** section, the data is pulled from state verified and monitored websites and was requested from the state regulated Records Center through an official request.  

The primary tools for my analysis were Microsoft Excel, MySQL Workbench, Microsoft Power BI, and RStudio.

### Data Cleaning

In the first step in processing the data, I utilized R programming to combine the datasets from 2 of the sources by a simple webscrape and join function. Details for this step can be found in the [R Markdown Report](https://texascountiesgisdata.netlify.app/) which in summary, combined the GIS data based on Texas Counties in regards to the County Numbers and the County Codes by Mailing Addresses. This first step ended us up with the dataset [Texas_Counties_GIS_Data_Final](https://docs.google.com/spreadsheets/d/14tZoSZokVC5MiGU60GWdX7WksUEG2_XwlfRmhH_cgo8/edit#gid=1495227071) available on google drive or in the Case Studies [repository](https://github.com/ItsMundo/Texas_GIS_Data_By_Counties) on [Github](https://github.com/).

In addition to the above GIS dataset, the raw datasets that were provided by TDLR are available in the repository on my Github account. The details in the extensive cleaning process can be found in my [Cleaning Report](https://github.com/).

In summary

- Duplicates were removed 
  
## **Analyze**
  
A full breakdown of my analysis process can be found in this [Analytics Journal](https://github.com/).  
  
In summary, I explored the data, manipulated it in MySQL and created a couple subsets from the main dataset to tackle the business tasks above:
* Differences in number of expired licenses vs active licenses. 
* Active Licenses by Type of License
* License Expiration vs Issued dates by year
* Locations of Active Electricians by County
* Locations of experienced electricians by county (10+ years experience)
  
Several visualizations were produced. Below are some examples.  
  
![image](https://user-images.githubusercontent.com/.png)  
  
![image](https://user-images.githubusercontent.com/.png)  
  
![image](https://user-images.githubusercontent.com/.png)


## **Share**
![image](https://user-images.githubusercontent.com/.png)  
![image](https://user-images.githubusercontent.com/.png) 
*(Electricians In Texas Dashboard on Microsoft Power BI. )*  
  
Key take aways: 
* The number of electricians available when it comes to workforce will be slowly rising throughout the years. 
* The largest populated counties house the majority of the electricians with active licenses having a 3:1 ratio of Journeyman to Apprentice Electricians in some counties and even a 10:1 in less populated counties. 
* The pandemic was most likely the culprit to affect the workforce of electricians from 2019 to present. It will be intriguing to see how the data plays out within these next couple of years. 
  
  

## **Act**
My recommendations for the possible stakeholders are as follows:
1. If you are trying to establish an electrical contracting business and just want to ensure that you don't need much hands on involvement then you can decide on going towards the counties that have a higher number of journeyman electricians that can handle the workloads on their own. But must be prepared to pay upwards of $80K in salary for experienced technicians. 
2. If you are wanting to get a more hands on approach and have a passion for developing the next generations electricians then taking advantage of the influx of apprentices and training them with a couple Journeyman electricians who are willing to mentor then you may have luck with going with the counties that have a ratio of journeyman to apprentices of about  10:1 much like Hidalgo, along the border of Texas. 
3. With the electrical trade as a business not going anywhere even if the world sees another pandemic, it may be a good idea to open up shop somewhere where there isn't much competition and can stand out as a reliable company to take on a specific sector in texas rather than trying to fight others in a heavily populated area. Some counties that come to mind for this tactic would be Denton, El Paso, Brazoria County and even Williamson. 