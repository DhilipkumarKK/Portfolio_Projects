/*
Cleaning Data in SQL Quries
*/
select *
from PortfolioProject..NashvilleHousing

--standardize date format
select SaledateConverted,CONVERT(date,saledate)
from PortfolioProject..NashvilleHousing

update NashvilleHousing
set SaleDate = CONVERT(date,saledate)

alter table NashvilleHousing
add SaledateConverted date;

update NashvilleHousing
set SaledateConverted = CONVERT(date,saledate)

--populate property address data

select *
from PortfolioProject..NashvilleHousing
--where PropertyAddress is null
order by ParcelID

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,isnull(a.propertyaddress,b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
 on a.ParcelID = b.ParcelID
 and a.[UniqueID ]<>b.[UniqueID ]
 where a.PropertyAddress is null

 update a
 set propertyaddress = isnull(a.propertyaddress,b.PropertyAddress)
 from PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
 on a.ParcelID = b.ParcelID
 and a.[UniqueID ]<>b.[UniqueID ]
  where a.PropertyAddress is null


  --breaking address into individual column(address,city,state)

  select PropertyAddress
from PortfolioProject..NashvilleHousing
--where PropertyAddress is null
--order by ParcelID

select 
SUBSTRING(propertyaddress,1,CHARINDEX(',',propertyaddress) -1) as address,
SUBSTRING(propertyaddress,CHARINDEX(',',propertyaddress) +1,LEN(propertyaddress)) as address
from PortfolioProject..NashvilleHousing

alter table NashvilleHousing
add propertysplitaddress nvarchar(255);

update NashvilleHousing
set propertysplitaddress = SUBSTRING(propertyaddress,1,CHARINDEX(',',propertyaddress) -1)

alter table NashvilleHousing
add propertysplitcity nvarchar(255);

update NashvilleHousing
set propertysplitcity = SUBSTRING(propertyaddress,CHARINDEX(',',propertyaddress) +1,LEN(propertyaddress))

select 
PARSENAME(replace(OwnerAddress,',','.'),3),
PARSENAME(replace(OwnerAddress,',','.'),2),
PARSENAME(replace(OwnerAddress,',','.'),1)
from PortfolioProject..NashvilleHousing

alter table NashvilleHousing
add ownersplitaddress nvarchar(255);

update NashvilleHousing
set ownersplitaddress = PARSENAME(replace(OwnerAddress,',','.'),3)

alter table NashvilleHousing
add ownersplitcity nvarchar(255);

update NashvilleHousing
set ownersplitcity = PARSENAME(replace(OwnerAddress,',','.'),2)

alter table NashvilleHousing
add ownersplitstate nvarchar(255);

update NashvilleHousing
set ownersplitstate = PARSENAME(replace(OwnerAddress,',','.'),1)

select*
from PortfolioProject..NashvilleHousing

--change y and n as yes and no to "sold as vacant" field

select distinct(soldasvacant),COUNT(soldasvacant)
from PortfolioProject..NashvilleHousing
group by SoldAsVacant
order by 2


select SoldAsVacant,
case when SoldAsVacant ='Y' then 'YES'
when SoldAsVacant = 'N' then 'NO'
else SoldAsVacant
end
from PortfolioProject..NashvilleHousing

update NashvilleHousing
set SoldAsVacant =case when SoldAsVacant ='Y' then 'YES'
when SoldAsVacant = 'N' then 'NO'
else SoldAsVacant
end

--remove duplicates

with rownumCTE as(
select*,
	ROW_NUMBER()over(
	partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 order by
					UniqueID
					) row_num

from PortfolioProject..NashvilleHousing
)

delete
from rownumCTE
where row_num>1
--order by PropertyAddress

--delete unused columns

select*
from PortfolioProject..NashvilleHousing

alter table PortfolioProject..NashvilleHousing
drop column owneraddress,taxdistrict,propertyaddress

alter table PortfolioProject..NashvilleHousing
drop column saledate