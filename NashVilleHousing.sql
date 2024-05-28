--Cleaninf data in SQL queries
select * from [HousingData].[dbo].[Nashville];

select saledate,convert(date,saledate) from [HousingData].[dbo].[Nashville];

alter table [HousingData].[dbo].[Nashville] add SaleDateConverted Date;

update [HousingData].[dbo].[Nashville] set SaleDateConverted =convert(date,saledate);

select saledate, SaleDateConverted from [HousingData].[dbo].[Nashville];

--where propertyaddress is null

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From [HousingData].[dbo].[Nashville] a
JOIN [HousingData].[dbo].[Nashville] b
on a.ParcelID = b.ParcelID
AND a. [UniqueID ] <>b.[UniqueID ]
Where a.PropertyAddress is null;

Update a
SET propertyaddress=  ISNULL(a.PropertyAddress,b.PropertyAddress)
From [HousingData].[dbo].[Nashville] a
JOIN [HousingData].[dbo].[Nashville] b
on a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
where a.propertyaddress is null;

---breaking address into individual coulmns(address,city,state)

select propertyaddress from [HousingData].[dbo].[Nashville];

select
propertyaddress ,
Substring(propertyaddress, 1, CHARINDEX(',',propertyaddress)-1) as Address, -- we do not want ',' so -1
Substring(propertyaddress, CHARINDEX(',',propertyaddress)+1, len(propertyaddress))
from [HousingData].[dbo].[Nashville] ;

alter table [HousingData].[dbo].[Nashville]
add PropertySplitAddress Nvarchar(255);

update [HousingData].[dbo].[Nashville] set
PropertySplitAddress =Substring(propertyaddress, 1, CHARINDEX(',',propertyaddress)-1);

alter table [HousingData].[dbo].[Nashville]
add PropertySplitCity Nvarchar(255);

update [HousingData].[dbo].[Nashville] set
PropertySplitCity =Substring(propertyaddress, CHARINDEX(',',propertyaddress)+1, len(propertyaddress));

select propertyaddress,PropertySplitAddress, PropertySplitCity
from [HousingData].[dbo].[Nashville];

select Owneraddress from [HousingData].[dbo].[Nashville];

select
Owneraddress,
parsename(replace(owneraddress,',','.'),3)As OwnerSplitAddress,
parsename(replace(owneraddress,',','.'),2)As OwnerSplitCity,
parsename(replace(owneraddress,',','.'),1)As OwnerSplitState
from [HousingData].[dbo].[Nashville];

alter table [HousingData].[dbo].[Nashville]
add OwnerSplitAddress Nvarchar(255);


update [HousingData].[dbo].[Nashville] set
OwnerSplitAddress =parsename(replace(owneraddress,',','.'),3);
update [HousingData].[dbo].[Nashville] set
OwnerSplitCity=parsename(replace(owneraddress,',','.'),2);
update [HousingData].[dbo].[Nashville] set
OwnerSplitState=parsename(replace(owneraddress,',','.'),1);

alter table [HousingData].[dbo].[Nashville]
alter column OwnerSplitState nvarchar(255);

alter table [HousingData].[dbo].[Nashville]
alter column OwnerSplitState nvarchar(255);


select owneraddress, OwnerSplitAddress,OwnerSplitCity,OwnerSplitState from [HousingData].[dbo].[Nashville];

---------Change Y and N to Yes and No in column Sold or vacant

Select distinct (Soldasvacant), count(Soldasvacant)
from [HousingData].[dbo].[Nashville]
group by Soldasvacant
order by 2;


select Soldasvacant,
case when soldasvacant='Y' Then 'Yes'
     when soldasvacant='N' Then 'No'
	 else Soldasvacant
End
from [HousingData].[dbo].[Nashville]
where Soldasvacant='Y';

update [HousingData].[dbo].[Nashville] set
Soldasvacant=case when soldasvacant='Y' Then 'Yes'
     when soldasvacant='N' Then 'No'
	 else Soldasvacant
End;


-------------------Remove Duplicates
with RowNumcte as (
select *,
row_number() over
(Partition by  parcelID,
               propertyaddress,
			   saleprice,
			   saledate,
			   legalreference
			   order by 
			   uniqueid) as Row_num
from [HousingData].[dbo].[Nashville]
--where Row_num =2
--order by parcelid
)
select * from RowNumcte
where Row_num>1;




with RowNumcte as (
select *,
row_number() over
(Partition by  parcelID,
               propertyaddress,
			   saleprice,
			   saledate,
			   legalreference
			   order by 
			   uniqueid) as Row_num
from [HousingData].[dbo].[Nashville]
--where Row_num =2
--order by parcelid
)
delete from RowNumcte
where Row_num>1;

-----Delete unwanted columns


alter table [HousingData].[dbo].[Nashville]
drop column owneraddress, taxdistrict, propertyaddress,Saledate;
