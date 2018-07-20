# Analyze the impact of taxes and transfers on inequality using LIS data
Research project by [Elvire Guillaud](https://sites.google.com/site/elvireguillaud/), [Matthew Olckers](http://www.matthewolckers.com/), and [Michaël Zemmour](https://sites.google.com/site/mzemmour/home).

This repo includes all the code and supplementary data needed to extract the data from the Luxembourg Income Study (LIS) database we used in our study [Four levers of redistribution: The impact of tax and transfer systems on inequality reduction](http://www.lisdatacenter.org/wps/liswps/695.pdf). The [Luxembourg Income Study (LIS)](http://www.lisdatacenter.org/) provides harmonized national survey data from 46 countries over multiple years. The database in constantly growing by including new countries and expanding the number of years per country.

One of the main contributions of our paper is to enrich the LIS data by imputing employer (and in some cases employee) social security contributions. Researchers wishing to include the imputations in their own code may fork this repository.

In addition to the authors, [Victor Amoureux](https://fr.linkedin.com/in/victor-amoureux-54579194) contributed extensively to the code.  

## Explaining the code used to retrieve the data
Data is retrieved using the LISSY interface, which allows the researcher to input Stata code and the Stata output text is then returned via email (log file). The data restrictions on LIS prevent you from viewing the data itself. Commands such a list or browse cannot be used. My approach was to gather a series of summary statistics of the LIS data to create a new country-level dataset.

This section provides a step-by-step guide to the Stata code we used to create the main set of variables in the country-level dataset. The code snippet is shown first, with the corresponding explanation underneath. Most the code refers to the file `1a_Extract_from_Lissy.do` located in the `Stata\do` sub-directory. 

(Disclaimer: It may have been much easier to do this in R but LIS added support for R only after we had already started. If you wish to redo our work in R, please do!)

### Start by defining the globals

```
global datasets "at04 at07 at13 au03 au08 au10 ca04 ...

global net_datasets "at00 be00 gr00 hu05 hu07 ...

global pvars "pid hid dname pil pxit pxiti pxits age emp relation"

global hvars "hid dname nhhmem dhi nhhmem17 nhhmem65 hwgt"

global hvarsflow "hil hic pension hits hitsil ...

```
The program (.do file) begins by defining a set of globals. The globals are simply a shortening for the text inside the inverted commas. The global datasets corresponds to all the country-years on which this program will be executed. For example, au03 represent Australia 2003. At the time we started, LIS had 266 country-years in their database. The database grows as new national household surveys are harmonized to the LIS structure.

The other globals such as pvars, hvars, etc. are lists of variables that are used in certain parts of the program. Globals allow the code to be simplified. If you wish to add a new variable, you only have to add the variable name to the relevant global rather than editing many parts of the program.

### Program 1: Generate social security variables from person level dataset
```
program define gen_pvars
  merge_ssc
  gen_employee_ssc
  manual_corrections_employee_ssc
  gen_employer_ssc
  manual_corrections_employer_ssc
  convert_ssc_to_household_level
end
```
The most efficient way to work with LISSY is to define all the programs first, and then implement the programs with a loop over all country-years (taking special care to output only the information you need). By default, Stata log output includes many details of the intermediate steps of your program, but these details may be suppressed by defining the program first and running the program quietly .

The above code defines the first program `gen_pvars`, which works off the individual-level data recorded in LIS.`gen_pvars` is a collection of sub-programs that implement each step. The `gen_pvars` program starts with the `merge_ssc` sub-program, which merges an external dataset hosted the LIS server of the particular country-year under observation. The variable `dname` is short for dataset name. For example, `au03` is a `dname` for Australia 2003. 

```
program define merge_ssc
	merge m:1 dname using "$mydata/vamour/SSC_20180621.dta", keep(match) nogenerate
end
```

The file *SSS_YYYYMMDD.dta* contains a set of social security rates and ceiling for each country-year. Once the relevant rates and ceiling are merged into the individual-level dataset, the employer social security contributions may be imputed.


```
program define gen_employer_ssc
  * Generate Employer Social Security Contributions
  gen psscer=.
  replace psscer = pil*er_r1
  replace psscer = (pil-er_c1)*er_r2 + er_r1*er_c1  if pil>er_c1 & er_c1!=.
  ...
```

Social security contributions are imputed with a series of *replace* commands. The code starts by applying the rate below the first ceiling. It then corrects the social security contributions for all individuals above the first ceiling, and then above the second ceiling, and so on. All surveys in the LIS database contain household-level and individual-level variables. Individual level variables have the prefix `p`, for person. `p` is individual level labour income.  


In certain cases the social security contributions are too complex to be summarised by a set of rates and ceilings. For example, France includes a sliding scale rebate to employer social security contributions for employees paid at and up to 1.6 times the minimum wage. We include manual adjustments for these country-years.

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

This project focusses on income, taxes, and transfers so any difference in the measurement of these variables across countries creates additional challenges to extract the data. The most common difference results from the income measure, which may be before or after taxes. *Gross* datasets measure income before income taxes and social security contributions. *Net* datasets measure income after income taxes and social security contributions. *Mixed* datasets (such as France) measure income after social security contributions, but before income taxes. The table below shows the split of the LIS database between these different type of datasets (at the time we started our project). 


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
replace psscee = 1/(1-ee_r2)*(ee_r2*(pil - ee_c1) + ee_r1*ee_c1) if pil>(ee_c1 - ee_r1*ee_c1) & pil<=(ee_c2 - ee_r1*ee_c1 - ee_r2*(ee_c2-ee_c1))
```
Notice the adjustment to the formula when the input is mixed income instead of gross income. The formula must be divided by `(1-er_r2)` where `er_r2` is still the statutory rate that applies to gross income. This adjustment may seem confusing at first glance, but it can be easily derived.

### Program 2: Define the different stages of income

```
program define inc_and_decile

  gen inc1 = marketincome
  gen inc2 = marketincome + allpension
  gen inc3 = marketincome + allpension + transfer
  gen inc4 = marketincome + allpension + transfer - tax
  ...
```  
The second program uses the income, tax, and transfer variables to define the stages of income of interest in this study. The table below provides definitions of the income stages. 

| Variable name | Concept | Definition |
|----|----|----|
| inc1 | Primary income | Income from labour and capital |  
| inc2 | Market income | Primary income + pensions |
| inc3 | Gross income | Market income + cash social transfers (other than pensions) |
| inc4 | Disposable income | Gross income - income taxation and social security contribution (employer and employee) |  

The variables are defined in the program `def_tax_and_transfer`. All variables are at the household level (as shown by h prefix in the variable names). .If you add or subtract missing values in Stata, the result will be equal to missing. We have set the missing values equal to zero for several variables to prevent this problem.

```
program define def_tax_and_transfer
  ...
  replace pubpension=0 if pubpension==.
  replace hits=0 if hits==.
  replace hicvip=0 if hicvip==.
  replace hitsil=0 if hitsil==.
  ...
  gen tax = hxit + hsscer
  gen hssc = hxits + hsscer
  gen marketincome = hil + (hic-hicvip) + hsscer
  ...
```

#### Program 3 Apply PPP conversions and equivalence scales to flow variables
```
program define ppp_equiv
  * Define PPP conversions to 2011 international dollars (ppp)
  merge m:1 dname using "$mydata/vamour/ppp_20180622.dta", keep(match) nogenerate

  * Complete the PPP conversions and equivalence scales with replace commands
  foreach var in $hvarsflow $hvarsnew {
    replace `var' = (`var'*ppp_2011_usd)/(nhhmem^0.5)
    }
...
```
Certain summary statistics are displayed in currency units so we completed purchasing power parity (PPP) conversions to allow for comparisons across countries. The excerpt above shows how the PPP conversions are completed.

We run a loop over all the variables that are measured in monetary units (flow variables) and apply the PPP conversions. We also apply the square root equivalence scale to correct for household size. This equivalence scale implies that a household of four members needs only double the income of a one-person household to reach the same level of consumption.

### Output: Loop over datasets and report summary statistics
The final step is to use the program on each country-year in the LIS database. Slightly different codes are used for the mixed datasets of Italy and France. 

```
foreach ccyy in $datasets {
  quietly use $pvars using $`ccyy'p, clear
  local cc : di substr("`ccyy'",1,2)
  if "`cc'" == "fr" {
    quietly merge m:1 hid using "$`ccyy'h", keep(match) keepusing(hxiti) nogenerate
    quietly FR_gen_pvars
  }
  else if "`cc'" == "it" {
    quietly merge m:1 hid using "$`ccyy'h", keep(match) keepusing(hxiti) nogenerate
    quietly IT_gen_pvars
  }
  else if strpos("$net_datasets","`ccyy'") > 0 {
    quietly NET_gen_pvars
  }
  else {
    quietly gen_pvars
  }
  quietly merge 1:1 hid using $`ccyy'h,  nogenerate // keepusing($hvars $hvarsflow)
  quietly missing_values
  if "`cc'" == "fr" {
    quietly correct_dhi
  }
  quietly ppp_equiv
  quietly def_tax_and_transfer
  if "`cc'" == "fr" {
    quietly FR_def_tax_and_transfer
  }
  foreach certain_ccyy in $fixpensions_datasets3 {
    quietly fix_pensions_type3 if "`ccyy'" == "`certain_ccyy'"
  }
  foreach var in $hvarsinc $hvarsflow $hvarsnew {
    quietly capture sgini `var' [aw=hwgt*nhhmem]
    local `var'_gini = r(coeff)
	quietly capture sgini `var' [aw=hwgt*nhhmem] if hhactivage==1
    local hhaa_`var'_gini = r(coeff)
    quietly sum `var' [w=hwgt*nhhmem]
    local `var'_mean = r(mean)
	quietly sum `var' [w=hwgt*nhhmem] if hhactivage==1
    local hhaa_`var'_mean = r(mean)
    foreach sortvar in $incconcept {
      quietly capture sgini `var' [aw=hwgt*nhhmem], sortvar(`sortvar')
      local `var'conc_`sortvar' = r(coeff)
	  quietly capture sgini `var' [aw=hwgt*nhhmem] if hhactivage==1, sortvar(`sortvar')
      local hhaa_`var'conc_`sortvar' = r(coeff)
      }
	foreach var2 in $incconcept{
		forvalues num = 1/10 {
			quietly sum `var' [w=hwgt*nhhmem] if decile_`var2'==`num'
			local `var'_mean_`num'_`var2' = r(mean)
			local `var'_min_`num'_`var2' = r(min)
			local `var'_max_`num'_`var2' = r(max)
    				      }			
			            }
   }
  
     if "`ccyy'" == "at04" di "countryyear,decile,inc1_mean_inc1,inc1_min_inc1,inc1_max_inc1...
     di "`ccyy',D01,`inc1_mean_1_inc1',`inc1_min_1_inc1',`inc1_max_1_inc1'...
```
This final part of the code may be divided into three parts. Firstly, the programs are run to impute and generate the relevant variables. Secondly, a range of summary statistics are calculated and recorded in the Stata memory. Lastly, the summary statistics are displayed in a format that makes it convenient to extract them from the text log file, which is sent via email.

#### Summary statistics
The program calculates the following summary statistics:
- Gini inequality index for each definition of income.
- The concentration coefficient of taxes and transfers, sorted by market income and by gross income.
- The Kakwani index of tax or transfer progressivity may be calculated by using the Gini index and the concentration coefficient. To check the accuracy of our results, I also calculate the Kakwani index directly using a separate command.
- Mean, miniumum, and maxium of each income variable at each decile
- Mean, minimum, and maximum of taxes and transfers at each decile

All of the above summary statistics use population weights to ensure the statistics are nationally representative. We analyse the missing values of each variable in each dataset by decile to determine if non-response may bias any of the results.

### Converting the log file to a useful format

Running the code produces a lengthy text log file. I first copy the relevant portions of the log file to a text editor. Most of the data displayed in the log file ran over multiple lines. The first step was to remove the characters separating each line. This was done using a find and replace command. The lines were separated by three characters: "return", ">" and "space".

Once cleaned of the unnecessary characters, the data was copied to a Google Sheets spreadsheet. All figures are separated by a comma. I used the split function in Google Sheets to separate the data into columns. Variables for the country and year of each observation are added using a vlookup function by matching the database code.

Finally, the spreadsheet is downloaded as comma separated values file (.csv) and imported into Stata. Variable labels are added and one new variable is created to convert the decile variable to numeric format.

## Data sources for imputations
Although we primarily used data from the Luxembourg Income Study, we also used the [OECD Taxing Wages](http://dx.doi.org/10.1787/tax_wages-2015-en) publications (1999 to 2015) to provide statutory rates and ceilings for employer and employee social security contributions.

## Terms of use for LIS data
The terms of use for LIS data require research to be submitted to the LIS Working Paper series.

The datasets must be cited as follows:
> Luxembourg Income Study Database (LIS), www.lisdatacenter.org (multiple countries; [Start date] to [End Date]). Luxembourg: LIS.
