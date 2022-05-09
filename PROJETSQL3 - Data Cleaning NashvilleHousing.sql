-- PROJETSQL3 - Data Cleaning NashvilleHousing

-- Modifier le format de la colonne "SaleDate"

SELECT SaleDateConverted, CONVERT(Date,SaleDate) FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate;

-- Alimenter les addresses manquantes dans la colonne "PropertyAddress"

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress) FROM NashvilleHousing a
JOIN NashvilleHousing b ON a.ParcelID=b.ParcelID AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL;

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress) FROM NashvilleHousing a
JOIN NashvilleHousing b ON a.ParcelID=b.ParcelID AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL;

-- Séparer la colonne "PropertyAddress" en 2 colonnes (adresse, ville)

SELECT PropertyAddress
SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1) as PropertyAddress,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as PropertyCity FROM NashvilleHousing

ALTER TABLE NashvilleHousing 
ADD PropertyAddress nvarchar(255)
UPDATE NashvilleHousing 
SET PropertyAddress = SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE NashvilleHousing 
ADD PropertyCity nvarchar(255)
UPDATE NashvilleHousing 
SET PropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

ALTER TABLE NashvilleHousing 
DROP COLUMN PropertyAddress

-- Séparer la colonne "OwnerAddress" en 3 colonnes (adresse, ville, état)

SELECT OwnerAddress, 
PARSENAME(REPLACE(OwnerAddress,',','.'),3) AS OwnerStreet,
PARSENAME(REPLACE(OwnerAddress,',','.'),2) AS OwnerCity,
PARSENAME(REPLACE(OwnerAddress,',','.'),1) AS OwnerState FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerStreet nvarchar(255)

UPDATE NashvilleHousing
SET OwnerStreet = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE NashvilleHousing
ADD OwnerCity nvarchar(255)

UPDATE NashvilleHousing
SET OwnerCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE NashvilleHousing
ADD OwnerState nvarchar(255)

UPDATE NashvilleHousing
SET OwnerState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress

-- Changer les "Y" en "Yes" et les "N" en "No" dans la colonne "SoldAsVacant"

SELECT SoldAsVacant, CASE
WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END
FROM NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE
WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END

-- Supprimer les doublons

WITH RowNumCTE AS 
(
SELECT *, ROW_NUMBER() OVER(PARTITION BY ParcelID, SalePrice, LegalReference, OwnerName, PropertyAddress, OwnerStreet,SaleDate ORDER BY UniqueID) as Row_Num 
FROM NashvilleHousing
)

DELETE
FROM RowNumCTE
WHERE Row_Num > 1
