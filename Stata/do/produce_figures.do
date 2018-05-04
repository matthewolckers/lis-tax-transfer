clear
cd "C:\Users\zemmour\Documents\GitHub\lis-tax-transfer\"

use "Stata\output\LIS et OECD.dta", clear

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
gen bismindx=ssc/totalexp
gen kindshare=totalkind/totalexp
gen taxOECD=ssc+tax1100
gen sharetax=(ssc+tax1100)/totaltax
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

drop if countryyear=="kr06"|countryyear=="jp08" |countryyear=="is04"|country=="Poland"|country=="Switzerland"/*Japon: problÃ¨me sur les taxes qui apparaÃ®t lorsqu'on compare Ve34 et Ve34 verif; iceland 04 aberrant sur SSC; pologne aussi*/

gen zone=1 if year==2003| year==2004|year==2005|countryyear=="il10"|countryyear=="ee10"|countryyear=="is07"|countryyear=="gr07"|countryyear=="es07"
sort r2to4
*encode country if zone==1 & constax_kakwani!=., gen(ccode)

gen ccodeshort=substr(countryyear, 1, 2)

*******************************************
* Taux de couverture des donnÃ©es et rÃ´le respectifs des cotisations employeur et salariÃ©s**********
*******************************************



**********Fig 2 ici on ne met que les cotisations pas les taxes sur la conso**************


twoway (histogram Lisorig, color(gs12) xscale(range(.1 .7)) xlabel(#8) yscale(range(0 6)) ) ///
       (histogram sharetax, fcolor(none) lcolor(black) xscale(range(.1 .7)) xlabel(#8) yscale(range(0 6)) ), ///
       legend(order(1 "Before imputation" 2 "After imputation") ring(0) position(10) bmargin(large)) ///
       xtitle(Percentage coverage of national tax revenue) ///
       ytitle(Number of country-years)

graph export "figure2.pdf", replace

************Figure 3 Part des cotisations employeur et employÃ©s*******

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
gen label_fig5 = country + " [" + string_r2to4 + "]"


* Generate a position variable so the mlabels do not overlap
gen position_fig5 = 3
replace position_fig5 = 9 if country=="Norway"
replace position_fig5 = 10 if country=="Luxembourg"
replace position_fig5 = 8 if country=="Spain"
replace position_fig5 = 11 if country=="Czech Republic"
replace position_fig5 = 2 if country=="Netherlands"
replace position_fig5 = 6 if country=="Iceland"
replace position_fig5 = 6 if country=="Greece"


recode r2to4 (0 / 0.049 = 1)  (0.05 / .081 = 2) ( .082 / .13 = 3) (0.131 / 0.2 = 4) , gen(redis_categories)


/*Figure 5 role respectif */
twoway (function y=x, range(0 .1) lcolor(gs12) lpattern(solid)) ///
(scatter  r2to3 r3to4 if redis_categories==1 , msymbol(th) msize(medsmall) mcolor(gs8) ) ///
(scatter  r2to3 r3to4 if redis_categories==2 , msymbol(oh) msize(medsmall) mcolor(gs6) ) ///
(scatter  r2to3 r3to4 if redis_categories==3 , msymbol(oh) msize(large) mcolor(gs4) ) ///
(scatter  r2to3 r3to4 if redis_categories==4 , msymbol(th) msize(large) mcolor(gs8) ) ///
(scatter  r2to3 r3to4 if redis_categories==1 , mlabel(label_fig5) msymbol(none) mlabvpos(position_fig5) mlabcolor(gs8)) ///
(scatter  r2to3 r3to4 if redis_categories==2 , mlabel(label_fig5) msymbol(none) mlabvpos(position_fig5) mlabcolor(gs6)) ///
(scatter  r2to3 r3to4 if redis_categories==3 , mlabel(label_fig5) msymbol(none) mlabvpos(position_fig5) mlabcolor(gs4) ) ///
(scatter  r2to3 r3to4 if redis_categories==4, mlabel(label_fig5) msymbol(none) mlabvpos(position_fig5) mlabcolor(gs8)) ///
if zone==1, ///
ytitle(Transfer inequality reduction) xtitle(Tax inequality reduction) ///
legend(order(3 "Low reduction cluster" 4 "High reduction cluster" 2 "Low reduction outlier" 5 "High reduction outlier") ring(0) position(10) bmargin(large)) ///
xscale(range(0 .105))

drop position_fig5 redis_categories string_r2to4 label_fig5

graph export "figure5.pdf", replace






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

* Alternate version: various line thicknewss

/*
twoway ///
(function y=-(1-x)/x*.01 ,  range(.00662 .112) n(1000) lcolor(gs12) lpattern(solid) lwidth(vthin) ) ///
(function y=-(1-x)/x*.03 ,  range(.01961 .112) n(1000) lcolor(gs12) lpattern(solid) lwidth(thin) ) ///
(function y=-(1-x)/x*.05 ,  range(.03226 .112) n(1000) lcolor(gs12) lpattern(solid) lwidth(medthin) ) ///
(function y=-(1-x)/x*.07 ,  range(.04459 .112) n(1000) lcolor(gs12) lpattern(solid) lwidth(medium) ) ///
(function y=-(1-x)/x*.09 ,  range(.05660 .112) n(1000) lcolor(gs12) lpattern(solid) lwidth(thick) ) ///
(function y=-(1-x)/x*.11 ,  range(.06832 .112) n(1000) lcolor(gs12) lpattern(solid) lwidth(vthick) ) ///
(scatter transfer_kakwani transshare if zone==1, mlabel(country) msymbol(oh)) ///
,yscale(reverse) xscale(range(0 .12))  ///
legend(off) xtitle("Transfer rate") ytitle("Transfer targeting")
*/

* Generate a position variable so the mlabels do not overlap
gen position_fig6 = 3
replace position_fig6 = 2 if country=="Canada"
replace position_fig6 = 2 if country=="Spain"
replace position_fig6 = 4 if country=="Norway"


* Normal version: line thickness is constant
twoway ///
(function y=-(1-x)/x*.01 ,  range(.00662 .15) n(1000) lcolor(gs12) lpattern(solid) ) ///
(function y=-(1-x)/x*.03 ,  range(.01961 .15) n(1000) lcolor(gs12) lpattern(solid) ) ///
(function y=-(1-x)/x*.05 ,  range(.03226 .15) n(1000) lcolor(gs12) lpattern(solid) ) ///
(function y=-(1-x)/x*.07 ,  range(.04459 .15) n(1000) lcolor(gs12) lpattern(solid) ) ///
(function y=-(1-x)/x*.09 ,  range(.05660 .15) n(1000) lcolor(gs12) lpattern(solid) ) ///
(function y=-(1-x)/x*.11 ,  range(.06832 .15) n(1000) lcolor(gs12) lpattern(solid) ) ///
(scatter transfer_kakwani transshare if zone==1, mlabel(country) msymbol(oh) mlabvpos(position_fig6)) ///
,yscale(reverse) xscale(range(0 .12))  ///
legend(off) xtitle("Transfer rate") ytitle("Transfer targeting")

drop position_fig6

graph export "figure6.pdf", replace

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

twoway (scatter r2to3 transshare if zone==1 , mlabel(country) msymbol(oh) mlabvpos(position_fig6bis)) ///
|| lfit r2to3 transshare , range(0 .15) legend(off) ///
ytitle(Inequality reduction due to transfers)

drop position_fig6bis

graph export "figure6bis.pdf", replace

/*Figure 7 Lignes de niveau taxes*/

* Generate a position variable so the mlabels do not overlap
gen position_fig7 = 3
replace position_fig7 = 2 if country=="France"
replace position_fig7 = 4 if country=="Germany"
replace position_fig7 = 6 if country=="Spain"

 twoway ///
(function y=(1-x)/x*.02 ,  range(.07407 .499) n(1000) lcolor(gs12) lpattern(solid) ) ///
(function y=(1-x)/x*.04 ,  range(.13793 .499) n(1000) lcolor(gs12) lpattern(solid) ) ///
(function y=(1-x)/x*.06 ,  range(.19355 .499) n(1000) lcolor(gs12) lpattern(solid) ) ///
(function y=(1-x)/x*.08 ,  range(.24242 .499) n(1000) lcolor(gs12) lpattern(solid) ) ///
(function y=(1-x)/x*.10 ,  range(.28571 .499) n(1000) lcolor(gs12) lpattern(solid) ) ///
(function y=(1-x)/x*.12 ,  range(.32432 .499) n(1000) lcolor(gs12) lpattern(solid) ) ///
(scatter tax_kakwani taxshare if zone==1, mlabel(country) msymbol(oh) mlabvpos(position_fig7)) ///
, legend(off) ytitle("Tax progressivity") xtitle("Tax rate")

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

twoway (scatter r3to4 taxshare if zone==1 , mlabel(country) msymbol(oh) mlabvpos(position_fig7bis)) ///
|| lfit r3to4 taxshare , range(0.2 .45)  legend(off) ytitle(Inequality reduction due to taxes)

drop position_fig7bis

graph export "figure7bis.pdf", replace



/*incompatibilitÃ©*/

*Tax et progressivitÃ©

twoway (scatter tax_kakwani taxshare, mlabel(countryyear_upper) msymbol(oh)) ///
 (lfit tax_kakwani taxshare) ///
 ,  legend(off) ytitle("Tax progressivity") xtitle("Tax rate")

graph export "figure8.pdf", replace

******targetting and size*
twoway (scatter transfer_kakwani transshare, mlabel(countryyear_upper) msymbol(oh)) ///
(lfit transfer_kakwani transshare) ///
(lfit transfer_kakwani transshare if country!="Ireland" & country!="United Kingdom") ///
,  legend(label(1 "Country-year") ///
lab(2 "Fitted value") lab(3 "Fitted value without UK and IE") ///
ring(0) position(2)) ///
ytitle("Transfer targeting") xtitle("Transfer rate")

graph export "figure9.pdf", replace

*Market income inequality and kakwani*
twoway (scatter transfer_kakwani inc2_gini, mlabel(countryyear_upper) msymbol(oh)) ///
(lfit transfer_kakwani inc2_gini) ,  yscale(reverse) legend(off) ///
ytitle("Transfer targeting") xtitle("Market Income inequality")
graph save combi13.gph, replace

twoway (scatter tax_kakwani inc2_gini, mlabel(countryyear_upper) msymbol(oh)) ///
(lfit tax_kakwani inc2_gini) ,  legend(off) ///
ytitle("Tax progressivity") xtitle("Market Income inequality")
graph save combi14.gph, replace

graph combine combi13.gph combi14.gph , iscale(.4)

graph export "figure10.pdf", replace



************************** module pension****************


/*lignes de niveau retraites*/

* Generate a position variable so the mlabels do not overlap
gen position_figA1 = 3
replace position_figA1 = 12 if country=="United Kingdom"
replace position_figA1 = 6 if country=="Spain"
replace position_figA1 = 7 if country=="Italy"
replace position_figA1 = 6 if country=="Sweden"
replace position_figA1 = 9 if country=="Luxembourg"
replace position_figA1 = 6 if country=="Greece"
replace position_figA1 = 6 if country=="Finland"
replace position_figA1 = 6 if country=="Estonia"
replace position_figA1 = 6 if country=="United States"
replace position_figA1 = 9 if country=="Norway"
replace position_figA1 = 6 if country=="Austria"
replace position_figA1 = 6 if country=="Israel"


twoway ///
(function y=-(1-x)/x*.05 , range(.1 .35) n(1000) lcolor(gs12) lpattern(solid) ) ///
(function y=-(1-x)/x*.07 , range(.1 .35) n(1000) lcolor(gs12) lpattern(solid) ) ///
(function y=-(1-x)/x*.09 , range(.1139 .35) n(1000) lcolor(gs12) lpattern(solid) ) ///
(function y=-(1-x)/x*.11 , range(.1358 .35) n(1000) lcolor(gs12) lpattern(solid) ) ///
(function y=-(1-x)/x*.13 , range(.1566 .35) n(1000) lcolor(gs12) lpattern(solid) ) ///
(function y=-(1-x)/x*.15 , range(.1764 .35) n(1000) lcolor(gs12) lpattern(solid) ) ///
(function y=-(1-x)/x*.17 , range(.1954 .35) n(1000) lcolor(gs12) lpattern(solid) ) ///
(function y=-(1-x)/x*.19 , range(.2135 .35) n(1000) lcolor(gs12) lpattern(solid) ) ///
(function y=-(1-x)/x*.21 , range(.2308 .35) n(1000) lcolor(gs12) lpattern(solid) ) ///
(scatter kakwani_pension pubpensionrate if zone==1 , mlabel(country) msymbol(oh) mlabvpos(position_figA1)) ///
 ,yscale(reverse titlegap(*-30)) legend(off) xscale(range(0.1 .35))  ///
 ytitle("Pension targeting")  xtitle("Pension rate")

drop position_figA1

graph export "figureA1.pdf", replace

/*Egalite revenu disponible et montant des pensions*/
gen position_figA2 = 3
replace position_figA2 = 7 if country=="Luxembourg"
replace position_figA2 = 5 if country=="Denmark"
replace position_figA2 = 1 if country=="Sweden"
replace position_figA2 = 4 if country=="Finland"
replace position_figA2 = 2 if country=="Greece"
replace position_figA2 = 2 if country=="Norway"
replace position_figA2 = 12 if country=="United Kingdom"
replace position_figA2 = 6 if country=="Israel"
replace position_figA2 = 5 if country=="Estonia"
replace position_figA2 = 2 if country=="United States"
replace position_figA2 = 2 if country=="Slovak Republic"


twoway ///
(pcspike pubpensionrate inc2_gini pubpensionrate inc4_gini if zone==1 , lcolor(gs14)) ///
(lfit pubpensionrate inc2_gini, lcolor(gs5) lpattern(solid)) ///
(lfit pubpensionrate inc4_gini, lcolor(gs5) lpattern(dash)) ///
(scatter pubpensionrate inc2_gini, mlabel(country) mlabvpos(position_figA2) msymbol(X) mcolor(gs3)) ///
(scatter pubpensionrate inc4_gini , msymbol(o) xscale(range(.25 .52)) mcolor(gs3) ) ///
if zone==1 ///
, ytitle("Pension rate")  xtitle("Income inequality (Disposble and Market)") ///
legend(order( 5 "Disposable income" 4 "Market income" 1  "Transfers + taxes" ) ring(0) position(2) bmargin(large))

drop position_figA2

graph export "figureA2.pdf", replace



****anexe A3 et A4 dans le dofile appending 9*
