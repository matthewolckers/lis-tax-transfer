global datasets "at04 au03 au08 au10 ca04 ca07 ca10 ch00 ch02 ch04 cz02 cz04 cz07 cz10 de00 de04 de07 de10 dk00 dk04 dk07 dk10 ee10 es07 es10 es13 fi00 fi04 fi07 fi10 gr07 gr10 ie04 ie07 ie10 il10 il12 is04 is07 is10 jp08 kr06 lu04 lu07 lu10 nl04 nl07 nl10 nl99 no00 no04 no07 no10 pl04 pl07 pl10 pl13 pl99 se00 se05 sk04 sk07 sk10 uk99 uk04 uk07 uk10 us00 us04 us07 us10 us13" 
 
// New gross datasets to add as of 2 October 2016: Germany 2013 de13; Norway 2013 no13; Finland 2013 fi13; Luxembourg 2013 lu13; United Kingdom 2013 uk13 
 
global pvars "pid hid dname pil age"  
 
global hvars "hid dname nhhmem dhi nhhmem65 hwgt" 
  
global hvarsflow "hil hic pension hits hitsil hitsup hitsap hxit hxiti hxits hc hicvip dhi hitsilmip hitsilo hitsilep hitsilwi hitsilepo hitsilepd hitsileps" // Local currency, given in the datasets 
 
global hvarsnew "hsscer hsscee" // Local currency, imputed 
 
global hvarsinc "inc1 inc2 inc3 inc4 inc5 tax transfer allpension pubpension pripension hxct hssc" // Summation / imputed after PPP conversion  
 
global fixpensions_datasets1 "at04 ee10 lu04 nl04 no04 no10 se00 se05"  // hitsil missing, hicvip defined 
 
global fixpension_datasets2 "au08 au10 ca04 ca07 ca10 is04 is07 is10 jp08 no00 no07" // hitsil missing, hicvip missing 
 
global fixpension_datasets3 "ie04 ie07 ie10 uk99 uk04 uk07 uk10" 
 
 
************************************************************* 
* Program 1: Generate SSC variables from person level dataset 
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
  
 *Netherlands 2004 NL04 
 // I will tackle the Netherlands adjustments at a later stage.  
 *Netherlands 2007 NL07 
 *Netherlands 2010 NL10 
 
  
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
  
 *France 2000 fr00 
 // Doesn't seem there is a rebate, but I need to look at this in more detail when I have time.  
  
 *France 2005 fr05 
 replace psscer=psscer-((0.26/0.6)*((24692.8/pil)-1)*pil) if pil>15433 & pil<24692.8 & dname=="fr05" // I am not sure I have this adjustment correct.  
  
 *France 2010 fr10 
 replace psscer=psscer-((0.26/0.6)*((25800.32/pil)-1)*pil) if pil>16125 & pil<25800.32 & dname=="fr10" 
  
 *Germany 2004 de04 
  
 *Germany 2007 de07 
  
 *Germany 2010 de10 
 
 *Greece 2000 gr00 
  
 *Greece 2004 gr04 
  
 *Greece 2007 gr07 
  
 *Greece 2010 gr10 
  
 *Hungary 2007 hu07 
 
 *Hungary 2009 hu09 
 
 *Hungary 2012 hu12 
  
 *Ireland 2000 ie00 
 replace psscer=pil*.085 if  pil<14560 & dname=="ie00" // I could have easily included these changes for Ireland in the rates and ceilings.                     
 
 *Ireland 2004 ie04 
 replace psscer=pil*.085 if  pil<18512 & dname=="ie04" 
  
 *Ireland 2007 ie07 
 replace psscer=pil*.085 if  pil<18512 & dname=="ie07" 
  
 *Ireland 2010 ie10 
 replace psscer=pil*.085 if  pil<18512 & dname=="ie10" 
 
 *Netherlands 1999 nl99 
 
 *Netherlands 2004 nl04 
 
 *Netherlands 2007 nl07 
 
 *Netherlands 2010 nl10 
 
 *Norway 2004 no04 
 
 *Norway 2007 no07 
  
 *Norway 2010 no10 
  
 
* Convert variables to household level   
 bysort hid: egen hsscee=total(psscee)  
  
 bysort hid: egen hsscer=total(psscer) 
 
 keep hid hsscee hsscer 
 drop if hid==. 
 duplicates drop hid, force 
 
end 
 
**************************************************** 
* Program 2: Generate a variable for consumption tax  
****************************************************  
 
program define gen_hxct 
 
merge m:1 dname using "$mydata\molcke\consumption_20161114b.dta", keep(master match) nogenerate 
 
sum dhi , detail 
gen dhi_norm = dhi/r(p50) 
gen log_dhi_norm =log(dhi_norm) 
gen apc_log = log(apc_oecd) 
gen apc = exp(apc_log+(log_dhi_norm*dpc_ccyy)) 
replace apc = exp(apc_log+(log_dhi_norm*dpc_richsmean)) if dpc_ccyy==. 
gen hc_imputed = dhi*apc // Think about bottom-coding with a minimum subsistence level of consumption. 
gen hxct = (itrc_2/100)*hc_imputed 
 
end 
 
************************************************** 
* Program 3: Define the different stages of income  
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
gen inc_decile = inc2/(nhhmem^0.5) 
xtile decile = inc_decile [w=hwgt], nquantiles(10) 
 
end 
 
*************************************************************************** 
* Program 3b: Adjustments to pensions for certain countries 
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
gen inc_decile = inc2/(nhhmem^0.5) 
xtile decile = inc_decile [w=hwgt], nquantiles(10) 
 
end 
 
*************************************************************************** 
* Program 3c: Adjustments to pensions for UK and Ireland 
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
gen inc_decile = inc2/(nhhmem^0.5) 
xtile decile = inc_decile [w=hwgt], nquantiles(10) 
 
end 
 
*************************************************************************** 
* Program 4: Apply PPP conversions and equivalence scales to flow variables  
*************************************************************************** 
 
program define ppp_equiv  
    
* Define PPP conversions to 2011 international dollars (ppp)  
gen ppp =.  
replace ppp= 2.250787458 if dname== "au81" 
replace ppp= 1.657498516 if dname== "au85" 
replace ppp= 1.214320511 if dname== "au89" 
replace ppp= 1.000376517 if dname== "au95" 
replace ppp= 0.8714341231 if dname== "au01" 
replace ppp= 0.8232173276 if dname== "au03" 
replace ppp= 0.7085937106 if dname== "au08" 
replace ppp= 0.6766741503 if dname== "au10" 
replace ppp= 0.14490316 if dname== "at87" 
replace ppp= 0.1170305091 if dname== "at94" 
replace ppp= 0.1144551542 if dname== "at95" 
replace ppp= 0.1109319572 if dname== "at97" 
replace ppp= 0.1067477525 if dname== "at00" 
replace ppp= 1.358644375 if dname== "at04" 
replace ppp= 0.04813423594 if dname== "be85" 
replace ppp= 0.04625377671 if dname== "be88" 
replace ppp= 0.0410185911 if dname== "be92" 
replace ppp= 0.03842840404 if dname== "be95" 
replace ppp= 0.03705017934 if dname== "be97" 
replace ppp= 0.03539334721 if dname== "be00" 
replace ppp= 0.7755689883 if dname== "br06" 
replace ppp= 0.6752474127 if dname== "br09" 
replace ppp= 0.6028517409 if dname== "br11" 
replace ppp= 0.5385543375 if dname== "br13" 
replace ppp= 4.463233867 if dname== "ca71" 
replace ppp= 3.222163783 if dname== "ca75" 
replace ppp= 1.88414854 if dname== "ca81" 
replace ppp= 1.362770698 if dname== "ca87" 
replace ppp= 1.127676776 if dname== "ca91" 
replace ppp= 1.088843446 if dname== "ca94" 
replace ppp= 1.0325176 if dname== "ca97" 
replace ppp= 1.022335724 if dname== "ca98" 
replace ppp= 0.9782980211 if dname== "ca00" 
replace ppp= 0.8915216858 if dname== "ca04" 
replace ppp= 0.8371931248 if dname== "ca07" 
replace ppp= 0.8011320014 if dname== "ca10" 
replace ppp= 0.3522349135 if dname== "cn02" 
replace ppp= 0.001139242431 if dname== "co04" 
replace ppp= 0.0009852043152 if dname== "co07" 
replace ppp= 0.0008639560224 if dname== "co10" 
replace ppp= 0.1807154054 if dname== "cz92" 
replace ppp= 0.1145258967 if dname== "cz96" 
replace ppp= 0.08432020006 if dname== "cz02" 
replace ppp= 0.08191355909 if dname== "cz04" 
replace ppp= 0.0762143895 if dname== "cz07" 
replace ppp= 0.06993686191 if dname== "cz10" 
replace ppp= 0.2063846037 if dname== "dk87" 
replace ppp= 0.1755854829 if dname== "dk92" 
replace ppp= 0.1665306262 if dname== "dk95" 
replace ppp= 0.1485453185 if dname== "dk00" 
replace ppp= 0.1372031883 if dname== "dk04" 
replace ppp= 0.1300367539 if dname== "dk07" 
replace ppp= 0.1213275131 if dname== "dk10" 
replace ppp= 0.5177810806 if dname== "eg12" 
replace ppp= 0.1651599828 if dname== "ee00" 
replace ppp= 0.1444078605 if dname== "ee04" 
replace ppp= 0.124626561 if dname== "ee07" 
replace ppp= 0.1097516247 if dname== "ee10" 
replace ppp= 0.2947351428 if dname== "fi87" 
replace ppp= 0.2380702693 if dname== "fi91" 
replace ppp= 0.2226233356 if dname== "fi95" 
replace ppp= 0.206213542 if dname== "fi00" 
replace ppp= 1.164608938 if dname== "fi04" 
replace ppp= 1.109012238 if dname== "fi07" 
replace ppp= 1.052931327 if dname== "fi10" 
replace ppp= 0.5725400614 if dname== "fr78" 
replace ppp= 0.304695372 if dname== "fr84" 
replace ppp= 0.2557435629 if dname== "fr89" 
replace ppp= 0.2255574143 if dname== "fr94" 
replace ppp= 0.2086897662 if dname== "fr00" 
replace ppp= 1.245649815 if dname== "fr05" 
replace ppp= 1.155320259 if dname== "fr10" 
replace ppp= 1.289155913 if dname== "ge10" 
replace ppp= 1.205193557 if dname== "ge13" 
replace ppp= 1.679796131 if dname== "de73" 
replace ppp= 1.333955751 if dname== "de78" 
replace ppp= 1.144077365 if dname== "de81" 
replace ppp= 1.05300653 if dname== "de83" 
replace ppp= 1.027448119 if dname== "de84" 
replace ppp= 0.9664580481 if dname== "de89" 
replace ppp= 0.8023722223 if dname== "de94" 
replace ppp= 0.740923883 if dname== "de00" 
replace ppp= 1.363964565 if dname== "de04" 
replace ppp= 1.29261909 if dname== "de07" 
replace ppp= 1.241879562 if dname== "de10" 
replace ppp= 0.00695328101 if dname== "gr95" 
replace ppp= 0.0054891306 if dname== "gr00" 
replace ppp= 1.638950976 if dname== "gr04" 
replace ppp= 1.490663481 if dname== "gr07" 
replace ppp= 1.350468347 if dname== "gr10" 
replace ppp= 0.3450888173 if dname== "gt06" 
replace ppp= 0.05987052247 if dname== "hu91" 
replace ppp= 0.03345519905 if dname== "hu94" 
replace ppp= 0.01421315174 if dname== "hu99" 
replace ppp= 0.009738013011 if dname== "hu05" 
replace ppp= 0.008685266191 if dname== "hu07" 
replace ppp= 0.007857787494 if dname== "hu09" 
replace ppp= 0.006817862507 if dname== "hu12" 
replace ppp= 0.01157192441 if dname== "is04" 
replace ppp= 0.009927815178 if dname== "is07" 
replace ppp= 0.007463783685 if dname== "is10" 
replace ppp= 0.1151164155 if dname== "in04" 
replace ppp= 2.445000667 if dname== "ie87" 
replace ppp= 2.015194141 if dname== "ie94" 
replace ppp= 1.965765676 if dname== "ie95" 
replace ppp= 1.933037881 if dname== "ie96" 
replace ppp= 1.733979901 if dname== "ie00" 
replace ppp= 1.176620797 if dname== "ie04" 
replace ppp= 1.053737298 if dname== "ie07" 
replace ppp= 1.070310407 if dname== "ie10" 
replace ppp= 1.125645834 if dname== "il79" 
replace ppp= 1.461807206 if dname== "il86" 
replace ppp= 0.5590149856 if dname== "il92" 
replace ppp= 0.3360308434 if dname== "il97" 
replace ppp= 0.2962955258 if dname== "il01" 
replace ppp= 0.275981895 if dname== "il05" 
replace ppp= 0.2688962816 if dname== "il07" 
replace ppp= 0.2422799774 if dname== "il10" 
replace ppp= 0.2302475253 if dname== "il12" 
replace ppp= 0.001422519145 if dname== "it86" 
replace ppp= 0.001358243607 if dname== "it87" 
replace ppp= 0.001216488683 if dname== "it89" 
replace ppp= 0.001074584076 if dname== "it91" 
replace ppp= 0.0009788199427 if dname== "it93" 
replace ppp= 0.0008940382519 if dname== "it95" 
replace ppp= 0.0008264244232 if dname== "it98" 
replace ppp= 0.0007929868785 if dname== "it00" 
replace ppp= 1.389136335 if dname== "it04" 
replace ppp= 1.267641673 if dname== "it08" 
replace ppp= 1.239122112 if dname== "it10" 
replace ppp= 0.008411969433 if dname== "jp08" 
replace ppp= 0.04464308194 if dname== "lu85" 
replace ppp= 0.03971976459 if dname== "lu91" 
replace ppp= 0.03637318791 if dname== "lu94" 
replace ppp= 0.03472429474 if dname== "lu97" 
replace ppp= 0.03301337469 if dname== "lu00" 
replace ppp= 1.218159424 if dname== "lu04" 
replace ppp= 1.131530459 if dname== "lu07" 
replace ppp= 1.066052894 if dname== "lu10" 
replace ppp= 0.02181507729 if dname== "mx84" 
replace ppp= 0.001246286157 if dname== "mx89" 
replace ppp= 0.0006945141236 if dname== "mx92" 
replace ppp= 0.5915965622 if dname== "mx94" 
replace ppp= 0.3261122682 if dname== "mx96" 
replace ppp= 0.2332040787 if dname== "mx98" 
replace ppp= 0.1826824582 if dname== "mx00" 
replace ppp= 0.1635273648 if dname== "mx02" 
replace ppp= 0.1494087594 if dname== "mx04" 
replace ppp= 0.1268552701 if dname== "mx08" 
replace ppp= 0.115665467 if dname== "mx10" 
replace ppp= 0.1074368937 if dname== "mx12" 
replace ppp= 0.9063676611 if dname== "nl83" 
replace ppp= 0.8626213246 if dname== "nl87" 
replace ppp= 0.8268434447 if dname== "nl90" 
replace ppp= 0.7574138425 if dname== "nl93" 
replace ppp= 0.6653961087 if dname== "nl99" 
replace ppp= 1.288573303 if dname== "nl04" 
replace ppp= 1.232829108 if dname== "nl07" 
replace ppp= 1.173800248 if dname== "nl10" 
replace ppp= 0.3671377375 if dname== "no79" 
replace ppp= 0.200455968 if dname== "no86" 
replace ppp= 0.1534858902 if dname== "no91" 
replace ppp= 0.14115251 if dname== "no95" 
replace ppp= 0.1259756814 if dname== "no00" 
replace ppp= 0.1172685387 if dname== "no04" 
replace ppp= 0.1120609982 if dname== "no07" 
replace ppp= 0.1032266748 if dname== "no10" 
replace ppp= 2.20524755 if dname== "pa07" 
replace ppp= 1.913159868 if dname== "pa10" 
replace ppp= 1.643388395 if dname== "pa13" 
replace ppp= 0.7685871207 if dname== "pe04" 
replace ppp= 0.7285469465 if dname== "pe07" 
replace ppp= 0.6589832689 if dname== "pe10" 
replace ppp= 0.5981763267 if dname== "pe13" 
replace ppp= 0.03505363175 if dname== "pl86" 
replace ppp= 0.0003013505436 if dname== "pl92" 
replace ppp= 1.290178219 if dname== "pl95" 
replace ppp= 0.7806835412 if dname== "pl99" 
replace ppp= 0.6320988255 if dname== "pl04" 
replace ppp= 0.5979496178 if dname== "pl07" 
replace ppp= 0.5373617381 if dname== "pl10" 
replace ppp= 0.4926158027 if dname== "pl13" 
replace ppp= 0.002099556236 if dname== "ro95" 
replace ppp= 0.0005936209234 if dname== "ro97" 
replace ppp= 0.2102128276 if dname== "ru00" 
replace ppp= 0.118602379 if dname== "ru04" 
replace ppp= 0.08803509688 if dname== "ru07" 
replace ppp= 0.06466346644 if dname== "ru10" 
replace ppp= 0.05316201628 if dname== "ru13" 
replace ppp= 0.03364177568 if dname== "rs06" 
replace ppp= 0.02451201731 if dname== "rs10" 
replace ppp= 0.01908110711 if dname== "rs13" 
replace ppp= 0.2109946996 if dname== "sk92" 
replace ppp= 0.1301112252 if dname== "sk96" 
replace ppp= 0.07165367541 if dname== "sk04" 
replace ppp= 0.06497889963 if dname== "sk07" 
replace ppp= 1.824294354 if dname== "sk10" 
replace ppp= 0.01161198176 if dname== "si97" 
replace ppp= 0.01013709276 if dname== "si99" 
replace ppp= 0.007305881776 if dname== "si04" 
replace ppp= 1.609280893 if dname== "si07" 
replace ppp= 1.482964863 if dname== "si10" 
replace ppp= 0.2314262384 if dname== "za08" 
replace ppp= 0.2071924897 if dname== "za10" 
replace ppp= 0.1867751316 if dname== "za12" 
replace ppp= 0.001294792924 if dname== "kr06" 
replace ppp= 0.03734913008 if dname== "es80" 
replace ppp= 0.02097988441 if dname== "es85" 
replace ppp= 0.01533481332 if dname== "es90" 
replace ppp= 0.01192256168 if dname== "es95" 
replace ppp= 0.01047705186 if dname== "es00" 
replace ppp= 1.537850473 if dname== "es04" 
replace ppp= 1.398225419 if dname== "es07" 
replace ppp= 1.323529322 if dname== "es10" 
replace ppp= 0.9220648842 if dname== "se67" 
replace ppp= 0.5614226681 if dname== "se75" 
replace ppp= 0.3039805567 if dname== "se81" 
replace ppp= 0.2040338487 if dname== "se87" 
replace ppp= 0.1466646498 if dname== "se92" 
replace ppp= 0.1337514449 if dname== "se95" 
replace ppp= 0.1306646397 if dname== "se00" 
replace ppp= 0.121532238 if dname== "se05" 
replace ppp= 1.034403432 if dname== "ch82" 
replace ppp= 0.756885644 if dname== "ch92" 
replace ppp= 0.6878606908 if dname== "ch00" 
replace ppp= 0.6767746078 if dname== "ch02" 
replace ppp= 0.6671254541 if dname== "ch04" 
replace ppp= 0.06698969591 if dname== "tw10" 
replace ppp= 15.07812957 if dname== "uk69" 
replace ppp= 9.528540217 if dname== "uk74" 
replace ppp= 4.619898287 if dname== "uk79" 
replace ppp= 2.679901936 if dname== "uk86" 
replace ppp= 2.043881176 if dname== "uk91" 
replace ppp= 1.875303174 if dname== "uk94" 
replace ppp= 1.826775751 if dname== "uk95" 
replace ppp= 1.701297247 if dname== "uk99" 
replace ppp= 1.603050876 if dname== "uk04" 
replace ppp= 1.500212687 if dname== "uk07" 
replace ppp= 1.372109791 if dname== "uk10" 
replace ppp= 4.560467436 if dname== "us74" 
replace ppp= 3.098629026 if dname== "us79" 
replace ppp= 2.052364659 if dname== "us86" 
replace ppp= 1.651636786 if dname== "us91" 
replace ppp= 1.517552145 if dname== "us94" 
replace ppp= 1.401344616 if dname== "us97" 
replace ppp= 1.306266938 if dname== "us00" 
replace ppp= 1.190889438 if dname== "us04" 
replace ppp= 1.084868066 if dname== "us07" 
replace ppp= 1.031568416 if dname== "us10" 
replace ppp= 0.965582001 if dname== "us13" 
replace ppp= 0.09768052363 if dname== "uy04" 
replace ppp= 0.08110438719 if dname== "uy07" 
replace ppp= 0.06581512446 if dname== "uy10" 
replace ppp= 0.05187736702 if dname== "uy13" 
replace ppp= 0.06240857291 if dname== "do07" 
replace ppp= 0.0007936747416 if dname== "co13" 
replace ppp= 0.0642902863 if dname== "tw13" 
replace ppp= 1.23452568 if dname== "es13" 
 
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
 
********************************************************** 
* Output: Loop over datasets and output summary statistics 
********************************************************** 
 
 foreach ccyy in $datasets {  
   use $pvars using $`ccyy'p,clear  
   quietly gen_pvars 
   quietly merge 1:1 hid using $`ccyy'h, keepusing($hvars $hvarsflow) nogenerate 
   quietly ppp_equiv 
   quietly gen_hxct 
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
