DECLARE @RangeSize INT = 400; -- Example range size

WITH CostRanges AS (
    -- Step 1: Find the minimum and maximum StandardCost
    SELECT 
        CAST(MIN(StandardCost) AS INT) AS MinCost,
        CAST(MAX(StandardCost) AS INT) AS MaxCost
    FROM CompanyX.Production.Product
),
RangeCTE AS (
    -- Step 2: Generate ranges using a recursive CTE
    SELECT 
        CAST(MinCost AS INT) AS RangeStart,
        -- The first range should end at MinCost + RangeSize unless that exceeds MaxCost
        CASE 
            WHEN MinCost + @RangeSize > MaxCost THEN MaxCost
            ELSE CAST(MinCost + @RangeSize AS INT)
        END AS RangeEnd
    FROM CostRanges
    UNION ALL
    SELECT 
        CAST(RangeEnd AS INT) AS RangeStart,
        -- Generate next range, ensuring the final range ends at MaxCost
        CASE 
            WHEN RangeEnd + @RangeSize > (SELECT MaxCost FROM CostRanges) 
            THEN (SELECT MaxCost FROM CostRanges)
            ELSE CAST(RangeEnd + @RangeSize AS INT)
        END AS RangeEnd
    FROM RangeCTE
    WHERE RangeEnd < (SELECT MaxCost FROM CostRanges)
),
RangeStats AS (
    -- Step 3: Calculate average StandardCost within each range
    SELECT 
        r.RangeStart,
        r.RangeEnd,
        AVG(p.StandardCost) AS RangeAverage,
        COUNT(p.StandardCost) AS RecordCount
    FROM RangeCTE r
    LEFT JOIN CompanyX.Production.Product p
        ON CAST(p.StandardCost AS INT) >= r.RangeStart AND CAST(p.StandardCost AS INT) <= r.RangeEnd -- Use <= for the last range
    GROUP BY r.RangeStart, r.RangeEnd
)
-- Step 4: Calculate average difference from the range average
SELECT 
    rs.RangeStart,
    rs.RangeEnd,
    rs.RecordCount,
    AVG(ABS(CAST(p.StandardCost AS INT) - rs.RangeAverage)) AS AvgDifference -- Average of differences from range average
FROM RangeStats rs
LEFT JOIN CompanyX.Production.Product p
    ON CAST(p.StandardCost AS INT) >= rs.RangeStart AND CAST(p.StandardCost AS INT) <= rs.RangeEnd -- Include the upper bound of each range
GROUP BY rs.RangeStart, rs.RangeEnd, rs.RangeAverage, RecordCount
ORDER BY rs.RangeStart
OPTION (MAXRECURSION 0); -- Allow unlimited recursion depth
