USE AdventureWorks2022;
GO

SELECT TOP 10 * FROM Production.Product
where listprice is not null and weight is not null
