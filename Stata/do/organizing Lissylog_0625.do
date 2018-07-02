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


