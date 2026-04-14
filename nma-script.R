# ================================
# 0. Load Required Libraries
# ================================
library(readxl)
library(dplyr)
library(netmeta)
library(ggplot2)
library(meta)

# ================================
# 1. Import Data
# ================================
data_raw <- read_excel("nma_input.xlsx", sheet = 1)

# ================================
# 2. Network Geometry Assessment
# ================================
pw <- pairwise(
  treat = Treatment,
  mean = Mean,
  sd = SD,
  n = N,
  studlab = Study,
  data = data_raw,
  sm = "SMD"
)

# Network plot
png("01_network_plot.png", width = 8, height = 6, units = "in", res = 800)
net_temp <- netmeta(pw$TE, pw$seTE, pw$treat1, pw$treat2, studlab = pw$studlab)
netgraph(net_temp,
         plastic = TRUE,
         points = TRUE,
         cex.points = 4,
         col.points = "skyblue")
title("Network Geometry")
dev.off()

# Save basic network structure
write.csv(pw, "01_pairwise_data.csv", row.names = FALSE)

# ================================
# 3. Network Meta-Analysis Model
# ================================
net <- netmeta(
  TE = pw$TE,
  seTE = pw$seTE,
  treat1 = pw$treat1,
  treat2 = pw$treat2,
  studlab = pw$studlab,
  data = pw,
  sm = "SMD",
  common = FALSE,
  random = TRUE
)
# Save full results
res <- summary(net)
# Extract the main results table (relative treatment effects)
df_nma <- as.data.frame(res$random)
write.csv(df_nma, "02_nma_results.csv", row.names = TRUE)
# Forest Plot of NMA 
png("02_forest_plot.png", width = 8, height = 6, units = "in", res = 800)
forest(net,
       ref = "C-ESPB",  # change based on your dataset
       sortvar = TE,
       main = "Network Meta-Analysis")
dev.off()

# ================================
# 4. Global Heterogeneity
# ================================
heterogeneity <- data.frame(
  tau = net$tau,
  tau2 = net$tau^2,
  I2 = net$I2
)

hetero_df <- data.frame(
  Q_total = net$Q,
  df = net$df.Q,
  p_value = net$pval.Q,
  I2 = net$I2,
  tau = net$tau,
  tau2 = net$tau^2
)
write.csv(hetero_df, "03_heterogeneity.csv", row.names = FALSE)

# ================================
# 5. Consistency Assessment
# ================================

# --- Global inconsistency (design-by-treatment)
decomp <- decomp.design(net)
# Extract decomposition table
df_global <- as.data.frame(decomp$Q.decomp)
write.csv(df_global, "04_global_inconsistency.csv", row.names = TRUE)

# --- Local inconsistency (node splitting)
nsplit <- netsplit(net)

png("05_local_inconsistency.png", width = 8, height = 10, units = "in", res = 800)
forest(nsplit,
       main = "Local Inconsistency")
dev.off()

# ================================
# 6. Ranking of Treatments
# ================================
rank <- netrank(net, small.values = "good")
# Inspect structure
str(rank)

df_rank <- data.frame(
  treatment = names(rank$ranking.random),
  Pscore = rank$ranking.random
)

write.csv(df_rank, "06_treatment_ranking.csv", row.names = FALSE)

# Rank plot
png("06_ranking_plot.png", width = 8, height = 6, units = "in", res = 800)
barplot(rank$ranking.random,
        names.arg = names(rank$ranking.random),
        las = 2,
        main = "Treatment Ranking (P-scores)",
        ylab = "P-score")
dev.off()

# ================================
# 7. Publication Bias
# ================================
png("07_funnel_plot.png", width = 8, height = 6, units = "in", res = 800)
# Use ranking you already computed
ord <- names(sort(rank$ranking.random, decreasing = TRUE))
funnel(net, order = ord)
title("Comparison-Adjusted Funnel Plot")
dev.off()

# ================================
# END OF SCRIPT
# ================================