# Airport Ticketing System — SQL Project

This is a full-featured relational database system designed for a real-world airport ticketing process. It was built using T-SQL and implemented in Microsoft SQL Server Management Studio (SSMS), applying best practices in normalization, data integrity, security, and concurrency.

## Features

-  Normalized to 3NF
-  Custom views, stored procedures, triggers, and user-defined functions
-  Sample test queries using JOINs and subqueries
-  Data integrity constraints and security considerations
-  Backup and recovery strategy

## Files

| File | Description |
|------|-------------|
| `01_CreateTables.sql` | Table creation script with constraints |
| `02_InsertData.sql` | Sample data insertions |
| `03_Views_Triggers_Functions.sql` | Extra credit objects (views, UDFs, triggers) |
| `04_TestQueries.sql` | Business logic test queries |
| `Full_Project_Report.docx` | Written report with explanation for each section |

## Sample Query

```sql
-- Get UK customers with order amount between £500 and £1000
SELECT c.name, c.country
FROM Customers c
...

Tools Used
SQL Server Management Studio (SSMS)

Microsoft SQL Server

Excel/CSV for data preprocessing