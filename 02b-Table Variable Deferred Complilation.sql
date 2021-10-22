/**************************************************************************************************
- Table Variable Deffered Compilataion Demo
***************************************************************************************************/

--------------------------------------------------------------------------------------------------
-- Step 1: Create the stored procedure to use a table variable. 
--------------------------------------------------------------------------------------------------
USE WideWorldImporters
GO
CREATE or ALTER PROCEDURE [Sales].[CustomerProfits]
AS
BEGIN
-- Declare the table variable
DECLARE @ilines TABLE
(	[InvoiceLineID] [int] NOT NULL primary key,
	[InvoiceID] [int] NOT NULL,
	[StockItemID] [int] NOT NULL,
	[Description] [nvarchar](100) NOT NULL,
	[PackageTypeID] [int] NOT NULL,
	[Quantity] [int] NOT NULL,
	[UnitPrice] [decimal](18, 2) NULL,
	[TaxRate] [decimal](18, 3) NOT NULL,
	[TaxAmount] [decimal](18, 2) NOT NULL,
	[LineProfit] [decimal](18, 2) NOT NULL,
	[ExtendedPrice] [decimal](18, 2) NOT NULL,
	[LastEditedBy] [int] NOT NULL,
	[LastEditedWhen] [datetime2](7) NOT NULL
)
-- Insert all the rows from InvoiceLines into the table variable
INSERT INTO @ilines SELECT * FROM Sales.InvoiceLines

-- Find my total profile by customer
SELECT TOP 1 COUNT(i.CustomerID) as customer_count, SUM(il.LineProfit) as total_profit
FROM Sales.Invoices i
INNER JOIN @ilines il
ON i.InvoiceID = il.InvoiceID
GROUP By i.CustomerID
END
GO

--------------------------------------------------------------------------------------------------
-- Step 2: Set to a lower compat
--------------------------------------------------------------------------------------------------


USE MASTER
GO
ALTER DATABASE WideWorldImporters SET compatibility_level = 130
GO

--------------------------------------------------------------------------------------------------
-- Step 3: Run the stored procedure under dbcompat = 130
--------------------------------------------------------------------------------------------------

USE WideWorldImporters
GO

EXEC [Sales].[CustomerProfits]


GO
--------------------------------------------------------------------------------------------------
-- Step 4: Run the stored procedure under dbcompat = 130
--------------------------------------------------------------------------------------------------
USE master
GO
ALTER DATABASE wideworldimporters SET compatibility_level = 150
GO
USE WideWorldImporters
GO

EXEC [Sales].[CustomerProfits]
--GO 25

GO

