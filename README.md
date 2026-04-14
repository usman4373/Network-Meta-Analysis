# Network Meta‑Analysis (NMA) of Continuous Outcomes

This repository provides a complete, reproducible R script for **random‑effects network meta‑analysis** of continuous outcome data using the standardised mean difference (SMD). The script performs all essential steps: data preparation, network geometry, model fitting, inconsistency assessment, treatment ranking, and publication bias evaluation. All results are saved as CSV files and high‑resolution PNG figures.

---

## 📋 Table of Contents

- [✨ Features](#-features)
- [📥 Input Data Requirements](#-input-data-requirements)
- [📤 Output Files](#-output-files)
- [🚀 How to Run](#-how-to-run)
- [🔧 Customisation Guide](#-customisation-guide)
- [📜 Citation & License](#-citation--license)

---

## ✨ Features

- Converts arm‑based data to pairwise (contrast‑based) format automatically
- Draws a network geometry plot with treatment nodes and direct comparisons
- Fits a **random‑effects NMA** (frequentist, using `netmeta`)
- Assesses **global heterogeneity** (τ², I², Cochran’s Q)
- Evaluates **global inconsistency** (design‑by‑treatment decomposition) and **local inconsistency** (node‑splitting)
- Computes **P‑scores** (frequentist analogue of SUCRA) for treatment ranking
- Generates a **comparison‑adjusted funnel plot** for publication bias detection
- Saves all numerical results (CSV) and figures (PNG, 800 DPI)

---

## 📥 Input Data Requirements

Prepare an Excel file named **`nma_input.xlsx`** with the following columns (exact names required):

| Column name | Description                                 | Example          |
|-------------|---------------------------------------------|------------------|
| `Study`     | Study identifier (character or numeric)     | "Smith 2020"     |
| `Treatment` | Treatment name/identifier                   | "A", "Placebo"   |
| `Mean`      | Mean outcome value in that arm              | 2.5              |
| `SD`        | Standard deviation of the outcome           | 1.2              |
| `N`         | Number of participants in that arm          | 30               |

**Important notes:**

- Each study must contribute **at least two rows** (one per arm). Multi‑arm studies are fully supported.
- Treatment names must be consistent across studies (e.g., do not write "A" in one study and "A (low dose)" in another).
- The script assumes a **continuous outcome** and uses **SMD** as the effect measure. For binary outcomes or other effect sizes, modify the `sm` argument (see [🔧 Customisation Guide](#-customisation-guide)).

**Example data snippet:**

| Study        | Treatment | Mean | SD  | N |
|--------------|-----------|------|-----|---|
| Smith 2020   | A         | 2.5  | 1.2 | 30 |
| Smith 2020   | B         | 3.1  | 1.5 | 32 |
| Jones 2021   | A         | 2.8  | 1.3 | 28 |
| Jones 2021   | C         | 3.5  | 1.4 | 29 |

Place this file in the same directory as the R script before running.

---

## 📤 Output Files

After successful execution, the working directory will contain the following files:

| File name                         | Description                                                                 |
|-----------------------------------|-----------------------------------------------------------------------------|
| `01_pairwise_data.csv`            | Pairwise (contrast‑based) data used for NMA                                 |
| `01_network_plot.png`             | Network geometry plot (nodes = treatments, edges = direct comparisons)      |
| `02_nma_results.csv`              | Random‑effects NMA results – all treatment comparisons vs. every treatment  |
| `02_forest_plot.png`              | Forest plot comparing all treatments against a reference (default: "C-ESPB")|
| `03_heterogeneity.csv`            | Global heterogeneity statistics (Q, p‑value, I², τ, τ²)                     |
| `04_global_inconsistency.csv`     | Design‑by‑treatment decomposition (consistency vs. inconsistency)           |
| `05_local_inconsistency.png`      | Node‑splitting forest plot (direct vs. indirect evidence for each contrast) |
| `06_treatment_ranking.csv`        | P‑scores for each treatment (higher = better outcome)                       |
| `06_ranking_plot.png`             | Bar plot of P‑scores                                                        |
| `07_funnel_plot.png`              | Comparison‑adjusted funnel plot (ordered by P‑score)                        |

---

## 🚀 How to Run

### 1. Install required R packages

Open R or RStudio and run:

```r
install.packages(c("readxl", "dplyr", "netmeta", "ggplot2", "meta"))
```

## 🔧 Customisation Guide

| What you want to change | Where to modify in the script |
|------------------------|------------------------------|
| Reference treatment for forest plot | In `forest(net, ref = "C-ESPB", ...)` – replace `"C-ESPB"` with a valid treatment name from your data |
| Effect measure (e.g., MD, OR, RR) | In `pairwise(..., sm = "SMD")` and `netmeta(..., sm = "SMD")` – change `"SMD"` to `"MD"`, `"OR"`, etc. |
| Fixed-effect instead of random-effects | In `netmeta()` set `common = TRUE`, `random = FALSE` |
| Plot resolution / size | Modify `width`, `height`, `res` in each `png()` call (e.g., `width = 10`, `height = 8`, `res = 600`) |
| Order of treatments in funnel plot | Change the `order` argument inside `funnel()` – by default it uses the P-score ranking |
| Title or axis labels | Add or modify `main`, `xlab`, `ylab` in the respective plotting calls |

## 📜 Citation & License

If you use this script in a publication, please cite the core R packages:

    Rücker G, Schwarzer G, Krahn U, König J (2024). netmeta: Network Meta‑Analysis using Frequentist Methods. R package version 2.8-0.
    Schwarzer G, Carpenter JR, Rücker G (2015). meta: An R package for meta‑analysis. R News, 15(3): 9–13.

License: MIT

Disclaimer: This script is provided “as is”, without warranty of any kind. The authors are not responsible for any errors or consequences arising from its use.
