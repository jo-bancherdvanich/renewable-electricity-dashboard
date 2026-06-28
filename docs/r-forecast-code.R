# R Forecasting Code (Power BI R Script Visual)
#
# Two R linear-regression visuals were used in the Power BI dashboard to forecast
# Australia's renewable electricity to 2035: one for generation (TWh) and one for
# renewable share (%). R was chosen over Power BI built-in forecasting because it
# prints the regression equation, R-squared, p-value, and 95% prediction interval
# directly on the chart, making the method transparent and verifiable.
#
# Required fields in the Power BI R visual:
#   dim_Year[Year], dim_Country[Country], Renewable Generation TWh (from _Measures)
# Visual filter: Country = Australia
#
# Below is the generation (TWh) forecast. The share (%) forecast uses the same
# structure with the Renewable Share % measure in place of Renewable Generation TWh.

df <- dataset
# Clean column names
names(df) <- make.names(names(df), unique = TRUE)
# Find columns automatically
year_col <- grep("Year", names(df), value = TRUE)[1]
country_col <- grep("Country", names(df), value = TRUE)[1]
value_col <- grep("Renewable.*Generation.*TWh|Renewable.Generation.TWh|TWh", names(df), value = TRUE)[1]
# Keep only required columns
df <- df[, c(year_col, country_col, value_col)]
names(df) <- c("Year", "Country", "Renewable_TWh")
# Convert data types
df$Year <- as.numeric(as.character(df$Year))
df$Country <- as.character(df$Country)
df$Renewable_TWh <- as.numeric(gsub(",", "", as.character(df$Renewable_TWh)))
# Keep Australia only
aus <- df[df$Country == "Australia", ]
# Remove missing values
aus <- aus[!is.na(aus$Year) & !is.na(aus$Renewable_TWh), ]
# Aggregate in case Power BI sends duplicate rows
aus <- aggregate(Renewable_TWh ~ Year, data = aus, sum)
# Sort by year
aus <- aus[order(aus$Year), ]
# Forecast years
last_year <- max(aus$Year)
future_years <- data.frame(Year = (last_year + 1):2035)
# Create year index for simpler regression equation
aus$Year_Index <- aus$Year - min(aus$Year)
future_years$Year_Index <- future_years$Year - min(aus$Year)
# Linear trend model
model <- lm(Renewable_TWh ~ Year_Index, data = aus)
pred <- predict(model, newdata = future_years, interval = "prediction", level = 0.95)
# Model statistics
model_summary <- summary(model)
r_squared <- model_summary$r.squared
intercept <- coef(model)[1]
slope <- coef(model)[2]
p_value <- model_summary$coefficients["Year_Index", "Pr(>|t|)"]
p_label <- ifelse(
  p_value < 0.001,
  "p < 0.001",
  paste0("p = ", round(p_value, 3))
)
r2_label <- paste0("R² = ", round(r_squared, 3), ", ", p_label)
eq_label <- paste0("y = ", round(slope, 2), "x + ", round(intercept, 1))
# Forecast dataframe
forecast_data <- data.frame(
  Year = future_years$Year,
  Renewable_TWh = pred[, "fit"],
  Lower_95 = pred[, "lwr"],
  Upper_95 = pred[, "upr"],
  Type = "Forecast"
)
# Historical dataframe
historical_data <- data.frame(
  Year = aus$Year,
  Renewable_TWh = aus$Renewable_TWh,
  Lower_95 = NA,
  Upper_95 = NA,
  Type = "Historical"
)
library(ggplot2)
ggplot() +
  # Prediction interval
  geom_ribbon(
    data = forecast_data,
    aes(x = Year, ymin = Lower_95, ymax = Upper_95),
    fill = "#D62728",
    alpha = 0.16
  ) +
  # Historical line and points
  geom_line(
    data = historical_data,
    aes(x = Year, y = Renewable_TWh, colour = Type),
    linewidth = 1.4
  ) +
  geom_point(
    data = historical_data,
    aes(x = Year, y = Renewable_TWh, colour = Type),
    size = 2.6
  ) +
  # Forecast line and points
  geom_line(
    data = forecast_data,
    aes(x = Year, y = Renewable_TWh, colour = Type),
    linewidth = 1.4,
    linetype = "dashed"
  ) +
  geom_point(
    data = forecast_data,
    aes(x = Year, y = Renewable_TWh, colour = Type),
    size = 2.6
  ) +
  # Forecast label
  geom_text(
    data = tail(forecast_data, 1),
    aes(
      x = Year,
      y = Renewable_TWh,
      label = paste0(round(Renewable_TWh, 1), " TWh")
    ),
    hjust = 1.1,
    vjust = -0.6,
    size = 4.8,
    fontface = "bold",
    colour = "#D62728"
  ) +
  # R2 and p-value 
  annotate(
    "text",
    x = 2006,
    y = max(c(historical_data$Renewable_TWh, forecast_data$Upper_95), na.rm = TRUE) * 0.96,
    label = r2_label,
    hjust = 0,
    size = 5.8,
    colour = "navy"
  ) +
  # Regression formula 
  annotate(
    "text",
    x = 2006,
    y = max(c(historical_data$Renewable_TWh, forecast_data$Upper_95), na.rm = TRUE) * 0.84,
    label = eq_label,
    hjust = 0,
    size = 5.8,
    colour = "red"
  ) +
  # Manual colours
  scale_colour_manual(
    values = c(
      "Historical" = "#1F77B4",
      "Forecast" = "#D62728"
    )
  ) +
  # Axes
  scale_x_continuous(
    breaks = c(2005, 2010, 2015, 2020, 2025, 2030, 2035),
    limits = c(2005, 2036)
  ) +
  scale_y_continuous(
    limits = c(0, NA),
    expand = expansion(mult = c(0, 0.10))
  ) +

  labs(
    x = NULL,
    y = "Generation (TWh)",
    colour = NULL
  ) +

  theme_minimal(base_size = 14) +
  theme(
    legend.position = "top",
    legend.text = element_text(size = 15),
    axis.title.y = element_text(size = 13, face = "bold"),
    axis.text = element_text(size = 11, colour = "#555555"),
    panel.grid.minor = element_blank(),
    panel.grid.major.x = element_blank(),
    panel.grid.major.y = element_line(colour = "#D9E2F3", linewidth = 0.4),

    # background
    panel.background = element_rect(fill = "#F4F8FC", colour = NA),
    plot.background = element_rect(fill = "#F4F8FC", colour = NA),

    plot.margin = margin(8, 18, 8, 8)
  )
E2 - Renewable Share Forecast (%)
# Power BI creates the dataset automatically from the fields added to the R visual
# Required fields: Year, Country, Renewable Share %

df <- dataset

# Clean column names
names(df) <- make.names(names(df), unique = TRUE)

# Find columns automatically
year_col <- grep("Year", names(df), value = TRUE)[1]
country_col <- grep("Country", names(df), value = TRUE)[1]
share_col <- grep("Renewable.*Share|Share", names(df), value = TRUE)[1]

# Check missing columns
if (is.na(year_col)) stop("Year column not found. Add Year to the R visual.")
if (is.na(country_col)) stop("Country column not found. Add Country to the R visual.")
if (is.na(share_col)) stop("Renewable Share % column not found. Add Renewable Share % to the R visual.")

# Keep only required columns
df <- df[, c(year_col, country_col, share_col)]
names(df) <- c("Year", "Country", "Renewable_Share")

# Convert data types
df$Year <- as.numeric(as.character(df$Year))
df$Country <- as.character(df$Country)

# Convert share to numeric
df$Renewable_Share <- as.character(df$Renewable_Share)
df$Renewable_Share <- gsub("%", "", df$Renewable_Share)
df$Renewable_Share <- gsub(",", "", df$Renewable_Share)
df$Renewable_Share <- as.numeric(df$Renewable_Share)

# If Power BI sends share as decimal, convert to percentage
# Example: 0.35 becomes 35
if (max(df$Renewable_Share, na.rm = TRUE) <= 1) {
  df$Renewable_Share <- df$Renewable_Share * 100
}

# Keep Australia only
aus <- df[df$Country == "Australia", ]

# Remove missing values
aus <- aus[!is.na(aus$Year) & !is.na(aus$Renewable_Share), ]

# Aggregate in case Power BI sends duplicate rows
aus <- aggregate(Renewable_Share ~ Year, data = aus, mean)

# Sort by year
aus <- aus[order(aus$Year), ]

# Forecast years
last_year <- max(aus$Year)
future_years <- data.frame(Year = (last_year + 1):2035)

# Create year index for simpler regression equation
aus$Year_Index <- aus$Year - min(aus$Year)
future_years$Year_Index <- future_years$Year - min(aus$Year)

# Linear trend model
model <- lm(Renewable_Share ~ Year_Index, data = aus)
pred <- predict(model, newdata = future_years, interval = "prediction", level = 0.95)

# Model statistics
model_summary <- summary(model)
r_squared <- model_summary$r.squared
intercept <- coef(model)[1]
slope <- coef(model)[2]
p_value <- model_summary$coefficients["Year_Index", "Pr(>|t|)"]

p_label <- ifelse(
  p_value < 0.001,
  "p < 0.001",
  paste0("p = ", round(p_value, 3))
)

r2_label <- paste0("R² = ", round(r_squared, 3), ", ", p_label)
eq_label <- paste0("y = ", round(slope, 2), "x + ", round(intercept, 1))

# Forecast dataframe
forecast_data <- data.frame(
  Year = future_years$Year,
  Renewable_Share = pred[, "fit"],
  Lower_95 = pred[, "lwr"],
  Upper_95 = pred[, "upr"],
  Type = "Forecast"
)

# Historical dataframe
historical_data <- data.frame(
  Year = aus$Year,
  Renewable_Share = aus$Renewable_Share,
  Lower_95 = NA,
  Upper_95 = NA,
  Type = "Historical"
)

library(ggplot2)

ggplot() +
  # Prediction interval
  geom_ribbon(
    data = forecast_data,
    aes(x = Year, ymin = Lower_95, ymax = Upper_95),
    fill = "#D62728",
    alpha = 0.16
  ) +

  # Historical line and points
  geom_line(
    data = historical_data,
    aes(x = Year, y = Renewable_Share, colour = Type),
    linewidth = 1.4
  ) +
  geom_point(
    data = historical_data,
    aes(x = Year, y = Renewable_Share, colour = Type),
    size = 2.6
  ) +

  # Forecast line and points
  geom_line(
    data = forecast_data,
    aes(x = Year, y = Renewable_Share, colour = Type),
    linewidth = 1.4,
    linetype = "dashed"
  ) +
  geom_point(
    data = forecast_data,
    aes(x = Year, y = Renewable_Share, colour = Type),
    size = 2.6
  ) +

  # Forecast label
  geom_text(
    data = tail(forecast_data, 1),
    aes(
      x = Year,
      y = Renewable_Share,
      label = paste0(round(Renewable_Share, 1), "%")
    ),
    hjust = 1.1,
    vjust = -0.6,
    size = 4.8,
    fontface = "bold",
    colour = "#D62728"
  ) +

  # R2 and p-value
  annotate(
    "text",
    x = 2006,
    y = max(c(historical_data$Renewable_Share, forecast_data$Upper_95), na.rm = TRUE) * 0.96,
    label = r2_label,
    hjust = 0,
    size = 5.8,
    colour = "navy"
  ) +

  # Regression formula
  annotate(
    "text",
    x = 2006,
    y = max(c(historical_data$Renewable_Share, forecast_data$Upper_95), na.rm = TRUE) * 0.84,
    label = eq_label,
    hjust = 0,
    size = 5.8,
    colour = "red"
  ) +

  # Manual colours
  scale_colour_manual(
    values = c(
      "Historical" = "#1F77B4",
      "Forecast" = "#D62728"
    )
  ) +

  # Axes
  scale_x_continuous(
    breaks = c(2005, 2010, 2015, 2020, 2025, 2030, 2035),
    limits = c(2005, 2036)
  ) +
  scale_y_continuous(
    limits = c(0, 100),
    labels = function(x) paste0(x, "%"),
    expand = expansion(mult = c(0, 0.08))
  ) +

  labs(
    x = NULL,
    y = "Renewable Share (%)",
    colour = NULL
  ) +

  theme_minimal(base_size = 14) +
  theme(
    legend.position = "top",
    legend.text = element_text(size = 15),
    axis.title.y = element_text(size = 13, face = "bold"),
    axis.text = element_text(size = 11, colour = "#555555"),
    panel.grid.minor = element_blank(),
    panel.grid.major.x = element_blank(),
    panel.grid.major.y = element_line(colour = "#D9E2F3", linewidth = 0.4),

    panel.background = element_rect(fill = "#F4F8FC", colour = NA),
    plot.background = element_rect(fill = "#F4F8FC", colour = NA),

    plot.margin = margin(8, 18, 8, 8)
  )
