DECLARE @RangeSize INT = 600; -- Example range size

WITH PriceRanges AS (
    -- Step 1: Find the minimum and maximum ListPrice
    SELECT 
        CAST(MIN(ListPrice) AS INT) AS MinPrice,
        CAST(MAX(ListPrice) AS INT) AS MaxPrice
    FROM CompanyX.Production.Product
),
RangeCTE AS (
    -- Step 2: Generate ranges using a recursive CTE
    SELECT 
        CAST(MinPrice AS INT) AS RangeStart,
        -- The first range should end at MinPrice + RangeSize unless that exceeds MaxPrice
        CASE 
            WHEN MinPrice + @RangeSize > MaxPrice THEN MaxPrice
            ELSE CAST(MinPrice + @RangeSize AS INT)
        END AS RangeEnd
    FROM PriceRanges
    UNION ALL
    SELECT 
        CAST(RangeEnd AS INT) AS RangeStart,
        -- Generate next range, ensuring the final range ends at MaxPrice
        CASE 
            WHEN RangeEnd + @RangeSize > (SELECT MaxPrice FROM PriceRanges) 
            THEN (SELECT MaxPrice FROM PriceRanges)
            ELSE CAST(RangeEnd + @RangeSize AS INT)
        END AS RangeEnd
    FROM RangeCTE
    WHERE RangeEnd < (SELECT MaxPrice FROM PriceRanges)
),
RangeStats AS (
    -- Step 3: Calculate average ListPrice within each range
    SELECT 
        r.RangeStart,
        r.RangeEnd,
        AVG(p.ListPrice) AS RangeAverage,
        COUNT(p.ListPrice) AS RecordCount
    FROM RangeCTE r
    LEFT JOIN CompanyX.Production.Product p
        ON CAST(p.ListPrice AS INT) >= r.RangeStart AND CAST(p.ListPrice AS INT) <= r.RangeEnd -- Use <= for the last range
    GROUP BY r.RangeStart, r.RangeEnd
)
-- Step 4: Calculate average difference from the range average
SELECT 
    rs.RangeStart,
    rs.RangeEnd,
    rs.RecordCount,
    AVG(ABS(CAST(p.ListPrice AS INT) - rs.RangeAverage)) AS AvgDifference -- Average of differences from range average
FROM RangeStats rs
LEFT JOIN CompanyX.Production.Product p
    ON CAST(p.ListPrice AS INT) >= rs.RangeStart AND CAST(p.ListPrice AS INT) <= rs.RangeEnd -- Include the upper bound of each range
GROUP BY rs.RangeStart, rs.RangeEnd, rs.RangeAverage, RecordCount
ORDER BY rs.RangeStart
OPTION (MAXRECURSION 0); -- Allow unlimited recursion depth
