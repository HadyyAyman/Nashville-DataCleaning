
/*  
	Data Cleaning Portfolio Project
*/

------------------------------------------------------------------------------------------------

/* Determine what columns needs to be cleaned  */
Select *
from [Nashville housing]..Nashville 

------------------------------------------------------------------------------------------------
/* PropertyAddress column need to be populated */

select  PropertyAddress
from [Nashville housing]..Nashville 
where PropertyAddress is null -- 29 rows null >> 0 rows 

select a.ParcelID, a.PropertyAddress , b.ParcelID, b.PropertyAddress, 
ISNULL(a.PropertyAddress,b.PropertyAddress)
from [Nashville housing]..Nashville a
join [Nashville housing]..Nashville b 
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ]<>b.[UniqueID ]
	where a.PropertyAddress is null

update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from [Nashville housing]..Nashville a
join [Nashville housing]..Nashville b 
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ]<>b.[UniqueID ]
	where a.PropertyAddress is null

------------------------------------------------------------------------------------------------
/* Split PropertyAddress column (Address, City, State) */

select *
from [Nashville housing]..Nashville 

select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress)) City
from [Nashville housing]..Nashville 

alter table [Nashville housing]..Nashville 
add Property_Address varchar(255),
Property_City varchar(255);

update [Nashville housing]..Nashville
SET Property_Address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

update [Nashville housing]..Nashville
SET Property_City = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress))

------------------------------------------------------------------------------------------------
/* Format SaleDate column */

select *
from [Nashville housing]..Nashville 

select SaleDate, CONVERT(date, SaleDate) SaleDateConverted
from [Nashville housing]..Nashville 

alter table Nashville
add SaleDateConverted date;

update Nashville
SET SaleDateConverted = CONVERT(date, SaleDate) 

------------------------------------------------------------------------------------------------
/* Standarize the SoldAsVacant column to just Yes and NO */

-- This code to see how many (Yes , No), (Y , N) do we have to choose wich form we take 
select distinct(SoldAsVacant), COUNT(SoldAsVacant)
from [Nashville housing]..Nashville
group by SoldAsVacant

select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	 Else SoldAsVacant
	 End
from [Nashville housing]..Nashville

update Nashville
SET SoldAsVacant =
case when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	 Else SoldAsVacant
	 End
from [Nashville housing]..Nashville

------------------------------------------------------------------------------------------------
/* spilt OwnerAddress  column into (Address, City, State) */

select *
from [Nashville housing]..Nashville 


select 
Parsename(REPLACE(OwnerAddress, ',', '.'),3),
Parsename(REPLACE(OwnerAddress, ',', '.'),2),
Parsename(REPLACE(OwnerAddress, ',', '.'),1)
from [Nashville housing]..Nashville 

alter table [Nashville housing]..Nashville 
add Owner_Address varchar(255),
Owner_City varchar(255),
Owner_State varchar(255);

update Nashville
SET Owner_Address = Parsename(REPLACE(OwnerAddress, ',', '.'),3)

update Nashville
SET Owner_City = Parsename(REPLACE(OwnerAddress, ',', '.'),2)

update Nashville
SET Owner_State = Parsename(REPLACE(OwnerAddress, ',', '.'),1)

------------------------------------------------------------------------------------------------
/* Remove Duplicates */ 

with row_num_duplicates as(
select *,
ROW_NUMBER() over (PARTITION BY
				   ParcelID,
				   PropertyAddress,
				   SaleDate,
				   SalePrice,
				   LegalReference
				   ORDER BY
				   UniqueID) row_num
from [Nashville housing]..Nashville )
Select *
from row_num_duplicates
where row_num > 1

-- FINAL PRODUCT

select * 
from [Nashville housing]..Nashville 
