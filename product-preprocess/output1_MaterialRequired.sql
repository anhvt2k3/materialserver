-- A table to show the material requirements of a Product manufactering process
with c as
( select 
	b.ProductAssemblyID,
	b.ComponentID,
	p.Name,
	SUM(PerAssemblyQty) as Qty
from CompanyX.Production.BillOfMaterials b left join CompanyX.Production.Product p on b.ComponentID = p.ProductID
group by b.ProductAssemblyID, b.ComponentID, p.Name )

select 
	c.ProductAssemblyID,
	p.Name as ProductName,
	case when c.ProductAssemblyID in (select ProductAssemblyID from CompanyX.Production.BillOfMaterials)
		then 1 else 0 end
		as MadeOfComponents,

	c.ComponentID,
	c.Name as ComponentName,
	c.Qty
from 
	c left join CompanyX.Production.Product p on c.ProductAssemblyID = p.ProductID
--where c.ProductAssemblyID = null
order by ProductAssemblyID