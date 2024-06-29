--- Explore Nashville Housing Dataset
SELECT *
FROM [Nashville Housing]

--- Convert the column SaleDate from DateTime function to Date function
SELECT SaleDate, CONVERT(Date, SaleDate) NewDate
FROM [Nashville Housing]

ALTER TABLE [Nashville Housing]
ADD NewSaleDate Date;

UPDATE [Nashville Housing]
SET NewSaleDate = CONVERT(Date, SaleDate)

--- Fill NULL values in the column PropertyAddress with values
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [Nashville Housing] a
JOIN [Nashville Housing] b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [Nashville Housing] a
JOIN [Nashville Housing] b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is NULL

--- Replace values 'Y' and 'N' in the column SoldAsVacant as 'Yes' and 'No'
SELECT DISTINCT(SoldAsVacant)
FROM [Nashville Housing]

SELECT SoldAsVacant,
CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END
FROM [Nashville Housing]
Where SoldAsVacant = 'N'

UPDATE [Nashville Housing]
SET SoldAsVacant = CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END
FROM [Nashville Housing]

--- Separate values in column PropertyAddress into 2 columns
SELECT PropertyAddress, SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) Address,
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) City
FROM [Nashville Housing]

ALTER TABLE [Nashville Housing]
ADD Address nvarchar(200),
	City nvarchar(200)

UPDATE [Nashville Housing]
SET Address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

UPDATE [Nashville Housing]
SET City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

--- Separate values in column OwnerAddress into 3 columns
SELECT OwnerAddress, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) Owner_Address,
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) HomeCity,
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) State
FROM [Nashville Housing]

ALTER TABLE [Nashville Housing]
ADD Owner_Address nvarchar(200),
	HomeCity nvarchar(200),
	State nvarchar(200)

UPDATE [Nashville Housing]
SET Owner_Address = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
	HomeCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
	State = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

--- Delete duplicate rows
SELECT *, ROW_NUMBER() OVER (PARTITION BY ParcelID, PropertyAddress, SalePrice, LegalReference
								ORDER BY UniqueID)
FROM [Nashville Housing]

WITH CTE_Duplicate AS
(SELECT *, ROW_NUMBER() OVER (PARTITION BY ParcelID, PropertyAddress, SalePrice, LegalReference
								ORDER BY UniqueID) as row_num
FROM [Nashville Housing]
)
DELETE FROM CTE_Duplicate
WHERE row_num > 1

--- DELETE Unused columns
ALTER TABLE [Nashville Housing]
DROP COLUMN PropertyAddress, SaleDate, TaxDistrict

ALTER TABLE [Nashville Housing]
ADD SaleDate Date;

UPDATE [Nashville Housing]
SET SaleDate = NewSaleDate

ALTER TABLE [Nashville Housing]
DROP COLUMN NewSaleDate

SELECT *
FROM [Nashville Housing]