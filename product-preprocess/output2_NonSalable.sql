select
	p.ProductID,
	p.Name
from 
	( select p.ProductID, p.Name from CompanyX.Production.Product p full join CompanyX.Production.BillOfMaterials b
		on p.ProductID = b.ProductAssemblyID 
		where p.ProductID is null 
		) p

select *
from ( select * from CompanyX.Production.BillOfMaterials where ProductAssemblyID is null ) b
		join CompanyX.Production.Product p on b.ComponentID = p.ProductID

select *
from ( select * from CompanyX.Production.BillOfMaterials where ProductAssemblyID is null ) b
		join CompanyX.Production.BillOfMaterials bb on b.ComponentID = bb.ComponentID
where bb.ProductAssemblyID is not null