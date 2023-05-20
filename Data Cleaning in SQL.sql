select *
from [portfolio project].dbo.NashvilleHousing
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--made a new column of sale date with proper format

select saledateconverted, cast(saledate as date) as dates
from [portfolio project].dbo.NashvilleHousing

update NashvilleHousing
set SaleDate=cast(saledate as date)

alter table NashvilleHousing
add saledateconverted date;

update NashvilleHousing
set saledateconverted = cast(saledate as date)
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--populate property address data
--using this method we updated the property in which address was null

select *
from [portfolio project].dbo.NashvilleHousing
where PropertyAddress is null

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.propertyaddress,b.PropertyAddress)
from [portfolio project].dbo.NashvilleHousing as a
join [portfolio project].dbo.NashvilleHousing as b
  on a.ParcelID=b.ParcelID
  and a.[UniqueID ]<>b.[UniqueID ]


update a
set PropertyAddress = ISNULL(a.propertyaddress,b.PropertyAddress)
from [portfolio project].dbo.NashvilleHousing as a
join [portfolio project].dbo.NashvilleHousing as b
  on a.ParcelID=b.ParcelID
  and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--breaking out address into individual columns (address,city,state)

select *
from [portfolio project].dbo.NashvilleHousing

select
SUBSTRING(propertyaddress, 1, CHARINDEX(',',propertyaddress)-1) as address,
SUBSTRING(propertyaddress, CHARINDEX(',',propertyaddress)+1,LEN(propertyaddress)) as address
from [portfolio project].dbo.NashvilleHousing

alter table NashvilleHousing
add propertysplitaddress nvarchar(255);

update NashvilleHousing
set propertysplitaddress = SUBSTRING(propertyaddress, 1, CHARINDEX(',',propertyaddress)-1) 

alter table NashvilleHousing
add propertysplitcity nvarchar(255);

update NashvilleHousing
set propertysplitcity = SUBSTRING(propertyaddress, CHARINDEX(',',propertyaddress)+1,LEN(propertyaddress))

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--breaking owneraddress into housenumber,city,state

select OwnerAddress
from [portfolio project].dbo.NashvilleHousing
order by OwnerAddress desc

select
PARSENAME(replace(owneraddress,',','.'),3),
PARSENAME(replace(owneraddress,',','.'),2),
PARSENAME(replace(owneraddress,',','.'),1)
from [portfolio project].dbo.NashvilleHousing

alter table NashvilleHousing
add ownersaddress nvarchar(255);

update NashvilleHousing
set ownersaddress = PARSENAME(replace(owneraddress,',','.'),3)

alter table NashvilleHousing
add ownerscity nvarchar(255);

update NashvilleHousing
set ownerscity =  PARSENAME(replace(owneraddress,',','.'),2)

alter table NashvilleHousing
add ownerstate nvarchar(255);

update NashvilleHousing
set ownerstate =  PARSENAME(replace(owneraddress,',','.'),1)

select *
from [portfolio project].dbo.NashvilleHousing

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--change y and n to yes AND no in 'sold as vacant' field

select SoldAsVacant,count(soldAsVacant) as total_number
from [portfolio project].dbo.NashvilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant,
case when SoldAsVacant='Y' THEN 'Yes'
     when SoldAsVacant='N' then 'No'
	 else SoldAsVacant
	 end as soldasvacant
from [portfolio project].dbo.NashvilleHousing

update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant='Y' THEN 'Yes'
     when SoldAsVacant='N' then 'No'
	 else SoldAsVacant
	 end

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--removing duplicates

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

From [portfolio project]..NashvilleHousing
--order by ParcelID
)
DELETE
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--DELETE UNUSED COLUMS

select *
from [portfolio project]..NashvilleHousing

alter table [portfolio project]..NashvilleHousing
drop column owneraddress, taxdistrict, propertyaddress

alter table [portfolio project]..NashvilleHousing
drop column SaleDate

Select *
From [portfolio project]..NashvilleHousing


