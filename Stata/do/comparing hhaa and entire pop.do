
twoway (scatter hhaa_inc1_gini hhaa_inc2_gini) (function y=x, range(inc2_gini)), title(activ age inc1 vs inc2 gini)
graph save a.gph, replace

twoway (scatter hhaa_inc2_gini inc2_gini ) (function y=x, range(inc2_gini)) , title(activ age inc2 vs allpop inc2 gini)
graph save b.gph, replace
twoway (scatter inc1_gini inc2_gini) (function y=x, range(inc2_gini)), title(allpop inc1 vs inc2 gini)
graph save c.gph, replace

graph combine a.gph b.gph c.gph




***************trade-off****************

twoway scatter hhaa_taxshare hhaa_tax_kakwani , mlabel(countryyear)
graph save d.gph, replace
twoway scatter taxshare tax_kakwani , mlabel(countryyear)
graph save e.gph, replace

graph combine d.gph e.gph





/* Create a country label with effective redistribution in brackets
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
*/

/*Figure 5 role respectif */
twoway (function y=x, range(0 .1) lcolor(gs12) lpattern(solid)) ///
(scatter  hhaa_r2to3 hhaa_r3to4 , mlabel(countryyear) ) ///
if zone==1, ///
ytitle(Transfer inequality reduction) xtitle(Tax inequality reduction) legend(off) title(activ age) ///
xscale(range(0 .105))

graph save comp1.gph, replace


twoway (function y=x, range(0 .1) lcolor(gs12) lpattern(solid)) ///
(scatter  r2to3 r3to4 , mlabel(countryyear) ) ///
if zone==1, ///
ytitle(Transfer inequality reduction) xtitle(Tax inequality reduction) legend(off) title(allpop) ///
xscale(range(0 .105))

graph save comp2.gph, replace

graph combine comp1.gph comp2.gph

twoway (scatter hhaa_r2to3 r2to3 , mlabel(countryyear)) (function y=x, range(r2to3)) if country!="Ireland" & zone==1, title(transfer redistribution)
graph save ag1.gph, replace
twoway (scatter hhaa_r3to4 r3to4 , mlabel(countryyear)) (function y=x, range(r3to4)) if  zone==1, title(tax redistribution)
graph save ag2.gph, replace

graph combine ag1.gph ag2.gph

*comparaisons*
twoway (scatter hhaa_taxshare taxshare ) (function y=x, range(taxshare))
graph save g1.gph, replace
twoway (scatter hhaa_transshare transshare ) (function y=x, range(transshare)) if country!="Ireland"
graph save g2.gph, replace
twoway (scatter hhaa_tax_kakwani tax_kakwani ) (function y=x, range(tax_kakwani))
graph save g3.gph, replace
twoway (scatter hhaa_transfer_kakwani transfer_kakwani ) (function y=x, range(transfer_kakwani))
graph save g4.gph, replace

graph combine g1.gph g2.gph g3.gph g4.gph, title(4 levers - activ age (y) vs all pop (x))



su r2to3 hhaa_r2to3 r3to4 hhaa_r3to4  taxshare hhaa_taxshare  tax_kakwani hhaa_tax_kakwani  transshare hhaa_transshare transfer_kakwani hhaa_transfer_kakwani



****************EPL and LM ineq********

twoway (lfit hhaa_inc2_gini EPL) (scatter hhaa_inc2_gini EPL, mlabel(countryyear)) if zone==1, xtitle(EPL index (regular contracts)) ytitle(Market inequality)
twoway (lfit hhaa_inc1_gini EPL) (scatter hhaa_inc1_gini EPL, mlabel(countryyear)) if zone==1, xtitle(EPL index (regular contracts)) ytitle(Market inequality)

twoway (lfit inc2_gini EPL) (scatter inc2_gini EPL, mlabel(countryyear)) if zone==1, xtitle(EPL index (regular contracts)) ytitle(Market inequality)


