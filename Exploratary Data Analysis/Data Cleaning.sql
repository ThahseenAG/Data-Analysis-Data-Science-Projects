--Data Cleaning Using SQL
select * 
from [Protfolio Project]..NashvilleHousing

--Standardizing Date
Alter table [Protfolio Project]..NashvilleHousing
add ConvertedSaleDate Date;

update [Protfolio Project]..NashvilleHousing
SET ConvertedSaleDate = cast(SaleDate as date)


---Replace Null values in PropertyAddress, if Address given in another row with same ParcelID by joining table to itself

Update A
SET PropertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM [Protfolio Project]..NashvilleHousing A
JOIN [Protfolio Project]..NashvilleHousing B
	on A.ParcelID = B.ParcelID
	and A.[UniqueID ] <> B.[UniqueID ]
where A.PropertyAddress is null

---Splitting PropertyAddress to Address, City and State using delimeter and substring

Select 
	SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
	SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)+1 , LEN(PropertyAddress)) as Address

from [Protfolio Project]..NashvilleHousing


--Adding new columns for address and city

ALTER TABLE [Protfolio Project]..NashvilleHousing
	Add  Address Nvarchar(255);


Update [Protfolio Project]..NashvilleHousing
SET Address = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE [Protfolio Project]..NashvilleHousing
	Add  City Nvarchar(255);


Update [Protfolio Project]..NashvilleHousing
SET City = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))

select * 
from [Protfolio Project]..NashvilleHousing

---Splitting PropertyAddress to Address, City and State using parsename
---Parsename Checks for '.' so repalcing comma to period

Select 
PARSENAME(replace(OwnerAddress , ',','.'),3),
PARSENAME(replace(OwnerAddress , ',','.'),2),
PARSENAME(replace(OwnerAddress , ',','.'),1)
from [Protfolio Project]..NashvilleHousing

--Adding new columns for address and city

ALTER TABLE [Protfolio Project]..NashvilleHousing
	Add  Owner_Address Nvarchar(255);

Update [Protfolio Project]..NashvilleHousing
SET Owner_Address = PARSENAME(replace(OwnerAddress , ',','.'),3)


ALTER TABLE [Protfolio Project]..NashvilleHousing
	Add  Owner_City Nvarchar(255);

Update [Protfolio Project]..NashvilleHousing
SET Owner_City = PARSENAME(replace(OwnerAddress , ',','.'),2)


ALTER TABLE [Protfolio Project]..NashvilleHousing
	Add  Owner_State Nvarchar(255);

Update [Protfolio Project]..NashvilleHousing
SET Owner_State = PARSENAME(replace(OwnerAddress , ',','.'),1)


----Changing Y and N in columns as Yes and NO

Select Distinct(SoldAsVacant),count(SoldAsVacant)
from [Protfolio Project]..NashvilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
	     ELSE SoldAsVacant
	END
from [Protfolio Project]..NashvilleHousing


update [Protfolio Project]..NashvilleHousing
set SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
						WHEN SoldAsVacant = 'N' THEN 'No'
						ELSE SoldAsVacant
					END

---Removing Duplicates using CTE And Windows Function
---if it has same value row_num will be greater than 1

with RowNumCTE AS(
select *,
	ROW_NUMBER() OVER (
	Partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				Order by UniqueID ) row_num
from [Protfolio Project]..NashvilleHousing)

delete from RowNumCTE
where row_num > 1 


----Deleting Unused Column
Alter table [Protfolio Project]..NashvilleHousing
drop column OwnerAddress, PropertyAddress, TaxDistrict, SaleDate





