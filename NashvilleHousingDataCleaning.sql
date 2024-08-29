
--Cleaning data in sql

select * 
from PortfolioProject.dbo.NashvilleHousing


----Standardize date format----------------------------------------------------------
 select SaleDate
 from PortfolioProject.dbo.NashvilleHousing

 UPDATE PortfolioProject.dbo.NashvilleHousing   --- it did not work at all
 SET SaleDate = CONVERT(Date, SaleDate)

 Alter Table PortfolioProject.dbo.NashvilleHousing
 Add SaleDateConverted Date;

 UPDATE PortfolioProject.dbo.NashvilleHousing
 SET SaleDateConverted = CONVERT(Date, SaleDate)


 ----Populate property address data (null handling)-------------------------------------

select *
from PortfolioProject.dbo.NashvilleHousing
where PropertyAddress is null


												--join tablewith itself to find address of null proprty if the 
												--same order is repeated and have address already associated with other orders 
select a.ParcelID, a.PropertyAddress, b.ParcelId, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	ON a.ParcelId = b.ParcelId
	AND a.[UniqueID] <> b.[UniqueID]
where a.PropertyAddress is null


UPDATE a
SET a.PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	ON a.ParcelId = b.ParcelId
	AND a.[UniqueID] <> b.[UniqueID]
where a.PropertyAddress is null

--------------------Breaking address into individual address (Adress, city, state)------------

select PropertyAddress
from PortfolioProject.dbo.NashvilleHousing


SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) AS Address
,SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) AS Address
from PortfolioProject.dbo.NashvilleHousing


 Alter Table PortfolioProject.dbo.NashvilleHousing
 Add PropertSplitAddress Nvarchar(255);

 UPDATE PortfolioProject.dbo.NashvilleHousing
 SET PropertSplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

 Alter Table PortfolioProject.dbo.NashvilleHousing
 Add PropertSplitCity Nvarchar(255);

 UPDATE PortfolioProject.dbo.NashvilleHousing
 SET PropertSplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

 select *
from PortfolioProject.dbo.NashvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'), 3 ),
PARSENAME(REPLACE(OwnerAddress,',','.'), 2 ),
PARSENAME(REPLACE(OwnerAddress,',','.'), 1 )
from PortfolioProject.dbo.NashvilleHousing


Alter Table PortfolioProject.dbo.NashvilleHousing
 Add OwnerSplitAddress Nvarchar(255);

 UPDATE PortfolioProject.dbo.NashvilleHousing
 SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'), 3 )

 Alter Table PortfolioProject.dbo.NashvilleHousing
 Add OwnerSplitCity Nvarchar(255);

 UPDATE PortfolioProject.dbo.NashvilleHousing
 SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'), 2 )

  Alter Table PortfolioProject.dbo.NashvilleHousing
 Add OwnerSplitState Nvarchar(255);

 UPDATE PortfolioProject.dbo.NashvilleHousing
 SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'), 1 )



 ------------REplcing Y and N to YES and NO--------------------------------

 Select 
 DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
 From PortfolioProject.dbo.NashvilleHousing
 GROUP BY SoldAsVacant
 ORDER BY 2

 SELECT SoldAsVacant,
	CASE When SoldAsVacant = 'Y' Then 'Yes'
		 When SoldASVacant = 'N' Then 'No'
		 Else SoldAsVacant
		 End
  From PortfolioProject.dbo.NashvilleHousing


 UPDATE PortfolioProject.dbo.NashvilleHousing
 SET SoldAsVacant =CASE When SoldAsVacant = 'Y' Then 'Yes'
		 When SoldASVacant = 'N' Then 'No'
		 Else SoldAsVacant
		 End


--------------------------------------------Removing duplicates-----------------------------------------------
 WITH RowNumCTE AS(
	Select * ,
	ROW_NUMBER() OVER (
		PARTITION BY ParcelID,
		PropertyAddress,
		SalePrice,
		SaleDate,
		LegalReference
		ORDER BY
			UniqueID
					)row_num
		
	From PortfolioProject.dbo.NashvilleHousing
 )
 Select * 
 from RowNumCTE
 where row_num >1
 ORDER BY PropertyAddress
 
 
 --DELETE
 --from RowNumCTE
 --where row_num >1
 --ORDER BY PropertyAddress


 -------------------------------------Deleting unused columns-------------------------------------------------
 select *
from PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict, SaleDate