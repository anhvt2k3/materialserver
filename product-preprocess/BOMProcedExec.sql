USE [CompanyX]
GO

DECLARE	@return_value int

EXEC	@return_value = [dbo].[uspGetBillOfMaterials]
		@StartProductID = 808,
		@CheckDate = N'2010-08-08 00:00:00.000'

SELECT	'Return Value' = @return_value

GO
