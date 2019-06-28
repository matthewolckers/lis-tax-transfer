---
layout: default
title: Home
nav_order: 1
description: "Data on taxes and transfers for social science researchers."
permalink: /
---

# Data on Taxes and Transfers
{: .fs-9 }

We calculated tax, transfer and inequality measures for 22 countries using the Luxembourg Income Study (LIS) database. Most importantly, <mark style="background-color: #FFFF98">we imputed employer social security contributions</mark> to provide a more accurate measure of taxes. The data is available for your use.
{: .fs-6 .fw-300 }

[Download .dta](public_data/DoTT.dta){: .btn .btn-primary .fs-5 .mb-4 .mb-md-0 .mr-2 } [Download .csv](public_data/DoTT.csv){: .btn .fs-5 .mb-4 .mb-md-0 }


---

<canvas id="myChart"></canvas>
<script src="https://cdn.jsdelivr.net/npm/chart.js@2.8.0"></script>
<script>
var ctx = document.getElementById('myChart').getContext('2d');
var myChart = new Chart(ctx, {
    type: 'bar',
    data: {
        labels: ['Denmark','Sweden','Netherlands','Austria','Iceland','Slovak Republic','Italy','Greece','Luxembourg','Spain','Canada','Norway','Finland','Germany','United States','France','Estonia','Czech Republic','Australia','United Kingdom','Israel','Ireland'],
        datasets: [{
            label: 'Kakwani index of tax progressivity',
            data: [0.077503 ,0.0973947 ,0.0984367 ,0.1041686 ,0.1068879 ,0.1080925 ,0.1133034 ,0.1169652 ,0.1171474 ,0.118849 ,0.1204064 ,0.1214598 ,0.1238587 ,0.1367677 ,0.1391912 ,0.1437898 ,0.1472755 ,0.1523037 ,0.1860332 ,0.1899157 ,0.1949978 ,0.2340027],
            hoverBackgroundColor:'rgba(255, 99, 132, 0.2)',
            hoverBorderColor:'rgba(255, 99, 132, 1)',
            borderWidth: 1
        }]
    },
    options: {
        scales: {
            yAxes: [{
                ticks: {
                    beginAtZero: true
                }
            }]
        }
    }
});
</script>

## Citation

If you use the data for your research, please cite:

> Guillaud, E., Olckers, M., & Zemmour, M. (Forthcoming). [Four levers of redistribution: The impact of tax and transfer systems on inequality reduction](https://rdcu.be/bgJQs). ***Review of Income and Wealth***.

## Sources

Our data is extracted from nationally representative household surveys, harmonized by the [Luxembourg Income Study](https://www.lisdatacenter.org). We used the [OECD's Taxing Wages series](https://www.oecd.org/tax/taxing-wages-20725124.htm) to record tax rates for the imputations of social security contributions. You may view our code in [this Github repo](https://github.com/matthewolckers/lis-tax-transfer).

## Team

This data is part of research project on tax and transfer systems by [Elvire Guillaud](https://sites.google.com/site/elvireguillaud/), [Matthew Olckers](http://www.matthewolckers.com/) and [Michaël Zemmour](https://sites.google.com/site/mzemmour/home). Elvire and Michaël have a research agenda focusing on redistribution, which includes this project and several others.

[Victor Amoureux](https://fr.linkedin.com/in/victor-amoureux-54579194) contributed extensively to [the code](https://github.com/matthewolckers/lis-tax-transfer).   


## Documentation

- [Description](/description)
  - [Codebook](/description/codebook)
  - [Countries](/description/countries)

---

<img src="assets/img/liepp.png" alt="LIEPP" title="Sciences Po, Le Laboratoire Interdisciplinaire d'Evaluation des Politiques Publiques" width="400" margin-left="auto" margin-right="auto" display="block" /> <img src="assets/img/en3s-web.jpg" alt="EN3S" title="L'Ecole nationale supérieure de Sécurité sociale" width="200" margin-left="auto" margin-right="auto" display="block" />
