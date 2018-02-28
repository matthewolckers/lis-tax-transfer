# Analyze the impact of taxes and transfers on inequality using LIS data
Research project by [Elvire Guillaud](https://sites.google.com/site/elvireguillaud/), [Matthew Olckers](http://www.matthewolckers.com/), and [Michaël Zemmour](https://sites.google.com/site/mzemmour/home).

This repo includes all the code and supplementary data needed to extract the data from the Luxembourg Income Study (LIS) database we used in our study [Four levers of redistribution: The impact of tax and transfer systems on inequality reduction](http://www.lisdatacenter.org/wps/liswps/695.pdf).

The [Luxembourg Income Study (LIS)](http://www.lisdatacenter.org/) provides harmonized national survey data from 46 countries over multiple years. The database in constantly growing by including new countries and expanding the number of years per country.

This guide is written by Matthew Olckers.

## Explaining the code used to retrieve the data
Data is retrieved using the LISSY interface, which allows the researcher to input Stata code and the Stata output text is then returned via email (log file). The data restrictions on LIS prevent you from viewing the data itself. Commands such a list or browse cannot be used. My approach was to gather a series of summary statistics of the LIS data to create a new country-level dataset.

This section provides a step-by-step guide to the Stata code I used to create the main set of variables in the country-level dataset. The code snippet is shown first, with the corresponding explanation underneath.

(I have a feeling it would have been much easier to do this in R but LIS added support for R only after we had already started.)

### Start by defining the globals

```
global datasets "au03 au08 au10 at04 ca04 ...

global pvars "pid hid dname pil age"

global hvars "hid dname nhhmem dhi nhhmem65 hwgt"

global hvarsflow "hil hic pension hits hitsil hitsup hitsap hitp hxiti hxits hc hicvip"

global hvarsnew "hsscer hxct"

global hvarsinc "inc1 inc2 inc3 inc4 inc5 tax transfer"
```
The program (.do file) begins by defining a set of globals. The globals are simply a shortening for the text inside the inverted commas. The global datasets corresponds to all the country-years on which this program will be executed. For example, au03 represent Australia 2003. At the time we started, LIS had 266 country-years in their database. The database grows as new national household surveys are harmonized to the LIS structure.

The other globals such as pvars, hvars, etc. are lists of variables that are used in certain parts of the program. Globals allow the code to be simplified. If you wish to add a new variable, you only have to add the variable name to the relevant global rather than editing many parts of the program.

### Program 1: Generate social security variables from person level dataset
```
program define gen_pvars

merge m:1 dname using "http://s3.eu-central-1.amazonaws.com/lissy/ssc_stata12.dta", keep(match) nogenerate
```
The most efficient way to work with LISSY is to define all the programs first, and then implement the programs with a loop over all country-years (taking special care to output only the information you need). By default, Stata log output includes many details of the intermediate steps of your program, but these details may be suppressed by defining the program first and running the program quietly .

The above code defines the first program `gen_pvars`, which works off the individual-level data recorded in LIS. All surveys in the LIS database contain household-level and individual-level variables. Individual level variables have the prefix `p`, for person.

This program starts by merging an external dataset hosted on a website to the individual-level survey of the particular country-year under observation. The variable `dname` is short for dataset name. For example, `au03` is a `dname` for Australia 2003. The LISSY interface is run using Stata 12 so the external dataset must also be saved in Stata 12 format. This version of Stata is only capable of merging from an unencrypted website (notice that the url starts with `http://`). If the website is encrypted (url starts with `https://`), then the merge cannot be completed by Stata 12.

The file *ssc_stata12.dta* contains a set of social security rates and ceiling for each country-year. Once the relevant rates and ceiling are merged into the individual-level dataset, the employer social security contributions may be imputed.

```
gen psscer=.

replace psscer = pil*er_r1

replace psscer = (pil-er_c1)*er_r2 + er_r1*er_c1  if pil>er_c1 & er_c1!=.

replace psscer = (pil-er_c2)*er_r3 + er_r2*er_c2 + er_r1*er_c1 if pil>er_c2 & er_c2!=.

...

*Manual adjustment for France 2010

replace psscer=psscer-((0.26/0.6)*((25800.32/pil)-1)*pil) if pil>16125 & pil<25800.32 & dname=="fr10"
```
Social security contributions are imputed with a series of *replace* commands. The code starts by applying the rate below the first ceiling. It then corrects the social security contributions for all individuals above the first ceiling, and then above the second ceiling, and so on.

In certain cases the social security contributions are too complex to be summarised by a set of rates and ceilings. For example, France includes a sliding scale rebate to employer social security contributions for employees paid at and up to 1.6 times the minimum wage. I include manual adjustments for these country-years.

```
bysort hid: egen hsscee=total(psscee)

bysort hid: egen hsscer=total(psscer)

keep hid hsscee hsscer
drop if hid==.
duplicates drop hid, force

end
```
The first program is completed by summing the individual social security contributions to the household level. The income, tax, and transfer variables are at the household level so this summation allows for consistent measurement.

#### Additional notes on Program 1

LIS sources their data from many different statistical agencies around the world. Each agency has different aims for their national surveys, which results in significant challenges to harmonize this data.

This project focusses on income, taxes, and transfers so any difference in the measurement of these variables across countries creates additional challenges to extract the data. The most common difference results from the income measure, which may be before or after taxes. *Gross* datasets measure income before income taxes and social security contributions. *Net* datasets measure income after income taxes and social security contributions. *Mixed* datasets (such as France) measure income after social security contributions, but before income taxes. The table below shows the split of the LIS database between these different type of datasets.


| Number of datasets (country-years) | Income type | Income taxes and employee social security contributions (one-shot) | Income taxes | Employee social security contributions |
| ---- |----| ----| ----| ----|
| 121 | Gross | yes | yes | yes |
| 29 | Gross | yes | yes | no |
| 26 | Gross | yes | no | no |
| 3 | Gross | no | no | no |
| 3 | Mixed | yes | yes | yes |
| 8 | Mixed | yes | yes | no |
| 2 | Mixed | no | no | no |
| 1 | Net | yes | yes | yes |
| 1 | Net | yes | no | yes |
| 2 | Net | yes | yes | no |
| 70 | Net | no | no | no |

Within each income type (gross, mixed, and net) there are also differences in the measurement of tax and employee social security contributions. Table 2 shows that certain datasets record income taxes and employee social security contributions separately, other datasets lump them together, and certain datasets have no data on these taxes at all.

It would be convenient if all the datasets had the characteristics of the first row of Table 1: income is gross, and both income tax and employee social security contributions are recorded. Unfortunately, only 121 of the 266 country-years are recorded in this manner. For the remaining country-years, I needed to create additional imputations.

If the income is gross then employee social security contributions may be imputed the same way as employer social security contributions. I apply the relevant rates and ceilings in the same manner described in the previous section. The mixed datasets (such as France) have an additional complication.

The statutory rates and ceiling sourced from the OECD Taxing Wages publication apply to gross income. If income after employee social security contributions is used in these formulas, the result will understate the correct amount. The formulas must be adjusted to output the correct amount.

Here is an excerpt from the formula for imputing employee social security contributions from gross income:
```
replace psscee = (pil-ee_c1)*ee_r2 + ee_r1*ee_c1  if pil>ee_c1
```
- `psscee` is individual employee social security contributions.
- `pil` is individual gross labour income.
- `ee_c1` is the first ceiling, and `ee_r2` is the rate that applies above the first ceiling.

Here is the same excerpt, but adjusted for mixed income (after employee social security contributions but before income taxes):
```
replace psscee = ((pil_mix-ee_c1)*ee_r2)/(1-er_r2) + ee_r1*ee_c1  if pil_mix>ee_c1_mix
```
Notice the adjustment to the formula when the input is mixed income instead of gross income. The first term must be divided by `(1-er_r2)` where `er_r2` is still the statutory rate that applies to gross income. The second part of the adjustment is to change the threshold `er_c1` to `er_c1_mix` where `er_c1_mix` is the ceiling that applies to mixed income. This adjustment may seem confusing at first glance, but it can be easily derived by plugging `(pil_mix + psscee) = pil` in the first formula.

The net datasets are even more complicated. To impute income taxes and employee social security contributions from formulas that apply to gross income when you only have net income creates simultaneous equations. This is because net income = gross income - employee ssc - income taxes. Rather than attempting to solve this simultaneous equation analytically, I have used a numerical solution.

I create an external dataset that includes every integer value of net income and the corresponding taxes for every county-year covering the range of net income values observed in the respective datasets. This external dataset is created by plugging a large range of gross income values into the imputation formulas and recording the output. I first round the the income figures in the net datasets to the nearest integer and then match this value to the external dataset. This numerical matching allows me to impute the correct amount of employee social security contributions and income taxes, which can then be used to convert net income to gross income.

### Program 2: Impute consumption taxes
*Work in progress*

### Program 3: Define the different stages of income

```
program define income_stages

gen inc1 = hil + (hic-hicvip) + hsscer

gen inc2 = hil + (hic-hicvip) + hsscer + (pension - hitsap - hitsup)

gen inc3 = hil + (hic-hicvip) + hsscer + (pension - hitsap - hitsup) + (hits - hitsil)

gen inc4 = hil + (hic-hicvip + (pension - hitsap - hitsup) + (hits - hitsil) - hxiti - hxits

gen inc5 = hil + (hic-hicvip + (pension - hitsap - hitsup) + (hits - hitsil) - hxiti - hxits - hxct
```
The third program uses the income, tax, and transfer variables to define the stages of income of interest in this study. All variables are at the household level (as shown by h prefix in the variable names). Table 3 provides definitions of the income variables.

If you add or subtract missing values in Stata, the result will be equal to missing. I have set the missing values equal to zero for most variables to prevent this problem. A more detailed analysis of missing values in each dataset is necessary to check if this operation creates any bias.

| Variable name | Concept | Definition |
|----|----|----|
| inc1 | Primary income | Income from labour and capital |  
| inc2 | Market income | Primary income + pensions |
| inc3 | Gross income | Market income + cash social transfers (other than pensions) |
| inc4 | Disposable income | Gross income - income taxation and social security contribution (employer and employee) |  
| inc5 | Disposable income net of consumption taxes | Disposable income - tax on consumption |

#### Program 4: Apply PPP conversions and equivalence scales to flow variables
```
program define ppp_equiv

gen ppp =.
replace ppp= 2.250787458 if dname== "au81"
replace ppp= 1.657498516 if dname== "au85"
replace ppp= 1.214320511 if dname== "au89"
...
```
Certain summary statistics are displayed in currency units so I completed purchasing power parity (PPP) conversions to allow for comparisons across countries. The excerpt above shows the PPP conversion rates for three country-years.

The most comprehensive PPP figures are supplied by the World Bank in their World Development Indicators database (WDI). In particular, the year 2011 includes PPP adjustments for the largest number of countries, as the World Bank released their second International Comparison Program (ICP) in this year. To exploit the data availability in 2011, the LIS approach was to convert any prices to their 2011 local currency levels using consumer price indexes and then convert to international US dollars using the PPP conversions.

I had to make manual adjustments for country-years in which the currency used in that year was not the same as that used in 2011. For example, Italy used the Italian Lira in 1986 so the LIS microdata is measured in Lira for the 1986 Italian dataset. This PPP adjustment required three steps:
- convert from 1986 prices to 2011 prices
- convert from Lira to Euros
- convert from 2011 Euros to 2011 international dollars under purchasing power parity
The second step was missing and this is what my manual adjustment corrected for. All the countries that changed currencies provide a fixed rate to move from the old to the new currency, so these manual adjustments were straightforward.

PPP conversion for the datasets of Taiwan from 1981 to 2007 could not be calculated because a consumer price index was not available for these years. There is a spreadsheet titled WDI-CPI-PPP accompanying this document, which shows my PPP calculations in detail.

```
foreach var in $hvarsflow $hvarsinc $hvarsnew {
   replace `var' = 0 if `var' < 0 & `var' !=.  
   replace `var' = (`var'*ppp)/(nhhmem^0.5)
   }
```
I run a loop over all the variables that are measured in monetary units (flow variables) and apply the PPP conversions. I also apply the square root equivalence scale to correct for household size. This equivalence scale implies that a household of four members needs only double the income of a one-person household to reach the same level of consumption.

### Output: Loop over datasets and report summary statistics
The final step is to use the program on each country-year in the LIS database. I run different versions of code for the gross, mixed, and net datasets.
```
foreach ccyy in $datasets {
   use $pvars using $`ccyy'p,clear
   quietly gen_pvars
   quietly merge 1:1 hid using $`ccyy'h, keepusing($hvars
           $hvarsflow) nogenerate
   quietly gen_hxct
   quietly income_stages
   quietly ppp_equiv
   quietly capture sgini transfer [aw=hwgt], sortvar(inc2)
   local transconc = r(coeff)
   quietly capture sgini tax [aw=hwgt], sortvar(inc2)
   local taxconc = r(coeff)
   quietly sum inc2 [w=hwgt]
   local income_mean = r(mean)
   quietly sum transfer [w=hwgt]
   local transfer_mean = r(mean)
   quietly sum tax [w=hwgt]
   local tax_mean = r(mean)
   foreach var in $hvarsinc {
   quietly fastgini `var' [w=hwgt] , nocheck
   local `var'_gini = r(gini)
   forvalues num = 1/10 {
   quietly sum `var' [w=hwgt] if decile==`num'
   local `var'_mean_`num' = r(mean)
   local `var'_min_`num' = r(min)
   local `var'_max_`num' = r(max)
 }
 }
	if "`ccyy'" == "au03" di "countryyear,decile,inc1_mean,inc1_min,inc1_max,inc2_mean ...
		di "`ccyy',D01,`inc1_mean_1',`inc1_min_1',`inc1_max_1',`inc2_mean_1 ...
```
This final part of the code may be divided into three parts. Firstly, the programs are run to impute and generate the relevant variables. Secondly, a range of summary statistics are calculated and recorded in the Stata memory. Lastly, the summary statistics are displayed in a format that makes it convenient to extract them from the text log file, which is sent via email.

#### Summary statistics
The program calculates the following summary statistics:
- Gini inequality index for each definition of income.
- The concentration coefficient of taxes and transfers, sorted by market income and by gross income.
- The Kakwani index of tax or transfer progressivity may be calculated by using the Gini index and the concentration coefficient. To check the accuracy of our results, I also calculate the Kakwani index directly using a separate command.
- Mean, miniumum, and maxium of each income variable at each decile
- Mean, minimum, and maximum of taxes and transfers at each decile

All of the above summary statistics use population weights to ensure the statistics are nationally representative. I analyse the missing values of each variable in each dataset by decile to determine if non-response may bias any of the results.

### Converting the log file to a useful format

Running the code produces a lengthy text log file. I first copy the relevant portions of the log file to a text editor. Most of the data displayed in the log file ran over multiple lines. The first step was to remove the characters separating each line. This was done using a find and replace command. The lines were separated by three characters: "return", ">" and "space".

Once cleaned of the unnecessary characters, the data was copied to a Google Sheets spreadsheet. All figures are separated by a comma. I used the split function in Google Sheets to separate the data into columns. Variables for the country and year of each observation are added using a vlookup function by matching the database code.

Finally, the spreadsheet is downloaded as comma separated values file (.csv) and imported into Stata. Variable labels are added and one new variable is created to convert the decile variable to numeric format.

## Data sources
Although I primarily used data from the Luxembourg Income Study, I also used additional data sources for certain imputations:
- [OECD Taxing Wages](http://dx.doi.org/10.1787/tax_wages-2015-en) publications (1999 to 2015) provided statutory rates and ceiling for employer and employee social security contributions as well as income tax.
- World Development Indicators database (WDI) provided PPP conversion rates.

## Terms of use for LIS data
The terms of use for LIS data require research to be submitted to the LIS Working Paper series.

The datasets must be cited as follows:
> Luxembourg Income Study Database (LIS), www.lisdatacenter.org (multiple countries; [Start date] to [End Date]). Luxembourg: LIS.
