/* CLEANING DATA FROM SQL QUERIES */

SELECT * FROM houseingdata;

--------------------------------------------------------------------------------------------------------------------------------

--Standardize Data Format.

SELECT SaleDateConverted,
       CONVERT(DATE,saledate)
FROM houseingdata;

UPDATE houseingdata
SET SaleDate = CONVERT(DATE,saledate);

ALTER TABLE houseingdata
ADD SaleDateConverted DATE; 

UPDATE houseingdata
SET SaleDateConverted =CONVERT(DATE,SaleDate);

-----------------------------------------------------------------------------------------------------------------------------------

--Populate Property Address Data.

SELECT * FROM houseingdata
--WHERE PropertyAddress is null
ORDER BY ParcelID;

SELECT a.ParcelID,
       a.PropertyAddress,
	   b.ParcelID,
	   b.PropertyAddress,
	   ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM houseingdata a
     JOIN houseingdata b 
     ON a.ParcelID=b.ParcelID
     AND a.[UniqueID ]<>b.[UniqueID ]
     WHERE a.PropertyAddress is null; 

UPDATE a 
 SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
 FROM houseingdata a
      JOIN houseingdata b 
      ON a.ParcelID=b.ParcelID
      AND a.[UniqueID ]<>b.[UniqueID ]
      WHERE a.PropertyAddress is null; 

------------------------------------------------------------------------------------------------------------------------------------------

--Breaking Address Into Individual Columns (Address,City,State).

SELECT 
 PropertyAddress 
FROM houseingdata;

SELECT PropertyAddress ,
 SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
 SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress)) as City
 FROM houseingdata;

 ALTER TABLE houseingdata
ADD PropertySplitAddress NVARCHAR(255); 

UPDATE houseingdata
SET PropertysplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1);

 ALTER TABLE houseingdata
ADD PropertySplitCity NVARCHAR(255); 

UPDATE houseingdata
SET PropertysplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress)) ;

SELECT
  OwnerAddress 
from houseingdata;

SELECT OwnerAddress,
  PARSENAME(Replace(OwnerAddress,',','.'),3) AS Address,
  PARSENAME(Replace(OwnerAddress,',','.'),2) AS City,
  PARSENAME(Replace(OwnerAddress,',','.'),1) AS state
FROM houseingdata
WHERE OwnerAddress IS NOT NULL;

 ALTER TABLE houseingdata
ADD OwnerSplitAddress NVARCHAR(255); 

UPDATE houseingdata
SET OwnerSplitAddress = PARSENAME(Replace(OwnerAddress,',','.'),3);

 ALTER TABLE houseingdata
ADD OwnerSplitCity NVARCHAR(255); 

UPDATE houseingdata
SET OwnerSplitCity = PARSENAME(Replace(OwnerAddress,',','.'),2);

 ALTER TABLE houseingdata
ADD OwnerSplitState NVARCHAR(255); 

UPDATE houseingdata
SET OwnerSplitState = PARSENAME(Replace(OwnerAddress,',','.'),1);

----------------------------------------------------------------------------------------------------------------------------------------------

-- Change Y and N As Yes and No in "SoldAsVacant" Feild.
SELECT DISTINCT SoldAsVacant,
       COUNT(SoldAsVacant)
FROM houseingdata
 GROUP BY SoldAsVacant
 ORDER BY 2;

 SELECT SoldAsVacant,
     CASE WHEN SoldAsVacant='Y' THEN 'Yes'
	      WHEN SoldAsVacant='N' THEN 'No'
	 ELSE SoldAsVacant
	 END 
FROM houseingdata;

UPDATE houseingdata
SET SoldAsVacant= CASE WHEN SoldAsVacant='Y' THEN 'Yes'
	                   WHEN SoldAsVacant='N' THEN 'No'
	                   ELSE SoldAsVacant
	                   END 
FROM houseingdata;

--------------------------------------------------------------------------------------------------------------------

--Removing Duplicates.
WITH row_numCTE AS (
SELECT *,
ROW_NUMBER() OVER(
    PARTITION BY parcelID,
	             PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
    ORDER BY UniqueID) row_num
FROM houseingdata )

DELETE FROM row_numCTE
WHERE row_num>1;

-----------------------------------------------------------------------------------------------------------------------

--Delete Unused Columns.
SELECT * FROM houseingdata;

ALTER TABLE houseingdata
DROP COLUMN PropertyAddress,
            SaleDate,
			OwnerAddress,
			TaxDistrict;


	              

