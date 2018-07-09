clear

*cd "C:\Users\zemmour\Documents\GitHub\lis-tax-transfer\"
cd "/Users/matthewolckers/repos/lis-tax-transfer"
use "LIS et OECD.dta", clear

* Set scheme and save figures in a folder with the scheme name
set scheme plotplain, perm
*cd "C:\Users\zemmour\Documents\GitHub\lis-tax-transfer\Stata\output\"
cd "/Users/matthewolckers/repos/lis-tax-transfer/Stata/output"

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

***hhaa version***
gen hhaa_taxshare=hhaa_tax_mean/hhaa_inc3_mean
gen hhaa_transshare=hhaa_transfer_mean/hhaa_inc2_mean


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

gen tax_kakwani = tax_conc_inc3 - inc3_gini
gen transfer_kakwani = transfer_conc_inc2 - inc2_gini

gen hhaa_tax_kakwani = hhaa_tax_conc_inc3 - hhaa_inc3_gini
gen hhaa_transfer_kakwani = hhaa_transfer_conc_inc2 - hhaa_inc2_gini

/*Reduction gini (indice de Reynold-Smolensky)*/
gen r2to4=inc2_gini-inc4_gini
gen r3to4=inc3_gini-inc4_gini
gen r2to3=inc2_gini-inc3_gini


/*Reduction gini (indice de Reynold-Smolensky) version hhaa*/
gen hhaa_r2to4=hhaa_inc2_gini-hhaa_inc4_gini
gen hhaa_r3to4=hhaa_inc3_gini-hhaa_inc4_gini
gen hhaa_r2to3=hhaa_inc2_gini-hhaa_inc3_gini

/*calcul du reranking*/

gen Rerank2=inc2_conc_inc2-inc2_conc_inc1
gen Rerank3=inc3_conc_inc3-inc3_conc_inc2
gen Rerank4=inc4_conc_inc4-inc4_conc_inc3

/*Calcul de la redistribution verticale (directement Ã  partir du Reynold Smolenski, et indirectement Ã  partir du Kakwani*/

gen Ve23=r2to3+Rerank3
gen Ve34=r3to4+Rerank4


gen VeSSC=(SSCshare/(1-SSCshare))*SSC_kakwani
gen VeSSCer=(SSCershare/(1-SSCershare))*SSCer_kakwani
gen VeSSCee=(SSCeeshare/(1-SSCeeshare))*SSCee_kakwani

gen Vepension= -pubpensionrate/(1+pubpensionrate)*kakwani_pension

gen Ve23verif=-transshare/(1+transshare)*transfer_kakwani
gen Ve34verif=taxshare/(1-taxshare)*tax_kakwani

/*autres variables d'indicateurs issues de l'OCDE*/

gen sscem2=sscem /*save OECD employer contrib in a sscem2 variable*/
replace sscem=sscem+payroll  /*add payroll to sscem OECD variable*/
replace ssc=ssc+payroll
gen bismindx=(ssc)/totalexp
gen kindshare=totalkind/totalexp
gen taxOECD=ssc+tax1100
gen sharetax=(taxOECD)/totaltax
gen sharetax2=sharetax+tax5100/totaltax
gen LisorigOECD=sscee+tax1100
gen Lisorig=(sscee+tax1100)/totaltax

gen sum=sscee+sscem

label var Lisorig "Perimetre LIS: IR + cotis. employees"
label var sharetax "IR + cotis. employÃ©s et employeur"
label var sharetax2 "IR + cotis. employÃ©s et employeur+ TVA & taxes sur la conso"
label var taxshare "Tax rate"
label var transshare "Transfer rate"
label var r3to4 "Gini [Gross Income]- Gini [Disp Income]"
label var r2to3 "Gini [Market income] - Gini [Gross Income]"


****************************************************************
*Nettoyage des donnÃ©es et crÃ©ation d'une zone (1 point par pays)
****************************************************************




drop if inc2_gini==.
*drop if datatype=="Net"
global net_datasets "at00 be00 gr00 hu05 hu07 hu09 hu12 hu99 ie00 it00 lu00 mx00 mx02 mx04 mx08 mx10 mx12 mx98 si10" 

foreach ccyy in $net_datasets {
drop if countryyear=="`ccyy'"
}

drop if ccode=="kr"|countryyear=="jp08" |country=="Poland"|country=="Switzerland"/*|country=="Switzerland"Japon: problÃ¨me sur les taxes qui apparaÃ®t lorsqu'on compare Ve34 et Ve34 verif; pologne aussi*/
**création d'une zone sur la dernière année disponible
gen zone=.


bys ccode: egen ymax=max(year)
replace ymax=0 if ymax>year
replace ymax=1 if ymax==year

replace zone=0
replace zone=1 if ymax==1
replace zone=0 if countryyear=="ie10"
replace zone=1 if countryyear=="ie07"

sort r2to4
*encode country if zone==1 & constax_kakwani!=., gen(ccode)

gen ccodeshort=substr(countryyear, 1, 2)


*******************************************
* Taux de couverture des données et rôle respectifs des cotisations employeur et salariés**********
*******************************************



**********Fig 2 ici on ne met que les cotisations pas les taxes sur la conso**************


twoway (histogram Lisorig, color(gs12) xscale(range(.1 .7)) xlabel(#8) yscale(range(0 6)) ) ///
       (histogram sharetax, fcolor(none) lcolor(black) xscale(range(.1 .7)) xlabel(#8) yscale(range(0 6)) ), ///
       legend(order(1 "Before imputation" 2 "After imputation") ring(0) position(10) bmargin(large)) ///
       xtitle(Percentage coverage of national tax revenue) ///
       ytitle(Number of country-years)

graph export "figure2.pdf", replace

************Figure 3 Part des cotisations employeur et employés******


graph bar (asis) sscee sscem if zone==1, ///
over(country, sort(sum) descending label(angle(forty_five))) ///
stack ytitle(Percentage of GDP) ///
legend(order(1 "Employee contributions" 2 "Employer contributions") ring(0) position(2) bmargin(large)) ///
bar(1,color(gs2)) bar(2,color(gs12))


graph export "figure3.pdf", replace


******Figure 4*********
graph bar (asis) inc2_gini (asis) inc3_gini (asis) inc4_gini if zone==1, ///
over(country,  sort(inc4_gini) descending label(angle(forty_five)) gap(100)) ///
exclude0 yscale(range(0.2 0.5)) ///
legend(on position(6) rows(1) ) ///
bar(1,color(gs2)) bar(2,color(gs8)) bar(3,color(gs12))


graph export "figure4.pdf", replace


***********************

* Create a country label with effective redistribution in brackets
gen string_r2to4 = round(r2to4, .001)
tostring string_r2to4 , replace format(%9.0g) force
gen label_fig5 = country /*+ " [" + string_r2to4 + "]"*/


* Generate a position variable so the mlabels do not overlap
gen position_fig5 = 3
replace position_fig5 = 4 if country=="Norway"
replace position_fig5 = 9 if country=="Luxembourg"
replace position_fig5 = 9 if country=="Spain"
replace position_fig5 = 2 if country=="Netherlands"
replace position_fig5 = 12 if country=="Iceland"
replace position_fig5 = 6 if country=="Greece"
replace position_fig5 = 6 if country=="Estonia"
replace position_fig5 = 8 if country=="Slovak Republic"
replace position_fig5 = 10 if country=="United States"
replace position_fig5 = 6 if country=="Israel"
replace position_fig5 = 10 if country=="Canada"
replace position_fig5 = 2 if country=="Austria"


recode r2to4 (0 / 0.049 = 1)  (0.05 / .081 = 2) ( .082 / .13 = 3) (0.131 / 0.2 = 4) , gen(redis_categories)


/*Figure 5 role respectif */
twoway (function y=x, range(0 .1) lcolor(gs12) lpattern(solid)) ///
(scatter  r2to3 r3to4 if redis_categories==2 , msymbol(oh) msize(medsmall) mcolor(gs6) ) ///
(scatter  r2to3 r3to4 if redis_categories==3 , msymbol(oh) msize(large) mcolor(gs4) ) ///
(scatter  r2to3 r3to4 if redis_categories==4 , msymbol(th) msize(large) mcolor(gs8) ) ///
(scatter  r2to3 r3to4 if redis_categories==2 , mlabel(label_fig5) msymbol(none) mlabvpos(position_fig5) mlabcolor(gs6)) ///
(scatter  r2to3 r3to4 if redis_categories==3 , mlabel(label_fig5) msymbol(none) mlabvpos(position_fig5) mlabcolor(gs4) ) ///
(scatter  r2to3 r3to4 if redis_categories==4, mlabel(label_fig5) msymbol(none) mlabvpos(position_fig5) mlabcolor(gs8)) ///
if zone==1, ///
ytitle(Transfer inequality reduction) xtitle(Tax inequality reduction) ///
legend(order(2 "Low reduction cluster" 3 "High reduction cluster" 4 "High reduction outlier") ring(0) position(10) bmargin(large)) ///
xscale(range(0 .105))

drop position_fig5 string_r2to4 redis_categories label_fig5

graph export "figure5.pdf", replace

// In the 2013-2016 data there are no "low reduction outliers"
*(scatter  r2to3 r3to4 if redis_categories==1 , msymbol(th) msize(medsmall) mcolor(gs8) ) ///
*(scatter  r2to3 r3to4 if redis_categories==1 , mlabel(label_fig5) msymbol(none) mlabvpos(position_fig5) mlabcolor(gs8)) ///
* legend(order(3 "Low reduction cluster" 4 "High reduction cluster" 2 "Low reduction outlier" 5 "High reduction outlier") ring(0) position(10) bmargin(large)) ///


**********************************************************************************
/*
The following graphs are quite complicated. You have to plot isolines for that
specify the redistribution caused by a certain combination of targeting 
(progressivity) and average transfer (tax) rate. 

The function is R = 1/(1-t)*K where R is the redistribution, K is the Kakwani,
and t is the average transfer/tax rate. The plots have the Kakwani on the y-axis
, and the rate on the x axis. Therefore, these isolines are plotted with:

K = (1-t)/t * R => y=(1-x)/x*R

Then, if we want to specify the correct range for the graph, we need to solve for
the average transfer/tax rate that will stop at certain Kakwani. 

This will be solved by: t = 1/(1-(K/R))

Transfers are more complicated because the transfer Kakwani is negative.

*/
********************************************************************************

/*Figure 6 Lignes de niveau transferts*/


* Generate a position variable so the mlabels do not overlap
gen position_fig6 = 3

replace position_fig6 = 12 if country=="Australia"
replace position_fig6 = 8 if country=="Austria"
replace position_fig6 = 2 if country=="Canada"
replace position_fig6 = 10 if country=="Czech Republic"
replace position_fig6 = 8 if country=="Germany"
replace position_fig6 = 8 if country=="Greece"
replace position_fig6 = 9 if country=="Iceland"
replace position_fig6 = 12 if country=="Ireland"
replace position_fig6 = 9 if country=="Israel"
replace position_fig6 = 9 if country=="Italy"
replace position_fig6 = 6 if country=="Norway"
replace position_fig6 = 11 if country=="Netherlands"
replace position_fig6 = 8 if country=="Slovak Republic"
replace position_fig6 = 3 if country=="Spain"
replace position_fig6 = 12 if country=="United States"




* Normal version: line thickness is constant
twoway ///
(function y=-(1+x)/x*.01 ,  range(.00671 .15) n(1000) lcolor(gs12) lpattern(solid) ) ///
(function y=-(1+x)/x*.03 ,  range(.02041 .15) n(1000) lcolor(gs12) lpattern(solid) ) ///
(function y=-(1+x)/x*.05 ,  range(.03448 .15) n(1000) lcolor(gs12) lpattern(solid) ) ///
(function y=-(1+x)/x*.07 ,  range(.04895 .15) n(1000) lcolor(gs12) lpattern(solid) ) ///
(function y=-(1+x)/x*.09 ,  range(.06383 .15) n(1000) lcolor(gs12) lpattern(solid) ) ///
(function y=-(1+x)/x*.11 ,  range(.07914 .15) n(1000) lcolor(gs12) lpattern(solid) ) ///
(scatter transfer_kakwani transshare if zone==1, mlabel(country) msymbol(o) mlabvpos(position_fig6) mcolor(gs4)) ///
,yscale(reverse) xscale(range(0 .12))  ///
text(-0.076 0.15 ".01", place(e) size(vsmall) color(gs8)) ///
text(-0.23 0.15 ".03", place(e) size(vsmall) color(gs8)) ///
text(-0.383 0.15 ".05", place(e) size(vsmall) color(gs8)) ///
text(-0.536 0.15 ".07", place(e) size(vsmall) color(gs8)) ///
text(-0.69 0.15 ".09", place(e) size(vsmall) color(gs8)) ///
text(-0.843 0.15 ".11", place(e) size(vsmall) color(gs8)) ///
legend(off) xtitle("Transfer rate") ytitle("Transfer targeting")

drop position_fig6

graph export "figure6.pdf", replace

// To add arrows:
* (pcarrowi -1.51 0.02 -1.51 0.04, color(gs8) ) ///
 
/* Figure 6bis Regression niveau des transferts et transferts*/

* Generate a position variable so the mlabels do not overlap
gen position_fig6bis = 3
replace position_fig6bis = 9 if country=="United States"
replace position_fig6bis = 9 if country=="Czech Republic"
replace position_fig6bis = 4 if country=="Slovak Republic"
replace position_fig6bis = 6 if country=="Spain"
replace position_fig6bis = 2 if country=="Italy"
replace position_fig6bis = 4 if country=="Greece"
replace position_fig6bis = 9 if country=="Canada"
 
twoway (scatter r2to3 transshare if zone==1 , mlabel(country) msymbol(o) mlabvpos(position_fig6bis)) ///
|| lfit r2to3 transshare , range(0 .15) legend(off) ///
ytitle(Inequality reduction due to transfers)

drop position_fig6bis
 
graph export "figure6bis.pdf", replace
 
/*Figure 7 Lignes de niveau taxes*/

* Generate a position variable so the mlabels do not overlap
gen position_fig7 = 3
replace position_fig7 = 9 if country=="Australia"
replace position_fig7 = 3 if country=="Austria"
replace position_fig7 = 9 if country=="Canada"
replace position_fig7 = 3 if country=="Czech Republic"
replace position_fig7 = 10 if country=="Estonia"
replace position_fig7 = 3 if country=="Germany"
replace position_fig7 = 3 if country=="Greece"
replace position_fig7 = 3 if country=="Iceland"
replace position_fig7 = 3 if country=="Ireland"
replace position_fig7 = 9 if country=="Israel"
replace position_fig7 = 3 if country=="Italy"
replace position_fig7 = 8 if country=="Luxembourg"
replace position_fig7 = 12 if country=="Norway"
replace position_fig7 = 8 if country=="Netherlands"
replace position_fig7 = 8 if country=="Slovak Republic"
replace position_fig7 = 12 if country=="Spain"
replace position_fig7 = 9 if country=="United States"

 twoway ///
(function y=(1-x)/x*.02 ,  range(.07407 .499) n(1000) lcolor(gs12) lpattern(solid) ) ///
(function y=(1-x)/x*.04 ,  range(.13793 .499) n(1000) lcolor(gs12) lpattern(solid) ) ///
(function y=(1-x)/x*.06 ,  range(.19355 .499) n(1000) lcolor(gs12) lpattern(solid) ) ///
(function y=(1-x)/x*.08 ,  range(.24242 .499) n(1000) lcolor(gs12) lpattern(solid) ) ///
(function y=(1-x)/x*.10 ,  range(.28571 .499) n(1000) lcolor(gs12) lpattern(solid) ) ///
(function y=(1-x)/x*.12 ,  range(.32432 .499) n(1000) lcolor(gs12) lpattern(solid) ) ///
(scatter tax_kakwani taxshare if zone==1, mlabel(country) msymbol(o) mlabvpos(position_fig7) mcolor(gs4) ) ///
, legend(off) ytitle("Tax progressivity") xtitle("Tax rate") ///
text(0.02 0.5 ".02", place(e) size(vsmall) color(gs8)) ///
text(0.04 0.5 ".04", place(e) size(vsmall) color(gs8)) ///
text(0.06 0.5 ".06", place(e) size(vsmall) color(gs8)) ///
text(0.08 0.5 ".08", place(e) size(vsmall) color(gs8)) ///
text(0.1 0.5 ".10", place(e) size(vsmall) color(gs8)) ///
text(0.12 0.5 ".12", place(e) size(vsmall) color(gs8))

drop position_fig7
 
graph export "figure7.pdf", replace
 
/* Figure 7bis Regression niveau des transferts et transferts*/

* Generate a position variable so the mlabels do not overlap
gen position_fig7bis = 3
replace position_fig7bis = 8 if country=="United States"
replace position_fig7bis = 4 if country=="United Kingdom"
replace position_fig7bis = 9 if country=="France"
replace position_fig7bis = 6 if country=="Luxembourg"
replace position_fig7bis = 12 if country=="Canada"
 
twoway (scatter r3to4 taxshare if zone==1 , mlabel(country) msymbol(o) mlabvpos(position_fig7bis)) ///
|| lfit r3to4 taxshare , range(0.2 .45)  legend(off) ytitle(Inequality reduction due to taxes)

drop position_fig7bis
 
graph export "figure7bis.pdf", replace
 
 
  
/*incompatibilité*/
 
*Tax et progressivité

gen position_fig8 = 3
replace position_fig8 = 4 if country=="Australia"
replace position_fig8 = 9 if country=="Austria"
replace position_fig8 = 9 if country=="Canada"
replace position_fig8 = 3 if country=="Czech Republic"
replace position_fig8 = 10 if country=="Estonia"
replace position_fig8 = 3 if country=="Germany"
replace position_fig8 = 3 if country=="Greece"
replace position_fig8 = 3 if country=="Iceland"
replace position_fig8 = 3 if country=="Ireland"
replace position_fig8 = 2 if country=="Israel"
replace position_fig8 = 3 if country=="Italy"
replace position_fig8 = 8 if country=="Luxembourg"
replace position_fig8 = 12 if country=="Norway"
replace position_fig8 = 8 if country=="Netherlands"
replace position_fig8 = 8 if country=="Slovak Republic"
replace position_fig8 = 12 if country=="Spain"
replace position_fig8 = 9 if country=="United States"


/* * Old figure: 
twoway (lfit tax_kakwani taxshare, color(gs8)) ///
(scatter tax_kakwani taxshare, mlabel(countryyear_upper) msymbol(none)) ///
 ,  legend(off) ytitle("Tax progressivity") xtitle("Tax rate") 
 */
 
twoway (lfit tax_kakwani taxshare, color(gs8)) ///
(scatter tax_kakwani taxshare, msymbol(o) mcolor(gs12) ) ///
(scatter tax_kakwani taxshare if zone==1, msymbol(o) mcolor(gs4) mlabel(country) mlabvpos(position_fig8)) ///
 ,  legend(off) ytitle("Tax progressivity") xtitle("Tax rate") 
 
drop position_fig8

graph export "figure8.pdf", replace



******targetting and size*

gen position_fig9 = 3

replace position_fig9 = 12 if country=="Australia"
replace position_fig9 = 8 if country=="Austria"
replace position_fig9 = 2 if country=="Canada"
replace position_fig9 = 10 if country=="Czech Republic"
replace position_fig9 = 9 if country=="Germany"
replace position_fig9 = 8 if country=="Greece"
replace position_fig9 = 9 if country=="Iceland"
replace position_fig9 = 12 if country=="Ireland"
replace position_fig9 = 9 if country=="Israel"
replace position_fig9 = 9 if country=="Italy"
replace position_fig9 = 6 if country=="Norway"
replace position_fig9 = 11 if country=="Netherlands"
replace position_fig9 = 8 if country=="Slovak Republic"
replace position_fig9 = 3 if country=="Spain"
replace position_fig9 = 12 if country=="United States"


twoway ///
(lfit transfer_kakwani transshare, color(gs8)) ///
(lfit transfer_kakwani transshare if country!="Ireland" & country!="United Kingdom", color(gs8)) ///
(scatter transfer_kakwani transshare, msymbol(o) mcolor(gs12) ) ///
(scatter transfer_kakwani transshare if zone==1, msymbol(o) mcolor(gs4) mlabel(country) mlabvpos(position_fig9)) ///
,  legend( order(1 "Fitted value" 2 "Fitted value without UK and IE") ring(0) position(4)) ///
yscale(reverse) ///
ytitle("Transfer targeting") xtitle("Transfer rate")

drop position_fig9

graph export "figure9.pdf", replace
 
*Market income inequality and kakwani*
twoway (scatter transfer_kakwani inc2_gini, mlabel(countryyear_upper) msymbol(none)) ///
(lfit transfer_kakwani inc2_gini) ,  yscale(reverse) legend(off) ///
ytitle("Transfer targeting") xtitle("Market Income inequality")
graph save combi13.gph, replace

twoway (scatter tax_kakwani inc2_gini, mlabel(countryyear_upper) msymbol(none)) ///
(lfit tax_kakwani inc2_gini) ,  legend(off) ///
ytitle("Tax progressivity") xtitle("Market Income inequality")
graph save combi14.gph, replace

graph combine combi13.gph combi14.gph , iscale(.4)

graph export "figure10.pdf", replace




*******************************Section Robustness age actif**********************


* Create a country label with effective redistribution in brackets
gen string_r2to4 = round(hhaa_r2to4, .001)
tostring string_r2to4 , replace format(%9.0g) force
gen label_fig5 = country /*+ " [" + string_r2to4 + "]"*/


* Generate a position variable so the mlabels do not overlap
gen position_fig5 = 3
replace position_fig5 = 12 if country=="Australia"
replace position_fig5 = 3 if country=="Norway"
replace position_fig5 = 9 if country=="Luxembourg"
replace position_fig5 = 8 if country=="Spain"
replace position_fig5 = 11 if country=="Czech Republic"
replace position_fig5 = 9 if country=="Netherlands"
replace position_fig5 = 6 if country=="Iceland"
replace position_fig5 = 6 if country=="Greece"
replace position_fig5 = 9 if country=="Canada"


recode hhaa_r2to4 (0 / 0.0449 = 1)  (0.045 / .081 = 2) ( .082 / .125 = 3) (0.1251 / 0.2 = 4) , gen(redis_categories)


/*Figure 5 role respectif */
twoway (function y=x, range(0 .1) lcolor(gs12) lpattern(solid)) ///
(scatter  hhaa_r2to3 hhaa_r3to4 if redis_categories==2 , msymbol(oh) msize(medsmall) mcolor(gs6) ) ///
(scatter  hhaa_r2to3 hhaa_r3to4 if redis_categories==3 , msymbol(oh) msize(large) mcolor(gs4) ) ///
(scatter  hhaa_r2to3 hhaa_r3to4 if redis_categories==4 , msymbol(th) msize(large) mcolor(gs8) ) ///
(scatter  hhaa_r2to3 hhaa_r3to4 if redis_categories==2 , mlabel(label_fig5) msymbol(none) mlabvpos(position_fig5) mlabcolor(gs6)) ///
(scatter  hhaa_r2to3 hhaa_r3to4 if redis_categories==3 , mlabel(label_fig5) msymbol(none) mlabvpos(position_fig5) mlabcolor(gs4) ) ///
(scatter  hhaa_r2to3 hhaa_r3to4 if redis_categories==4, mlabel(label_fig5) msymbol(none) mlabvpos(position_fig5) mlabcolor(gs8)) ///
if zone==1, ///
ytitle(Transfer inequality reduction) xtitle(Tax inequality reduction) ///
legend(order(2 "Low reduction cluster" 3 "High reduction cluster" 4 "High reduction outlier") ring(0) position(10) bmargin(large)) ///
xscale(range(0 .105))

drop position_fig5 redis_categories string_r2to4 label_fig5

graph export "figure5_hhaa.pdf", replace


*Tax et progressivité

gen position_fig8 = 3
replace position_fig8 = 3 if country=="Australia"
replace position_fig8 = 4 if country=="Austria"
replace position_fig8 = 3 if country=="Norway"
replace position_fig8 = 3 if country=="Luxembourg"
replace position_fig8 = 9 if country=="Spain"
replace position_fig8 = 6 if country=="Czech Republic"
replace position_fig8 = 1 if country=="Netherlands"
replace position_fig8 = 4 if country=="Iceland"
replace position_fig8 = 3 if country=="Greece"
replace position_fig8 = 9 if country=="Canada"
replace position_fig8 = 9 if country=="Estonia"
replace position_fig8 = 9 if country=="Denmark"
replace position_fig8 = 12 if country=="Finland"
replace position_fig8 = 12 if country=="Germany"
 
twoway ///
(lfit tax_kakwani taxshare) ///
(scatter hhaa_tax_kakwani hhaa_taxshare, msymbol(o) mcolor(gs12)) ///
(scatter hhaa_tax_kakwani hhaa_taxshare if zone==1, msymbol(o) mcolor(gs4) mlabel(country) mlabvpos(position_fig8)) ///
 ,  legend(off) ytitle("Tax progressivity") xtitle("Tax rate") 
 
drop position_fig8

graph export "figure8_hhaa.pdf", replace







************************** module pension****************


/*lignes de niveau retraites*/

* Generate a position variable so the mlabels do not overlap
gen position_figA1 = 3
replace position_figA1 = 2 if country=="United Kingdom"
replace position_figA1 = 3 if country=="Spain"
replace position_figA1 = 9 if country=="Italy"
replace position_figA1 = 9 if country=="Sweden"
replace position_figA1 = 9 if country=="Luxembourg"
replace position_figA1 = 9 if country=="Greece"
replace position_figA1 = 3 if country=="Finland"
replace position_figA1 = 12 if country=="Estonia"
replace position_figA1 = 7 if country=="United States"
replace position_figA1 = 3 if country=="Norway"
replace position_figA1 = 3 if country=="Austria"
replace position_figA1 = 6 if country=="Israel"
replace position_figA1 = 9 if country=="Netherlands"
replace position_figA1 = 9 if country=="Slovak Republic"
replace position_figA1 = 11 if country=="Iceland"
replace position_figA1 = 9 if country=="France"
replace position_figA1 = 9 if country=="Ireland"


twoway ///
(function y=-(1+x)/x*.01 , range(.01266 .4) n(1000) lcolor(gs12) lpattern(solid) ) ///
(function y=-(1+x)/x*.03 , range(.03896 .4) n(1000) lcolor(gs12) lpattern(solid) ) ///
(function y=-(1+x)/x*.05 , range(.06666 .4) n(1000) lcolor(gs12) lpattern(solid) ) ///
(function y=-(1+x)/x*.07 , range(.09589 .4) n(1000) lcolor(gs12) lpattern(solid) ) ///
(function y=-(1+x)/x*.09 , range(.12676 .4) n(1000) lcolor(gs12) lpattern(solid) ) ///
(function y=-(1+x)/x*.11 , range(.15942 .4) n(1000) lcolor(gs12) lpattern(solid) ) ///
(scatter kakwani_pension pubpensionrate if zone==1 , mlabel(country) mcolor(gs4) msymbol(o) mlabvpos(position_figA1)) ///
,yscale(reverse ) legend(off)  ///
text(-0.035 0.4 ".01", place(e) size(vsmall) color(gs8)) ///
text(-0.105 0.4 ".03", place(e) size(vsmall) color(gs8)) ///
text(-0.175 0.4 ".05", place(e) size(vsmall) color(gs8)) ///
text(-0.245 0.4 ".07", place(e) size(vsmall) color(gs8)) ///
text(-0.315 0.4 ".09", place(e) size(vsmall) color(gs8)) ///
text(-0.385 0.4 ".11", place(e) size(vsmall) color(gs8)) ///
 ytitle("Pension targeting")  xtitle("Pension rate") 
  
drop position_figA1
  
graph export "figureA1.pdf", replace

/*Egalite revenu disponible et montant des pensions*/
gen position_figA2 = 3
replace position_figA2 = 3 if country=="Luxembourg"
replace position_figA2 = 3 if country=="Denmark"
replace position_figA2 = 4 if country=="Sweden"
replace position_figA2 = 4 if country=="Finland"
replace position_figA2 = 3 if country=="Greece"
replace position_figA2 = 12 if country=="Norway"
replace position_figA2 = 12 if country=="United Kingdom"
replace position_figA2 = 2 if country=="Israel"
replace position_figA2 = 5 if country=="Estonia"
replace position_figA2 = 4 if country=="United States"
replace position_figA2 = 2 if country=="Slovak Republic"
replace position_figA2 = 4 if country=="Czech Republic"
replace position_figA2 = 12 if country=="Austria"
replace position_figA2 = 2 if country=="Italy"


*twoway (lfit pubpensionrate inc2_gini, lcolor(gs5) lpattern(solid)) ///
*(lfit pubpensionrate inc4_gini, lcolor(gs5) lpattern(dash))

twoway (pcspike pubpensionrate inc2_gini pubpensionrate inc4_gini if zone==1 , lcolor(gs12)) ///
(scatter pubpensionrate inc2_gini, mlabel(country) mlabvpos(position_figA2) msymbol(X) mcolor(gs3)) ///
(scatter pubpensionrate inc4_gini , msymbol(o) xscale(range(.25 .52)) mcolor(gs3) ) ///
if zone==1 ///
, ytitle("Pension rate")  xtitle("Income inequality (Disposble and Market)") ///
legend(order(2 "Market income" 3 "Disposable income" 1 "Inequality reduction") ring(0) position(2) bmargin(large))

drop position_figA2

graph export "figureA2.pdf", replace


****annexe A3 et A4 dans le dofile appending 9 // additional for appendix*


/*********************EPL*************************/

twoway (lfit hhaa_inc2_gini EPL) (scatter hhaa_inc2_gini EPL, mlabel(countryyear)) ///
 if zone==1, xtitle(EPL index (regular contracts)) ytitle(Market inequality)


graph export "EPL1.pdf", replace


twoway (lfit hhaa_tax_kakwani EPL) (scatter hhaa_tax_kakwani EPL, mlabel(countryyear)) ///
 if zone==1, xtitle(EPL index (regular contracts)) ytitle(Tax progressivity) legend(off)
 
graph save EPLa.gph,replace 
 
twoway (lfit hhaa_transfer_kakwani EPL) (scatter hhaa_transfer_kakwani EPL, mlabel(countryyear)) ///
 if zone==1, xtitle(EPL index (regular contracts)) ytitle(Transfer targetting) legend(off)

graph save EPLb.gph,replace 

graph combine EPLa.gph EPLb.gph

graph export "EPL tradeoff.pdf", replace

/*
***************************************************************
* Figure Policy Brief LIEPP : somme des effets redistributifs *
***************************************************************

sort zone r2to5
gen index=_n if zone==1
labmask index, values(countryyear)

*transferts, fiscalité, tva (meme si tva>0) -- GRAPHIQUE DEFINITIF --
gen r2to5bis=r2to5
gen r2to4bis=r2to4
gen r2to3bis=r2to3
gen r3to4bis=r3to4
gen r4to5bis=r4to5

replace r2to4bis=r2to5 if r4to5>0

label var r2to4bis "Effet des transferts"
label var r3to4bis "... de la fiscalité (IR + cotisations)"
label var r4to5bis "... des taxes sur la consommation"
label var r2to5bis "Effet total"
twoway (bar r2to4bis index, barw(0.65)) (bar r3to4bis index, barw(0.65))  (bar r4to5bis index, barw(0.65))(scatter r2to5bis index ) if zone==1 & r2to5!=., xlabel(#20 ,valuelabel  angle(forty_five) labsize(small)) ytitle("Redistribution effective") xtitle("Pays-Année") legend(ring(0) position(10)  region(fcolor(none)))

graph export "figure4PB.pdf", replace

*version anglaise*
label var r2to4bis "Effect of transfers"
label var r3to4bis "... of taxes (PIT + SSC)"
label var r4to5bis "... of consumption taxes"
label var r2to5bis "Total effect"
twoway (bar r2to4bis index, barw(0.65)) (bar r3to4bis index, barw(0.65))  (bar r4to5bis index, barw(0.65))(scatter r2to5bis index ) if zone==1 & r2to5!=., xlabel(#20 ,valuelabel  angle(forty_five) labsize(small)) ytitle("Effective redistribution") xtitle("Country-Year") legend(ring(0) position(10)  region(fcolor(none)))
graph export "figure4PB-english.pdf", replace


*/
*******************Appendix with and without imputations**************

clear
*cd  "/home/m.olckers/U/LIS Four Levers/"

cd "C:\Users\zemmour\Documents\GitHub\lis-tax-transfer\"
use "NI_LIS et OECD.dta", clear

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

***hhaa version***
gen hhaa_taxshare=hhaa_tax_mean/hhaa_inc3_mean
gen hhaa_transshare=hhaa_transfer_mean/hhaa_inc2_mean


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

gen tax_kakwani = tax_conc_inc3 - inc3_gini
gen transfer_kakwani = transfer_conc_inc2 - inc2_gini

gen hhaa_tax_kakwani = hhaa_tax_conc_inc3 - hhaa_inc3_gini
gen hhaa_transfer_kakwani = hhaa_transfer_conc_inc2 - hhaa_inc2_gini

/*Reduction gini (indice de Reynold-Smolensky)*/
gen r2to4=inc2_gini-inc4_gini
gen r3to4=inc3_gini-inc4_gini
gen r2to3=inc2_gini-inc3_gini


/*Reduction gini (indice de Reynold-Smolensky) version hhaa*/
gen hhaa_r2to4=hhaa_inc2_gini-hhaa_inc4_gini
gen hhaa_r3to4=hhaa_inc3_gini-hhaa_inc4_gini
gen hhaa_r2to3=hhaa_inc2_gini-hhaa_inc3_gini

/*calcul du reranking*/

gen Rerank2=inc2_conc_inc2-inc2_conc_inc1
gen Rerank3=inc3_conc_inc3-inc3_conc_inc2
gen Rerank4=inc4_conc_inc4-inc4_conc_inc3

/*Calcul de la redistribution verticale (directement Ã  partir du Reynold Smolenski, et indirectement Ã  partir du Kakwani*/

gen Ve23=r2to3+Rerank3
gen Ve34=r3to4+Rerank4


gen VeSSC=(SSCshare/(1-SSCshare))*SSC_kakwani
gen VeSSCer=(SSCershare/(1-SSCershare))*SSCer_kakwani
gen VeSSCee=(SSCeeshare/(1-SSCeeshare))*SSCee_kakwani

gen Vepension= -pubpensionrate/(1+pubpensionrate)*kakwani_pension

gen Ve23verif=-transshare/(1+transshare)*transfer_kakwani
gen Ve34verif=taxshare/(1-taxshare)*tax_kakwani

/*autres variables d'indicateurs issues de l'OCDE*/

gen sscem2=sscem /*save OECD employer contrib in a sscem2 variable*/
replace sscem=sscem+payroll  /*add payroll to sscem OECD variable*/
replace ssc=ssc+payroll
gen bismindx=(ssc)/totalexp
gen kindshare=totalkind/totalexp
gen taxOECD=ssc+tax1100
gen sharetax=(taxOECD)/totaltax
gen sharetax2=sharetax+tax5100/totaltax
gen LisorigOECD=sscee+tax1100
gen Lisorig=(sscee+tax1100)/totaltax

gen sum=sscee+sscem

label var Lisorig "Perimetre LIS: IR + cotis. employees"
label var sharetax "IR + cotis. employÃ©s et employeur"
label var sharetax2 "IR + cotis. employÃ©s et employeur+ TVA & taxes sur la conso"
label var taxshare "Tax rate"
label var transshare "Transfer rate"
label var r3to4 "Gini [Gross Income]- Gini [Disp Income]"
label var r2to3 "Gini [Market income] - Gini [Gross Income]"

drop totaltax tax1000 tax1100 tax1200 payroll tax5000 tax5100 tax5110 tax5111 totalexpphppp totalcashphppp ///
totalkindphppp totalexp totalcash totalkind totalexpgg gdp_exp pop cp_nationalcurrency disp_hhplus_nationalcurrency ///
disp_nationalcurrency ghdi_by_gdp apc_oecd itrc_1 itrc_2 itrc_3 _merge EPL _merge2 taxOECD sharetax sharetax2 LisorigOECD

foreach var of varlist * {

rename `var' NI_`var'
    }
rename NI_countryyear countryyear

drop if NI_inc2_gini==.
sort countryyear

save "Without imputations.dta", replace

use "LIS et OECD.dta", clear
drop _merge
drop if inc2_gini==.
sort countryyear
save "With imputations.dta", replace

merge 1:1 countryyear using "Without imputations.dta"

save "With and without imputations.dta", replace

* Set scheme and save figures in a folder with the scheme name
set scheme plotplain, perm
cd "C:\Users\zemmour\Documents\GitHub\lis-tax-transfer\Stata\output\"

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

***hhaa version***
gen hhaa_taxshare=hhaa_tax_mean/hhaa_inc3_mean
gen hhaa_transshare=hhaa_transfer_mean/hhaa_inc2_mean


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

gen tax_kakwani = tax_conc_inc3 - inc3_gini
gen transfer_kakwani = transfer_conc_inc2 - inc2_gini

gen hhaa_tax_kakwani = hhaa_tax_conc_inc3 - hhaa_inc3_gini
gen hhaa_transfer_kakwani = hhaa_transfer_conc_inc2 - hhaa_inc2_gini

/*Reduction gini (indice de Reynold-Smolensky)*/
gen r2to4=inc2_gini-inc4_gini
gen r3to4=inc3_gini-inc4_gini
gen r2to3=inc2_gini-inc3_gini


/*Reduction gini (indice de Reynold-Smolensky) version hhaa*/
gen hhaa_r2to4=hhaa_inc2_gini-hhaa_inc4_gini
gen hhaa_r3to4=hhaa_inc3_gini-hhaa_inc4_gini
gen hhaa_r2to3=hhaa_inc2_gini-hhaa_inc3_gini

/*calcul du reranking*/

gen Rerank2=inc2_conc_inc2-inc2_conc_inc1
gen Rerank3=inc3_conc_inc3-inc3_conc_inc2
gen Rerank4=inc4_conc_inc4-inc4_conc_inc3

/*Calcul de la redistribution verticale (directement Ã  partir du Reynold Smolenski, et indirectement Ã  partir du Kakwani*/

gen Ve23=r2to3+Rerank3
gen Ve34=r3to4+Rerank4


gen VeSSC=(SSCshare/(1-SSCshare))*SSC_kakwani
gen VeSSCer=(SSCershare/(1-SSCershare))*SSCer_kakwani
gen VeSSCee=(SSCeeshare/(1-SSCeeshare))*SSCee_kakwani

gen Vepension= -pubpensionrate/(1+pubpensionrate)*kakwani_pension

gen Ve23verif=-transshare/(1+transshare)*transfer_kakwani
gen Ve34verif=taxshare/(1-taxshare)*tax_kakwani

/*autres variables d'indicateurs issues de l'OCDE*/

gen sscem2=sscem /*save OECD employer contrib in a sscem2 variable*/
replace sscem=sscem+payroll  /*add payroll to sscem OECD variable*/
replace ssc=ssc+payroll
gen bismindx=(ssc)/totalexp
gen kindshare=totalkind/totalexp
gen taxOECD=ssc+tax1100
gen sharetax=(taxOECD)/totaltax
gen sharetax2=sharetax+tax5100/totaltax
gen LisorigOECD=sscee+tax1100
gen Lisorig=(sscee+tax1100)/totaltax

gen sum=sscee+sscem

label var Lisorig "Perimetre LIS: IR + cotis. employees"
label var sharetax "IR + cotis. employÃ©s et employeur"
label var sharetax2 "IR + cotis. employÃ©s et employeur+ TVA & taxes sur la conso"
label var taxshare "Tax rate"
label var transshare "Transfer rate"
label var r3to4 "Gini [Gross Income]- Gini [Disp Income]"
label var r2to3 "Gini [Market income] - Gini [Gross Income]"


****************************************************************
*Nettoyage des donnÃ©es et crÃ©ation d'une zone (1 point par pays)
****************************************************************




drop if inc2_gini==.
*drop if datatype=="Net"
global net_datasets "at00 be00 gr00 hu05 hu07 hu09 hu12 hu99 ie00 it00 lu00 mx00 mx02 mx04 mx08 mx10 mx12 mx98 si10" 

foreach ccyy in $net_datasets {
drop if countryyear=="`ccyy'"
}

drop if ccode=="kr"|countryyear=="jp08" |country=="Poland"|country=="Switzerland"/*|country=="Switzerland"Japon: problÃ¨me sur les taxes qui apparaÃ®t lorsqu'on compare Ve34 et Ve34 verif; pologne aussi*/
**création d'une zone sur la dernière année disponible
gen zone=.


bys ccode: egen ymax=max(year)
replace ymax=0 if ymax>year
replace ymax=1 if ymax==year

replace zone=0
replace zone=1 if ymax==1
replace zone=0 if countryyear=="ie10"
replace zone=1 if countryyear=="ie07"

sort r2to4
*encode country if zone==1 & constax_kakwani!=., gen(ccode)

gen ccodeshort=substr(countryyear, 1, 2)






************************************** Figures********************************
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
graph export "figureA4.pdf", replace
