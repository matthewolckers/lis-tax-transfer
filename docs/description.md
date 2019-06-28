---
layout: default
title: Description
nav_order: 2
has_toc: false
permalink: /description
---

# Data Description

## Understanding the variables

The data can be decomposed into two parts: the income measure and the summary statistic. All variables have the following naming convention:

`INCOME MEASURE _ SUMMARY STATISTIC`

For example, `inc1_gini` is the gini coeffcient of primary income (`inc1`).

We also add the prefix `hhaa` if the summary statistic is restricted to [working age households](#working-age-subsample).

### Summary statistics

| Variable name | Concept| Stata code |
|----|----|----|
| mean | [Mean](#weighted-mean) | `sum VARIABLE [w=hwgt*nhhmem]` |
| gini | [Gini coefficient](#gini-coefficient) | `sgini VARIABLE [aw=hwgt*nhhmem]` |
| conc | [Concentration index](#concentration-index) | `sgini VARIABLE [aw=hwgt*nhhmem], sortvar(SORTVARIABLE)` |
| kakwani | [Kakwani index](#kakwani-index) | `VARIABLE_conc_SORTVARIABLE - SORTVARIABLE_gini` |

All statistics are calculated at the individual level. We first calculate the measures at the household level (using the square root equivalence scale) but then we weight the summary statistics by the number of household members to provide an individual level summary statistic. This approach assumes the household resources are shared equally among the household members.

### Income measures

| Variable name | Concept | Definition |
|----|----|----|
| inc1 | Primary income | Income from labor and capital |  
| inc2 | Market income | Primary income + pensions |
| inc3 | Gross income | Market income + cash social transfers (other than pensions) |
| inc4 | Disposable income | Gross income - income taxation and social security contribution (employer and employee) |
| dhi | Disposable income | The survey measure available in the LIS database. |

### Other measures

In addition to income, we also calculate summary statistics of the following concepts:

| Variable name | Concept | LIS variables |
|----|----|----|
| tax | Taxes | `hxit + hsscer` |
| transfer | Transfers | `hits - pubpension` |
| allpension | Pensions | `pension - hitsap` |
| pubpension | Public pensions | `hitsil + hitsup` |
| pripension | Private pensions | `hicvip` |
| hxits| Employee social security contributions (LIS and imputed) | `hxits=hsscee if hxits==.` |
| hsscee | Employee social security contributions (imputed) | |
| hsscer | Employer social security contributions (imputed) | |
| hssc | Social security contributions (imputed) | |

## Working-age subsample

We calculate our summary statistics on the full sample of respondents for each national survey and we categorize pensions as part of income. Researchers may prefer to exclude pensioners and focus only on working-age households. We have also calculated our summary statistics for the subsample of working-age households.

We define working-age households as those whose household head is between 25 and 60 years of age at the survey date

## Details on the summary statistics

In progress
{: .label .label-yellow }

### Weighted mean

We estimate the population mean of a variable by weighting the sample mean with weights provided in each household survey. The weights are calculated to match the sample with the population.

### Gini coefficient

The Gini coefficient is a standardized measure of inequality which ranges from 0 to 1. Perfect equality has Gini coefficient of 0 and the most extreme level of inequality (where one person has everything and everyone else has nothing) has a Gini coefficient of 1.

### Concentration index

The concentration index summarizes the distribution of a variable over households, ranked by household income. The index ranges from -1 to 1.

### Kakwani index

The Kakwani index is the difference between the concentration index and the Gini index. The Kakwani index corrects the concentration index for the initial level of inequality.
