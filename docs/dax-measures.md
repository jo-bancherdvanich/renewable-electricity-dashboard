# Key DAX Measures

All measures are stored in a dedicated `_Measures` table in Power BI Desktop, kept separate from the fact and dimension tables for clarity and maintainability.

```dax
-- Sums renewable electricity generation from all renewable sources
Renewable Generation GWh =
SUM(fact_RenewableGeneration[Generation_GWh])

-- Converts renewable electricity generation from GWh to TWh
Renewable Generation TWh =
DIVIDE([Renewable Generation GWh], 1000)

-- Sums total electricity generation for each country and year
Total Generation GWh =
SUM(fact_TotalGeneration[Total_Generation_GWh])

-- Converts total electricity generation from GWh to TWh
Total Generation TWh =
DIVIDE([Total Generation GWh], 1000)

-- Calculates electricity generated from non-renewable sources
Non-Renewable Generation GWh =
[Total Generation GWh] - [Renewable Generation GWh]

-- Converts non-renewable generation from GWh to TWh for cleaner dashboard display
Non-Renewable Generation TWh =
DIVIDE([Non-Renewable Generation GWh], 1000)

-- Calculates renewable electricity as a proportion of total electricity generation
Renewable Share % =
DIVIDE(
    [Renewable Generation GWh],
    [Total Generation GWh]
)

-- Calculates each renewable source as a share of total renewable generation
Renewable Source Mix % =
DIVIDE(
    [Renewable Generation GWh],
    CALCULATE(
        [Renewable Generation GWh],
        ALL(dim_EnergySource[Source_Group])
    )
)
```
