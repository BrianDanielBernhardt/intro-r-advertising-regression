# ============================================================================
# INTRODUCTION TO R FOR QUANTITATIVE DECISION-MAKING 08/10/26 
# UAI 
# Case study: Advertising expenditure and sales
# Dataset: advertising (package glmtoolbox)
# ============================================================================
rm(list=ls())
# ----------------------------------------------------------------------------
# 0. SETUP
# ----------------------------------------------------------------------------
library(ISLR2)
library(car)
library(glmtoolbox)
library(corrplot)

data("advertising")


# ----------------------------------------------------------------------------
# 1. FIRST LOOK AT THE DATA
# ----------------------------------------------------------------------------

head(advertising)
dim(advertising)
names(advertising)
str(advertising)
summary(advertising)

# Questions to ask:
# - What does one row represent?
# - Which variable is the outcome (Y)?
# - Which variables are potential predictors (X)?
# - Are all variables numeric?


# ----------------------------------------------------------------------------
# 2. BASIC DATA-QUALITY CHECKS
# ----------------------------------------------------------------------------

# Missing values by variable
colSums(is.na(advertising))

# Duplicate rows
sum(duplicated(advertising))

# Basic ranges
sapply(advertising, range)

# For this teaching dataset, little/no cleaning should be required.
# In a real project we would investigate missing values, incorrect types,
# impossible values, duplicates and influential/extreme observations.


# ----------------------------------------------------------------------------
# 3. EXPLORATORY DATA ANALYSIS (EDA)
# ----------------------------------------------------------------------------

# Distribution of the outcome
hist(advertising$sales)
hist(
  advertising$sales,
  main = "Distribution of Sales",
  xlab = "Sales"
)

# Scatterplots: each advertising channel versus sales

plot(
  advertising$radio,
  advertising$sales,
  main = "Presupesto Radio vs Vtas",
  xlab = "-",
  ylab = "-",
  pch = 10
)

plot(
  advertising$TV,
  advertising$sales,
  main = "Presupesto tv vs Vtas",
  xlab = "-",
  ylab = "-",
  pch = 10
)

plot(
  advertising$newspaper,
  advertising$sales,
  main = "Newspaper Advertising vs Sales",
  xlab = "Newspaper advertising budget",
  ylab = "Sales",
  pch = 9
)

# Correlation matrix
round(cor(advertising), 3)
corrplot(cor(advertising)) # Plot

pairs(advertising)
scatterplotMatrix(advertising) # pairs scatterplot Matrix
# Useful discussion:
# Which advertising channel has the strongest raw relationship with sales?
# Does correlation imply causation? No.


# ----------------------------------------------------------------------------
# 4. SIMPLE LINEAR REGRESSION: SALES ~ TV
# ----------------------------------------------------------------------------

model_tv <- lm(sales ~ TV, data = advertising)

summary(model_tv)
coef(model_tv)

# Regression line
plot(
  advertising$TV,
  advertising$sales,
  main = "Simple Linear Regression: Sales ~ TV",
  xlab = "TV advertising budget",
  ylab = "Sales",
  pch = 19
)
abline(model_tv, col = "red", lwd = 2)

# Interpretation template:
# Intercept:
# Expected sales when TV advertising expenditure equals zero.
#
# TV coefficient:
# Expected change in sales associated with a one-unit increase in TV
# advertising expenditure.


# ----------------------------------------------------------------------------
# 5. MULTIPLE LINEAR REGRESSION
# ----------------------------------------------------------------------------

model_full <- lm(
  sales ~ TV + radio + newspaper,
  data = advertising
)

summary(model_full)
coef(model_full)

# Key questions:
# 1. Which coefficients are positive/negative?
# 2. How large are they?
# 3. Which variables have small p-values?
# 4. What proportion of variation in sales is explained by the model (R^2)?
# 5. Does newspaper still provide much information once TV and radio
#    are considered simultaneously?


# ----------------------------------------------------------------------------
# 6. COMPARE SIMPLE AND MULTIPLE MODELS
# ----------------------------------------------------------------------------

summary(model_tv)$r.squared
summary(model_full)$r.squared

# Adjusted R-squared is especially useful when comparing models with
# different numbers of predictors.
summary(model_tv)$adj.r.squared
summary(model_full)$adj.r.squared


# ----------------------------------------------------------------------------
# 7. PREDICTION FOR A NEW MARKETING SCENARIO
# ----------------------------------------------------------------------------

scenario <- data.frame(
  TV = 150,
  radio = 30,
  newspaper = 20
)

predict(model_full, newdata = scenario)
predict(model_tv, newdata = scenario)

# Prediction interval: range for an individual future observation
predict(
  model_full,
  newdata = scenario,
  interval = "prediction",
  level = 0.95
)


# ----------------------------------------------------------------------------
# 8. COMPARE SEVERAL DECISION SCENARIOS
# ----------------------------------------------------------------------------

scenarios <- data.frame(
  scenario = c("A", "B", "C", "D"),
  TV = c(50, 100, 150, 200),
  radio = c(30, 30, 30, 30),
  newspaper = c(20, 20, 20, 20)
)

scenarios$predicted_sales <- predict(
  model_full,
  newdata = scenarios
)

scenarios

# Important interpretation:
# These are model-based predictions, not causal estimates of what would
# necessarily happen if management changed the advertising budget.


# ----------------------------------------------------------------------------
# 9. OPTIONAL: QUICK MODEL DIAGNOSTICS
# ----------------------------------------------------------------------------
# Use this only if time allows. It can be introduced as "what comes next".

par(mfrow = c(2, 2))
plot(model_full)
par(mfrow = c(1, 1))

# Typical issues to discuss later:
# - linearity
# - constant error variance (homoskedasticity)
# - influential observations
# - residual normality (mainly relevant for classical inference)


# ----------------------------------------------------------------------------
# 10. TAKEAWAY
# ----------------------------------------------------------------------------
# Workflow:
# Data -> Quality checks -> EDA -> Model -> Interpretation -> Prediction -> Decision
#
# Linear regression is useful because it is both predictive and interpretable,
# but predictive associations should not automatically be interpreted as causal.

model_tv_quad <- lm(
  sales ~ TV + I(TV^2),
  data = advertising
)

summary(model_tv_quad)

plot(
  advertising$TV,
  advertising$sales,
  main = "Ventas vs publicidad en TV",
  xlab = "Presupuesto de publicidad en TV",
  ylab = "Ventas",
  pch = 19
)

# Linear
abline(model_tv, col = "red", lwd = 2)

# Quadratic
tv_grid <- seq(
  min(advertising$TV),
  max(advertising$TV),
  length.out = 200
)

pred_quad <- predict(
  model_tv_quad,
  newdata = data.frame(TV = tv_grid)
)

lines(tv_grid, pred_quad, col = "blue", lwd = 2)

summary(model_tv)$r.squared
summary(model_tv_quad)$r.squared

summary(model_tv)$adj.r.squared
summary(model_tv_quad)$adj.r.squared


