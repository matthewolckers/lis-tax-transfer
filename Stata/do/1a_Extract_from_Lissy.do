*************************************************************
* Define globals
*************************************************************

global datasets "at04 at07 at13 au03 au08 au10 ca04 ca07 ca10 ca13 ch00 ch02 ch04 ch07 ch10 ch13 cz02 cz04 cz07 cz10 cz13 de00 de04 de07 de10 de13 de15 dk00 dk04 dk07 dk10 dk13 ee10 ee13 es07 es10 es13 fi00 fi04 fi07 fi10 fi13 fr00 fr05 fr10 gr07 gr10 gr13 ie04 ie07 ie10 il10 is04 is07 is10 it04 it08 it10 it14 jp08 kr06 kr08 kr10 kr12 lu04 lu07 lu10 lu13 nl99 nl04 nl07 nl10 nl13 no00 no04 no07 no10 no13 pl04 pl07 pl10 pl13 pl16 pl99 se00 se05 sk04 sk07 sk10 sk13 uk99 uk04 uk07 uk10 uk13 us00 us04 us07 us10 us13 us16 at00 be00 gr00 hu05 hu07 hu09 hu12 hu99 ie00 lu00 mx00 mx02 mx04 mx08 mx10 mx12 mx98 si10"  /*it00 il12 si12*/ 

global net_datasets "at00 be00 gr00 hu05 hu07 hu09 hu12 hu99 ie00 lu00 mx00 mx02 mx04 mx08 mx10 mx12 mx98 si10" /*it00*/ // Removed es00 and it98 in this version since they contain dupicates and missing values respectively in pil.

global pvars "pid hid dname pil pxit pxiti pxits age emp relation"

global hvars "hid dname nhhmem dhi nhhmem17 nhhmem65 hwgt"

global hvarsflow "hil hic pension hits hitsil hitsup hitsap hxit hxiti hxits hc hicvip dhi hitsilmip hitsilo hitsilep hitsilwi hitsilepo hitsilepd hitsileps" // Local currency, given in the datasets

global hvarsnew "hsscer hsscee" // Local currency, imputed

global hvarsinc "inc1 inc2 inc3 inc3_SSER inc3_SSEE inc4 tax transfer allpension pubpension pripension hssc" // Summation / imputed after PPP conversion

global incconcept "inc1 inc2 inc3 inc3_SSER inc3_SSEE inc4" /*Concept of income: for the loops*/

global fixpension_datasets3 "ie04 ie07 ie10 uk99 uk04 uk07 uk10 uk13"

*************************************************************
* Program: Generate SSC variables from person level dataset
*************************************************************

program define merge_ssc
	merge m:1 dname using "$mydata/vamour/SSC_20180621.dta", keep(match) nogenerate
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

program define missing_values
/*Here we replace missing values of aggregates by the sum of values of the subvariables if it brings extra information*/
  egen hitsilep2=rowtotal(hitsilepo hitsilepd hitsileps)
  replace hitsilep=hitsilep2 if hitsilep==. & hitsilep2 !=0
  
  egen hitsil2=rowtotal(hitsilmip hitsilo hitsilep hitsilwi)  
  replace hitsil=hitsil2 if hitsil==. & hitsil2 !=0
  
  egen hitsis2=rowtotal(hitsissi hitsisma hitsiswi hitsisun) 
  replace hitsis=hitsis2 if hitsis==. &	 hitsis !=0
  
  egen hitsup2=rowtotal(hitsupo hitsupd hitsups)
  replace hitsup=hitsup2 if hitsup==. & hitsup2 !=0
  
  egen hitsufa2=rowtotal(hitsufaca hitsufaam hitsufacc)
  replace hitsufa = hitsufa2 if hitsufa==. & hitsufa !=0
  
  egen hitsu2=rowtotal(hitsup hitsuun hitsudi hitsufa hitsued)
  replace hitsu=hitsu2 if hitsu==. & hitsu2 !=0
  
  egen hitsap2=rowtotal(hitsapo hitsapd hitsaps) 
  replace hitsap=hitsap2 if hitsap==. & hitsap2 !=0
  
  egen hitsa2=rowtotal(hitsagen hitsap hitsaun hitsafa hitsaed hitsaho hitsahe hitsafo hitsame)
  replace hitsa=hitsa2 if hitsa==. & hitsa2 !=0
  
  egen hits2=rowtotal(hitsi hitsil hitsis hitsu hitsa)
  replace hits=hits2 if hits==. & hits2 !=0
  
  egen pension2=rowtotal(hitsil hitsup hitsap hicvip)
  replace pension=pension2 if pension==. & pension2 !=0 /*A priori pension is always defined so this should have no impact...*/

  egen hicid2=rowtotal(hicidi hicidd)
  replace hicid=hicid2 if hicid==.
  
  egen hicren2=rowtotal(hicrenr hicrenl hicrenm)
  replace hicren=hicren2 if hicren==.

  egen hic2=rowtotal(hicid hicren hicroy)
  replace hic=hic2 if hic==.  
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
  /*We assume that the original INSEE survey provides information about actual "net" wages in the sense "net of all contributions" and not in the sense of "declared income", which contains non deductible CSG. If not, one should 
  remove this rate in the excel file and add it manually after we have the gross income*/

  gen psscee=.
  replace psscee = pil*ee_r1/(1-ee_r1) if pil>0 & pil<=(ee_c1 - ee_r1*ee_c1) 
  replace psscee = 1/(1-ee_r2)*(ee_r2*(pil - ee_c1) + ee_r1*ee_c1) if pil>(ee_c1 - ee_r1*ee_c1) & pil<=(ee_c2 - ee_r1*ee_c1 - ee_r2*(ee_c2-ee_c1))
  replace psscee = 1/(1-ee_r3)*(ee_r3*(pil - ee_c2) + ee_r1*ee_c1 + ee_r2*(ee_c2-ee_c1)) if pil>(ee_c2 - ee_r2*(ee_c2-ee_c1) - ee_r1*ee_c1) & pil<=(ee_c3 - ee_r3*(ee_c3-ee_c2) - ee_r2*(ee_c2-ee_c1) - ee_r1*ee_c1)
  replace psscee = 1/(1-ee_r4)*(ee_r4*(pil - ee_c3) + ee_r1*ee_c1 + ee_r2*(ee_c2-ee_c1) + ee_r3*(ee_c3 - ee_c2)) if pil>(ee_c3 - ee_r3*(ee_c3-ee_c2) - ee_r2*(ee_c2-ee_c1) - ee_r1*ee_c1)


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
  gen_employee_ssc 
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
  *Germany 2004 de04
  replace psscer = 0.25*pil if pil<4800 & dname=="de04"
  replace psscer = 0.25*pil if pil<4800 & dname=="de07"
  *Germany 2010 de10 
  replace psscer = 0.30*pil if pil<4800 & dname=="de10" 
  *Germany 2013 de13 *Seems to be now 450/month : http://www.bmas.de/EN/Our-Topics/Social-Security/450-euro-mini-jobs-marginal-employment.html
  replace psscer = 0.30*pil if pil<5400 & dname=="de13" 
  *Germany 2015 de15 (VA)
  replace psscer = 0.30*pil if pil<5400 & dname=="de15"
  *Denmark dk
   replace psscer = psscer +  1789 if pil>0 & dname=="dk00" 
   replace psscer = psscer +  1789 if pil>0 & dname=="dk04"
   replace psscer = psscer +  1951.2 if pil>0 & dname=="dk07"
   replace psscer = psscer + 2160 if pil>0 & dname=="dk10"
   replace psscer = psscer + 2160 if pil>0 & dname=="dk13"
  *Estonia 2010 ee10
  replace psscer = psscer + 17832 if pil>0 & dname=="ee10"
  *Hungary 2005 hu05
  replace psscer = psscer + 3450*10 + 1950*2 if pil>0 & dname=="hu05"
  *Hungary 2007 2009 hu07 hu09 
  replace psscer = psscer + 1950*12 if pil>0 & dname=="hu07"
  replace psscer = psscer + 1950*12 if pil>0 & dname=="hu09"
  *Ireland 2000 ie00
  replace psscer=pil*.085 if  pil<14560 & dname=="ie00" // I could have easily included these changes for Ireland in the rates and ceilings.
  *Ireland 2004 ie04
  replace psscer=pil*.085 if  pil<18512 & dname=="ie04"
  *Ireland 2007 ie07
  replace psscer=pil*.085 if  pil<18512 & dname=="ie07"
  *Ireland 2010 ie10
  replace psscer=pil*.085 if  pil<18512 & dname=="ie10"
  *Korea 2012 kr12
  replace psscer=0.045*240000*12+0.0308995*280000*12+(0.008+0.0177)*pil if pil>0 & pil<240000*12 & dname=="kr12"
  replace psscer=0.0308995*280000*12+(0.045+0.008+0.0177)*pil if pil>240000*12 & pil<280000*12 & dname=="kr12"
  *France 2000 fr00 (measured in Francs, not Euros)
  replace psscer=psscer-(0.182*pil) if pil<=83898 & dname=="fr00"
  replace psscer=psscer-(0.55*(111584.34-pil)) if pil>83898 & pil<=111584.34 & dname=="fr00" 
  *France 2005 fr05
  replace psscer=psscer-((0.26/0.6)*((24692.8/pil)-1)*pil) if pil>15433 & pil<24692.8 & dname=="fr05" //I am not sure I have this adjustment correct.
  *France 2010 fr10
  replace psscer=psscer-((0.26/0.6)*((25800.32/pil)-1)*pil) if pil>16125 & pil<25800.32 & dname=="fr10"
 *Mexico 2000 mx00
  replace psscer=psscer + 0.152*35.12*365 if pil>0 & dname=="mx00"
  replace psscer=psscer + 0.0502*(pil-3*35.12*365) if pil>3*35.12*365 & dname=="mx00"
  *Mexico 2002 mx02
  replace psscer=psscer + 0.165*39.74*365 if pil>0 & dname=="mx02"
  replace psscer=psscer + 0.0404*(pil-3*39.74*365) if pil>3*39.74*365 & dname=="mx02"
 *Mexico 2004 mx04
  replace psscer=psscer + 0.178*45.24*365 if pil>0 & dname=="mx04"
  replace psscer=psscer + 0.0306*(pil-3*45.24*365) if pil>3*45.24*365 & dname=="mx04"
 *Mexico 2008 mx08
  replace psscer=psscer + 0.204*52.59*365 if pil>0 & dname=="mx08"
  replace psscer=psscer + 0.011*(pil-3*52.59*365) if pil>3*52.59*365 & dname=="mx08"
 *Mexico 2010 mx10
  replace psscer=psscer + 0.204*57.46*365 if pil>0 & dname=="mx10"
  replace psscer=psscer + 0.011*(pil-3*57.46*365) if pil>3*57.46*365 & pil<25*57.46*365 & dname=="mx10"
  replace psscer=psscer + 0.011*((25-3)*57.46*365)	 if pil>25*57.46*365 & dname=="mx10"
 *Mexico 2012 mx12 VA
  replace psscer=psscer + 0.204*62.33*365 if pil>0 & dname=="mx10"
  replace psscer=psscer + 0.011*(pil-3*62.33*365) if pil>3*62.33*365 & pil<25*62.33*365 & dname=="mx10"
  replace psscer=psscer + 0.011*((25-3)*62.33*365)	 if pil>25*62.33*365 & dname=="mx10"

  *Netherlands 1999 nl99
  replace psscer=psscer + 0.0585*pil  if pil>0 & pil<54810 & dname=="nl99"
  replace psscer=psscer + 0.0585*54810  if pil>0 & pil<64300 & dname=="nl99"
  *Netherlands 2004 nl04
  replace psscer=psscer + 0.0675*pil  if pil>0 & pil<29493 & dname=="nl04"
  replace psscer=psscer + 0.0675*29493  if pil>0 & pil<32600 & dname=="nl04"
end

***************************************************************************
* Program: Apply PPP conversions and equivalence scales to flow variables
***************************************************************************

program define ppp_equiv
  * Define PPP conversions to 2011 international dollars (ppp)
  merge m:1 dname using "$mydata/vamour/ppp_20180622.dta", keep(match) nogenerate

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
  gen inc3_SSER = marketincome + allpension + transfer - hsscer /*Inc3 minus Employer (ER) social security contributions (SSER)*/
  gen inc3_SSEE = marketincome + allpension + transfer - hsscer - hxits /*Inc3 minus ER and EE SSC*/
  gen inc4 = marketincome + allpension + transfer - tax

  * Trim and bottom code
  // The preceding steps are in the ppp_equiv program
  * Step 3
  foreach var in $hvarsflow $hvarsnew {
  replace `var' = 0 if `var' < 0
  }
  * Define the income deciles - Define various deciles for various concepts of income
  foreach var in $incconcept{
  xtile decile_`var' = `var' [w=hwgt*nhhmem], nquantiles(10) // already corrected for household size by ppp_equiv
  xtile hhaa_decile_`var' = `var' [w=hwgt*nhhmem] if hhactivage==1, nquantiles(10) // already corrected for household size by ppp_equiv
}

end

**************************************************
* Program: Define taxes and transfer variables
**************************************************

program define def_tax_and_transfer
  gen pubpension = hitsil + hitsup /*Use conventional definition: hitsil + hitsup if nothing missing. Recall that hitsil or hitsup may have been "enriched" by their components but there are still missing values left */
  * if hitsil or hitsup is missing (=> previous formula generates a missing value), use the negative definition of pubpension*/
 
  replace pubpension= pension - hicvip - hitsap if pubpension==. /*Recall: pension = hitsil + hitsup + hicvip + hitsap: if hicvip and hitsap are defined, hitsil + hitsup can be defined by the residual*/
  replace pubpension = pension - hicvip if pubpension==.  /*use pension - hicvip if only hitsap missing*/
  replace pubpension = pension - hitsap if pubpension==.  /*use pension - hitsap if only hicvip missing*/
  replace pubpension = pension if pubpension==. /*if pension is the only variable not missing, use this as pubpension*/
  
   *Now we define transfers and pensions. We set to 0 the remaining missing values
  replace pubpension=0 if pubpension==.
  replace hits=0 if hits==.
  replace hicvip=0 if hicvip==.
  replace hitsil=0 if hitsil==.
  replace hitsap=0 if hitsap==.
  replace hitsup=0 if hitsup==.
  replace pension=0 if pension==.

  gen transfer = hits - pubpension
  gen pripension = hicvip
  gen allpension = pension - hitsap
 
  *Finally define PIT and social security contribution. Rather use hxit in the income definitions
   * Use the imputed data if employee social security contributions is not available
  replace hxits=hsscee if hxits==.
  replace hxiti=hxit - hxits if hxiti==.
  replace hxit = hxiti + hxits if hxit==.

  gen tax = hxit + hsscer
  gen hssc = hxits + hsscer
  gen marketincome = hil + (hic-hicvip) + hsscer
  
  * Italy is reported net of both SSC contributions and income tax while the gross datasets 
  * are net of employer contributions but gross of employee SSC and income tax.
  replace marketincome = hil + (hic-hicvip) + tax if dname=="it04" | dname=="it08" | dname=="it10" | dname=="it14"

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
  drop pubpension allpension transfer inc1 inc2 inc3 inc4 inc3_SSER inc3_SSEE decile_inc1 decile_inc2 decile_inc3 decile_inc4 decile_inc3_SSER decile_inc3_SSEE hhaa_decile_inc1 hhaa_decile_inc2 hhaa_decile_inc3 hhaa_decile_inc4 hhaa_decile_inc3_SSER hhaa_decile_inc3_SSEE
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
  drop tax inc1 inc2 inc3 inc4 inc3_SSER inc3_SSEE  decile_inc1 decile_inc2 decile_inc3 decile_inc4 decile_inc3_SSER decile_inc3_SSEE hhaa_decile_inc1 hhaa_decile_inc2 hhaa_decile_inc3 hhaa_decile_inc4 hhaa_decile_inc3_SSER hhaa_decile_inc3_SSEE marketincome
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
  gen hic_csg_crds = hic * 0.08 if dname =="fr00"
  replace hic_csg_crds = hic * 0.087 if dname =="fr05"
  replace hic_csg_crds = hic * 0.087  if dname =="fr10"
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
    gen hil_temp=hil-hxiti-hsscee /*On regarde bien le salaire net pour calculer le RFR*/
    replace pension_csg_crds = 0.043/(1-0.043)*(hitsil + hitsup) if ((hil_temp/(1-0.024*0.97) + hitsil + hitsup)*0.9 + hic) > (6584+2*(familyshare - 1)*1759) & hxit<=0 & dname=="fr00" // 2002 figures deflated to 2000 prices using WDI CPI
    replace pension_csg_crds = 0.067/(1-0.067)*(hitsil + hitsup) if ((hil_temp/(1-0.024*0.97) + hitsil + hitsup)*0.9 + hic) > (6584+2*(familyshare - 1)*1759) & hxit>0 & dname=="fr00" // 2002 figures deflated to 2000 prices using WDI CPI
    replace pension_csg_crds = 0.043/(1-0.043)*(hitsil + hitsup) if ((hil_temp/(1-0.024*0.97) + hitsil + hitsup)*0.9 + hic) > (7165+2*(familyshare - 1)*1914) & hxit<=0 & dname=="fr05"
    replace pension_csg_crds = 0.071/(1-0.071)*(hitsil + hitsup) if ((hil_temp/(1-0.024*0.97)+ hitsil + hitsup)*0.9 + hic) >  (7165+2*(familyshare - 1)*1914) & hxit>0 & dname=="fr05"
    replace pension_csg_crds = 0.043/(1-0.043)*(hitsil + hitsup) if ((hil_temp/(1-0.024*0.97) + hitsil + hitsup)*0.9 + hic) > (9876+2*(familyshare - 1)*2637) & hxit<=0 & dname=="fr10"
    replace pension_csg_crds = 0.071/(1-0.071)*(hitsil + hitsup) if ((hil_temp/(1-0.024*0.97) + hitsil + hitsup)*0.9 + hic) > (9876+2*(familyshare - 1)*2637) & hxit>0& dname=="fr10"
    drop hil_temp
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
      local `var'_conc_`sortvar' = r(coeff)
	  quietly capture sgini `var' [aw=hwgt*nhhmem] if hhactivage==1, sortvar(`sortvar')
      local hhaa_`var'_conc_`sortvar' = r(coeff)
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
  
     if "`ccyy'" == "at04" di "countryyear,decile,inc1_mean_inc1,inc1_min_inc1,inc1_max_inc1,transfer_mean_inc1,transfer_min_inc1,transfer_max_inc1,tax_mean_inc1,tax_min_inc1,tax_max_inc1,inc2_mean_inc2,inc2_min_inc2,inc2_max_inc2,transfer_mean_inc2,transfer_min_inc2,transfer_max_inc2,tax_mean_inc2,tax_min_inc2,tax_max_inc2,inc3_mean_inc3,inc3_min_inc3,inc3_max_inc3,transfer_mean_inc3,transfer_min_inc3,transfer_max_inc3,tax_mean_inc3,tax_min_inc3,tax_max_inc3,inc4_mean_inc4,inc4_min_inc4,inc4_max_inc4,transfer_mean_inc4,transfer_min_inc4,transfer_max_inc4,tax_mean_inc4,tax_min_inc4,tax_max_inc4,inc3_SSER_mean_inc3_SSER,inc3_SSER_min_inc3_SSER,inc3_SSER_max_inc3_SSER,transfer_mean_inc3_SSER,transfer_min_inc3_SSER,transfer_max_inc3_SSER,tax_mean_inc3_SSER,tax_min_inc3_SSER,tax_max_inc3_SSER,inc3_SSEE_mean_inc3_SSEE,inc3_SSEE_min_inc3_SSEE,inc3_SSEE_max_inc3_SSEE,transfer_mean_inc3_SSEE,transfer_min_inc3_SSEE,transfer_max_inc3_SSEE,tax_mean_inc3_SSEE,tax_min_inc3_SSEE,tax_max_inc3_SSEE"
     di "`ccyy',D01,`inc1_mean_1_inc1',`inc1_min_1_inc1',`inc1_max_1_inc1',`transfer_mean_1_inc1',`transfer_min_1_inc1',`transfer_max_1_inc1',`tax_mean_1_inc1',`tax_min_1_inc1',`tax_max_1_inc1',`inc2_mean_1_inc2',`inc2_min_1_inc2',`inc2_max_1_inc2',`transfer_mean_1_inc2',`transfer_min_1_inc2',`transfer_max_1_inc2',`tax_mean_1_inc2',`tax_min_1_inc2',`tax_max_1_inc2',`inc3_mean_1_inc3',`inc3_min_1_inc3',`inc3_max_1_inc3',`transfer_mean_1_inc3',`transfer_min_1_inc3',`transfer_max_1_inc3',`tax_mean_1_inc3',`tax_min_1_inc3',`tax_max_1_inc3',`inc4_mean_1_inc4',`inc4_min_1_inc4',`inc4_max_1_inc4',`transfer_mean_1_inc4',`transfer_min_1_inc4',`transfer_max_1_inc4',`tax_mean_1_inc4',`tax_min_1_inc4',`tax_max_1_inc4',`inc3_SSER_mean_1_inc3_SSER',`inc3_SSER_min_1_inc3_SSER',`inc3_SSER_max_1_inc3_SSER',`transfer_mean_1_inc3_SSER',`transfer_min_1_inc3_SSER',`transfer_max_1_inc3_SSER',`tax_mean_1_inc3_SSER',`tax_min_1_inc3_SSER',`tax_max_1_inc3_SSER',`inc3_SSEE_mean_1_inc3_SSEE',`inc3_SSEE_min_1_inc3_SSEE',`inc3_SSEE_max_1_inc3_SSEE',`transfer_mean_1_inc3_SSEE',`transfer_min_1_inc3_SSEE',`transfer_max_1_inc3_SSEE',`tax_mean_1_inc3_SSEE',`tax_min_1_inc3_SSEE',`tax_max_1_inc3_SSEE'"
     di "`ccyy',D02,`inc1_mean_2_inc1',`inc1_min_2_inc1',`inc1_max_2_inc1',`transfer_mean_2_inc1',`transfer_min_2_inc1',`transfer_max_2_inc1',`tax_mean_2_inc1',`tax_min_2_inc1',`tax_max_2_inc1',`inc2_mean_2_inc2',`inc2_min_2_inc2',`inc2_max_2_inc2',`transfer_mean_2_inc2',`transfer_min_2_inc2',`transfer_max_2_inc2',`tax_mean_2_inc2',`tax_min_2_inc2',`tax_max_2_inc2',`inc3_mean_2_inc3',`inc3_min_2_inc3',`inc3_max_2_inc3',`transfer_mean_2_inc3',`transfer_min_2_inc3',`transfer_max_2_inc3',`tax_mean_2_inc3',`tax_min_2_inc3',`tax_max_2_inc3',`inc4_mean_2_inc4',`inc4_min_2_inc4',`inc4_max_2_inc4',`transfer_mean_2_inc4',`transfer_min_2_inc4',`transfer_max_2_inc4',`tax_mean_2_inc4',`tax_min_2_inc4',`tax_max_2_inc4',`inc3_SSER_mean_2_inc3_SSER',`inc3_SSER_min_2_inc3_SSER',`inc3_SSER_max_2_inc3_SSER',`transfer_mean_2_inc3_SSER',`transfer_min_2_inc3_SSER',`transfer_max_2_inc3_SSER',`tax_mean_2_inc3_SSER',`tax_min_2_inc3_SSER',`tax_max_2_inc3_SSER',`inc3_SSEE_mean_2_inc3_SSEE',`inc3_SSEE_min_2_inc3_SSEE',`inc3_SSEE_max_2_inc3_SSEE',`transfer_mean_2_inc3_SSEE',`transfer_min_2_inc3_SSEE',`transfer_max_2_inc3_SSEE',`tax_mean_2_inc3_SSEE',`tax_min_2_inc3_SSEE',`tax_max_2_inc3_SSEE'"
     di "`ccyy',D03,`inc1_mean_3_inc1',`inc1_min_3_inc1',`inc1_max_3_inc1',`transfer_mean_3_inc1',`transfer_min_3_inc1',`transfer_max_3_inc1',`tax_mean_3_inc1',`tax_min_3_inc1',`tax_max_3_inc1',`inc2_mean_3_inc2',`inc2_min_3_inc2',`inc2_max_3_inc2',`transfer_mean_3_inc2',`transfer_min_3_inc2',`transfer_max_3_inc2',`tax_mean_3_inc2',`tax_min_3_inc2',`tax_max_3_inc2',`inc3_mean_3_inc3',`inc3_min_3_inc3',`inc3_max_3_inc3',`transfer_mean_3_inc3',`transfer_min_3_inc3',`transfer_max_3_inc3',`tax_mean_3_inc3',`tax_min_3_inc3',`tax_max_3_inc3',`inc4_mean_3_inc4',`inc4_min_3_inc4',`inc4_max_3_inc4',`transfer_mean_3_inc4',`transfer_min_3_inc4',`transfer_max_3_inc4',`tax_mean_3_inc4',`tax_min_3_inc4',`tax_max_3_inc4',`inc3_SSER_mean_3_inc3_SSER',`inc3_SSER_min_3_inc3_SSER',`inc3_SSER_max_3_inc3_SSER',`transfer_mean_3_inc3_SSER',`transfer_min_3_inc3_SSER',`transfer_max_3_inc3_SSER',`tax_mean_3_inc3_SSER',`tax_min_3_inc3_SSER',`tax_max_3_inc3_SSER',`inc3_SSEE_mean_3_inc3_SSEE',`inc3_SSEE_min_3_inc3_SSEE',`inc3_SSEE_max_3_inc3_SSEE',`transfer_mean_3_inc3_SSEE',`transfer_min_3_inc3_SSEE',`transfer_max_3_inc3_SSEE',`tax_mean_3_inc3_SSEE',`tax_min_3_inc3_SSEE',`tax_max_3_inc3_SSEE'"    
     di "`ccyy',D04,`inc1_mean_4_inc1',`inc1_min_4_inc1',`inc1_max_4_inc1',`transfer_mean_4_inc1',`transfer_min_4_inc1',`transfer_max_4_inc1',`tax_mean_4_inc1',`tax_min_4_inc1',`tax_max_4_inc1',`inc2_mean_4_inc2',`inc2_min_4_inc2',`inc2_max_4_inc2',`transfer_mean_4_inc2',`transfer_min_4_inc2',`transfer_max_4_inc2',`tax_mean_4_inc2',`tax_min_4_inc2',`tax_max_4_inc2',`inc3_mean_4_inc3',`inc3_min_4_inc3',`inc3_max_4_inc3',`transfer_mean_4_inc3',`transfer_min_4_inc3',`transfer_max_4_inc3',`tax_mean_4_inc3',`tax_min_4_inc3',`tax_max_4_inc3',`inc4_mean_4_inc4',`inc4_min_4_inc4',`inc4_max_4_inc4',`transfer_mean_4_inc4',`transfer_min_4_inc4',`transfer_max_4_inc4',`tax_mean_4_inc4',`tax_min_4_inc4',`tax_max_4_inc4',`inc3_SSER_mean_4_inc3_SSER',`inc3_SSER_min_4_inc3_SSER',`inc3_SSER_max_4_inc3_SSER',`transfer_mean_4_inc3_SSER',`transfer_min_4_inc3_SSER',`transfer_max_4_inc3_SSER',`tax_mean_4_inc3_SSER',`tax_min_4_inc3_SSER',`tax_max_4_inc3_SSER',`inc3_SSEE_mean_4_inc3_SSEE',`inc3_SSEE_min_4_inc3_SSEE',`inc3_SSEE_max_4_inc3_SSEE',`transfer_mean_4_inc3_SSEE',`transfer_min_4_inc3_SSEE',`transfer_max_4_inc3_SSEE',`tax_mean_4_inc3_SSEE',`tax_min_4_inc3_SSEE',`tax_max_4_inc3_SSEE'"
     di "`ccyy',D05,`inc1_mean_5_inc1',`inc1_min_5_inc1',`inc1_max_5_inc1',`transfer_mean_5_inc1',`transfer_min_5_inc1',`transfer_max_5_inc1',`tax_mean_5_inc1',`tax_min_5_inc1',`tax_max_5_inc1',`inc2_mean_5_inc2',`inc2_min_5_inc2',`inc2_max_5_inc2',`transfer_mean_5_inc2',`transfer_min_5_inc2',`transfer_max_5_inc2',`tax_mean_5_inc2',`tax_min_5_inc2',`tax_max_5_inc2',`inc3_mean_5_inc3',`inc3_min_5_inc3',`inc3_max_5_inc3',`transfer_mean_5_inc3',`transfer_min_5_inc3',`transfer_max_5_inc3',`tax_mean_5_inc3',`tax_min_5_inc3',`tax_max_5_inc3',`inc4_mean_5_inc4',`inc4_min_5_inc4',`inc4_max_5_inc4',`transfer_mean_5_inc4',`transfer_min_5_inc4',`transfer_max_5_inc4',`tax_mean_5_inc4',`tax_min_5_inc4',`tax_max_5_inc4',`inc3_SSER_mean_5_inc3_SSER',`inc3_SSER_min_5_inc3_SSER',`inc3_SSER_max_5_inc3_SSER',`transfer_mean_5_inc3_SSER',`transfer_min_5_inc3_SSER',`transfer_max_5_inc3_SSER',`tax_mean_5_inc3_SSER',`tax_min_5_inc3_SSER',`tax_max_5_inc3_SSER',`inc3_SSEE_mean_5_inc3_SSEE',`inc3_SSEE_min_5_inc3_SSEE',`inc3_SSEE_max_5_inc3_SSEE',`transfer_mean_5_inc3_SSEE',`transfer_min_5_inc3_SSEE',`transfer_max_5_inc3_SSEE',`tax_mean_5_inc3_SSEE',`tax_min_5_inc3_SSEE',`tax_max_5_inc3_SSEE'"
     di "`ccyy',D06,`inc1_mean_6_inc1',`inc1_min_6_inc1',`inc1_max_6_inc1',`transfer_mean_6_inc1',`transfer_min_6_inc1',`transfer_max_6_inc1',`tax_mean_6_inc1',`tax_min_6_inc1',`tax_max_6_inc1',`inc2_mean_6_inc2',`inc2_min_6_inc2',`inc2_max_6_inc2',`transfer_mean_6_inc2',`transfer_min_6_inc2',`transfer_max_6_inc2',`tax_mean_6_inc2',`tax_min_6_inc2',`tax_max_6_inc2',`inc3_mean_6_inc3',`inc3_min_6_inc3',`inc3_max_6_inc3',`transfer_mean_6_inc3',`transfer_min_6_inc3',`transfer_max_6_inc3',`tax_mean_6_inc3',`tax_min_6_inc3',`tax_max_6_inc3',`inc4_mean_6_inc4',`inc4_min_6_inc4',`inc4_max_6_inc4',`transfer_mean_6_inc4',`transfer_min_6_inc4',`transfer_max_6_inc4',`tax_mean_6_inc4',`tax_min_6_inc4',`tax_max_6_inc4',`inc3_SSER_mean_6_inc3_SSER',`inc3_SSER_min_6_inc3_SSER',`inc3_SSER_max_6_inc3_SSER',`transfer_mean_6_inc3_SSER',`transfer_min_6_inc3_SSER',`transfer_max_6_inc3_SSER',`tax_mean_6_inc3_SSER',`tax_min_6_inc3_SSER',`tax_max_6_inc3_SSER',`inc3_SSEE_mean_6_inc3_SSEE',`inc3_SSEE_min_6_inc3_SSEE',`inc3_SSEE_max_6_inc3_SSEE',`transfer_mean_6_inc3_SSEE',`transfer_min_6_inc3_SSEE',`transfer_max_6_inc3_SSEE',`tax_mean_6_inc3_SSEE',`tax_min_6_inc3_SSEE',`tax_max_6_inc3_SSEE'"
     di "`ccyy',D07,`inc1_mean_7_inc1',`inc1_min_7_inc1',`inc1_max_7_inc1',`transfer_mean_7_inc1',`transfer_min_7_inc1',`transfer_max_7_inc1',`tax_mean_7_inc1',`tax_min_7_inc1',`tax_max_7_inc1',`inc2_mean_7_inc2',`inc2_min_7_inc2',`inc2_max_7_inc2',`transfer_mean_7_inc2',`transfer_min_7_inc2',`transfer_max_7_inc2',`tax_mean_7_inc2',`tax_min_7_inc2',`tax_max_7_inc2',`inc3_mean_7_inc3',`inc3_min_7_inc3',`inc3_max_7_inc3',`transfer_mean_7_inc3',`transfer_min_7_inc3',`transfer_max_7_inc3',`tax_mean_7_inc3',`tax_min_7_inc3',`tax_max_7_inc3',`inc4_mean_7_inc4',`inc4_min_7_inc4',`inc4_max_7_inc4',`transfer_mean_7_inc4',`transfer_min_7_inc4',`transfer_max_7_inc4',`tax_mean_7_inc4',`tax_min_7_inc4',`tax_max_7_inc4',`inc3_SSER_mean_7_inc3_SSER',`inc3_SSER_min_7_inc3_SSER',`inc3_SSER_max_7_inc3_SSER',`transfer_mean_7_inc3_SSER',`transfer_min_7_inc3_SSER',`transfer_max_7_inc3_SSER',`tax_mean_7_inc3_SSER',`tax_min_7_inc3_SSER',`tax_max_7_inc3_SSER',`inc3_SSEE_mean_7_inc3_SSEE',`inc3_SSEE_min_7_inc3_SSEE',`inc3_SSEE_max_7_inc3_SSEE',`transfer_mean_7_inc3_SSEE',`transfer_min_7_inc3_SSEE',`transfer_max_7_inc3_SSEE',`tax_mean_7_inc3_SSEE',`tax_min_7_inc3_SSEE',`tax_max_7_inc3_SSEE'"
     di "`ccyy',D08,`inc1_mean_8_inc1',`inc1_min_8_inc1',`inc1_max_8_inc1',`transfer_mean_8_inc1',`transfer_min_8_inc1',`transfer_max_8_inc1',`tax_mean_8_inc1',`tax_min_8_inc1',`tax_max_8_inc1',`inc2_mean_8_inc2',`inc2_min_8_inc2',`inc2_max_8_inc2',`transfer_mean_8_inc2',`transfer_min_8_inc2',`transfer_max_8_inc2',`tax_mean_8_inc2',`tax_min_8_inc2',`tax_max_8_inc2',`inc3_mean_8_inc3',`inc3_min_8_inc3',`inc3_max_8_inc3',`transfer_mean_8_inc3',`transfer_min_8_inc3',`transfer_max_8_inc3',`tax_mean_8_inc3',`tax_min_8_inc3',`tax_max_8_inc3',`inc4_mean_8_inc4',`inc4_min_8_inc4',`inc4_max_8_inc4',`transfer_mean_8_inc4',`transfer_min_8_inc4',`transfer_max_8_inc4',`tax_mean_8_inc4',`tax_min_8_inc4',`tax_max_8_inc4',`inc3_SSER_mean_8_inc3_SSER',`inc3_SSER_min_8_inc3_SSER',`inc3_SSER_max_8_inc3_SSER',`transfer_mean_8_inc3_SSER',`transfer_min_8_inc3_SSER',`transfer_max_8_inc3_SSER',`tax_mean_8_inc3_SSER',`tax_min_8_inc3_SSER',`tax_max_8_inc3_SSER',`inc3_SSEE_mean_8_inc3_SSEE',`inc3_SSEE_min_8_inc3_SSEE',`inc3_SSEE_max_8_inc3_SSEE',`transfer_mean_8_inc3_SSEE',`transfer_min_8_inc3_SSEE',`transfer_max_8_inc3_SSEE',`tax_mean_8_inc3_SSEE',`tax_min_8_inc3_SSEE',`tax_max_8_inc3_SSEE'"
     di "`ccyy',D09,`inc1_mean_9_inc1',`inc1_min_9_inc1',`inc1_max_9_inc1',`transfer_mean_9_inc1',`transfer_min_9_inc1',`transfer_max_9_inc1',`tax_mean_9_inc1',`tax_min_9_inc1',`tax_max_9_inc1',`inc2_mean_9_inc2',`inc2_min_9_inc2',`inc2_max_9_inc2',`transfer_mean_9_inc2',`transfer_min_9_inc2',`transfer_max_9_inc2',`tax_mean_9_inc2',`tax_min_9_inc2',`tax_max_9_inc2',`inc3_mean_9_inc3',`inc3_min_9_inc3',`inc3_max_9_inc3',`transfer_mean_9_inc3',`transfer_min_9_inc3',`transfer_max_9_inc3',`tax_mean_9_inc3',`tax_min_9_inc3',`tax_max_9_inc3',`inc4_mean_9_inc4',`inc4_min_9_inc4',`inc4_max_9_inc4',`transfer_mean_9_inc4',`transfer_min_9_inc4',`transfer_max_9_inc4',`tax_mean_9_inc4',`tax_min_9_inc4',`tax_max_9_inc4',`inc3_SSER_mean_9_inc3_SSER',`inc3_SSER_min_9_inc3_SSER',`inc3_SSER_max_9_inc3_SSER',`transfer_mean_9_inc3_SSER',`transfer_min_9_inc3_SSER',`transfer_max_9_inc3_SSER',`tax_mean_9_inc3_SSER',`tax_min_9_inc3_SSER',`tax_max_9_inc3_SSER',`inc3_SSEE_mean_9_inc3_SSEE',`inc3_SSEE_min_9_inc3_SSEE',`inc3_SSEE_max_9_inc3_SSEE',`transfer_mean_9_inc3_SSEE',`transfer_min_9_inc3_SSEE',`transfer_max_9_inc3_SSEE',`tax_mean_9_inc3_SSEE',`tax_min_9_inc3_SSEE',`tax_max_9_inc3_SSEE'"
     di "`ccyy',D10,`inc1_mean_10_inc1',`inc1_min_10_inc1',`inc1_max_10_inc1',`transfer_mean_10_inc1',`transfer_min_10_inc1',`transfer_max_10_inc1',`tax_mean_10_inc1',`tax_min_10_inc1',`tax_max_10_inc1',`inc2_mean_10_inc2',`inc2_min_10_inc2',`inc2_max_10_inc2',`transfer_mean_10_inc2',`transfer_min_10_inc2',`transfer_max_10_inc2',`tax_mean_10_inc2',`tax_min_10_inc2',`tax_max_10_inc2',`inc3_mean_10_inc3',`inc3_min_10_inc3',`inc3_max_10_inc3',`transfer_mean_10_inc3',`transfer_min_10_inc3',`transfer_max_10_inc3',`tax_mean_10_inc3',`tax_min_10_inc3',`tax_max_10_inc3',`inc4_mean_10_inc4',`inc4_min_10_inc4',`inc4_max_10_inc4',`transfer_mean_10_inc4',`transfer_min_10_inc4',`transfer_max_10_inc4',`tax_mean_10_inc4',`tax_min_10_inc4',`tax_max_10_inc4',`inc3_SSER_mean_10_inc3_SSER',`inc3_SSER_min_10_inc3_SSER',`inc3_SSER_max_10_inc3_SSER',`transfer_mean_10_inc3_SSER',`transfer_min_10_inc3_SSER',`transfer_max_10_inc3_SSER',`tax_mean_10_inc3_SSER',`tax_min_10_inc3_SSER',`tax_max_10_inc3_SSER',`inc3_SSEE_mean_10_inc3_SSEE',`inc3_SSEE_min_10_inc3_SSEE',`inc3_SSEE_max_10_inc3_SSEE',`transfer_mean_10_inc3_SSEE',`transfer_min_10_inc3_SSEE',`transfer_max_10_inc3_SSEE',`tax_mean_10_inc3_SSEE',`tax_min_10_inc3_SSEE',`tax_max_10_inc3_SSEE'"
     if "`ccyy'" == "at04"  di "Inequality Measures 1,countryyear,inc1_gini,inc2_gini,inc3_gini,inc4_gini,inc3_SSER_gini,inc3_SSEE_gini,dhi_gini,transfer_conc_inc1,transfer_conc_inc2,transfer_conc_inc3,transfer_conc_inc4,transfer_conc_inc3_SSER,transfer_conc_inc3_SSEE,tax_conc_inc1,tax_conc_inc2,tax_conc_inc3,tax_conc_inc4,tax_conc_inc3_SSER,tax_conc_inc3_SSEE"
     di "Inequality Measures 1,`ccyy',`inc1_gini',`inc2_gini',`inc3_gini',`inc4_gini',`inc3_SSER_gini',`inc3_SSEE_gini',`dhi_gini',`transferconc_inc1',`transfer_conc_inc2',`transfer_conc_inc3',`transfer_conc_inc4',`transfer_conc_inc3_SSER',`transfer_conc_inc3_SSEE',`tax_conc_inc1',`tax_conc_inc2',`tax_conc_inc3',`tax_conc_inc4',`tax_conc_inc3_SSER',`tax_conc_inc3_SSEE'"
     if "`ccyy'" == "at04"  di "Inequality Measures 2,countryyear,allpension_conc_inc1,allpension_conc_inc2,allpension_conc_inc3,allpension_conc_inc4,allpension_conc_inc3_SSER,allpension_conc_inc3_SSEE,pubpension_conc_inc1,pubpension_conc_inc2,pubpension_conc_inc3,pubpension_conc_inc4,pubpension_conc_inc3_SSER,pubpension_conc_inc3_SSEE,pripension_conc_inc1,pripension_conc_inc2,pripension_conc_inc3,pripension_conc_inc4,pripension_conc_inc3_SSER,pripension_conc_inc3_SSEE"
     di "Inequality Measures 2,`ccyy',`allpension_conc_inc1',`allpension_conc_inc2',`allpension_conc_inc3',`allpension_conc_inc4',`allpension_conc_inc3_SSER',`allpension_conc_inc3_SSEE',`pubpension_conc_inc1',`pubpension_conc_inc2',`pubpension_conc_inc3',`pubpension_conc_inc4',`pubpension_conc_inc3_SSER',`pubpension_conc_inc3_SSEE',`pripension_conc_inc1',`pripension_conc_inc2',`pripension_conc_inc3',`pripension_conc_inc4',`pripension_conc_inc3_SSER',`pripension_conc_inc3_SSEE'"
     if "`ccyy'" == "at04"  di "Inequality Measures 3,countryyear,inc1_mean,inc2_mean,inc3_mean,inc4_mean,inc3_SSER_mean,inc3_SSEE_mean,dhi_mean,transfer_mean,tax_mean,allpension_mean,pubpension_mean,pripension_mean"
     di "Inequality Measures 3,`ccyy',`inc1_mean',`inc2_mean',`inc3_mean',`inc4_mean',`inc3_SSER_mean',`inc3_SSEE_mean',`dhi_mean',`transfer_mean',`tax_mean',`allpension_mean',`pubpension_mean',`pripension_mean'"
     if "`ccyy'" == "at04" di "Inequality Measures 4,countryyear,inc1_conc_inc1,inc1_conc_inc2,inc1_conc_inc3,inc1_conc_inc3_SSER,inc1_conc_inc3_SSEE,inc1_conc_inc4,inc2_conc_inc1,inc2_conc_inc2,inc2_conc_inc3,inc2_conc_inc3_SSER,inc2_conc_inc3_SSEE,inc2_conc_inc4,inc3_conc_inc1,inc3_conc_inc2,inc3_conc_inc3,inc3_conc_inc3_SSER,inc3_conc_inc3_SSEE,inc3_conc_inc4,inc3_SSER_conc_inc1,inc3_SSER_conc_inc2,inc3_SSER_conc_inc3,inc3_SSER_conc_inc3_SSER,inc3_SSER_conc_inc3_SSEE,inc3_SSER_conc_inc4,inc3_SSEE_conc_inc1,inc3_SSEE_conc_inc2,inc3_SSEE_conc_inc3,inc3_SSEE_conc_inc3_SSEE,inc3_SSEE_conc_inc3_SSEE,inc3_SSEE_conc_inc4,inc4_conc_inc1,inc4_conc_inc2,inc4_conc_inc3,inc4_conc_inc3_SSER,inc4_conc_inc3_SSEE,inc4_conc_inc4"
     di "Inequality Measures 4,`ccyy',`inc1_conc_inc1',`inc1_conc_inc2',`inc1_conc_inc3',`inc1_conc_inc3_SSER',`inc1_conc_inc3_SSEE',`inc1_conc_inc4',`inc2_conc_inc1',`inc2_conc_inc2',`inc2_conc_inc3',`inc2_conc_inc3_SSER',`inc2_conc_inc3_SSEE',`inc2_conc_inc4',`inc3_conc_inc1',`inc3_conc_inc2',`inc3_conc_inc3',`inc3_conc_inc3_SSER',`inc3_conc_inc3_SSEE',`inc3_conc_inc4',`inc3_SSER_conc_inc1',`inc3_SSER_conc_inc2',`inc3_SSER_conc_inc3',`inc3_SSER_conc_inc3_SSER',`inc3_SSER_conc_inc3_SSEE',`inc3_SSER_conc_inc4',`inc3_SSEE_conc_inc1',`inc3_SSEE_conc_inc2',`inc3_SSEE_conc_inc3',`inc3_SSEE_conc_inc3_SSER',`inc3_SSEE_conc_inc3_SSEE',`inc3_SSEE_conc_inc4',`inc4_conc_inc1',`inc4_conc_inc2',`inc4_conc_inc3',`inc4_conc_inc3_SSER',`inc4_conc_inc3_SSEE',`inc4_conc_inc4'"   
     if "`ccyy'" == "at04"  di "Inequality Measures 5,countryyear,hxits_mean,hsscee_mean,hsscer_mean,hssc_mean,hxits_conc_inc3,hsscee_conc_inc3,hsscer_conc_inc3,hssc_conc_inc3"
     di "Inequality Measures 5,`ccyy',`hxits_mean',`hsscee_mean',`hsscer_mean',`hssc_mean',`hxits_conc_inc3',`hsscee_conc_inc3',`hsscer_conc_inc3',`hssc_conc_inc3'"
     if "`ccyy'" == "at04"  di "Inequality Measures 6,countryyear,hhaa_inc1_gini,hhaa_inc2_gini,hhaa_inc3_gini,hhaa_inc4_gini,hhaa_inc3_SSER_gini,hhaa_inc3_SSEE_gini,hhaa_dhi_gini,hhaa_transfer_conc_inc1,hhaa_transfer_conc_inc2,hhaa_transfer_conc_inc3,hhaa_transfer_conc_inc4,hhaa_transfer_conc_inc3_SSER,hhaa_transfer_conc_inc3_SSEE,hhaa_tax_conc_inc1,hhaa_tax_conc_inc2,hhaa_tax_conc_inc3,hhaa_tax_conc_inc4,hhaa_tax_conc_inc3_SSER,hhaa_tax_conc_inc3_SSEE"
     di "Inequality Measures 6,`ccyy',`hhaa_inc1_gini',`hhaa_inc2_gini',`hhaa_inc3_gini',`hhaa_inc4_gini',`hhaa_inc3_SSER_gini',`hhaa_inc3_SSEE_gini',`hhaa_dhi_gini',`hhaa_transfer_conc_inc1',`hhaa_transfer_conc_inc2',`hhaa_transfer_conc_inc3',`hhaa_transfer_conc_inc4',`hhaa_transfer_conc_inc3_SSER',`hhaa_transfer_conc_inc3_SSEE',`hhaa_tax_conc_inc1',`hhaa_tax_conc_inc2',`hhaa_tax_conc_inc3',`hhaa_tax_conc_inc4',`hhaa_tax_conc_inc3_SSER',`hhaa_tax_conc_inc3_SSEE'"
     if "`ccyy'" == "at04"  di "Inequality Measures 7,countryyear,hhaa_inc1_mean,hhaa_inc2_mean,hhaa_inc3_mean,hhaa_inc4_mean,hhaa_inc3_SSER_mean,hhaa_inc3_SSEE_mean,hhaa_dhi_mean,hhaa_transfer_mean,hhaa_tax_mean,hhaa_allpension_mean,hhaa_pubpension_mean,hhaa_pripension_mean"
     di "Inequality Measures 7,`ccyy',`hhaa_inc1_mean',`hhaa_inc2_mean',`hhaa_inc3_mean',`hhaa_inc4_mean',`hhaa_inc3_SSER_mean',`hhaa_inc3_SSEE_mean',`hhaa_dhi_mean',`hhaa_transfer_mean',`hhaa_tax_mean',`hhaa_allpension_mean',`hhaa_pubpension_mean',`hhaa_pripension_mean'"
 }
program drop _all
clear all
