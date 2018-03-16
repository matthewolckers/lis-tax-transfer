clear
cd  "/home/m.olckers/U/LIS Four Levers/"

use "LIS Reducing Inequality - 19 - Country.dta", clear

* Set scheme and save figures in a folder with the scheme name
set scheme plotplain, perm

*****************************************
* Labels
*****************************************

tostring year , gen(year_str)
gen countryyear_full = country + " " + year_str
drop year_str
gen countryyear_upper = upper(countryyear)


****************************************
/*definition des variables*/
****************************************

*indices de niveau sur donnÃ©es LIS  exprimÃ©s en "share" (% au concept de revenu prÃ©cÃ©dent) et en niveau (% du revenu disponible inc_4)

gen transshare=transfer_mean/inc2_mean
gen transLvL=transfer_mean/inc4_mean
gen taxshare=tax_mean/inc3_mean
gen taxLvL=tax_mean/inc4_mean
gen pubpensionshare=pubpension_mean/inc1_mean
gen pubpensionLvL=pubpension_mean/inc4_mean
gen totalbenefit_mean=transfer_mean+pubpension_mean
gen totalbenefitshare=transfer_mean+pubpension_mean/inc2_mean
gen totalbenefitLvL=transLvL+pubpensionLvL
gen pubpensionrate= pubpension_mean/inc1_mean







gen SSCshare=hssc_mean/inc3_mean
gen SSCLvL=hssc_mean/inc4_mean
gen SSCershare=hsscer_mean/inc3_mean
gen SSCerLvL=hsscer_mean/inc4_mean
gen SSCeeshare=hxits_mean/inc3_mean
gen SSCeeLvL=hxits_mean/inc4_mean





/*variable Kakwani pour les cotisations sociales*/

gen SSC_kakwani=hsscconc_inc3-inc3_gini
replace SSC_kakwani=0 if SSCshare==0
gen SSCer_kakwani=hsscerconc_inc3-inc3_gini
replace SSCer_kakwani=0 if SSCershare==0
gen SSCee_kakwani=hxitsconc_inc3-inc3_gini
gen kakwani_pension= pubpension_conc_inc2-inc2_gini


/*Reduction gini (indice de Reynold-Smolensky)*/
gen r2to4=inc2_gini-inc4_gini
gen r3to4=inc3_gini-inc4_gini
gen r2to3=inc2_gini-inc3_gini

/*calcul du reranking*/

gen Rerank2=inc2_conc_inc2-inc2_conc_inc1
gen Rerank3=inc3_conc_inc3-inc3_conc_inc2
gen Rerank4=inc4_conc_inc4-inc4_conc_inc3
gen Rerank24=inc4_conc_inc4-inc4_conc_inc2

/*Calcul de la redistribution verticale (directement Ã  partir du Reynold Smolenski, et indirectement Ã  partir du Kakwani*/

gen Ve23=r2to3+Rerank3
gen Ve34=r3to4+Rerank4
gen Ve45=r4to5+Rerank5

gen VeSSC=(SSCshare/(1-SSCshare))*SSC_kakwani
gen VeSSCer=(SSCershare/(1-SSCershare))*SSCer_kakwani
gen VeSSCee=(SSCeeshare/(1-SSCeeshare))*SSCee_kakwani

gen Vepension= -pubpensionrate/(1+pubpensionrate)*kakwani_pension

gen Ve23verif=-transshare/(1+transshare)*transfer_kakwani
gen Ve34verif=taxshare/(1-taxshare)*tax_kakwani
gen Ve45verif=constaxshare/(1-constaxshare)*constax_kakwani






save "Sans_imputations.dta", replace

foreach nomvar of varlist inc1_gini-Ve45verif{
quietly rename `nomvar' NI_`nomvar'
}

sort countryyear

save "Sans_imputations.dta", replace

use "LIS et OECD.dta", clear
drop _merge
sort countryyear
save "Avec_imputations.dta", replace

merge 1:1 country year using "Sans_imputations.dta"

save "Avec_et_Sans_imputations.dta", replace




****************************************
/*definition des variables*/
****************************************

*indices de niveau sur donnÃ©es LIS  exprimÃ©s en "share" (% au concept de revenu prÃ©cÃ©dent) et en niveau (% du revenu disponible inc_4)

gen transshare=transfer_mean/inc2_mean
gen transLvL=transfer_mean/inc4_mean
gen taxshare=tax_mean/inc3_mean
gen taxLvL=tax_mean/inc4_mean
gen pubpensionshare=pubpension_mean/inc1_mean
gen pubpensionLvL=pubpension_mean/inc4_mean
gen totalbenefit_mean=transfer_mean+pubpension_mean
gen totalbenefitshare=transfer_mean+pubpension_mean/inc2_mean
gen totalbenefitLvL=transLvL+pubpensionLvL
gen pubpensionrate= pubpension_mean/inc1_mean







gen SSCshare=hssc_mean/inc3_mean
gen SSCLvL=hssc_mean/inc4_mean
gen SSCershare=hsscer_mean/inc3_mean
gen SSCerLvL=hsscer_mean/inc4_mean
gen SSCeeshare=hxits_mean/inc3_mean
gen SSCeeLvL=hxits_mean/inc4_mean





/*variable Kakwani pour les cotisations sociales*/

gen SSC_kakwani=hsscconc_inc3-inc3_gini
replace SSC_kakwani=0 if SSCshare==0
gen SSCer_kakwani=hsscerconc_inc3-inc3_gini
replace SSCer_kakwani=0 if SSCershare==0
gen SSCee_kakwani=hxitsconc_inc3-inc3_gini
gen kakwani_pension= pubpension_conc_inc2-inc2_gini


/*Reduction gini (indice de Reynold-Smolensky)*/
gen r2to4=inc2_gini-inc4_gini
gen r3to4=inc3_gini-inc4_gini
gen r2to3=inc2_gini-inc3_gini

/*calcul du reranking*/

gen Rerank2=inc2_conc_inc2-inc2_conc_inc1
gen Rerank3=inc3_conc_inc3-inc3_conc_inc2
gen Rerank4=inc4_conc_inc4-inc4_conc_inc3
gen Rerank24=inc4_conc_inc4-inc4_conc_inc2


/*Calcul de la redistribution verticale (directement Ã  partir du Reynold Smolenski, et indirectement Ã  partir du Kakwani*/

gen Ve23=r2to3+Rerank3
gen Ve34=r3to4+Rerank4
gen Ve45=r4to5+Rerank5

gen VeSSC=(SSCshare/(1-SSCshare))*SSC_kakwani
gen VeSSCer=(SSCershare/(1-SSCershare))*SSCer_kakwani
gen VeSSCee=(SSCeeshare/(1-SSCeeshare))*SSCee_kakwani

gen Vepension= -pubpensionrate/(1+pubpensionrate)*kakwani_pension

gen Ve23verif=-transshare/(1+transshare)*transfer_kakwani
gen Ve34verif=taxshare/(1-taxshare)*tax_kakwani
gen Ve45verif=constaxshare/(1-constaxshare)*constax_kakwani

/*autres variables d'indicateurs issues de l'OCDE*/
gen bismindx=ssc/totalexp
gen kindshare=totalkind/totalexp
gen taxOECD=ssc+tax1100
gen sharetax=(ssc+tax1100)/totaltax
gen sharetax2=sharetax+tax5100/totaltax
gen LisorigOECD=sscee+tax1100
gen Lisorig=(sscee+tax1100)/totaltax

label var Lisorig "PÃ©rimÃ¨tre LIS: IR + cotis. employÃ©s"
label var sharetax "IR + cotis. employÃ©s et employeur"
label var sharetax2 "IR + cotis. employÃ©s et employeur+ TVA & taxes sur la conso"
label var taxshare "Niveau des taxes/Revenu brut"
label var transshare "Niveau des transferts/Market income"
label var r3to4 "Gini Revenu disponible-Gini Revenu Brut"
label var r2to3 "Gini Revenu Brut-Gini Market income"


save "Avec_et_Sans_imputations.dta", replace

*************************************
*Comparaison des deux fichiers*******
*************************************


drop if inc2_gini==.
drop if datatype=="Net"
drop if countryyear=="kr06"|countryyear=="jp08" |countryyear=="is04"|country=="Poland"|country=="Switzerland"/*Japon: problÃ¨me sur les taxes qui apparaÃ®t lorsqu'on compare Ve34 et Ve34 verif; iceland 04 aberrant sur SSC; pologne aussi*/

gen zone=1 if year==2003| year==2004|year==2005|countryyear=="il10"|countryyear=="ee10"|countryyear=="is07"|countryyear=="gr07"|countryyear=="es07"
sort r2to5
encode country if zone==1 & constax_kakwani!=., gen(ccode)

gen ccodeshort=substr(countryyear, 1, 2)

label var r2to4 "Avec donnÃ©es imputÃ©es"
label var NI_r2to4 "DonnÃ©es LIS originales"


*************************************
* Figure A3
*************************************
gen position_figA3 = 9
replace position_figA3 = 10 if country=="Austria"
replace position_figA3 = 12 if country=="Germany"
replace position_figA3 = 6 if country=="Denmark"
replace position_figA3 = 6 if country=="Italy"
replace position_figA3 = 10 if country=="Greece"
replace position_figA3 = 10 if country=="United States"
replace position_figA3 = 10 if country=="Estonia"


twoway ///
(scatter NI_tax_kakwani NI_taxshare, msymbol(Oh) mcolor(gs10) ) ///
(scatter tax_kakwani taxshare, msymbol(X) mcolor(gs10) ) ///
(pcspike tax_kakwani taxshare NI_tax_kakwani NI_taxshare , lpattern(dash) lcolor(gs12) ) ///
(scatter NI_tax_kakwani NI_taxshare, mlabel(country) msymbol(none) mlabvpos(position_figA3) ) ///
if zone==1 ///
, ytitle("Tax progressivity") xtitle("Tax rate") ///
legend(order(1 "Before imputation" 2 "After imputation") ring(0) position(2) bmargin(large))

drop position_figA3

cd "/home/m.olckers/U/LIS Four Levers/figures/plotplain/"
graph export "figureA3.pdf", replace


*************************************
* Figure A3
*************************************

gen position_figA4 = 9
replace position_figA4 = 12 if country=="United Kingdom"
replace position_figA4 = 12 if country=="Iceland"
replace position_figA4 = 7 if country=="Netherlands"
replace position_figA4 = 12 if country=="Finland"
replace position_figA4 = 6 if country=="Estonia"
replace position_figA4 = 11 if country=="Israel"
replace position_figA4 = 11 if country=="Luxembourg"
replace position_figA4 = 3 if country=="Czech Republic"
replace position_figA4 = 3 if country=="Slovak Republic"
replace position_figA4 = 10 if country=="Australia"


gen label_dummy_A4 = 0
replace label_dummy_A4 = 1 if country=="Czech Republic"
replace label_dummy_A4 = 1 if country=="Slovak Republic"

twoway ///
(function y=x, range(0 .1) lcolor(gs12) lpattern(solid)) ///
(scatter NI_r2to3 NI_r3to4 , msymbol(Oh) mcolor(gs10) ) ///
(scatter r2to3 r3to4 , msymbol(X) mcolor(gs10) ) ///
(pcspike r2to3 r3to4 NI_r2to3 NI_r3to4  , lpattern(dash) lcolor(gs12) ) ///
(scatter NI_r2to3 NI_r3to4 if label_dummy_A4 == 0, mlabel(country) msymbol(none) mlabvpos(position_figA4) ) ///
(scatter r2to3 r3to4 if label_dummy_A4 == 1, mlabel(country) msymbol(none) mlabvpos(position_figA4) ) ///
if zone==1 ///
, ytitle(Transfer inequality reduction) xtitle(Tax inequality reduction)  ///
legend(order(2 "Before imputation" 3 "After imputation") ring(0) position(3) bmargin(large)) ///
xscale(range(0 .105))

drop position_figA4 label_dummy_A4

cd "/home/m.olckers/U/LIS Four Levers/figures/plotplain/"
graph export "figureA4.pdf", replace
