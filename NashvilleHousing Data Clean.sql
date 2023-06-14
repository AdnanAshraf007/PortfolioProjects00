--CLeaning Data in SQL Queries

Select *
From PortfoliaProject.dbo.NashvilleHousing

--Standardize date format

Select SaleDateConverted, CONVERT(Date, SaleDate)
From PortfoliaProject.dbo.NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(date, SaleDate)

Alter Table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(date, SaleDate)

--Populate property Address Data

Select ParcelID, PropertyAddress
From PortfoliaProject.dbo.NashvilleHousing
order by ParcelID

Select a.ParcelID, b.ParcelID, a.PropertyAddress, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfoliaProject.dbo.NashvilleHousing a
Join PortfoliaProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is NULL

Update a 
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfoliaProject.dbo.NashvilleHousing a
Join PortfoliaProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is NULL

--Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From PortfoliaProject.dbo.NashvilleHousing
--order by ParcelID

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as Address
From PortfoliaProject.dbo.NashvilleHousing

Alter Table NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress  = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

Alter Table NashvilleHousing
Add PropertySplitcity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity  = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

Select *
From PortfoliaProject.dbo.NashvilleHousing

Select
PARSENAME(Replace(OwnerAddress, ',' , '.'), 3)
, PARSENAME(Replace(OwnerAddress, ',' , '.'), 2)
, PARSENAME(Replace(OwnerAddress, ',' , '.'), 1)
From PortfoliaProject.dbo.NashvilleHousing

Alter Table NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress  = PARSENAME(Replace(OwnerAddress, ',' , '.'), 3)


Alter Table NashvilleHousing
Add OwnerSplitcity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress  = PARSENAME(Replace(OwnerAddress, ',' , '.'), 2)

Alter Table NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState  = PARSENAME(Replace(OwnerAddress, ',' , '.'), 1)

--Change Y and N to Yes and No in 'Sold as Vacant' field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfoliaProject.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant
, CASE when SoldAsVacant = 'Y' THEN 'Yes'
		When SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
From PortfoliaProject.dbo.NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = CASE when SoldAsVacant = 'Y' THEN 'Yes'
		When SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
From PortfoliaProject.dbo.NashvilleHousing

--Remove Duplicates

With RowNumCTE AS (
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
From PortfoliaProject.dbo.NashvilleHousing
--Order By ParcelID
)
--DELETE
Select *
From RowNumCTE
where row_num > 1
--order by PropertyAddress

--Delete Unused columns

Select *
From PortfoliaProject.dbo.NashvilleHousing

ALTER TABLE PortfoliaProject.dbo.NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfoliaProject.dbo.NashvilleHousing
Drop Column SaleDate

