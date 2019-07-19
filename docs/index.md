---
layout: default
title: Home
nav_order: 1
description: "Data on redistribution (taxes, transfers and inequality) for social science researchers."
permalink: /
---

# Data on REDucing INEQuality
{: .fs-9 }



Our data on redistribution includes tax, transfer and inequality measures for 22 countries over the 1999-2016 period. We used household surveys harmonized by the Luxembourg Income Study (LIS) and we imputed missing tax data. <mark style="background-color: #FEE5D9">You may use the data to compare the reduction in inequality due to taxes and transfers across countries and time.</mark> The data also includes measures of the progressivity and average rate of taxes and transfers so you can compare how each country delivers redistribution.
{: .fs-5 .fw-300 }

[Download .dta](public_data/redistribution_data.dta){: .btn .btn-primary .fs-5 .mb-4 .mb-md-0 .mr-2 } [Download .csv](public_data/redistribution_data.csv){: .btn .fs-5 .mb-4 .mb-md-0 }

---

<div class="chart-container">
<canvas id="Chart1"></canvas>
<p style="font-size: 0.75rem">Note: We display the most recent year for each country, which is between 2010 and 2016 with two exceptions. For Ireland, we use the pre‐crisis year of 2007 and the most recent year for Sweden is 2005.</p>
</div>
<script src="https://cdn.jsdelivr.net/npm/chart.js@2.8.0"></script>
<script>
var ctx = document.getElementById('Chart1').getContext('2d');
var Chart1 = new Chart(ctx, {
    type: 'bar',
    data: {
        labels: ['Ireland','Sweden','United Kingdom','Germany','Finland','France','Czech Republic','Denmark','Norway','Netherlands','Estonia','Austria','Australia','Slovak Republic','Greece','Italy','Spain','Iceland','Canada','Israel','Luxembourg','United States'],
        datasets: [{
                    label: 'Pensions',
                    data:[0.0303,0.0667,0.0451,0.0759,0.0667,0.0577,0.0865,0.0732,0.0635,0.0539,0.0745,0.0569,0.0471,0.0675,0.0678,0.0445,0.0455,0.0399,0.0351,0.0292,0.0295,0.0324],
                    backgroundColor:'rgba(217,217,217, 0.8)',
                    borderColor:'rgba(217,217,217, 1)',
                    hoverBackgroundColor:'rgba(254,224,210, 1)',
                    hoverBorderColor:'rgba(254,224,210, 1)',                    
                    borderWidth: 1},
                    {label: 'Transfers',
                    data:[0.0970,0.0556,0.0841,0.0364,0.0480,0.0424,0.0208,0.0580,0.0316,0.0386,0.0121,0.0339,0.0451,0.0190,0.0127,0.0103,0.0329,0.0328,0.0429,0.0327,0.0400,0.0217],
                    backgroundColor:'rgba(189, 189, 189, 0.8)',
                    borderColor:'rgba(189, 189, 189, 1)',
                    hoverBackgroundColor:'rgba(252,146,114, 1)',
                    hoverBorderColor:'rgba(252,146,114, 1)',
                    borderWidth: 1},
                    {label: 'Tax',
                    data:[0.0609,0.0630,0.0494,0.0647,0.0614,0.0723,0.0633,0.0356,0.0534,0.0549,0.0583,0.0517,0.0425,0.0397,0.0449,0.0657,0.0416,0.0448,0.0366,0.0470,0.0386,0.0462],
                    backgroundColor:'rgba(99, 99, 99, 0.8)',
                    borderColor:'rgba(99, 99, 99, 1)',
                    hoverBackgroundColor:'rgba(222,45,38, 1)',
                    hoverBorderColor:'rgba(222,45,38, 1)',
                    borderWidth: 1}]
    },
    options: {
        scales: {
            xAxes: [{
              stacked: true
              }],
            yAxes: [{
                scaleLabel: {display: true, labelString: 'Reduction of inequality (Gini points)'},
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

If you use the data for your research, please cite the publication:

> Guillaud, E., Olckers, M., & Zemmour, M. (Forthcoming). Four levers of redistribution: The impact of tax and transfer systems on inequality reduction. ***Review of Income and Wealth***. DOI: [10.1111/roiw.12408
](https://rdcu.be/bgJQs)

and the dataset:

> Guillaud, E., Olckers, M., & Zemmour, M. 2019. REDINEQ data (version: {{ site.time | date: '%B, %Y' }}). [www.redineq.com](//www.redineq.com)

## Sources

Our data is extracted from nationally representative household surveys, harmonized by the [Luxembourg Income Study](https://www.lisdatacenter.org). We used the [OECD's Taxing Wages series](https://www.oecd.org/tax/taxing-wages-20725124.htm) to record tax rates for the imputations of social security contributions. You may view our code in [this Github repo](https://github.com/matthewolckers/lis-tax-transfer).

## Team

This data is part of research project on tax and transfer systems by [Elvire Guillaud](https://sites.google.com/site/elvireguillaud/), [Matthew Olckers](http://www.matthewolckers.com/) and [Michaël Zemmour](https://sites.google.com/site/mzemmour/home). Elvire and Michaël have a research agenda focusing on redistribution, which includes this project and several others.

[Victor Amoureux](https://fr.linkedin.com/in/victor-amoureux-54579194) contributed extensively to [the code](https://github.com/matthewolckers/lis-tax-transfer).


## Documentation

- [Description](description.md)
- [Codebook](codebook.md)
- [Countries](countries.md)

---

This project received funding and support from [LIEPP Sciences Po](https://www.sciencespo.fr/liepp/en) and [EN3S](https://en3s.fr/en/). We thank Silvia Avram, Thomas Breda, Laurent Caussat, Marie-Cécile Cazenave, Conchita D’Ambrosio, Bernhard Ebbinghaus, Jörg Neugschwender, Bruno Palier, and Denisa Solognon for useful discussions about the data and methodology. We are also grateful to the LIS team for answering our questions about the data.

<img src="assets/img/liepp.png" alt="LIEPP" title="Sciences Po, Le Laboratoire Interdisciplinaire d'Evaluation des Politiques Publiques" width="300"/> <img src="assets/img/en3s-web.jpg" alt="EN3S" title="L'Ecole nationale supérieure de Sécurité sociale" width="150"  />
