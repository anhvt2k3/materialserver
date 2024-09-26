SELECT [BillOfMaterialsID]
      ,[ProductAssemblyID]
      ,[ComponentID]
      ,[StartDate]
      ,[EndDate]
      ,[UnitMeasureCode]
      ,[BOMLevel]
      ,[PerAssemblyQty]
      ,[ModifiedDate]
  FROM [CompanyX].[Production].[BillOfMaterials] 
  --where ProductAssemblyID = 477
  order by ProductAssemblyID
