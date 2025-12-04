install.packages("lme4")
install.packages("lmerTest")   # optional but gives p-values

library(lme4)
library(lmerTest)


# assume bumbledata exists
bd <- bumbledata

# Extract columns by exact names (use backticks if needed)
population <- bd$Population
plant <- bd$Plant
pierced_pct <- bd$`Pierced flowers (%)`
nectar_pierced <- bd$`Nectar production rate from pierced flower (µl/flower/24 h)`
nectar_undamaged <- bd$`Nectar production rate from undamaged flower (µl/flower/24 h)`

# Make a long dataframe by stacking
nectar_long <- data.frame(
  Population = rep(population, 2),
  Plant = rep(plant, 2),
  pierced_pct = rep(pierced_pct, 2),
  flower_status = rep(c("pierced", "undamaged"), each = nrow(bd)),
  nectar_rate = c(nectar_pierced, nectar_undamaged),
  stringsAsFactors = FALSE
)

# Convert to factors where appropriate
nectar_long$flower_status <- factor(nectar_long$flower_status, levels = c("undamaged", "pierced"))
nectar_long$Population <- factor(nectar_long$Population)
nectar_long$Plant <- factor(nectar_long$Plant)

# quick check
head(nectar_long)
summary(nectar_long$nectar_rate)
table(nectar_long$flower_status)
