cd "C:\Users\zemmour\Documents\GitHub\lis-tax-transfer\"


****************************************************************************************
*********Put together the country level variable from Inequality measures 1 to 6********
****************************************************************************************


import delimited "Stata\log\logfile.csv", varnames(1) clear


**drop the decile part****
drop if decile=="D01"|decile=="D02"|decile=="D03"|decile=="D04"|decile=="D05"|decile=="D06"|decile=="D07"|decile=="D08"|decile=="D09"|decile=="D10"

*******sort so that the headers becomes the first 6 obs****
gsort -inc1_mean


keep decile 
duplicates drop decile, force 
rename decile countryyear
save "Stata\output\Sumstat.dta", replace

******Isolate the 6 subpart, replace the variable name by the first obs, and merge to the Sumstat.dta"

forvalues i=1(1)7{
import delimited "Stata\log\logfile.csv", varnames(1) clear
drop if decile=="D01"|decile=="D02"|decile=="D03"|decile=="D04"|decile=="D05"|decile=="D06"|decile=="D07"|decile=="D08"|decile=="D09"|decile=="D10"
keep if countryyear=="Inequality Measures `i'"
gsort -inc1_mean
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
save "Stata\output\Sumstat`i'.dta", replace
merge 1:1 countryyear using "Stata\output\Sumstat.dta", gen(_merge`i')
save "Stata\output\Sumstat.dta", replace
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
save "Stata\output\LIS Reducing Inequality Country.dta", replace

sort country year

merge 1:1 country year using "Stata\dta\allOECD2.dta"

save "Stata\output\LIS et OECD.dta", replace

*************include EPL index*********
import delimited "Stata\dta\EPL_OECD.csv", clear 

rename time year
rename value EPL
keep country year EPL

sort country year
save "Stata\output\EPL.dta", replace

use "Stata\output\LIS et OECD.dta", clear

merge 1:1 country year using "Stata\output\EPL.dta", gen(_merge2)

save "Stata\output\LIS et OECD.dta", replace

*************************************
*********Display the deciles ********
*************************************

import delimited "Stata\log\logfile.csv", varnames(1) clear

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

save "Stata\output\LIS Inc2 Decile.dta", replace
