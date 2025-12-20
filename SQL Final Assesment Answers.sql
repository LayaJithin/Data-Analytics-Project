USE ecomm;
drop table customer_churn;
Select * from customer_churn;

## Imputed WarehouseToHome

UPDATE customer_churn
JOIN (
    SELECT ROUND(AVG(WarehouseToHome)) AS avg_value
    FROM customer_churn
    WHERE WarehouseToHome IS NOT NULL
) AS avg_table
SET customer_churn.WarehouseToHome = avg_table.avg_value
WHERE customer_churn.WarehouseToHome IS NULL;

## Imputed HourSpendOnApp

UPDATE customer_churn
JOIN (
    SELECT ROUND(AVG(HourSpendOnApp)) AS avg_value
    FROM customer_churn
    WHERE HourSpendOnApp IS NOT NULL
) AS avg_table
SET customer_churn.HourSpendOnApp = avg_table.avg_value
WHERE customer_churn.HourSpendOnApp IS NULL;

## OrderAmountHikeFromlastYear

UPDATE customer_churn
JOIN (
    SELECT ROUND(AVG(OrderAmountHikeFromlastYear)) AS avg_value
    FROM customer_churn
    WHERE OrderAmountHikeFromlastYear IS NOT NULL
) AS avg_table
SET customer_churn.OrderAmountHikeFromlastYear = avg_table.avg_value
WHERE customer_churn.OrderAmountHikeFromlastYear IS NULL;

##Imputed  DaySinceLastOrder

UPDATE customer_churn
JOIN (
    SELECT ROUND(AVG(DaySinceLastOrder)) AS avg_value
    FROM customer_churn
    WHERE DaySinceLastOrder IS NOT NULL
) AS avg_table
SET customer_churn.DaySinceLastOrder = avg_table.avg_value
WHERE customer_churn.DaySinceLastOrder IS NULL;

## Imputed Tenure
    
UPDATE customer_churn
JOIN (
    SELECT Tenure AS mode_value
    FROM customer_churn
    WHERE Tenure IS NOT NULL
    GROUP BY Tenure
    ORDER BY COUNT(*) DESC
    LIMIT 1
) AS mod_table
SET customer_churn.Tenure = mod_table.mode_value
WHERE customer_churn.Tenure IS NULL;

# Imputed CouponUsed 

UPDATE customer_churn
JOIN (
    SELECT CouponUsed  AS mode_value
    FROM customer_churn
    WHERE CouponUsed  IS NOT NULL
    GROUP BY CouponUsed 
    ORDER BY COUNT(*) DESC
    LIMIT 1
) AS mod_table
SET customer_churn.CouponUsed  = mod_table.mode_value
WHERE customer_churn.CouponUsed IS NULL;

## Imputed OrderCount

UPDATE customer_churn
JOIN (
    SELECT OrderCount AS mode_value
    FROM customer_churn
    WHERE OrderCount IS NOT NULL
    GROUP BY OrderCount
    ORDER BY COUNT(*) DESC
    LIMIT 1
) AS mod_table
SET customer_churn.OrderCount = mod_table.mode_value
WHERE customer_churn.OrderCount IS NULL;

## Handle outliers in WarehouseToHome

DELETE FROM customer_churn
WHERE WarehouseToHome > 100;

## Dealing with Inconsistency

UPDATE customer_churn
SET PreferredLoginDevice="Mobile Phone"
WHERE PreferredLoginDevice ="Phone";

UPDATE customer_churn
SET PreferedOrderCat="Mobile Phone"
WHERE PreferedOrderCat ="Mobile";

## Standardize payment mode values

UPDATE customer_churn
SET PreferredPaymentMode="Cash on Delivery"
WHERE PreferredPaymentMode ="COD";

UPDATE customer_churn
SET PreferredPaymentMode="Credit Card"
WHERE PreferredPaymentMode ="CC";

## Data Transformation 1.Column Renaming

ALTER TABLE customer_churn RENAME COLUMN PreferedOrderCat TO PreferredOrderCat;

ALTER TABLE  customer_churn RENAME COLUMN HourSpendOnApp TO HourSpentOnApp;

## 2.creating new Columns
Select * from customer_churn;

ALTER TABLE customer_churn ADD ComplaintReceived varchar(5);
UPDATE customer_churn SET ComplaintReceived="Yes" WHERE Complain=1;
UPDATE customer_churn SET ComplaintReceived="No" WHERE Complain=0;

ALTER TABLE customer_churn ADD ChurnStatus varchar(10);
UPDATE customer_churn SET ChurnStatus="Churned" WHERE Churn=1;
UPDATE customer_churn SET ChurnStatus="Active" WHERE Churn=0;

## 3.Dropping Columns

ALTER TABLE customer_churn DROP Churn;
ALTER TABLE customer_churn DROP Complain;

## Data Exploration and Analysis


SELECT * from customer_churn;
desc customer_churn;

SELECT ChurnStatus,count(*) AS CountofChurnStatus FROM customer_churn GROUP BY ChurnStatus ORDER BY count(*);

SELECT AVG(Tenure) AS AverageTenure,SUM(CashbackAmount) AS CashbackAmountofCustomers FROM customer_Churn WHERE ChurnStatus="Churned";

SELECT 
  ROUND(
    (SELECT COUNT(*) FROM customer_churn WHERE ComplaintReceived = 'YES') * 100.0 /
    (SELECT COUNT(*) FROM customer_churn),
    2
  ) AS PercentageComplaintChurn;
  
  SELECT count(*)as HighestNumber,CityTier FROM customer_churn WHERE ChurnStatus="Churned" 
  AND PreferredOrderCat ="Laptop & Accessory"
  GROUP BY ChurnStatus, CityTier 
  ORDER BY Count(*) DESC
  LIMIT 1;
  
  SELECT PreferredPaymentMode FROM customer_churn WHERE ChurnStatus="Active"
  GROUP BY PreferredPaymentMode
  ORDER BY count(*) DESC
  LIMIT 1;
  
  SELECT SUM(OrderAmountHikeFromlastYear) AS TotalOrderAmount 
  FROM customer_churn WHERE MaritalStatus="Single" 
  AND PreferredLoginDevice="Mobile Phone";
  
  SELECT AVG(NumberOfDeviceRegistered)AS AveragenoofDeviceRegistered FROM customer_churn 
  WHERE PreferredPaymentMode="UPI";
  
    
  SELECT CityTier,count(*)as CountofCustomer FROM customer_churn 
  GROUP BY CityTier 
  ORDER BY Count(*) DESC
  LIMIT 1;
  
  SELECT Gender,Count(*) AS CountofCoupons FROM customer_churn 
  GROUP BY CouponUsed,Gender 
  ORDER BY count(*)
  LIMIT 1;
  
  SELECT PreferredOrderCat, Count(CustomerID)  AS NumberofCustomer 
  FROM customer_churn 
  GROUP BY PreferredOrderCat
  HAVING Max(HourSpentOnApp);
  
  SELECT AVG(SatisfactionScore) AS AverageSatisfactionScore FROM customer_churn WHERE ComplaintReceived ="Yes";
  
  SELECT PreferredOrderCat FROM customer_churn Where CouponUsed >5 GROUP BY PreferredOrderCat;
  
  SELECT PreferredOrderCat FROM customer_churn GROUP BY PreferredOrderCat
  HAVING AVG(CashbackAmount)
  ORDER BY COUNT(*) 
  LIMIT 3;
  
SELECT PreferredPaymentMode FROM customer_churn  WHERE OrderCount >500
GROUP BY PreferredPaymentMode 
HAVING ROUND(AVG(Tenure))=10 ;


SELECT 
  CASE
    WHEN WarehouseToHome <= 5 THEN 'Very Close Distance'
    WHEN WarehouseToHome <= 10 THEN 'Close Distance'
    WHEN WarehouseToHome <= 15 THEN 'Moderate Distance'
    ELSE 'Far Distance'
  END AS DistanceCategory,
  ChurnStatus,
  COUNT(*) AS TotalCustomers
FROM customer_churn
GROUP BY DistanceCategory, ChurnStatus
ORDER BY DistanceCategory, ChurnStatus;

SELECT CustomerID,PreferredPaymentMode,PreferredOrderCat,OrderCount FROM customer_churn WHERE MaritalStatus="Married"AND CityTier=1 AND OrderCount>
(SELECT AVG(OrderCount) FROM customer_churn); 

create table customer_returns
(
  ReturnID int PRIMARY KEY,
  CustomerID int,
  ReturnDate date,
  RefundAmount int,
  FOREIGN KEY (CustomerID) references customer_churn(CustomerID)
  );
  
INSERT INTO customer_returns (ReturnID, CustomerID, ReturnDate, RefundAmount)
VALUES
(1001,50022,'2023-01-01',2130),
 (1002,50316,'2023-01-23',2000), 
(1003,51099,'2023-02-14',2290), 
(1004,52321,'2023-03-08',2510),
(1005,52928,'2023-03-20',3000),
(1006, 53749, '2023-04-17', 1740),
(1007, 54206, '2023-04-21', 3250),
(1008, 54838, '2023-04-30', 1990);
  
  
SELECT r.ReturnID,r.CustomerID,r.ReturnDate,r.RefundAmount,c.PreferredPaymentMode,
c.Gender,c.CityTier,c.PreferredLoginDevice,c.MaritalStatus,c.PreferredOrderCat
FROM customer_returns AS r
LEFT JOIN customer_churn AS c 
ON r.CustomerID=c.CustomerID
WHERE c.CustomerID IN (
    SELECT CustomerID 
    FROM customer_churn 
    WHERE ComplaintReceived = 'Yes' AND ChurnStatus = 'Churned');

  
  
  
  