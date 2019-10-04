
-- Create a CTE
with basketpairs as 
(
SELECT 			
a.OrderID OrderIDA,
a.GenProductName ProductA,
b.GenProductName ProductB,
b.OrderID OrderIDB,
(SELECT COUNT(*) FROM [Test].[dbo].[ProductOrders] WHERE  GenProductName = a.GenProductName) ProductACount,
(SELECT COUNT(*) FROM [Test].[dbo].[ProductOrders] WHERE  GenProductName = b.GenProductName) ProductBCount
FROM [Test].[dbo].[ProductOrders] a join
[Test].[dbo].[ProductOrders] b
on a.OrderID=b.OrderID
where a.GenProductName != b.GenProductName
and a.GenProductName < b.GenProductName	
and a.GenProductName in (Select Top 10 GenProductName From  [Test].[dbo].[ProductOrders] T Group by GenProductName order by count(*) DESC, GenProductName ASC)
)
			
SELECT ProductA,
	ProductB,
	Occurences, 
	Support,
	Confidence,
	Lift FROM
	(
	Select ProductA,
	ProductB,
	Occurences,
	TotalOrders,
	CAST(Occurences AS float) / CAST(TotalOrders AS float) as Support, --support showcases the probability in favor of the event under analysis
	CAST(Occurences AS float) / CAST(ProductACount  AS float) as Confidence, --expresses the operational efficiency of the rule. It calculated as the ratio of the probability of occurrence of the favorable event to the probability of the occurrence of the antecedent
	(CAST(Occurences AS float) / CAST(ProductACount  AS float))/(CAST(ProductBCount AS float) / CAST(TotalOrders  AS float)) as Lift --lift ratio calculates the efficiency of the rule in finding consequences, compared to a random selection of transactions
	FROM 
	(
		SELECT 
		ProductA,
		ProductB,
		COUNT(OrderIDA) Occurences,
		(SELECT count(Distinct OrderIDA) from basketpairs) TotalOrders,
		ProductACount,
		ProductBCount
		--INTO #PBDetails
		FROM
		( 
			SELECT * from basketpairs
		) Temp 
		GROUP BY ProductA, ProductB, ProductACount, ProductBCount
	) MarketBasket 
) MarketBasketAnalysis 
-- result set to consider product pairs that meet the following conditions
-- where Support >= 0.2 and Confidence >= 0.6 and Lift > 1  -- Applying this where condition doesnot return me results and hence I have commented it. I need to work more on generalizing the product names
-- I added few approaches but nothing improved the Support. Many of my approaches are commented in the python 
--Sorted in the following order:
Order by support DESC,
ProductA ASC,
ProductB ASC

