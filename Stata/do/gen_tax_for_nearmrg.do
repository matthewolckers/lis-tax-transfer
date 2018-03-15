clear all
set more off

global folder "/Users/matthewolckers/Google Drive/Research/RA Work/Guillaud and Zemmour/2016"

**********
* Version: 2 * 29 June 2016
**********

* Set the number of "buckets" for the approximate merge
set obs 10000
gen x = _n
replace x = x / 10000

gen pilat00  = 4320000
gen pilbe00  = 78240000
gen piles00  = 36000000
gen pilgr00  = 42000000
gen pilhu05  = 21600000
gen pilhu07  = 14800000
gen pilhu09  = 9400000
gen pilhu12  = 9600000
gen pilhu99  = 7140000
gen pilie00  = 278000
gen pilit00  = 729285500
gen pilit98  = 799000000
gen pillu00  = 7357127
gen pilmx00  = 2307360
gen pilmx02  = 1200000
gen pilmx04  = 8279640
gen pilmx08  = 17348908
gen pilmx10  = 3774701
gen pilmx12  = 3130435
gen pilmx98  = 3820000
gen pilsi10  = 139151

global datasets "pilat00 pilbe00 piles00 pilgr00 pilhu05 pilhu07 pilhu09 pilhu12 pilhu99 pilie00 pilit00 pilit98 pillu00 pilmx00 pilmx02 pilmx04 pilmx08 pilmx10 pilmx12 pilmx98 pilsi10"

foreach var in $datasets {
	replace `var' = `var'*x*2
	}

reshape long pil , i(x) j(dname) string

merge m:1 dname using "$folder/net_taxrates.dta", keep(match) nogenerate

*-------------------------------------------------------------------------------

**************
* Employer SSC
**************

gen psscer=.
replace psscer = pil*er_r1
replace psscer = (pil-er_c1)*er_r2 + er_r1*er_c1  if pil>er_c1 & er_c1!=.
replace psscer = (pil-er_c2)*er_r3 + er_r2*er_c2 + er_r1*er_c1 if pil>er_c2 & er_c2!=.
replace psscer = (pil-er_c3)*er_r4 + er_r3*er_c3 + er_r2*er_c2 + er_r1*er_c1 if pil>er_c3 & er_c3!=.
replace psscer = (pil-er_c4)*er_r5 + er_r4*er_c4 + er_r3*er_c3 + er_r2*er_c2 + er_r1*er_c1 if pil>er_c4 & er_c4!=.
replace psscer = (pil-er_c5)*er_r6 + er_r5*er_c5 + er_r4*er_c4 + er_r3*er_c3 + er_r2*er_c2 + er_r1*er_c1  if pil>er_c5 & er_c5!=.


**************
* Employee SSC
**************

* Generate Employee Social Security Contributions
gen psscee=.
replace psscee = pil*ee_r1
replace psscee = (pil-ee_c1)*ee_r2 + ee_r1*ee_c1  if pil>ee_c1 & ee_c1!=.
replace psscee = (pil-ee_c2)*ee_r3 + ee_r2*(ee_c2 - ee_c1) + ee_r1*ee_c1 if pil>ee_c2 & ee_c2!=.
replace psscee = (pil-ee_c3)*ee_r4 + ee_r3*(ee_c3 - ee_c2) + ee_r2*(ee_c2 - ee_c1) + ee_r1*ee_c1 if pil>ee_c3 & ee_c3!=.
replace psscee = (pil-ee_c4)*ee_r5 + ee_r4*(ee_c4 - ee_c3) + ee_r3*(ee_c3 - ee_c2) + ee_r2*(ee_c2 - ee_c1) + ee_r1*ee_c1 if pil>ee_c4 & ee_c4!=.
replace psscee = (pil-ee_c5)*ee_r6 + ee_r5*(ee_c5 - ee_c4) + ee_r4*(ee_c4 - ee_c3) + ee_r3*(ee_c3 - ee_c2) + ee_r2*(ee_c2 - ee_c1) + ee_r1*ee_c1  if pil>ee_c5 & ee_c5!=.

	* Manual corrections for certain datasets (Employee Social Security Contributions)

	*Belgium 2000 BE00
	replace psscee=psscee-2600 if pil>34000 & pil<=42500 & dname=="be00"
	replace psscee=psscee-(2600-0.4*(pil-42500)) if pil>42500 & pil<=4900 & dname=="be00"

																				// I need to check if there are other manual adjustments for the other datasets

**************
* Conversion 1
**************

replace pil = pil - psscee // In most countries SSC are deductible for calculating income tax.

************
* Income Tax
************

gen pinctax=.
replace pinctax = pil*it_r1
replace pinctax = (pil-it_c1)*it_r2 + it_r1*it_c1  if pil>it_c1 & it_c1!=.
replace pinctax = (pil-it_c2)*it_r3 + it_r2*(it_c2 - it_c1) + it_r1*it_c1 if pil>it_c2 & it_c2!=.
replace pinctax = (pil-it_c3)*it_r4 + it_r3*(it_c3 - it_c2) + it_r2*(it_c2 - it_c1) + it_r1*it_c1 if pil>it_c3 & it_c3!=.
replace pinctax = (pil-it_c4)*it_r5 + it_r4*(it_c4 - it_c3) + it_r3*(it_c3 - it_c2) + it_r2*(it_c2 - it_c1) + it_r1*it_c1 if pil>it_c4 & it_c4!=.
replace pinctax = (pil-it_c5)*it_r6 + it_r5*(it_c5 - it_c4) + it_r4*(it_c4 - it_c3) + it_r3*(it_c3 - it_c2) + it_r2*(it_c2 - it_c1) + it_r1*it_c1  if pil>it_c5 & it_c5!=.
replace pinctax = (pil-it_c6)*it_r7 + it_r6*(it_c6 - it_c5) + it_r5*(it_c5 - it_c4) + it_r4*(it_c4 - it_c3) + it_r3*(it_c3 - it_c2) + it_r2*(it_c2 - it_c1) + it_r1*it_c1  if pil>it_c6 & it_c6!=.
replace pinctax = (pil-it_c7)*it_r8 + it_r7*(it_c7 - it_c6) + it_r6*(it_c6 - it_c5) + it_r5*(it_c5 - it_c4) + it_r4*(it_c4 - it_c3) + it_r3*(it_c3 - it_c2) + it_r2*(it_c2 - it_c1) + it_r1*it_c1  if pil>it_c7 & it_c7!=.
replace pinctax = (pil-it_c8)*it_r9 + it_r8*(it_c8 - it_c7) + it_r7*(it_c7 - it_c6) + it_r6*(it_c6 - it_c5) + it_r5*(it_c5 - it_c4) + it_r4*(it_c4 - it_c3) + it_r3*(it_c3 - it_c2) + it_r2*(it_c2 - it_c1) + it_r1*it_c1  if pil>it_c8 & it_c8!=.
replace pinctax = (pil-it_c9)*it_r10 + it_r9*(it_c9 - it_c8) + it_r8*(it_c8 - it_c7) + it_r7*(it_c7 - it_c6) + it_r6*(it_c6 - it_c5) + it_r5*(it_c5 - it_c4) + it_r4*(it_c4 - it_c3) + it_r3*(it_c3 - it_c2) + it_r2*(it_c2 - it_c1) + it_r1*it_c1  if pil>it_c9 & it_c9!=.
replace pinctax = (pil-it_c10)*it_r11 + it_r10*(it_c10 - it_c9) + it_r9*(it_c9 - it_c8) + it_r8*(it_c8 - it_c7) + it_r7*(it_c7 - it_c6) + it_r6*(it_c6 - it_c5) + it_r5*(it_c5 - it_c4) + it_r4*(it_c4 - it_c3) + it_r3*(it_c3 - it_c2) + it_r2*(it_c2 - it_c1) + it_r1*it_c1  if pil>it_c10 & it_c10!=.
replace pinctax = (pil-it_c11)*it_r12 + it_r11*(it_c11 - it_c10) + it_r10*(it_c10 - it_c9) + it_r9*(it_c9 - it_c8) + it_r8*(it_c8 - it_c7) + it_r7*(it_c7 - it_c6) + it_r6*(it_c6 - it_c5) + it_r5*(it_c5 - it_c4) + it_r4*(it_c4 - it_c3) + it_r3*(it_c3 - it_c2) + it_r2*(it_c2 - it_c1) + it_r1*it_c1  if pil>it_c11 & it_c11!=.
replace pinctax = (pil-it_c12)*it_r13 + it_r12*(it_c12 - it_c11) + it_r11*(it_c11 - it_c10) + it_r10*(it_c10 - it_c9) + it_r9*(it_c9 - it_c8) + it_r8*(it_c8 - it_c7) + it_r7*(it_c7 - it_c6) + it_r6*(it_c6 - it_c5) + it_r5*(it_c5 - it_c4) + it_r4*(it_c4 - it_c3) + it_r3*(it_c3 - it_c2) + it_r2*(it_c2 - it_c1) + it_r1*it_c1  if pil>it_c12 & it_c12!=.
replace pinctax = (pil-it_c13)*it_r14 + it_r13*(it_c13 - it_c12) + it_r12*(it_c12 - it_c11) + it_r11*(it_c11 - it_c10) + it_r10*(it_c10 - it_c9) + it_r9*(it_c9 - it_c8) + it_r8*(it_c8 - it_c7) + it_r7*(it_c7 - it_c6) + it_r6*(it_c6 - it_c5) + it_r5*(it_c5 - it_c4) + it_r4*(it_c4 - it_c3) + it_r3*(it_c3 - it_c2) + it_r2*(it_c2 - it_c1) + it_r1*it_c1  if pil>it_c13 & it_c13!=.
replace pinctax = (pil-it_c14)*it_r15 + it_r14*(it_c14 - it_c13) + it_r13*(it_c13 - it_c12) + it_r12*(it_c12 - it_c11) + it_r11*(it_c11 - it_c10) + it_r10*(it_c10 - it_c9) + it_r9*(it_c9 - it_c8) + it_r8*(it_c8 - it_c7) + it_r7*(it_c7 - it_c6) + it_r6*(it_c6 - it_c5) + it_r5*(it_c5 - it_c4) + it_r4*(it_c4 - it_c3) + it_r3*(it_c3 - it_c2) + it_r2*(it_c2 - it_c1) + it_r1*it_c1  if pil>it_c14 & it_c14!=.
replace pinctax = (pil-it_c15)*it_r16 + it_r15*(it_c15 - it_c14) + it_r14*(it_c14 - it_c13) + it_r13*(it_c13 - it_c12) + it_r12*(it_c12 - it_c11) + it_r11*(it_c11 - it_c10) + it_r10*(it_c10 - it_c9) + it_r9*(it_c9 - it_c8) + it_r8*(it_c8 - it_c7) + it_r7*(it_c7 - it_c6) + it_r6*(it_c6 - it_c5) + it_r5*(it_c5 - it_c4) + it_r4*(it_c4 - it_c3) + it_r3*(it_c3 - it_c2) + it_r2*(it_c2 - it_c1) + it_r1*it_c1  if pil>it_c15 & it_c15!=.
replace pinctax = (pil-it_c16)*it_r17 + it_r16*(it_c16 - it_c15) + it_r15*(it_c15 - it_c14) + it_r14*(it_c14 - it_c13) + it_r13*(it_c13 - it_c12) + it_r12*(it_c12 - it_c11) + it_r11*(it_c11 - it_c10) + it_r10*(it_c10 - it_c9) + it_r9*(it_c9 - it_c8) + it_r8*(it_c8 - it_c7) + it_r7*(it_c7 - it_c6) + it_r6*(it_c6 - it_c5) + it_r5*(it_c5 - it_c4) + it_r4*(it_c4 - it_c3) + it_r3*(it_c3 - it_c2) + it_r2*(it_c2 - it_c1) + it_r1*it_c1  if pil>it_c16 & it_c16!=.
replace pinctax = (pil-it_c17)*it_r18 + it_r17*(it_c17 - it_c16) + it_r16*(it_c16 - it_c15) + it_r15*(it_c15 - it_c14) + it_r14*(it_c14 - it_c13) + it_r13*(it_c13 - it_c12) + it_r12*(it_c12 - it_c11) + it_r11*(it_c11 - it_c10) + it_r10*(it_c10 - it_c9) + it_r9*(it_c9 - it_c8) + it_r8*(it_c8 - it_c7) + it_r7*(it_c7 - it_c6) + it_r6*(it_c6 - it_c5) + it_r5*(it_c5 - it_c4) + it_r4*(it_c4 - it_c3) + it_r3*(it_c3 - it_c2) + it_r2*(it_c2 - it_c1) + it_r1*it_c1  if pil>it_c17 & it_c17!=.


// For income tax there are way more exemptions for family structure. I need to correct for this.

*-------------------------------------------------------------------------------

**************
* Conversion 2
**************

replace pil = pil - pinctax // Convert pil to net for the merge

*-------------------------------------------------------------------------------

* Keep only the variables needed for the merge
keep dname pil psscer psscee pinctax

* Deal with duplicates that will effect the merge
duplicates tag dname pil , gen(dup)
drop if dup>0
drop dup
duplicates report dname pil 
tab dname

* Save the dataset to upload on the LIS servers
saveold "$folder/Output/net_stata12.dta" , version(12) replace


/* The following corrections should be applied within LISSY

	bysort hid: egen hil=total(pil) if dname=="be00"
	replace psscee=psscee+0.09*hil if hil>750000 & hil<=850000 & dname=="be00"
	replace psscee=psscee+9000+0.013*hil if hil>850000 & hil<=2426924 & dname=="be00"
	replace psscee=psscee+29500 if hil>2426924 & dname=="be00"
