-- Cleaning Data in SQL Queries

--Creating the table query
CREATE TABLE nashville_housing_data_for_data_cleaning(
	uniqueID INT,
	parcel_id TEXT,
	land_use TEXT,
	property_address TEXT,
	sale_date TEXT,
	sale_price TEXT,
	legal_reference TEXT,
	sold_as_vacant TEXT,
	owner_name TEXT,
	owner_address TEXT,
	acreage TEXT,
	tax_district TEXT,
	land_value TEXT,
	building_value TEXT,
	total_value TEXT,
	year_built TEXT,
	bedrooms TEXT,
	full_bath TEXT,
	half_bath TEXT
)

SELECT *
FROM nashville_housing_data_for_data_cleaning
LIMIT 10;

-- Standardise Date Format
-- CAST sale_date into date format
SELECT sale_date, CAST(sale_date AS DATE)
FROM nashville_housing_data_for_data_cleaning
LIMIT 10;

-- Updating the sale_date col in table to reflect a date datatype
UPDATE nashville_housing_data_for_data_cleaning
SET sale_date = CAST(sale_date AS DATE);

-- Populate Property Address Data
SELECT *
FROM nashville_housing_data_for_data_cleaning
--WHERE property_address IS NULL
ORDER BY parcel_id
LIMIT 100;

-- For null property address values, we need to find the duplicate parcel_id and copy the property address into the null value as the address will be the same
-- Self Join

SELECT a.parcel_id, a.property_address, b.parcel_id, b.property_address,
COALESCE(a.property_address, b.property_address) as property_address_cleaned
FROM nashville_housing_data_for_data_cleaning AS a
JOIN nashville_housing_data_for_data_cleaning AS b
ON a.parcel_id = b.parcel_id
AND a.uniqueid <> b.uniqueid
WHERE a.property_address IS NULL;

-- Updating the null property addresses to the matching address
UPDATE nashville_housing_data_for_data_cleaning
SET property_address = COALESCE(a.property_address, b.property_address)
FROM nashville_housing_data_for_data_cleaning AS a
JOIN nashville_housing_data_for_data_cleaning AS b
ON a.parcel_id = b.parcel_id
AND a.uniqueid <> b.uniqueid;



-- Check to see if values have been updates - query should output be empty
SELECT a.parcel_id, a.property_address, b.parcel_id, b.property_address
FROM nashville_housing_data_for_data_cleaning AS a
JOIN nashville_housing_data_for_data_cleaning AS b
ON a.parcel_id = b.parcel_id
AND a.uniqueid <> b.uniqueid
WHERE a. property_address IS NULL;

-- Breaking out address into individual columns (Address, City, State)
SELECT property_address
FROM nashville_housing_data_for_data_cleaning;

-- substring to extract address, city & state, using Position function
SELECT property_address,
-- find the address
SUBSTRING(property_address, 1, POSITION(',' IN property_address)-1) AS addresss,
--finds the city
SUBSTRING(property_address, POSITION(',' IN property_address)+1, LENGTH(property_address)-1) AS city
FROM nashville_housing_data_for_data_cleaning;

-- add new address column to table
ALTER TABLE nashville_housing_data_for_data_cleaning
ADD property_split_address TEXT;

-- update new column with splited address
UPDATE nashville_housing_data_for_data_cleaning
SET property_split_address = SUBSTRING(property_address, 1, POSITION(',' IN property_address)-1);

-- Check new col is correct
SELECT property_split_address
FROM nashville_housing_data_for_data_cleaning;

-- add new city column 
ALTER TABLE nashville_housing_data_for_data_cleaning
ADD property_split_city TEXT;

-- update new column with city data
UPDATE nashville_housing_data_for_data_cleaning
SET property_split_city = SUBSTRING(property_address, POSITION(',' IN property_address)+1, LENGTH(property_address)-1);

-- Check new col is correct
SELECT property_split_city
FROM nashville_housing_data_for_data_cleaning;


-- spliting Owner address by address, city & state using split_part
SELECT SPLIT_PART(owner_address,',',1) AS address,
SPLIT_PART(owner_address,',',2) AS city,
SPLIT_PART(owner_address,',',3) AS state
FROM nashville_housing_data_for_data_cleaning;

--- 
ALTER TABLE nashville_housing_data_for_data_cleaning
ADD owner_split_address TEXT;

UPDATE nashville_housing_data_for_data_cleaning
SET owner_split_address = SPLIT_PART(owner_address,',',1);

---
ALTER TABLE nashville_housing_data_for_data_cleaning
ADD owner_split_city TEXT;

UPDATE nashville_housing_data_for_data_cleaning
SET owner_split_city = SPLIT_PART(owner_address,',',2);

---
ALTER TABLE nashville_housing_data_for_data_cleaning
ADD owner_split_state TEXT;

UPDATE nashville_housing_data_for_data_cleaning
SET owner_split_state = SPLIT_PART(owner_address,',',3);

SELECT *
FROM nashville_housing_data_for_data_cleaning;

-- Change Y and N to yes and no in sold as vacant field

-- query to check the different inconsistencies for yes & no - need to change just to yes & no
SELECT DISTINCT(sold_as_vacant), COUNT(sold_as_vacant)
FROM nashville_housing_data_for_data_cleaning
GROUP BY sold_as_vacant;

-- Case statement to change y & n to yes or no - empty query means changes have been made
SELECT sold_as_vacant,
CASE WHEN sold_as_vacant = 'Y' THEN 'Yes'
WHEN sold_as_vacant = 'N' THEN 'No'
ELSE sold_as_vacant
END
FROM nashville_housing_data_for_data_cleaning
WHERE sold_as_vacant = 'N' OR sold_as_vacant = 'Y';

-- update the sold_as_vacant column
UPDATE nashville_housing_data_for_data_cleaning
SET sold_as_vacant = CASE WHEN sold_as_vacant = 'Y' THEN 'Yes'
WHEN sold_as_vacant = 'N' THEN 'No'
ELSE sold_as_vacant
END;

-- Remove Duplicates - not standard practice - We won't delete the dups, just identifying them
WITH row_num_cte AS (
SELECT *,
ROW_NUMBER() OVER(
	PARTITION BY parcel_id, 
	property_address,
	sale_date,
	sale_price,
	legal_reference
	ORDER BY parcel_id
) AS row_num
FROM nashville_housing_data_for_data_cleaning
)
SELECT *
FROM row_num_cte
WHERE row_num >1;
--ORDER BY parcel_id;

-- DLETE unused cols - 
-- property address
-- onwer address
-- tax district
SELECT *
FROM nashville_housing_data_for_data_cleaning;

ALTER TABLE nashville_housing_data_for_data_cleaning
DROP COLUMN property_address;

ALTER TABLE nashville_housing_data_for_data_cleaning
DROP COLUMN owner_address;

ALTER TABLE nashville_housing_data_for_data_cleaning
DROP COLUMN tax_district;


