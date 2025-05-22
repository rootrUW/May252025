----------------------------------------------------------------------
-- Title: Assignment01
-- Desc: Creating a normalized database from sample data
-- Author: RRoot
-- ChangeLog: (When,Who,What)
-- 9/21/2021,RRoot,Created Script
----------------------------------------------------------------------

--[ Create the Database ]--
--********************************************************************--
Use Master;
go
If exists (Select * From sysdatabases Where name='Assignment01DB_RRoot')
  Begin
  	Use [master];
	  Alter Database Assignment01DB_RRoot Set Single_User With Rollback Immediate; -- Kick everyone out of the DB
		Drop Database Assignment01DB_RRoot;
  End
go
Create Database Assignment01DB_RRoot;
go
Use Assignment01DB_RRoot
go

--[ Create the Tables ]--
--********************************************************************--

/* TODO: Create Multiple tables to hold the following data
Products,Price,Units,Customer,Address,Date
Apples,$0.89,12,Bob Smith,123 Main Bellevue Wa,5/5/2006 
Milk,$1.59,2,Bob Smith,123 Main Bellevue Wa,5/5/2006 
Bread,$2.28,1,Bob Smith,123 Main Bellevue Wa,5/5/2006
*/

Create Table dbo.Products(
 ProductId int Primary Key Not Null, --PK
 ProductName varchar(50) Not Null,
 ProductCurrentPrice Money Null
);
go

Create Table dbo.Customers(
 CustomerId int Primary Key Not Null, --PK 
 CustomerFirstName varchar(50) Not Null,
 CustomerLastName varchar(50) Not Null,
 CustomerAddress varchar(50) Not Null,
 CustomerCity varchar(50) Not Null,
 CustomerState varchar(50) Not Null,
);
go

Create Table dbo.Sales(
 SalesId int Primary Key Not Null, --PK 
 SalesDate date Not Null,
 CustomerId int Not Null, --FK
);
go

Create Table dbo.SalesDetails(
 SalesId int Not Null, --PK
 SalesLineId int Not Null, --PK
 ProductId int Not Null, --FK
 SalesPrice money Not Null,
 SalesUnits int Not Null,
 Primary Key(SalesId, SalesLineId) 
);
go 


-- TODO: Insert the provided data to test your design
Insert Into Products (
  ProductId
, ProductName
, ProductCurrentPrice ) 
Values 
 (1, 'Apples',0.89 )
,(2, 'Milk',1.59)
,(3, 'Bread', 2.26);
go

Insert Into Customers(
  CustomerId 
, CustomerFirstName
, CustomerLastName 
, CustomerAddress 
, CustomerCity 
, CustomerState)
Values
 (1,'Bob','Smith', '123 Main','Bellevue','Wa')
;
go

Insert Into Sales(
  SalesId 
, SalesDate 
, CustomerId) 
Values
 (1, '5/5/2006', 1)
go

Insert Into SalesDetails(
  SalesId 
, SalesLineId 
, ProductId 
, SalesPrice
, SalesUnits)
Values 
 (1,1,1,0.89,12)
,(1,2,2,1.59,2)
,(1,3,3,2.28,1)
;
go 


--[ Review the design ]--
--********************************************************************--
-- Note: This is advanced code and it is not expected that you should be able to read it yet. 
-- However, you will be able to by the end of the course! :-)
-- Meta Data Query:
With 
TablesAndColumns As (
Select  
  [SourceObjectName] = TABLE_CATALOG + '.' + TABLE_SCHEMA + '.' + TABLE_NAME + '.' + COLUMN_NAME
, [IS_NULLABLE]=[IS_NULLABLE]
, [DATA_TYPE] = Case [DATA_TYPE]
                When 'varchar' Then  [DATA_TYPE] + '(' + IIf(DATA_TYPE = 'int','', IsNull(Cast(CHARACTER_MAXIMUM_LENGTH as varchar(10)), '')) + ')'
                When 'nvarchar' Then [DATA_TYPE] + '(' + IIf(DATA_TYPE = 'int','', IsNull(Cast(CHARACTER_MAXIMUM_LENGTH as varchar(10)), '')) + ')'
                When 'money' Then [DATA_TYPE] + '(' + Cast(NUMERIC_PRECISION as varchar(10)) + ',' + Cast(NUMERIC_SCALE as varchar(10)) + ')'
                When 'decimal' Then [DATA_TYPE] + '(' + Cast(NUMERIC_PRECISION as varchar(10)) + ',' + Cast(NUMERIC_SCALE as varchar(10)) + ')'
                When 'float' Then [DATA_TYPE] + '(' + Cast(NUMERIC_PRECISION as varchar(10)) + ',' + Cast(NUMERIC_SCALE as varchar(10)) + ')'
                Else [DATA_TYPE]
                End                          
, [TABLE_NAME]
, [COLUMN_NAME]
, [ORDINAL_POSITION]
, [COLUMN_DEFAULT]
From Information_Schema.columns 
),
Constraints As (
Select 
 [SourceObjectName] = TABLE_CATALOG + '.' + TABLE_SCHEMA + '.' + TABLE_NAME + '.' + COLUMN_NAME
,[CONSTRAINT_NAME]
From [INFORMATION_SCHEMA].[CONSTRAINT_COLUMN_USAGE]
), 
IdentityColumns As (
Select 
 [ObjectName] = object_name(c.[object_id]) 
,[ColumnName] = c.[name]
,[IsIdentity] = IIF(is_identity = 1, 'Identity', Null)
From sys.columns as c Join Sys.tables as t on c.object_id = t.object_id
) 
Select 
  TablesAndColumns.[SourceObjectName]
, [IsNullable] = [Is_Nullable]
, [DataType] = [Data_Type] 
, [ConstraintName] = IsNull([CONSTRAINT_NAME], 'NA')
, [COLUMN_DEFAULT] = IsNull(IIF([IsIdentity] Is Not Null, 'Identity', [COLUMN_DEFAULT]), 'NA')
--, [ORDINAL_POSITION]
From TablesAndColumns 
Full Join Constraints On TablesAndColumns.[SourceObjectName]= Constraints.[SourceObjectName]
Full Join IdentityColumns On TablesAndColumns.COLUMN_NAME = IdentityColumns.[ColumnName]
Where [TABLE_NAME] Not In (Select [TABLE_NAME] From [INFORMATION_SCHEMA].[VIEWS])
Order By [TABLE_NAME],[ORDINAL_POSITION]

