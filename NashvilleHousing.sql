SELECT * FROM [dbo].[NashvilleHousing]

-- Standardize date format
ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date; 

UPDATE NashvilleHousing
SET SaleDateConverted=CONVERT(Date, SaleDate)

SELECT SaleDateConverted,CONVERT(Date, SaleDate)
FROM [dbo].[NashvilleHousing]

-- Populate null property address data

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [dbo].[NashvilleHousing] a
JOIN [dbo].[NashvilleHousing] b
     ON a.ParcelID=b.ParcelID
	 AND a.[UniqueID ]<>b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress= ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [dbo].[NashvilleHousing] a
JOIN [dbo].[NashvilleHousing] b
     ON a.ParcelID=b.ParcelID
	 AND a.[UniqueID ]<>b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

-- Break out address into Individual Columns(Address, City, State)
SELECT PropertyAddress
FROM [dbo].[NashvilleHousing]
--ORDER BY ParcelId

SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address
,SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as City
FROM [dbo].[NashvilleHousing]

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress nvarchar(255); 

UPDATE NashvilleHousing
SET PropertySplitAddress=SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity nvarchar(255); 

UPDATE NashvilleHousing
SET PropertySplitCity=SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))

SELECT * [dbo].[NashvilleHousing]

-- Break up OwnerAddress using parsename
SELECT OwnerAddress
FROM [dbo].[NashvilleHousing]

SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM [dbo].[NashvilleHousing]


ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress nvarchar(255); 

UPDATE NashvilleHousing
SET OwnerSplitAddress=PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity nvarchar(255); 

UPDATE NashvilleHousing
SET OwnerSplitCity=PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState nvarchar(255); 

UPDATE NashvilleHousing
SET OwnerSplitState=PARSENAME(REPLACE(OwnerAddress,',','.'),1)

-- Change Y and N to Yes and No in "Sold as Vacant" field
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM [dbo].[NashvilleHousing]
GROUP BY SoldAsVacant
ORDER BY 2

UPDATE NashvilleHousing
SET SoldAsVacant=CASE WHEN SoldAsVacant='Y' THEN 'Yes'
	  WHEN SoldAsVacant='N' THEN 'No'
	  ELSE SoldAsVacant
	  END
FROM [dbo].[NashvilleHousing]

-- Remove Duplicates
WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID, PropertyAddress,SalePrice, SaleDate,LegalReference
	ORDER  BY UniqueID
						) row_num
FROM[dbo].[NashvilleHousing]
)
DELETE 
FROM RowNumCTE
WHERE row_num>1


ALTER TABLE [dbo].[NashvilleHousing]
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress