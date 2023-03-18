use project;
SELECT * FROM project.nashville_housing;
truncate table nashville_housing;

-- import Nashville Housing Data for Data Cleaning.csv 

load data infile 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\Nashville Housing Data for Data Cleaning.csv'
into table project.nashville_housing
fields terminated by ','
enclosed by '"'
lines terminated by '\r\n'
ignore 1 rows
;
SELECT * FROM project.nashville_housing;
-- Standardize Date Format
ALTER TABLE Nashville_Housing
modify SaleDate date;
Select saleDateConverted, CONVERT(Date,SaleDate)
From Nashville_Housing;


Update Nashville_Housing
SET SaleDate = CONVERT(Date,SaleDate);
-- Populate Property Address data

Select *
From Nashville_Housing
-- Where PropertyAddress is null
order by ParcelID;



Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From Nashville_Housing a
JOIN Nashville_Housing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID] 
Where a.PropertyAddress is null;


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From Nashville_Housing a
JOIN Nashville_Housing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null;

-- Breaking out Address into Individual Columns (Address, City, State)


Select PropertyAddress
From Nashville_Housing;
-- Where PropertyAddress is null
-- order by ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHAR INDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHAR INDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address

From Nashville_Housing;


ALTER TABLE Nashville_Housing
Add PropertySplitAddress Nvarchar(255);

Update Nashville_Housing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 );


ALTER TABLE Nashville_Housing
Add PropertySplitCity Nvarchar(255);

Update Nashville_Housing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress));




Select *
From NashvilleHousing;





Select OwnerAddress
From PortfolioProject.dbo.NashvilleHousing


Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From PortfolioProject.dbo.NashvilleHousing



ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3);


ALTER TABLE Nashville_Housing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2);



ALTER TABLE Nashville_Housing
Add OwnerSplitState Nvarchar(255);

Update Nashville_Housing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1);



Select *
From Nashville_Housing;

-- Change Y and N to Yes and No in "Sold as Vacant" field


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From Nashville_Housing
Group by SoldAsVacant
order by 2;




Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From Nashville_Housing;


Update Nashville_Housing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END;

-- Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From Nashville_Housing
-- order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress;



Select *
From Nashville_Housing;

-- Delete Unused Columns



Select *
From Nashville_Housing;


ALTER TABLE Nashville_Housing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate;


