*************************************************************
* Define globals
*************************************************************

global datasets "at04 au03 au08 au10 ca04 ca07 ca10 ch00 ch02 ch04 cz02 cz04 cz07 cz10 de00 de04 de07 de10 dk00 dk04 dk07 dk10 ee10 es07 es10 es13 fi00 fi04 fi07 fi10 fr00 fr05 fr10 gr07 gr10 ie04 ie07 ie10 il10 il12 is04 is07 is10 it04 it08 it10 jp08 kr06 lu04 lu07 lu10 nl04 nl07 nl10 nl99 no00 no04 no07 no10 pl04 pl07 pl10 pl13 pl99 se00 se05 sk04 sk07 sk10 uk99 uk04 uk07 uk10 us00 us04 us07 us10 us13 at00 be00 gr00 hu05 hu07 hu09 hu12 hu99 ie00 it00 lu00 mx00 mx02 mx04 mx08 mx10 mx12 mx98 si10"

global net_datasets "at00 be00 gr00 hu05 hu07 hu09 hu12 hu99 ie00 it00 lu00 mx00 mx02 mx04 mx08 mx10 mx12 mx98 si10" // Removed es00 and it98 in this version since they contain dupicates and missing values respectively in pil.

global pvars "pid hid dname pil pxit pxiti pxits age emp relation"

global hvars "hid dname nhhmem dhi nhhmem17 nhhmem65 hwgt"

global hvarsflow "hil hic pension hits hitsil hitsup hitsap hxit hxiti hxits hc hicvip dhi hitsilmip hitsilo hitsilep hitsilwi hitsilepo hitsilepd hitsileps" // Local currency, given in the datasets

global hvarsnew "hsscer hsscee" // Local currency, imputed

global hvarsinc "inc1 inc2 inc3 inc4 tax transfer allpension pubpension pripension hssc" // Summation / imputed after PPP conversion

global fixpensions_datasets1 "at04 ee10 gr00 lu04 nl04 no04 no10 se00 se05"  // hitsil missing, hicvip defined

global fixpension_datasets2 "au08 au10 ca04 ca07 ca10 is04 is07 is10 jp08 no00 no07 si10" // hitsil missing, hicvip missing

global fixpension_datasets3 "ie04 ie07 ie10 uk99 uk04 uk07 uk10"


*************************************************************
* Program: Generate SSC variables from person level dataset
*************************************************************

program define merge_ssc
  merge m:1 dname using "$mydata/molcke/molcke_ssc_20160630.dta", keep(match) nogenerate
end

program define gen_employee_ssc
  * Generate Employee Social Security Contributions
  gen psscee=.
  replace psscee = pil*ee_r1
  replace psscee = (pil-ee_c1)*ee_r2 + ee_r1*ee_c1  if pil>ee_c1 & ee_c1!=.
  replace psscee = (pil-ee_c2)*ee_r3 + ee_r2*(ee_c2 - ee_c1) + ee_r1*ee_c1 if pil>ee_c2 & ee_c2!=.
  replace psscee = (pil-ee_c3)*ee_r4 + ee_r3*(ee_c3 - ee_c2) + ee_r2*(ee_c2 - ee_c1) + ee_r1*ee_c1 if pil>ee_c3 & ee_c3!=.
  replace psscee = (pil-ee_c4)*ee_r5 + ee_r4*(ee_c4 - ee_c3) + ee_r3*(ee_c3 - ee_c2) + ee_r2*(ee_c2 - ee_c1) + ee_r1*ee_c1 if pil>ee_c4 & ee_c4!=.
  replace psscee = (pil-ee_c5)*ee_r6 + ee_r5*(ee_c5 - ee_c4) + ee_r4*(ee_c4 - ee_c3) + ee_r3*(ee_c3 - ee_c2) + ee_r2*(ee_c2 - ee_c1) + ee_r1*ee_c1  if pil>ee_c5 & ee_c5!=.
end

program define gen_employer_ssc
  * Generate Employer Social Security Contributions
  gen psscer=.
  replace psscer = pil*er_r1
  replace psscer = (pil-er_c1)*er_r2 + er_r1*er_c1  if pil>er_c1 & er_c1!=.
  replace psscer = (pil-er_c2)*er_r3 + er_r2*(er_c2 - er_c1) + er_r1*er_c1 if pil>er_c2 & er_c2!=.
  replace psscer = (pil-er_c3)*er_r4 + er_r3*(er_c3 - er_c2) + er_r2*(er_c2 - er_c1) + er_r1*er_c1 if pil>er_c3 & er_c3!=.
  replace psscer = (pil-er_c4)*er_r5 + er_r4*(er_c4 - er_c3) + er_r3*(er_c3 - er_c2) + er_r2*(er_c2 - er_c1) + er_r1*er_c1 if pil>er_c4 & er_c4!=.
  replace psscer = (pil-er_c5)*er_r6 + er_r5*(er_c5 - er_c4) + er_r4*(er_c4 - er_c3) + er_r3*(er_c3 - er_c2) + er_r2*(er_c2 - er_c1) + er_r1*er_c1  if pil>er_c5 & er_c5!=.
end

program define convert_ssc_to_household_level
  * Convert variables to household level
  bysort hid: egen hsscee=total(psscee)
  bysort hid: egen hsscer=total(psscer)
  *create household activ age dummy*
  activage_household
  * Keep only household level SSC and household id and activage dummy
  keep hid hsscee hsscer hhactivage
  drop if hid==.
  duplicates drop hid, force
end

program define activage_household
	*create a dummy variable taking 1 if head of household btw 25 and 59
	gen headactivage=1 if age>24 & age<60 & relation==1000
	replace headactivage=0 if headactivage!=1
	bys hid: egen hhactivage=total(headactivage)
	drop headactivage
end

program define gen_pvars
  merge_ssc
  gen_employee_ssc
  manual_corrections_employee_ssc
  gen_employer_ssc
  manual_corrections_employer_ssc
  convert_ssc_to_household_level
end

program define FR_gen_pvars
  merge_ssc
  * Impute individual level income tax from household level income tax
  bysort hid: egen hemp = total(emp) , missing // missing option to set a total of all missing values to missing rather than zero.
  drop pxiti
  gen pxiti = hxiti/hemp
  replace pxiti =. if emp!=1
  **IMPORTANT**Generate Employee Social Security Contributions
  gen psscee=.
  replace psscee = ((pil*ee_r1)/(1-ee_r1))
  replace psscee = (((pil-ee_c1)*ee_r2)/(1-ee_r2))  + ee_r1*ee_c1  if pil>ee_c1mix & ee_c1mix!=.
  replace psscee = (((pil-ee_c2)*ee_r3)/(1-ee_r3))  + ee_r2*(ee_c2 - ee_c1) + ee_r1*ee_c1 if pil>ee_c2mix & ee_c2mix!=.
  replace psscee = (((pil-ee_c3)*ee_r4)/(1-ee_r4))  + ee_r3*(ee_c3 - ee_c2) + ee_r2*(ee_c2 - ee_c1) + ee_r1*ee_c1 if pil>ee_c3mix & ee_c3mix!=.
  replace psscee = (((pil-ee_c4)*ee_r5)/(1-ee_r5))  + ee_r4*(ee_c4 - ee_c3) + ee_r3*(ee_c3 - ee_c2) + ee_r2*(ee_c2 - ee_c1) + ee_r1*ee_c1 if pil>ee_c4mix & ee_c4mix!=.
  replace psscee = (((pil-ee_c5)*ee_r6)/(1-ee_r6))  + ee_r5*(ee_c5 - ee_c4) + ee_r4*(ee_c4 - ee_c3) + ee_r3*(ee_c3 - ee_c2) + ee_r2*(ee_c2 - ee_c1) + ee_r1*ee_c1  if pil>ee_c5mix & ee_c5mix!=.
  **IMPORTANT**Convert French datasets from net to gross
  replace pil=pil+pxiti+psscee
  gen_employer_ssc
  manual_corrections_employer_ssc
  convert_ssc_to_household_level
end

program define IT_gen_pvars
  merge_ssc
  **IMPORTANT**Convert Italian datasets from net to gross
  replace pil=pil+pxit
  gen psscee=. // hxits is defined for italy, so no need to impute
  gen_employer_ssc
  convert_ssc_to_household_level
end

program define NET_gen_pvars
  * Impute taxes for net datasets
  nearmrg dname using "$mydata/molcke/net_20161101.dta", nearvar(pil) lower keep(match) nogenerate
  * Convert variables to household level
  bysort hid: egen hxiti=total(pinctax)
  bysort hid: egen hsscee=total(psscee)
  bysort hid: egen hsscer=total(psscer)
    *create household activ age dummy*
  activage_household
  * Keep only household level SSC and household id
  keep hid hsscee hsscer hxiti hhactivage
  drop if hid==.
  duplicates drop hid, force
end

***************************************************************************
* Helper Program: Manual corrections
***************************************************************************

program define manual_corrections_employee_ssc
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
end

program define manual_corrections_employer_ssc
  * Manual corrections for certain datasets (Employer Social Security Contributions)
  *Estonia 2010 ee10
  replace psscer = psscer + 17832 if pil>0 & dname=="ee10"
  *Ireland 2000 ie00
  replace psscer=pil*.085 if  pil<14560 & dname=="ie00" // I could have easily included these changes for Ireland in the rates and ceilings.
  *Ireland 2004 ie04
  replace psscer=pil*.085 if  pil<18512 & dname=="ie04"
  *Ireland 2007 ie07
  replace psscer=pil*.085 if  pil<18512 & dname=="ie07"
  *Ireland 2010 ie10
  replace psscer=pil*.085 if  pil<18512 & dname=="ie10"
  *France 2000 fr00 (measured in Francs, not Euros)
  replace psscer=psscer-(0.182*pil) if pil<=83898 & dname=="fr00"
  replace psscer=psscer-(0.55*(111584.34-pil)) if pil>83898 & pil<=111584.34 & dname=="fr00"
  *France 2005 fr05
  replace psscer=psscer-((0.26/0.6)*((24692.8/pil)-1)*pil) if pil>15433 & pil<24692.8 & dname=="fr05" //I am not sure I have this adjustment correct.
  *France 2010 fr10
  replace psscer=psscer-((0.26/0.6)*((25800.32/pil)-1)*pil) if pil>16125 & pil<25800.32 & dname=="fr10"
end

***************************************************************************
* Program: Apply PPP conversions and equivalence scales to flow variables
***************************************************************************

program define ppp_equiv
  * Define PPP conversions to 2011 international dollars (ppp)
  merge m:1 dname using "$mydata/molcke/ppp.dta", keep(match) nogenerate

  * Complete the PPP conversions and equivalence scales with replace commands
  foreach var in $hvarsflow $hvarsnew {
    replace `var' = (`var'*ppp_2011_usd)/(nhhmem^0.5)
    }

  * Trim and bottom code
    * Step 1
    drop if dhi<=0
    * Step 2
    replace hsscer=0 if hsscer<0 // Employer
    replace hsscee=0 if hsscee<0 // Employee
    * Step 3
    // completed within the inc_and_decile program
end


*******************************************************************
* Helper Program: Define the different stages of income and deciles
*******************************************************************

program define inc_and_decile

  gen inc1 = marketincome
  gen inc2 = marketincome + allpension
  gen inc3 = marketincome + allpension + transfer
  gen inc4 = marketincome + allpension + transfer - tax

  * Trim and bottom code
  // The preceding steps are in the ppp_equiv program
  * Step 3
  foreach var in $hvarsflow $hvarsnew {
  replace `var' = 0 if `var' < 0
  }
  * Define the income deciles
  xtile decile = inc2 [w=hwgt*nhhmem], nquantiles(10) // already corrected for household size by ppp_equiv
  xtile hhaa_decile = inc2 [w=hwgt*nhhmem] if hhactivage==1, nquantiles(10) // already corrected for household size by ppp_equiv

end

**************************************************
* Program: Define taxes and transfer variables
**************************************************

program define def_tax_and_transfer
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

  inc_and_decile

end

***************************************************************************
* Program: Adjustments to pensions for certain countries
***************************************************************************

/* It is noted in LIS that there is some difficulty in defining pension related
transfers in Sweden and Norway. The following code adjusts the definitions of
the income variables for use in Sweden and Norway */

program define fix_pensions_type1
  drop pubpension transfer inc1 inc2 inc3 inc4 decile hhaa_decile
  gen pubpension = pension - hicvip - hitsap
  *gen pripension = hicvip // No change
  *gen allpension = pension - hitsap // No change
  gen transfer = hits - pubpension
  *gen tax = hxit + hsscer // No change
  *gen marketincome = hil + (hic-hicvip) + hsscer // No change

  inc_and_decile

end

***************************************************************************
* Program: Adjustments to pensions for UK and Ireland
***************************************************************************

/* In the preceding income definitions, UK and Ireland have transfers that
seem to be too high. We propose moving HITSAP (old-age, disability assistance
pensions, a subcategory of assistance benefits) out of transfers, and into
pensions.  */

program define fix_pensions_type3
  drop pubpension allpension transfer inc1 inc2 inc3 inc4 decile hhaa_decile
  gen pubpension = hitsil + hitsup + hitsap // Added "+hitsap"
  *gen pripension = hicvip // No change
  gen allpension = pension // Removed "-hitsap"
  gen transfer = hits - pubpension
  *gen tax = hxit + hsscer // No change
  *gen marketincome = hil + (hic-hicvip) + hsscer // No change

  inc_and_decile

end

***************************************************************************
* Program: Adjustments to tax for France
***************************************************************************

program define FR_def_tax_and_transfer
  drop tax inc1 inc2 inc3 inc4 decile hhaa_decile marketincome
  * Impute the taxes CSG and CRDS
  FR_tax_CSG_CRDS
  * Define the components of the income stages
  gen tax = hxiti + hxits + hsscer + hic_csg_crds + pension_csg_crds
  * For France, incomes are reported net of ssc, but gross of income tax
  gen marketincome = hil + (hic-hicvip) + hsscer + hic_csg_crds + hxits + pension_csg_crds

  inc_and_decile

end

program define FR_tax_CSG_CRDS
  * Labour income
  // CSG and CRDS on labour income is imputed within Employee SSC
  * Capital income
  gen hic_csg_crds = hic * 0.087 if dname =="fr00"
  replace hic_csg_crds = hic * 0.087 if dname =="fr05"
  replace hic_csg_crds = hic * 0.08  if dname =="fr10"
  * Pensions
    *Family share
    gen N = (nhhmem - nhhmem17)
    replace N = 2 + ((nhhmem - nhhmem17)-2) / 2 if (nhhmem - nhhmem17)>2
    gen C = nhhmem17 / 2
    replace C = 1 + (nhhmem17 - 2) if nhhmem17>2
    gen familyshare = N + C
    drop N C
    *Imputation
    gen pension_csg_crds = 0
    replace pension_csg_crds = 0.043*(hitsil + hitsup) if hil > (6584+(familyshare - 1))*1759 & dname=="fr00" // 2002 figures deflated to 2000 prices using WDI CPI
    replace pension_csg_crds = 0.067*(hitsil + hitsup) if hil > (7796+(familyshare - 1))*2120 & dname=="fr00" // 2002 figures deflated to 2000 prices using WDI CPI
    replace pension_csg_crds = 0.043*(hitsil + hitsup) if hil > (7165+(familyshare - 1))*1914 & dname=="fr05"
    replace pension_csg_crds = 0.071*(hitsil + hitsup) if hil > (8492+(familyshare - 1))*2308 & dname=="fr05"
    replace pension_csg_crds = 0.043*(hitsil + hitsup) if hil > (9876+(familyshare - 1))*2637 & dname=="fr10"
    replace pension_csg_crds = 0.071*(hitsil + hitsup) if hil > (11793+(familyshare - 1))*3178 & dname=="fr10"
end

***************************************************************
* Program: Correct dhi (disposable household income) for France
***************************************************************

/* Notes: For France particularly, dhi is provided gross of income taxes, even
though the income tax variable is available. Ths is because income taxes are
collected once per year, directly from households. The income tax variable in
LIS is the amount of the previous year's tax. So it is just a proxy of current
income tax. Here we compute the dhi net of income tax */

program define correct_dhi
  gen hxiti_temp = hxiti
 * replace hxiti_temp = 0 if hxiti<0
  replace hxiti_temp = 0 if hxit==.
  replace dhi = dhi - hxiti_temp
end


**********************************************************
* Output: Loop over datasets and output summary statistics
**********************************************************

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
  quietly merge 1:1 hid using $`ccyy'h, keepusing($hvars $hvarsflow) nogenerate
  if "`cc'" == "fr" {
    quietly correct_dhi
  }
  quietly ppp_equiv
  quietly def_tax_and_transfer
  if "`cc'" == "fr" {
    quietly FR_def_tax_and_transfer
  }
  foreach certain_ccyy in $fixpensions_datasets1 {
    quietly fix_pensions_type1 if "`ccyy'" == "`certain_ccyy'"
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
    foreach sortvar in inc1 inc2 inc3 inc4 {
      quietly capture sgini `var' [aw=hwgt*nhhmem], sortvar(`sortvar')
      local `var'conc_`sortvar' = r(coeff)
	  quietly capture sgini `var' [aw=hwgt*nhhmem] if hhactivage==1, sortvar(`sortvar')
      local hhaa_`var'conc_`sortvar' = r(coeff)
      }
    forvalues num = 1/10 {
      quietly sum `var' [w=hwgt*nhhmem] if decile==`num'
      local `var'_mean_`num' = r(mean)
      local `var'_min_`num' = r(min)
      local `var'_max_`num' = r(max)
      }
   }
     if "`ccyy'" == "at04" di "countryyear,decile,inc1_mean,inc1_min,inc1_max,inc2_mean,inc2_min,inc2_max,inc3_mean,inc3_min,inc3_max,inc4_mean,inc4_min,inc4_max,transfer_mean,transfer_min,transfer_max,tax_mean,tax_min,tax_max"
     di "`ccyy',D01,`inc1_mean_1',`inc1_min_1',`inc1_max_1',`inc2_mean_1',`inc2_min_1',`inc2_max_1',`inc3_mean_1',`inc3_min_1',`inc3_max_1',`inc4_mean_1',`inc4_min_1',`inc4_max_1',`transfer_mean_1',`transfer_min_1',`transfer_max_1',`tax_mean_1',`tax_min_1',`tax_max_1'"
     di "`ccyy',D02,`inc1_mean_2',`inc1_min_2',`inc1_max_2',`inc2_mean_2',`inc2_min_2',`inc2_max_2',`inc3_mean_2',`inc3_min_2',`inc3_max_2',`inc4_mean_2',`inc4_min_2',`inc4_max_2',`transfer_mean_2',`transfer_min_2',`transfer_max_2',`tax_mean_2',`tax_min_2',`tax_max_2'"
     di "`ccyy',D03,`inc1_mean_3',`inc1_min_3',`inc1_max_3',`inc2_mean_3',`inc2_min_3',`inc2_max_3',`inc3_mean_3',`inc3_min_3',`inc3_max_3',`inc4_mean_3',`inc4_min_3',`inc4_max_3',`transfer_mean_3',`transfer_min_3',`transfer_max_3',`tax_mean_3',`tax_min_3',`tax_max_3'"
     di "`ccyy',D04,`inc1_mean_4',`inc1_min_4',`inc1_max_4',`inc2_mean_4',`inc2_min_4',`inc2_max_4',`inc3_mean_4',`inc3_min_4',`inc3_max_4',`inc4_mean_4',`inc4_min_4',`inc4_max_4',`transfer_mean_4',`transfer_min_4',`transfer_max_4',`tax_mean_4',`tax_min_4',`tax_max_4'"
     di "`ccyy',D05,`inc1_mean_5',`inc1_min_5',`inc1_max_5',`inc2_mean_5',`inc2_min_5',`inc2_max_5',`inc3_mean_5',`inc3_min_5',`inc3_max_5',`inc4_mean_5',`inc4_min_5',`inc4_max_5',`transfer_mean_5',`transfer_min_5',`transfer_max_5',`tax_mean_5',`tax_min_5',`tax_max_5'"
     di "`ccyy',D06,`inc1_mean_6',`inc1_min_6',`inc1_max_6',`inc2_mean_6',`inc2_min_6',`inc2_max_6',`inc3_mean_6',`inc3_min_6',`inc3_max_6',`inc4_mean_6',`inc4_min_6',`inc4_max_6',`transfer_mean_6',`transfer_min_6',`transfer_max_6',`tax_mean_6',`tax_min_6',`tax_max_6'"
     di "`ccyy',D07,`inc1_mean_7',`inc1_min_7',`inc1_max_7',`inc2_mean_7',`inc2_min_7',`inc2_max_7',`inc3_mean_7',`inc3_min_7',`inc3_max_7',`inc4_mean_7',`inc4_min_7',`inc4_max_7',`transfer_mean_7',`transfer_min_7',`transfer_max_7',`tax_mean_7',`tax_min_7',`tax_max_7'"
     di "`ccyy',D08,`inc1_mean_8',`inc1_min_8',`inc1_max_8',`inc2_mean_8',`inc2_min_8',`inc2_max_8',`inc3_mean_8',`inc3_min_8',`inc3_max_8',`inc4_mean_8',`inc4_min_8',`inc4_max_8',`transfer_mean_8',`transfer_min_8',`transfer_max_8',`tax_mean_8',`tax_min_8',`tax_max_8'"
     di "`ccyy',D09,`inc1_mean_9',`inc1_min_9',`inc1_max_9',`inc2_mean_9',`inc2_min_9',`inc2_max_9',`inc3_mean_9',`inc3_min_9',`inc3_max_9',`inc4_mean_9',`inc4_min_9',`inc4_max_9',`transfer_mean_9',`transfer_min_9',`transfer_max_9',`tax_mean_9',`tax_min_9',`tax_max_9'"
     di "`ccyy',D10,`inc1_mean_10',`inc1_min_10',`inc1_max_10',`inc2_mean_10',`inc2_min_10',`inc2_max_10',`inc3_mean_10',`inc3_min_10',`inc3_max_10',`inc4_mean_10',`inc4_min_10',`inc4_max_10',`transfer_mean_10',`transfer_min_10',`transfer_max_10',`tax_mean_10',`tax_min_10',`tax_max_10'"
     if "`ccyy'" == "at04"  di "Inequality Measures 1,countryyear,inc1_gini,inc2_gini,inc3_gini,inc4_gini,dhi_gini,transfer_conc_inc1,transfer_conc_inc2,transfer_conc_inc3,transfer_conc_inc4,tax_conc_inc1,tax_conc_inc2,tax_conc_inc3,tax_conc_inc4"
     di "Inequality Measures 1,`ccyy',`inc1_gini',`inc2_gini',`inc3_gini',`inc4_gini',`dhi_gini',`transferconc_inc1',`transferconc_inc2',`transferconc_inc3',`transferconc_inc4',`taxconc_inc1',`taxconc_inc2',`taxconc_inc3',`taxconc_inc4'"
     if "`ccyy'" == "at04"  di "Inequality Measures 2,countryyear,allpension_conc_inc1,allpension_conc_inc2,allpension_conc_inc3,allpension_conc_inc4,pubpension_conc_inc1,pubpension_conc_inc2,pubpension_conc_inc3,pubpension_conc_inc4,pripension_conc_inc1,pripension_conc_inc2,pripension_conc_inc3,pripension_conc_inc4"
     di "Inequality Measures 2,`ccyy',`allpensionconc_inc1',`allpensionconc_inc2',`allpensionconc_inc3',`allpensionconc_inc4',`pubpensionconc_inc1',`pubpensionconc_inc2',`pubpensionconc_inc3',`pubpensionconc_inc4',`pripensionconc_inc1',`pripensionconc_inc2',`pripensionconc_inc3',`pripensionconc_inc4'"
     if "`ccyy'" == "at04"  di "Inequality Measures 3,countryyear,inc1_mean,inc2_mean,inc3_mean,inc4_mean,dhi_mean,transfer_mean,tax_mean,allpension_mean,pubpension_mean,pripension_mean"
     di "Inequality Measures 3,`ccyy',`inc1_mean',`inc2_mean',`inc3_mean',`inc4_mean',`dhi_mean',`transfer_mean',`tax_mean',`allpension_mean',`pubpension_mean',`pripension_mean'"
     if "`ccyy'" == "at04"  di "Inequality Measures 4,countryyear,inc1_conc_inc1,inc1_conc_inc2,inc1_conc_inc3,inc1_conc_inc4,inc2_conc_inc1,inc2_conc_inc2,inc2_conc_inc3,inc2_conc_inc4,inc3_conc_inc1,inc3_conc_inc2,inc3_conc_inc3,inc3_conc_inc4,inc4_conc_inc1,inc4_conc_inc2,inc4_conc_inc3,inc4_conc_inc4"
     di "Inequality Measures 4,`ccyy',`inc1conc_inc1',`inc1conc_inc2',`inc1conc_inc3',`inc1conc_inc4',`inc2conc_inc1',`inc2conc_inc2',`inc2conc_inc3',`inc2conc_inc4',`inc3conc_inc1',`inc3conc_inc2',`inc3conc_inc3',`inc3conc_inc4',`inc4conc_inc1',`inc4conc_inc2',`inc4conc_inc3',`inc4conc_inc4'"
     if "`ccyy'" == "at04"  di "Inequality Measures 5,countryyear,hxits_mean,hsscee_mean,hsscer_mean,hssc_mean,hxitsconc_inc3,hssceeconc_inc3,hsscerconc_inc3,hsscconc_inc3"
     di "Inequality Measures 5,`ccyy',`hxits_mean',`hsscee_mean',`hsscer_mean',`hssc_mean',`hxitsconc_inc3',`hssceeconc_inc3',`hsscerconc_inc3',`hsscconc_inc3'"
	 if "`ccyy'" == "at04"  di "Inequality Measures 6,countryyear,hhaa_inc1_gini,hhaa_inc2_gini,hhaa_inc3_gini,hhaa_inc4_gini,hhaa_dhi_gini,hhaa_transfer_conc_inc1,hhaa_transfer_conc_inc2,hhaa_tax_conc_inc1,hhaa_tax_conc_inc2,hhaa_tax_conc_inc3,hhaa_tax_conc_inc4"
	 di "Inequality Measures 6,`ccyy',`hhaa_inc1_gini',`hhaa_inc2_gini',`hhaa_inc3_gini',`hhaa_inc4_gini',`hhaa_dhi_gini',`hhaa_transferconc_inc1',`hhaa_transferconc_inc2',`hhaa_taxconc_inc1',`hhaa_taxconc_inc2',`hhaa_taxconc_inc3',`hhaa_taxconc_inc4'"
	 if "`ccyy'" == "at04"  di "Inequality Measures 7,countryyear,hhaa_inc1_mean,hhaa_inc2_mean,hhaa_inc3_mean,hhaa_inc4_mean,hhaa_dhi_mean,hhaa_transfer_mean,hhaa_tax_mean,hhaa_allpension_mean,hhaa_pubpension_mean,hhaa_pripension_mean"
     di "Inequality Measures 7,`ccyy',`hhaa_inc1_mean',`hhaa_inc2_mean',`hhaa_inc3_mean',`hhaa_inc4_mean',`hhaa_dhi_mean',`hhaa_transfer_mean',`hhaa_tax_mean',`hhaa_allpension_mean',`hhaa_pubpension_mean',`hhaa_pripension_mean'"
 }

program drop _all
clear all
