

---Which products achieved their production targets most effectively?

SELECT
    Product,
    SUM(Planned_Units) AS Total_Planned_Units,
    SUM(Actual_Units) AS Total_Actual_Units,
    SUM(Actual_Units) - SUM(Planned_Units)
        AS Production_Gap_Units,
    CAST(
        100.0 * SUM(Actual_Units)
        / NULLIF(SUM(Planned_Units), 0)
        AS DECIMAL(10, 2)
    ) AS Achievement_Pct
FROM dbo.vw_CleanProduction
WHERE Planned_Units IS NOT NULL
  AND Actual_Units IS NOT NULL
GROUP BY Product
ORDER BY Achievement_Pct DESC;


--Records where actual production was below planned production

SELECT
    Production_ID,
    Production_Date,
    Product,
    Production_Line,
    Shift,
    Planned_Units,
    Actual_Units,
    Actual_Units - Planned_Units AS Production_Gap_Units
FROM dbo.vw_CleanProduction
WHERE Planned_Units IS NOT NULL
  AND Actual_Units IS NOT NULL
  AND Actual_Units < Planned_Units
ORDER BY Production_Gap_Units ASC;


--Which production lines have the highest defect rates?

SELECT
    Production_Line,
    SUM(Actual_Units) AS Total_Actual_Units,
    SUM(Defective_Units) AS Total_Defective_Units,
    CAST(
        100.0 * SUM(Defective_Units)
        / NULLIF(SUM(Actual_Units), 0)
        AS DECIMAL(10, 2)
    ) AS Defect_Rate_Pct
FROM dbo.vw_CleanProduction
WHERE Actual_Units IS NOT NULL
  AND Defective_Units IS NOT NULL
  AND Actual_Units > 0
  AND Defective_Units >= 0
  AND Defective_Units <= Actual_Units
GROUP BY Production_Line
ORDER BY Defect_Rate_Pct DESC;


--Which shifts recorded the most downtime?

SELECT
    Shift,
    SUM(Downtime_Minutes) AS Total_Downtime_Minutes,
    COUNT(*) AS Production_Records
FROM dbo.vw_CleanProduction
WHERE Shift IS NOT NULL
  AND LTRIM(RTRIM(Shift)) <> ''
  AND Downtime_Minutes IS NOT NULL
  AND Downtime_Minutes >= 0
GROUP BY Shift
ORDER BY Total_Downtime_Minutes DESC;


-----Which products recorded material usage above or below their standards?

SELECT
    Product,
    SUM(Raw_Material_Used_kg)
        AS Total_Actual_Material_kg,
    SUM(Standard_Material_kg)
        AS Total_Standard_Material_kg,
    SUM(Raw_Material_Used_kg)
        - SUM(Standard_Material_kg)
        AS Material_Variance_kg
FROM dbo.vw_CleanProduction
WHERE Raw_Material_Used_kg IS NOT NULL
  AND Standard_Material_kg IS NOT NULL
  AND Raw_Material_Used_kg >= 0
  AND Standard_Material_kg >= 0
GROUP BY Product
ORDER BY Material_Variance_kg DESC;


---Which products account for the highest recorded production costs?

SELECT
    Product,
    SUM(Material_Cost_GHc) AS Total_Material_Cost,
    SUM(Labour_Cost_GHc) AS Total_Labour_Cost,
    SUM(Overhead_Cost_GHc) AS Total_Overhead_Cost,
    SUM(
        Material_Cost_GHc
        + Labour_Cost_GHc
        + Overhead_Cost_GHc
    ) AS Total_Recorded_Cost
FROM dbo.vw_CleanProduction
WHERE Material_Cost_GHc IS NOT NULL
  AND Labour_Cost_GHc IS NOT NULL
  AND Overhead_Cost_GHc IS NOT NULL
GROUP BY Product
ORDER BY Total_Recorded_Cost DESC;


------Overall Production Achievement

SELECT
    SUM(Planned_Units) AS Total_Planned_Units,
    SUM(Actual_Units) AS Total_Actual_Units,
    SUM(Actual_Units) - SUM(Planned_Units)
        AS Production_Gap_Units,
    CAST(
        100.0 * SUM(Actual_Units)
        / NULLIF(SUM(Planned_Units), 0)
        AS DECIMAL(10, 2)
    ) AS Overall_Achievement_Pct
FROM dbo.vw_CleanProduction
WHERE Planned_Units IS NOT NULL
  AND Actual_Units IS NOT NULL;