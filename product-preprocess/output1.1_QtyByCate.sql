with 
CateMappedProducts as 
(
	select p.ProductID, p.Name as ProductName, 
			sc.Name as SubcateName, 
			c.Name as CategoryName
	from CompanyX.Production.Product p
		left join CompanyX.Production.ProductSubcategory sc on p.ProductSubcategoryID = sc.ProductSubcategoryID
		left join CompanyX.Production.ProductCategory c on sc.ProductCategoryID = c.ProductCategoryID
),
CateCount as 
(
	select CateMappedProducts.CategoryName, count(1) as CategoryCount
	from CateMappedProducts
	group by CateMappedProducts.CategoryName
),
ComponentByCate as 
(
	select ProductID, ProductName from CateMappedProducts
	where CategoryName = 'Components'
),
ComponentByBOM as
(
	select 
		p.ProductID,
		p.Name,
		b.ProductAssemblyID as ComponentTo
	from CompanyX.Production.Product p 
		join CompanyX.Production.BillOfMaterials b on p.ProductID = b.ComponentID
	--where b.ProductAssemblyID is not null
	group by p.ProductID, p.Name, b.ProductAssemblyID
),
CateNBOMReconcile as
(
	select
		cp.ProductID as ComponentByBOM,
		cp.ProductName,
		cp.CategoryName,
		bp.ComponentTo
	from CateMappedProducts cp
		join ComponentByBOM bp on cp.ProductID = bp.ProductID
	group by cp.ProductID, cp.ProductName, cp.CategoryName, bp.ComponentTo
),
ComponentCompare as
(
	select
		cc.ProductID as Cate, 
		cb.ProductID as BOM,
		cb.Name
	from ComponentByCate cc full join ComponentByBOM cb on cc.ProductID = cb.ProductID
	group by cc.ProductID, cb.ProductID, cb.Name
),
Out as (select * from CateNBOMReconcile)
select 
	*
from Out
	--group by out.CategoryName
	--order by Cate, BOM
;