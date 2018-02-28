**********
* Version: 17B (France) * 14 November 2016
**********

**********  
* Globals  
**********  

global datasets "fr00 fr05 fr10"

global pvars "pid hid dname pil pxit pxiti pxits age emp" 

global hvars "hid dname dhi nhhmem nhhmem17 nhhmem65 hwgt"
 
global hvarsflow "hil hic pension hits hitsil hitsup hitsap hxit hxiti hxits hc hicvip dhi hitsilmip hitsilo hitsilep hitsilwi hitsilepo hitsilepd hitsileps" // Local currency, given in the datasets

global hvarsnew "hsscer hsscee" // Local currency, imputed

global hvarsinc "inc1 inc2 inc3 inc4 inc5 tax transfer allpension pubpension pripension hxct hssc" // Summation after PPP conversion 


**********************************************************************
* Program 1 (France): Generate SSC variables from person level dataset
**********************************************************************

program define FR_gen_pvars

merge m:1 dname using "$mydata\molcke\molcke_ssc_20160711.dta", keep(match) nogenerate

* Impute individual level income tax from household level income tax
bysort hid: egen hemp = total(emp) , missing									// missing option to set a total of all missing values to missing rather than zero.
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

	
* Generate Employer Social Security Contributions 
gen psscer=.
replace psscer = pil*er_r1 
replace psscer = (pil-er_c1)*er_r2 + er_r1*er_c1  if pil>er_c1 & er_c1!=.
replace psscer = (pil-er_c2)*er_r3 + er_r2*(er_c2 - er_c1) + er_r1*er_c1 if pil>er_c2 & er_c2!=.
replace psscer = (pil-er_c3)*er_r4 + er_r3*(er_c3 - er_c2) + er_r2*(er_c2 - er_c1) + er_r1*er_c1 if pil>er_c3 & er_c3!=.
replace psscer = (pil-er_c4)*er_r5 + er_r4*(er_c4 - er_c3) + er_r3*(er_c3 - er_c2) + er_r2*(er_c2 - er_c1) + er_r1*er_c1 if pil>er_c4 & er_c4!=.
replace psscer = (pil-er_c5)*er_r6 + er_r5*(er_c5 - er_c4) + er_r4*(er_c4 - er_c3) + er_r3*(er_c3 - er_c2) + er_r2*(er_c2 - er_c1) + er_r1*er_c1  if pil>er_c5 & er_c5!=.

	* Manual corrections for certain datasets (Employer Social Security Contributions)

	*France 2000 fr00 (measured in Francs, not Euros)
	replace psscer=psscer-(0.182*pil) if pil<=83898 & dname=="fr00"
	replace psscer=psscer-(0.55*(111584.34-pil)) if pil>83898 & pil<=111584.34 & dname=="fr00"
	
	*France 2005 fr05
	replace psscer=psscer-((0.26/0.6)*((24692.8/pil)-1)*pil) if pil>15433 & pil<24692.8 & dname=="fr05" //I am not sure I have this adjustment correct. 
	
	*France 2010 fr10
	replace psscer=psscer-((0.26/0.6)*((25800.32/pil)-1)*pil) if pil>16125 & pil<25800.32 & dname=="fr10"
	

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
gen hc_imputed = dhi*apc														// Think about bottom-coding with a minimum subsistence level of consumption.
gen hxct = (itrc_2/100)*hc_imputed

end

**************************************************
* Program 3: Define the different stages of income 
**************************************************

program define income_stages

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

* Use the imputed data if employee social security contributions is not available
replace hxits=hsscee if hxits==.
replace hxits=0 if hxits==.														
replace hxiti=0 if hxiti==.														
	/* I have set social security contributions and income tax to zero if it is 
	missing, and then changed the definition of tax below. I need to look at how
	hxit (the sum of hxiti and hxits) is constructed. For example, if hxiti is
	defined but hxits is missing, then what happens to hxit? */
																																					


* Impute the taxes CSG and CRDS

	* Labour income
	// CSG and CRDS on labour income is imputed wihin Employee SSC

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
		
		/* The correct formulation to impute pension_csg_crds is to inc2 instead
		of hil to define the ceilings. However, this creates a looping in the 
		calculation. I have used hil as a proxy for inc2, which will cause 
		pension_csg_crds to be underestimated. I can't think of a simple 
		alternative to this approach. */
	

* Define the components of the income stages

gen pubpension = hitsil + hitsup

gen pripension = hicvip

gen allpension = pension - hitsap												

gen transfer = hits - pubpension

gen tax = hxiti + hxits + hsscer + hic_csg_crds + pension_csg_crds

gen hssc = hxits + hsscer

gen marketincome = hil + (hic-hicvip) + hsscer + hic_csg_crds + hxits + pension_csg_crds		// For France, incomes are reported net of ssc, but gross of income tax

* Define the income stages

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
  
* Trim, and bottom code
	
	* Step 1
		drop if dhi<=0
	
	* Step 2
		replace hsscer=0 if hsscer<0 // Employer
		replace hsscee=0 if hsscee<0 // Employee
		
	* Step 3
		// completed within the income_stages program
  
end

*****************************************************
* Program 5: Correct dhi (disposable household income
*****************************************************

/* Notes: For France particularly, dhi is provided net of income taxes, even
though the income tax variable is available. Ths is because income taxes are
collected once per year, directly from households. The income tax variable in
LIS is the amount of the previous year's tax. So it is just a proxy of current
income tax. */

program define correct_dhi

gen hxiti_temp = hxiti
replace hxiti_temp = 0 if hxiti<0
replace hxiti_temp = 0 if hxit==.
replace dhi = dhi - hxiti_temp

end

**********************************************************
* Output: Loop over datasets and output summary statistics
**********************************************************

 foreach ccyy in $datasets { 
   quietly use $pvars using $`ccyy'p, clear
   quietly merge m:1 hid using "$`ccyy'h", keep(match) keepusing(hxiti) nogenerate
   
   quietly FR_gen_pvars if "`ccyy'" == "fr00" | "`ccyy'" == "fr05" | "`ccyy'" == "fr10"
 	
   quietly merge 1:1 hid using $`ccyy'h, keepusing($hvars $hvarsflow) nogenerate
   quietly correct_dhi
   quietly ppp_equiv
   quietly gen_hxct
   quietly income_stages	   

	
	foreach v in $hvarsinc $hvarsflow $hvarsnew {
	
			quietly sum `v' [w=hwgt] , detail
			
			foreach m in mean sd N min max p1 p10 p25 p50 p75 p90 p99 {
					local col_`m' = r(`m')	
			}
			
			quietly sum hid
			local col_N2 = r(N)
	
	if "`ccyy'" == "at04" 	di "countryyear,variable,mean,sd,observations,min,max,p1,p10,p25,p50,p75,p90,p99,totalobservations"
							di "`ccyy',`v',`col_mean',`col_sd',`col_N',`col_min',`col_max',`col_p1',`col_p10',`col_p25',`col_p50',`col_p75',`col_p90',`col_p99',`col_N2'"
	}
	}
 
program drop _all
clear all

