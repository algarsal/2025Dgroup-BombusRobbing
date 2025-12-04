install.packages("lme4")
install.packages("lmerTest")   # optional but gives p-values

library(lme4)
library(lmerTest)

## 1. Start from your data frame
# Assume bumbledata already exists in your environment
bd <- bumbledata

# Quick check
nrow(bd)
names(bd)

## 2. Extract columns (adjust ONLY if your names differ)
population       <- bd$Population
plant            <- bd$Plant
pierced_pct      <- bd$`Pierced flowers (%)`
nectar_pierced   <- bd$`Nectar production rate from pierced flower (µl/flower/24 h)`
nectar_undamaged <- bd$`Nectar production rate from undamaged flower (µl/flower/24 h)`

# OPTIONAL: standing crop columns (only if they exist in bd)
# Check names(bd) and adjust the text inside backticks if needed
standing_pierced   <- bd$`Nectar standing crop from pierced flower (µl/flower)`
standing_undamaged <- bd$`Nectar standing crop from undamaged flower (µl/flower)`

## 3. Long format for nectar
nectar_long <- data.frame(
  Population    = rep(population, 2),
  Plant         = rep(plant, 2),
  pierced_pct   = rep(pierced_pct, 2),
  flower_status = rep(c("pierced", "undamaged"), each = nrow(bd)),
  nectar_rate   = c(nectar_pierced, nectar_undamaged),
  standing_crop = c(standing_pierced, standing_undamaged),
  stringsAsFactors = FALSE
)

## 4. Convert to factors
nectar_long$flower_status <- factor(
  nectar_long$flower_status,
  levels = c("undamaged", "pierced")
)
nectar_long$Population <- factor(nectar_long$Population)
nectar_long$Plant      <- factor(nectar_long$Plant)

## 5. Quick checks
nrow(nectar_long)          # should be 2 * nrow(bd)
head(nectar_long)
summary(nectar_long$nectar_rate)
table(nectar_long$flower_status)

## 6. Transform responses (log scale, small epsilon avoids log(0))
eps <- 1e-6
nectar_long$log_nectar_rate   <- log(nectar_long$nectar_rate   + eps)
nectar_long$log_standing_crop <- log(nectar_long$standing_crop + eps)

## 7. MODEL 1 – nectar standing crop
# Fixed effects: pierced_pct, Population, flower_status, all two-way interactions
m_standing <- lmer(
  log_standing_crop ~ pierced_pct + Population + flower_status +
    pierced_pct:Population +
    pierced_pct:flower_status +
    Population:flower_status +
    (1 | Population/Plant),
  data = nectar_long
)

summary(m_standing)
anova(m_standing)

## 8. MODEL 2 – nectar production rate
m_rate <- lmer(
  log_nectar_rate ~ pierced_pct + Population + flower_status +
    pierced_pct:Population +
    pierced_pct:flower_status +
    Population:flower_status +
    (1 | Population/Plant),
  data = nectar_long
)

summary(m_rate)
anova(m_rate)
