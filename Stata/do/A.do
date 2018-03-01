global datasets "at04 au03 au08 au10 ca04 ca07 ca10 ch00 ch02 ch04 cz02 cz04 cz07 cz10 de00 de04 de07 de10 dk00 dk04 dk07 dk10 ee10 es07 es10 es13 fi00 fi04 fi07 fi10 gr07 gr10 ie04 ie07 ie10 il10 il12 is04 is07 is10 jp08 kr06 lu04 lu07 lu10 nl04 nl07 nl10 nl99 no00 no04 no07 no10 pl04 pl07 pl10 pl13 pl99 se00 se05 sk04 sk07 sk10 uk99 uk04 uk07 uk10 us00 us04 us07 us10 us13"

global pvars "pid hid dname pil age"

global hvars "hid dname nhhmem dhi nhhmem65 hwgt"

global hvarsflow "hil hic pension hits hitsil hitsup hitsap hxit hxiti hxits hc hicvip dhi hitsilmip hitsilo hitsilep hitsilwi hitsilepo hitsilepd hitsileps" // Local currency, given in the datasets

global hvarsnew "hsscer hsscee" // Local currency, imputed

global hvarsinc "inc1 inc2 inc3 inc4 inc5 tax transfer allpension pubpension pripension hxct hssc" // Summation / imputed after PPP conversion

global fixpensions_datasets1 "at04 ee10 lu04 nl04 no04 no10 se00 se05"  // hitsil missing, hicvip defined

global fixpension_datasets2 "au08 au10 ca04 ca07 ca10 is04 is07 is10 jp08 no00 no07" // hitsil missing, hicvip missing

global fixpension_datasets3 "ie04 ie07 ie10 uk99 uk04 uk07 uk10"


*************************************************************
* Program: Generate SSC variables from person level dataset
*************************************************************

program define gen_pvars

merge m:1 dname using "$mydata\molcke\molcke_ssc_20160630.dta", keep(match) nogenerate

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

 bysort hid: egen hil=total(pil) if dname=="be00"
 replace psscee=psscee+0.09*hil if hil>750000 & hil<=850000 & dname=="be00"
 replace psscee=psscee+9000+0.013*hil if hil>850000 & hil<=2426924 & dname=="be00"
 replace psscee=psscee+29500 if hil>2426924 & dname=="be00"

 *Denmark 2007 DK07
 replace psscee=psscee+8052+975.6 if pil>0 & dname=="dk07"

 *Denmark 2010 DK10
 replace psscee=psscee+10244 if pil>0 & dname=="dk10"

 *Greece 2000 GR00
 replace psscee=0.159*6783000 if pil>6783000 & age>29 & dname=="gr00" //it would be betzter if I used year of birth

 *Greece 2004 GR04
 replace psscee=0.16*24699 if pil>24699 & age>33 & dname=="gr04"

 *Greece 2007 GR07
 replace psscee=0.16*27780 if pil>27780  & age>36 & dname=="gr07"

 *Greece 2010 GR10
 replace psscee=0.16*29187 if pil>29187  & age>39 & dname=="gr10"

 *Iceland 2007 IS07
 replace psscee=6314 if pil>ee_c1 & dname=="is07" //Should there also be an age restriction like in 2010?

 *Iceland 2010 IS10
 replace psscee=8400+17200 if pil>ee_c1 & age>=16 & age<=70 & dname=="is10"

* Generate Employer Social Security Contributions
gen psscer=.
replace psscer = pil*er_r1
replace psscer = (pil-er_c1)*er_r2 + er_r1*er_c1  if pil>er_c1 & er_c1!=.
replace psscer = (pil-er_c2)*er_r3 + er_r2*(er_c2 - er_c1) + er_r1*er_c1 if pil>er_c2 & er_c2!=.
replace psscer = (pil-er_c3)*er_r4 + er_r3*(er_c3 - er_c2) + er_r2*(er_c2 - er_c1) + er_r1*er_c1 if pil>er_c3 & er_c3!=.
replace psscer = (pil-er_c4)*er_r5 + er_r4*(er_c4 - er_c3) + er_r3*(er_c3 - er_c2) + er_r2*(er_c2 - er_c1) + er_r1*er_c1 if pil>er_c4 & er_c4!=.
replace psscer = (pil-er_c5)*er_r6 + er_r5*(er_c5 - er_c4) + er_r4*(er_c4 - er_c3) + er_r3*(er_c3 - er_c2) + er_r2*(er_c2 - er_c1) + er_r1*er_c1  if pil>er_c5 & er_c5!=.

 * Manual corrections for certain datasets (Employer Social Security Contributions)

 *Estonia 2010 ee10
 replace psscer = psscer + 17832 if pil>0 & dname=="ee10"

 *France 2005 fr05
 replace psscer=psscer-((0.26/0.6)*((24692.8/pil)-1)*pil) if pil>15433 & pil<24692.8 & dname=="fr05" // I am not sure I have this adjustment correct.

 *France 2010 fr10
 replace psscer=psscer-((0.26/0.6)*((25800.32/pil)-1)*pil) if pil>16125 & pil<25800.32 & dname=="fr10"

 *Ireland 2000 ie00
 replace psscer=pil*.085 if  pil<14560 & dname=="ie00" // I could have easily included these changes for Ireland in the rates and ceilings.

 *Ireland 2004 ie04
 replace psscer=pil*.085 if  pil<18512 & dname=="ie04"

 *Ireland 2007 ie07
 replace psscer=pil*.085 if  pil<18512 & dname=="ie07"

 *Ireland 2010 ie10
 replace psscer=pil*.085 if  pil<18512 & dname=="ie10"

* Convert variables to household level
 bysort hid: egen hsscee=total(psscee)

 bysort hid: egen hsscer=total(psscer)

 keep hid hsscee hsscer
 drop if hid==.
 duplicates drop hid, force

end

***************************************************************************
* Program: Apply PPP conversions and equivalence scales to flow variables
***************************************************************************

program define ppp_equiv

* Define PPP conversions to 2011 international dollars (ppp)
merge m:1 dname using "$mydata\molcke\ppp.dta", keep(match) nogenerate

* Complete the PPP conversions and equivalence scales with replace commands
 foreach var in $hvarsflow $hvarsnew {
 replace `var' = (`var'*ppp)/(nhhmem^0.5)
 }

* Trim and bottom code

 * Step 1
 drop if dhi<=0

 * Step 2
 replace hsscer=0 if hsscer<0 // Employer
 replace hsscee=0 if hsscee<0 // Employee

 * Step 3
 // completed within the income_stages program

end

**************************************************
* Program: Define the different stages of income
**************************************************

program define income_stages

* Use the imputed data if employee social security contributions is not available
replace hxits=hsscee if hxits==.

* For certain countries, hitsil is missing, but some of the hitsil subcategories are defined
egen hitsil2 = rowtotal(hitsilmip hitsilo hitsilep hitsilwi hitsilepo hitsilepd hitsileps)
replace hitsil = hitsil2 if hitsil==.

* Set the following variables to zero if they are missing, since these variables do not apply to many countries or were not included in their survey.
replace hitsil=0 if hitsil==.
replace hitsap=0 if hitsap==.
replace hitsup=0 if hitsup==.

* I will set the following variables to zero if they missing, but this is where I am going to need careful analysis of the missing values.
replace hicvip=0 if hicvip==.
replace hic=0 if hic==.
replace pension=0 if pension==.

* Rather use hxit in the income definitions
replace hxit = hxiti + hxits if hxit==.

* Define the components of the income stages
gen pubpension = hitsil + hitsup

gen pripension = hicvip

gen allpension = pension - hitsap

gen transfer = hits - pubpension

gen tax = hxit + hsscer

gen hssc = hxits + hsscer

gen marketincome = hil + (hic-hicvip) + hsscer

gen inc1 = marketincome
gen inc2 = marketincome + allpension
gen inc3 = marketincome + allpension + transfer
gen inc4 = marketincome + allpension + transfer - tax
gen inc5 = marketincome + allpension + transfer - tax - hxct

* Trim and bottom code
 // The preceding steps are in the ppp_equiv program
 * Step 3
 foreach var in $hvarsflow $hvarsnew {
 replace `var' = 0 if `var' < 0
 }

 * Define the income deciles
 xtile decile = inc2 [w=hwgt], nquantiles(10) // Note that inc2 is already corrected for household size by ppp_equiv

end

***************************************************************************
* Program: Adjustments to pensions for certain countries
***************************************************************************

/* It is noted in LIS that there is some difficulty in defining pension related
transfers in Sweden and Norway. The following code adjusts the definitions of
the income variables for use in Sweden and Norway */

program define fix_pensions_type1

drop pubpension transfer inc1 inc2 inc3 inc4 inc5 inc_decile decile

gen pubpension = pension - hicvip - hitsap

*gen pripension = hicvip // No change

*gen allpension = pension - hitsap // No change

gen transfer = hits - pubpension

*gen tax = hxit + hsscer // No change

*gen marketincome = hil + (hic-hicvip) + hsscer // No change

gen inc1 = marketincome
gen inc2 = marketincome + allpension
gen inc3 = marketincome + allpension + transfer
gen inc4 = marketincome + allpension + transfer - tax
gen inc5 = marketincome + allpension + transfer - tax - hxct

* Trim and bottom code
 // The preceding steps are in the ppp_equiv program
 * Step 3
 foreach var in $hvarsflow $hvarsnew {
 replace `var' = 0 if `var' < 0
 }

* Define the income deciles
xtile decile = inc2 [w=hwgt], nquantiles(10) // Note that inc2 is already corrected for household size by ppp_equiv

end

***************************************************************************
* Program: Adjustments to pensions for UK and Ireland
***************************************************************************

/* In the preceding income definitions, UK and Ireland have transfers that
seem to be too high. We propose moving HITSAP (old-age, disability assistance
pensions, a subcategory of assistance benefits) out of transfers, and into
pensions.  */

program define fix_pensions_type3

drop pubpension allpension transfer inc1 inc2 inc3 inc4 inc5 inc_decile decile

gen pubpension = hitsil + hitsup + hitsap // Added "+hitsap"

*gen pripension = hicvip // No change

gen allpension = pension // Removed "-hitsap"

gen transfer = hits - pubpension

*gen tax = hxit + hsscer // No change

*gen marketincome = hil + (hic-hicvip) + hsscer // No change

gen inc1 = marketincome
gen inc2 = marketincome + allpension
gen inc3 = marketincome + allpension + transfer
gen inc4 = marketincome + allpension + transfer - tax
gen inc5 = marketincome + allpension + transfer - tax - hxct

* Trim and bottom code
 // The preceding steps are in the ppp_equiv program
 * Step 3
 foreach var in $hvarsflow $hvarsnew {
 replace `var' = 0 if `var' < 0
 }

 * Define the income deciles
 xtile decile = inc2 [w=hwgt], nquantiles(10) // Note that inc2 is already corrected for household size by ppp_equiv

end

**********************************************************
* Output: Loop over datasets and output summary statistics
**********************************************************

 foreach ccyy in $datasets {
   use $pvars using $`ccyy'p,clear
   quietly gen_pvars
   quietly merge 1:1 hid using $`ccyy'h, keepusing($hvars $hvarsflow) nogenerate
   quietly ppp_equiv
   quietly income_stages

   foreach certain_ccyy in $fixpensions_datasets1 {
 quietly fix_pensions_type1 if "`ccyy'" == "`certain_ccyy'"
 }

   foreach certain_ccyy in $fixpensions_datasets3 {
 quietly fix_pensions_type3 if "`ccyy'" == "`certain_ccyy'"
 }

 foreach var in $hvarsinc $hvarsflow $hvarsnew {

 quietly capture sgini `var' [aw=hwgt]
 local `var'_gini = r(coeff)

 quietly sum `var' [w=hwgt]
 local `var'_mean = r(mean)

 foreach sortvar in inc1 inc2 inc3 inc4 inc5 {
 quietly capture sgini `var' [aw=hwgt], sortvar(`sortvar')
 local `var'conc_`sortvar' = r(coeff)
 }

 forvalues num = 1/10 {
 quietly sum `var' [w=hwgt] if decile==`num'
 local `var'_mean_`num' = r(mean)
 local `var'_min_`num' = r(min)
 local `var'_max_`num' = r(max)
 }
 }
 if "`ccyy'" == "at04" di "countryyear,decile,inc1_mean,inc1_min,inc1_max,inc2_mean,inc2_min,inc2_max,inc3_mean,inc3_min,inc3_max,inc4_mean,inc4_min,inc4_max,inc5_mean,inc5_min,inc5_max,transfer_mean,transfer_min,transfer_max,tax_mean,tax_min,tax_max"
 di "`ccyy',D01,`inc1_mean_1',`inc1_min_1',`inc1_max_1',`inc2_mean_1',`inc2_min_1',`inc2_max_1',`inc3_mean_1',`inc3_min_1',`inc3_max_1',`inc4_mean_1',`inc4_min_1',`inc4_max_1',`inc5_mean_1',`inc5_min_1',`inc5_max_1',`transfer_mean_1',`transfer_min_1',`transfer_max_1',`tax_mean_1',`tax_min_1',`tax_max_1'"
 di "`ccyy',D02,`inc1_mean_2',`inc1_min_2',`inc1_max_2',`inc2_mean_2',`inc2_min_2',`inc2_max_2',`inc3_mean_2',`inc3_min_2',`inc3_max_2',`inc4_mean_2',`inc4_min_2',`inc4_max_2',`inc5_mean_2',`inc5_min_2',`inc5_max_2',`transfer_mean_2',`transfer_min_2',`transfer_max_2',`tax_mean_2',`tax_min_2',`tax_max_2'"
 di "`ccyy',D03,`inc1_mean_3',`inc1_min_3',`inc1_max_3',`inc2_mean_3',`inc2_min_3',`inc2_max_3',`inc3_mean_3',`inc3_min_3',`inc3_max_3',`inc4_mean_3',`inc4_min_3',`inc4_max_3',`inc5_mean_3',`inc5_min_3',`inc5_max_3',`transfer_mean_3',`transfer_min_3',`transfer_max_3',`tax_mean_3',`tax_min_3',`tax_max_3'"
 di "`ccyy',D04,`inc1_mean_4',`inc1_min_4',`inc1_max_4',`inc2_mean_4',`inc2_min_4',`inc2_max_4',`inc3_mean_4',`inc3_min_4',`inc3_max_4',`inc4_mean_4',`inc4_min_4',`inc4_max_4',`inc5_mean_4',`inc5_min_4',`inc5_max_4',`transfer_mean_4',`transfer_min_4',`transfer_max_4',`tax_mean_4',`tax_min_4',`tax_max_4'"
 di "`ccyy',D05,`inc1_mean_5',`inc1_min_5',`inc1_max_5',`inc2_mean_5',`inc2_min_5',`inc2_max_5',`inc3_mean_5',`inc3_min_5',`inc3_max_5',`inc4_mean_5',`inc4_min_5',`inc4_max_5',`inc5_mean_5',`inc5_min_5',`inc5_max_5',`transfer_mean_5',`transfer_min_5',`transfer_max_5',`tax_mean_5',`tax_min_5',`tax_max_5'"
 di "`ccyy',D06,`inc1_mean_6',`inc1_min_6',`inc1_max_6',`inc2_mean_6',`inc2_min_6',`inc2_max_6',`inc3_mean_6',`inc3_min_6',`inc3_max_6',`inc4_mean_6',`inc4_min_6',`inc4_max_6',`inc5_mean_6',`inc5_min_6',`inc5_max_6',`transfer_mean_6',`transfer_min_6',`transfer_max_6',`tax_mean_6',`tax_min_6',`tax_max_6'"
 di "`ccyy',D07,`inc1_mean_7',`inc1_min_7',`inc1_max_7',`inc2_mean_7',`inc2_min_7',`inc2_max_7',`inc3_mean_7',`inc3_min_7',`inc3_max_7',`inc4_mean_7',`inc4_min_7',`inc4_max_7',`inc5_mean_7',`inc5_min_7',`inc5_max_7',`transfer_mean_7',`transfer_min_7',`transfer_max_7',`tax_mean_7',`tax_min_7',`tax_max_7'"
 di "`ccyy',D08,`inc1_mean_8',`inc1_min_8',`inc1_max_8',`inc2_mean_8',`inc2_min_8',`inc2_max_8',`inc3_mean_8',`inc3_min_8',`inc3_max_8',`inc4_mean_8',`inc4_min_8',`inc4_max_8',`inc5_mean_8',`inc5_min_8',`inc5_max_8',`transfer_mean_8',`transfer_min_8',`transfer_max_8',`tax_mean_8',`tax_min_8',`tax_max_8'"
 di "`ccyy',D09,`inc1_mean_9',`inc1_min_9',`inc1_max_9',`inc2_mean_9',`inc2_min_9',`inc2_max_9',`inc3_mean_9',`inc3_min_9',`inc3_max_9',`inc4_mean_9',`inc4_min_9',`inc4_max_9',`inc5_mean_9',`inc5_min_9',`inc5_max_9',`transfer_mean_9',`transfer_min_9',`transfer_max_9',`tax_mean_9',`tax_min_9',`tax_max_9'"
 di "`ccyy',D10,`inc1_mean_10',`inc1_min_10',`inc1_max_10',`inc2_mean_10',`inc2_min_10',`inc2_max_10',`inc3_mean_10',`inc3_min_10',`inc3_max_10',`inc4_mean_10',`inc4_min_10',`inc4_max_10',`inc5_mean_10',`inc5_min_10',`inc5_max_10',`transfer_mean_10',`transfer_min_10',`transfer_max_10',`tax_mean_10',`tax_min_10',`tax_max_10'"
 if "`ccyy'" == "at04"  di "Inequality Measures 1,countryyear,inc1_gini,inc2_gini,inc3_gini,inc4_gini,inc5_gini,dhi_gini,transfer_conc_inc1,transfer_conc_inc2,transfer_conc_inc3,transfer_conc_inc4,transfer_conc_inc5,tax_conc_inc1,tax_conc_inc2,tax_conc_inc3,tax_conc_inc4,tax_conc_inc5"
 di "Inequality Measures 1,`ccyy',`inc1_gini',`inc2_gini',`inc3_gini',`inc4_gini',`inc5_gini',`dhi_gini',`transferconc_inc1',`transferconc_inc2',`transferconc_inc3',`transferconc_inc4',`transferconc_inc5',`taxconc_inc1',`taxconc_inc2',`taxconc_inc3',`taxconc_inc4',`taxconc_inc5'"
 if "`ccyy'" == "at04"  di "Inequality Measures 2,countryyear,allpension_conc_inc1,allpension_conc_inc2,allpension_conc_inc3,allpension_conc_inc4,allpension_conc_inc5,pubpension_conc_inc1,pubpension_conc_inc2,pubpension_conc_inc3,pubpension_conc_inc4,pubpension_conc_inc5,pripension_conc_inc1,pripension_conc_inc2,pripension_conc_inc3,pripension_conc_inc4,pripension_conc_inc5"
 di "Inequality Measures 2,`ccyy',`allpensionconc_inc1',`allpensionconc_inc2',`allpensionconc_inc3',`allpensionconc_inc4',`allpensionconc_inc5',`pubpensionconc_inc1',`pubpensionconc_inc2',`pubpensionconc_inc3',`pubpensionconc_inc4',`pubpensionconc_inc5',`pripensionconc_inc1',`pripensionconc_inc2',`pripensionconc_inc3',`pripensionconc_inc4',`pripensionconc_inc5'"
 if "`ccyy'" == "at04"  di "Inequality Measures 3,countryyear,inc1_mean,inc2_mean,inc3_mean,inc4_mean,inc5_mean,dhi_mean,transfer_mean,tax_mean,allpension_mean,pubpension_mean,pripension_mean"
 di "Inequality Measures 3,`ccyy',`inc1_mean',`inc2_mean',`inc3_mean',`inc4_mean',`inc5_mean',`dhi_mean',`transfer_mean',`tax_mean',`allpension_mean',`pubpension_mean',`pripension_mean'"
 if "`ccyy'" == "at04"  di "Inequality Measures 4,countryyear,inc1_conc_inc1,inc1_conc_inc2,inc1_conc_inc3,inc1_conc_inc4,inc1_conc_inc5,inc2_conc_inc1,inc2_conc_inc2,inc2_conc_inc3,inc2_conc_inc4,inc2_conc_inc5,inc3_conc_inc1,inc3_conc_inc2,inc3_conc_inc3,inc3_conc_inc4,inc3_conc_inc5,inc4_conc_inc1,inc4_conc_inc2,inc4_conc_inc3,inc4_conc_inc4,inc4_conc_inc5,inc5_conc_inc1,inc5_conc_inc2,inc5_conc_inc3,inc5_conc_inc4,inc5_conc_inc5"
 di "Inequality Measures 4,`ccyy',`inc1conc_inc1',`inc1conc_inc2',`inc1conc_inc3',`inc1conc_inc4',`inc1conc_inc5',`inc2conc_inc1',`inc2conc_inc2',`inc2conc_inc3',`inc2conc_inc4',`inc2conc_inc5',`inc3conc_inc1',`inc3conc_inc2',`inc3conc_inc3',`inc3conc_inc4',`inc3conc_inc5',`inc4conc_inc1',`inc4conc_inc2',`inc4conc_inc3',`inc4conc_inc4',`inc4conc_inc5',`inc5conc_inc1',`inc5conc_inc2',`inc5conc_inc3',`inc5conc_inc4',`inc5conc_inc5'"
 if "`ccyy'" == "at04"  di "Inequality Measures 5,countryyear,hxct_mean,hxits_mean,hsscee_mean,hsscer_mean,hssc_mean,hxitsconc_inc3,hssceeconc_inc3,hsscerconc_inc3,hsscconc_inc3,hxctconc_inc4"
 di "Inequality Measures 5,`ccyy',`hxct_mean',`hxits_mean',`hsscee_mean',`hsscer_mean',`hssc_mean',`hxitsconc_inc3',`hssceeconc_inc3',`hsscerconc_inc3',`hsscconc_inc3',`hxctconc_inc4'"
 }

program drop _all
clear all
