# Data Decisions Log

This log records the genuine analytical and ETL decision points made during the project. Each entry documents the alternatives considered, the decision made, and the reasoning.

## Analytical & Modelling Decisions

| # | Decision Point | Alternatives Considered | Decision Made | Reason |
|---|----------------|------------------------|---------------|--------|
| 1 | Data model design | Single fact table vs galaxy schema | Galaxy schema with two fact tables | A single fact table would repeat total generation 5–6× per country-year and overcount if summed. Galaxy schema prevents this. |
| 2 | Australian financial year | Start-year vs end-year convention | End-year (FY 2023-24 = 2024) | Most of FY 2023-24 falls in calendar 2024. Aligns Australia with calendar-year countries. |
| 3 | China data source | Official NBS vs OWID / IEA | OWID drawing on IEA | NBS data not freely available in English. Data chain: NBS → IEA → OWID. |
| 4 | Germany data format | Excel vs PDF extraction | PDF (AGEE-Stat official) | No Excel version available; values extracted manually from the government PDF. |
| 5 | Source category structure | Keep raw sub-sources vs combine into 5 groups | Combine into 5 via `Source_Group` | Enables fair cross-country comparison; raw values preserved in the fact table. |
| 6 | China geothermal | Include small OWID values vs set to zero | Set to zero | Yangbajain plant ceased 2020; capacity negligible and not separately reported. |
| 7 | Display units | Keep GWh vs convert to TWh | Store GWh, convert to TWh via DAX | Preserves raw integrity; TWh is more readable for a government audience. |
| 8 | Forecast method | Power BI built-in vs R linear regression | R linear regression | R shows the equation, R², p-value, and 95% interval on the chart — more transparent. |
| 9 | Forecast data range | 2005–2024 vs 2015–2024 | Full 2005–2024 | More data points give a stronger model; the conservative bias is acknowledged. |
| 10 | Number of forecast charts | One vs two | Two (TWh and Share %) | TWh answers the volume question; Share % directly addresses the 82% target. |
| 11 | Q2 chart type | Stacked column over time vs clustered 2005 vs 2024 | Clustered column 2005 vs 2024 | Section 2.1 already shows the time trend; the snapshot shows source make-up clearly. |
| 12 | Q3 comparison measure | Volume only vs share only vs both | Both | Volume alone misleads due to country size; share alone loses scale. Both give the full picture. |
| 13 | Q1 reference line year | 2011 vs 2015 vs both | Both 2011 and 2015 | 2011 marks the LRET split; 2015 marks the policy confirmation behind the major acceleration. |
| 14 | NZ net vs gross | Treat as equivalent vs acknowledge | Acknowledged as minor limitation | Difference is typically <2% at annual level; not material but noted. |
| 15 | Slicer scope | Global vs restricted slicers | Year slicer → Q3 only; Source slicer → Q2 only | Filtering Q1/Q4 would break their time-trend story. |

## Source Category Combinations

| Country | Raw Sub-sources | Combined Into | Reason |
|---------|----------------|---------------|--------|
| Australia | Large-scale + Small-scale Solar PV | Solar | Show total solar consistently across countries |
| Australia | Bagasse/Wood, Biogas | Biomass | Match the five-category structure |
| New Zealand | Wood, Biogas | Biomass | Match the five-category structure |
| Germany | Onshore + Offshore Wind | Wind | Match single Wind category |
| Germany | Solid biomass, biogas, biomethane, sewage gas, landfill gas, biogenic waste | Biomass | Match the five-category structure |
| China | Geothermal | Set to zero | Negligible capacity; not separately reported by OWID |
