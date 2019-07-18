---
layout: default
title: Home
nav_order: 1
description: "Data on taxes, transfers and inequality for social science researchers."
permalink: /
---

# Data on Redistribution
{: .fs-9 }

We calculated tax, transfer and inequality measures for 22 countries using the Luxembourg Income Study (LIS) database. Most importantly, <mark style="background-color: #FFFF98">we imputed employer social security contributions</mark> to provide a more accurate measure of taxes. The data includes:
{: .fs-5 .fw-300 }
- Gini indexes of inequality, both before and after taxes and transfers;
- average tax and transfer rates;
- and measures of the progressivity of taxes and transfers.
{: .fs-5 .fw-300 }

[Download .dta](public_data/redistribution_data.dta){: .btn .btn-primary .fs-5 .mb-4 .mb-md-0 .mr-2 } [Download .csv](public_data/redistribution_data..csv){: .btn .fs-5 .mb-4 .mb-md-0 }

---

<canvas id="Chart1"></canvas>
<script src="https://cdn.jsdelivr.net/npm/chart.js@2.8.0"></script>
<script>
var ctx = document.getElementById('Chart1').getContext('2d');
var Chart1 = new Chart(ctx, {
    type: 'bar',
    data: {
        labels: ['Israel','United States','Estonia','Spain','Greece','Australia','United Kingdom','Canada','Italy','Ireland','Germany','France','Austria','Luxembourg','Slovak Republic','Netherlands','Czech Republic','Finland','Denmark','Iceland','Norway','Sweden'],
        datasets: [{
                    label: 'Inequality after taxes and transfers',
                    data:[0.3928,0.3880,0.3597,0.3460,0.3453,0.3373,0.3351,0.3225,0.3225,0.3056,0.3000,0.2935,0.2861,0.2816,0.2721,0.2687,0.2665,0.2640,0.2573,0.2545,0.2500,0.2437],
                    hoverBackgroundColor:'rgba(153, 0, 0, 0.4)',
                    hoverBorderColor:'rgba(153, 0, 0, 1)',
                    borderWidth: 1},
                    {label: 'Reduction in inequality due to redistribution',
                    data:[0.0797,0.0678,0.0704,0.0745,0.0576,0.0876,0.1336,0.0794,0.0760,0.1579,0.1012,0.1146,0.0856,0.0786,0.0587,0.0935,0.0841,0.1093,0.0936,0.0776,0.0850,0.1186],
                    backgroundColor:'rgba(189, 189, 189, 0.1)',
                    borderColor:'rgba(189, 189, 189, 1)',
                    hoverBackgroundColor:'rgba(255, 99, 132, 0.2)',
                    hoverBorderColor:'rgba(255, 99, 132, 1)',                    
                    borderWidth: 1}]
    },
    options: {
        scales: {
            minBarLength: 100,
            xAxes: [{
              stacked: true
              }],
            yAxes: [{
                ticks: {
                    beginAtZero: true
                },
                stacked: true
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
- [Codebook](/codebook)
- [Countries](/countries)

---

This project received funding and support from [LIEPP Sciences Po](https://www.sciencespo.fr/liepp/en) and [EN3S](https://en3s.fr/en/).

<img src="assets/img/liepp.png" alt="LIEPP" title="Sciences Po, Le Laboratoire Interdisciplinaire d'Evaluation des Politiques Publiques" width="300" margin-left="auto" margin-right="auto" display="block" /> <img src="assets/img/en3s-web.jpg" alt="EN3S" title="L'Ecole nationale supérieure de Sécurité sociale" width="150" margin-left="auto" margin-right="auto" display="block" />
