clear
cd "C:\Users\zemmour\Documents\GitHub\lis-tax-transfer\"
global incconcept "inc1 inc2 inc3 inc3_sser inc3_ssee inc4"
global filename "log_0625.csv"
****************************************************************************************
*********Put together the country level variable from Inequality measures 1 to 6********
****************************************************************************************


import delimited $filename, delimiter(comma) varnames(1) clear

**drop the decile part****
drop if decile=="D01"|decile=="D02"|decile=="D03"|decile=="D04"|decile=="D05"|decile=="D06"|decile=="D07"|decile=="D08"|decile=="D09"|decile=="D10"

*******sort so that the headers becomes the first 6 obs****
gsort -inc1_mean_inc1


keep decile 
duplicates drop decile, force 
rename decile countryyear
save "Sumstat.dta", replace

******Isolate the 6 subpart, replace the variable name by the first obs, and merge to the Sumstat.dta"

forvalues i=1(1)7{
import delimited $filename, varnames(1) clear
drop if decile=="D01"|decile=="D02"|decile=="D03"|decile=="D04"|decile=="D05"|decile=="D06"|decile=="D07"|decile=="D08"|decile=="D09"|decile=="D10"
keep if countryyear=="Inequality Measures `i'"
gsort -inc1_mean_inc1
drop countryyear
missings dropvars, force

/*don't know why does not work when done only once*/
ds
	foreach v in `r(varlist)' {
	local try = strtoname(`v'[1]) 
     capture rename `v'  `try' 
	}
	ds
	foreach v in `r(varlist)' {
	local try = strtoname(`v'[1]) 
     capture rename `v'  `try' 
	}
	ds
	foreach v in `r(varlist)' {
	local try = strtoname(`v'[1]) 
     capture rename `v'  `try' 
	}
save "Sumstat`i'.dta", replace
merge 1:1 countryyear using "Sumstat.dta", gen(_merge`i')
save "Sumstat.dta", replace
}
drop _merge1-_merge7

***drop the obs containing the header****
drop if countryyear=="countryyear"

**destring all variables but the first
ds
foreach v in `r(varlist)' {
destring `v', replace
}
********generate country code and year*****
gen ccode = substr(countryyear, 1, 2)

gen year=substr(countryyear,3,2)
destring year, replace
replace year=year+1900 if year>50
replace year=year+2000 if year<50

kountry ccode, from(iso2c)
rename NAMES_STD country

*****save the data set and include OECD macro data*****
label variable countryyear "Dataset identifier"
label variable country "Country"
label variable year "Year"

label variable inc1_gini "Primary Income"
label variable inc2_gini "Market Income"
label variable inc3_gini "Gross Income"
label variable inc4_gini "Disposable Income"
label var dhi_gini "Disposable household income (from the LIS variable dhi)"

label variable transfer_conc_inc1 "Transfer Concentration Coeffiicient (Primary Income)"
label variable transfer_conc_inc2 "Transfer Concentration Coeffiicient (Market Income)"
label variable transfer_conc_inc3 "Transfer Concentration Coeffiicient (Gross Income)"
label variable transfer_conc_inc4 "Transfer Concentration Coeffiicient (Disposable Income)"

label variable tax_conc_inc1 "Tax Concentration Coefficient (Primary Income)"
label variable tax_conc_inc2 "Tax Concentration Coefficient (Market Income)"
label variable tax_conc_inc3 "Tax Concentration Coefficient (Gross Income)"
label variable tax_conc_inc4 "Tax Concentration Coefficient (Disposable Income)"

label var inc1_mean "Primary Income"
label var inc2_mean "Market income"
label var inc3_mean "Gross Income"
label var inc4_mean "Disposable Income"
label var dhi_mean "Disposable household income (from the LIS variable dhi)"

label var transfer_mean "Social transfers"
label var tax_mean "Taxes and social security contributions"
label var allpension_mean "Public and private pensions"
label var pubpension_mean "Public pensions"
label var pripension_mean "Private pensions"

label var inc1_conc_inc1 "Primary Income Concentration Coefficient (Primary Income)"
label var inc1_conc_inc2 "Primary Income Concentration Coefficient (Market Income)"
label var inc1_conc_inc3 "Primary Income Concentration Coefficient (Gross Income)"
label var inc1_conc_inc4 "Primary Income Concentration Coefficient (Disposable Income)"
label var inc2_conc_inc1 "Market Income Concentration Coefficient (Primary Income)"
label var inc2_conc_inc2 "Market Income Concentration Coefficient (Market Income)"
label var inc2_conc_inc3 "Market Income Concentration Coefficient (Gross Income)"
label var inc2_conc_inc4 "Market Income Concentration Coefficient (Disposable Income)"
label var inc3_conc_inc1 "Gross Income Concentration Coefficient (Primary Income)"
label var inc3_conc_inc2 "Gross Income Concentration Coefficient (Market Income)"
label var inc3_conc_inc3 "Gross Income Concentration Coefficient (Gross Income)"
label var inc3_conc_inc4 "Gross Income Concentration Coefficient (Disposable Income)"
label var inc4_conc_inc1 "Disposable Income Concentration Coefficient (Primary Income)"
label var inc4_conc_inc2 "Disposable Income Concentration Coefficient (Market Income)"
label var inc4_conc_inc3 "Disposable Income Concentration Coefficient (Gross Income)"
label var inc4_conc_inc4 "Disposable Income Concentration Coefficient (Disposable Income)"


label var allpension_conc_inc1 "Pension Concentation Coefficient (Primary Income)"
label var allpension_conc_inc2 "Pension Concentation Coefficient (Market Income)"
label var allpension_conc_inc3 "Pension Concentation Coefficient (Gross Income)"
label var allpension_conc_inc4 "Pension Concentation Coefficient (Disposable Income)"
label var pubpension_conc_inc1 "Public Pension Concentation Coefficient (Primary Income)"
label var pubpension_conc_inc2 "Public Pension Concentation Coefficient (Market Income)"
label var pubpension_conc_inc3 "Public Pension Concentation Coefficient (Gross Income)"
label var pubpension_conc_inc4 "Public Pension Concentation Coefficient (Disposable Income)"
label var pripension_conc_inc1 "Private Pension Concentation Coefficient (Primary Income)"
label var pripension_conc_inc2 "Private Pension Concentation Coefficient (Market Income)"
label var pripension_conc_inc3 "Private Pension Concentation Coefficient (Gross Income)"
label var pripension_conc_inc4 "Private Pension Concentation Coefficient (Disposable Income)"

label variable hxits_mean "Employee Social Security Contributions (LIS and Imputations)"
label variable hsscee_mean "Employee Social Security Contributions (Imputed)"
label variable hsscer_mean "Employer Social Security Contributions (Imputed)"
label variable hssc_mean "Social Security Contributions (Imputed)"

label variable hxits_conc_inc3 "Social Security Contributions"
label variable hsscee_conc_inc3 "Employee Social Security Contributions"
label variable hsscee_conc_inc3 "Employee Social Security Contributions (Imputed)"
label variable hsscer_conc_inc3 "Employer Social Security Contributions (Imputed)"
label variable hssc_conc_inc3 "Social Security Contributions (Imputed)"

save "LIS Reducing Inequality Country.dta", replace

sort country year

merge 1:1 country year using "Stata\dta\allOECD2.dta"

save "LIS et OECD.dta", replace

*************include EPL index*********
import delimited "Stata\dta\EPL_OECD.csv", clear 

rename time year
rename value EPL
keep country year EPL

sort country year
save "EPL.dta", replace

use "LIS et OECD.dta", clear

merge 1:1 country year using "EPL.dta", gen(_merge2)

save "LIS et OECD.dta", replace

*************************************
*********Display the deciles ********
*************************************

import delimited $filename, varnames(1) clear

keep if decile=="D01"|decile=="D02"|decile=="D03"|decile=="D04"|decile=="D05"|decile=="D06"|decile=="D07"|decile=="D08"|decile=="D09"|decile=="D10"

ds
foreach v in `r(varlist)' {
destring `v', replace
}

********generate country code and year*****
gen ccode = substr(countryyear, 1, 2)

gen year=substr(countryyear,3,2)
destring year, replace
replace year=year+1900 if year>50
replace year=year+2000 if year<50

kountry ccode, from(iso2c)
rename NAMES_STD country


/******* On génère maintenant des rapports interquantiles avec les vraies définitions**********/

encode(countryyear), gen(ccyy)
foreach var in $incconcept{
forvalues j=1(4)9{
bysort ccyy (decile) : gen d`j'_`var'=`var'_max_`var'[`j']
}

bysort ccyy (decile) : gen d9d1_`var' = d9_`var'/d1_`var'
bysort ccyy (decile) : gen d5d1_`var' = d5_`var'/d1_`var'
bysort ccyy (decile) : gen d9d5_`var' = d9_`var'/d5_`var'
}

bysort ccyy (decile) : gen reduc_d9d5_cotis=d9d5_inc3 - d9d5_inc3_ssee /*Rappel inc3_ssee : inc3 - cotis (employes et employeurs)*/
bysort ccyy (decile) : gen reduc_d9d5_tax=d9d5_inc3_ssee - d9d5_inc4 

bysort ccyy (decile) : gen reduc_d5d1_cotis=d5d1_inc3 - d5d1_inc3_ssee /*Rappel inc3_ssee : inc3 - cotis (employes et employeurs)*/
bysort ccyy (decile) : gen reduc_d5d1_tax=d5d1_inc3_ssee - d5d1_inc4 


bysort ccyy (decile) : gen reduc_d9d5_cotis_employeur=d9d5_inc3 - d9d5_inc3_sser /*Rappel inc3_ssee : inc3 - cotis (employes et employeurs)*/
bysort ccyy (decile) : gen reduc_d9d5_cotis_salarie=d9d5_inc3_sser - d9d5_inc3_ssee/*Rappel inc3_ssee : inc3 - cotis (employes et employeurs)*/

bysort ccyy (decile) : gen reduc_d5d1_cotis_employeur=d5d1_inc3 - d5d1_inc3_sser
bysort ccyy (decile) : gen reduc_d5d1_cotis_salarie=d5d1_inc3_sser - d5d1_inc3_ssee


save "Export deciles.dta", replace





**************************************
*Organise the file without imputation*
***************************************


clear
cd "C:\Users\zemmour\Documents\GitHub\lis-tax-transfer\"
global incconcept "inc1 inc2 inc3 inc3_sser inc3_ssee inc4"
global filename "NI_log_0625.csv"
****************************************************************************************
*********Put together the country level variable from Inequality measures 1 to 6********
****************************************************************************************

import delimited $filename, delimiter(comma) varnames(1) clear

**drop the decile part****
drop if decile=="D01"|decile=="D02"|decile=="D03"|decile=="D04"|decile=="D05"|decile=="D06"|decile=="D07"|decile=="D08"|decile=="D09"|decile=="D10"

*******sort so that the headers becomes the first 6 obs****
gsort -inc1_mean_inc1


keep decile 
duplicates drop decile, force 
rename decile countryyear
save "Sumstat.dta", replace

******Isolate the 6 subpart, replace the variable name by the first obs, and merge to the Sumstat.dta"

forvalues i=1(1)7{
import delimited $filename, varnames(1) clear
drop if decile=="D01"|decile=="D02"|decile=="D03"|decile=="D04"|decile=="D05"|decile=="D06"|decile=="D07"|decile=="D08"|decile=="D09"|decile=="D10"
keep if countryyear=="Inequality Measures `i'"
gsort -inc1_mean_inc1
drop countryyear
missings dropvars, force

/*don't know why does not work when done only once*/
ds
	foreach v in `r(varlist)' {
	local try = strtoname(`v'[1]) 
     capture rename `v'  `try' 
	}
	ds
	foreach v in `r(varlist)' {
	local try = strtoname(`v'[1]) 
     capture rename `v'  `try' 
	}
	ds
	foreach v in `r(varlist)' {
	local try = strtoname(`v'[1]) 
     capture rename `v'  `try' 
	}
save "Sumstat`i'.dta", replace
merge 1:1 countryyear using "Sumstat.dta", gen(_merge`i')
save "Sumstat.dta", replace
}
drop _merge1-_merge7

***drop the obs containing the header****
drop if countryyear=="countryyear"

**destring all variables but the first
ds
foreach v in `r(varlist)' {
destring `v', replace
}
********generate country code and year*****
gen ccode = substr(countryyear, 1, 2)

gen year=substr(countryyear,3,2)
destring year, replace
replace year=year+1900 if year>50
replace year=year+2000 if year<50

kountry ccode, from(iso2c)
rename NAMES_STD country

*****save the data set and include OECD macro data*****
save "NI_LIS Reducing Inequality Country.dta", replace

sort country year

merge 1:1 country year using "Stata\dta\allOECD2.dta"

save "NI_LIS et OECD.dta", replace

*************include EPL index*********
import delimited "Stata\dta\EPL_OECD.csv", clear 

rename time year
rename value EPL
keep country year EPL

sort country year
save "EPL.dta", replace

use "NI_LIS et OECD.dta", clear

merge 1:1 country year using "EPL.dta", gen(_merge2)

save "NI_LIS et OECD.dta", replace

*************************************
*********Display the deciles ********
*************************************

import delimited $filename, varnames(1) clear

keep if decile=="D01"|decile=="D02"|decile=="D03"|decile=="D04"|decile=="D05"|decile=="D06"|decile=="D07"|decile=="D08"|decile=="D09"|decile=="D10"

ds
foreach v in `r(varlist)' {
destring `v', replace
}

********generate country code and year*****
gen ccode = substr(countryyear, 1, 2)

gen year=substr(countryyear,3,2)
destring year, replace
replace year=year+1900 if year>50
replace year=year+2000 if year<50

kountry ccode, from(iso2c)
rename NAMES_STD country


/******* On génère maintenant des rapports interquantiles avec les vraies définitions**********/

encode(countryyear), gen(ccyy)
foreach var in $incconcept{
forvalues j=1(4)9{
bysort ccyy (decile) : gen d`j'_`var'=`var'_max_`var'[`j']
}

bysort ccyy (decile) : gen d9d1_`var' = d9_`var'/d1_`var'
bysort ccyy (decile) : gen d5d1_`var' = d5_`var'/d1_`var'
bysort ccyy (decile) : gen d9d5_`var' = d9_`var'/d5_`var'
}

bysort ccyy (decile) : gen reduc_d9d5_cotis=d9d5_inc3 - d9d5_inc3_ssee /*Rappel inc3_ssee : inc3 - cotis (employes et employeurs)*/
bysort ccyy (decile) : gen reduc_d9d5_tax=d9d5_inc3_ssee - d9d5_inc4 

bysort ccyy (decile) : gen reduc_d5d1_cotis=d5d1_inc3 - d5d1_inc3_ssee /*Rappel inc3_ssee : inc3 - cotis (employes et employeurs)*/
bysort ccyy (decile) : gen reduc_d5d1_tax=d5d1_inc3_ssee - d5d1_inc4 


bysort ccyy (decile) : gen reduc_d9d5_cotis_employeur=d9d5_inc3 - d9d5_inc3_sser /*Rappel inc3_ssee : inc3 - cotis (employes et employeurs)*/
bysort ccyy (decile) : gen reduc_d9d5_cotis_salarie=d9d5_inc3_sser - d9d5_inc3_ssee/*Rappel inc3_ssee : inc3 - cotis (employes et employeurs)*/

bysort ccyy (decile) : gen reduc_d5d1_cotis_employeur=d5d1_inc3 - d5d1_inc3_sser
bysort ccyy (decile) : gen reduc_d5d1_cotis_salarie=d5d1_inc3_sser - d5d1_inc3_ssee


save "NI_Export deciles.dta", replace





