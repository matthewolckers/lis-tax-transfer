

cd "C:\Users\zemmour\Documents\GitHub\lis-tax-transfer\"

use "Stata\output\LIS Inc2 Decile.dta", clear

**********création d'une zone*******

drop if inc2_mean==.
*drop if datatype=="Net"
global net_datasets "at00 be00 gr00 hu05 hu07 hu09 hu12 hu99 ie00 it00 lu00 mx00 mx02 mx04 mx08 mx10 mx12 mx98 si10" 

foreach ccyy in $net_datasets {
drop if countryyear=="`ccyy'"
}

drop if countryyear=="kr06"|countryyear=="jp08" |countryyear=="is04"|country=="Poland"|country=="Switzerland"/*Japon: problÃ¨me sur les taxes qui apparaÃ®t lorsqu'on compare Ve34 et Ve34 verif; iceland 04 aberrant sur SSC; pologne aussi*/

gen zone=1 if year==2003| year==2004|year==2005|countryyear=="il10"|countryyear=="ee10"|countryyear=="is07"|countryyear=="gr07"|countryyear=="es07"
*******************************


reshape wide inc1_mean-tax_max , i(countryyear) j(decile,string)

encode countryyear, gen(ccyy)


forvalue i=1(1)4{
bys ccyy: egen total_inc`i'=total(inc`i'_meanD01+inc`i'_meanD02+inc`i'_meanD03+inc`i'_meanD04+inc`i'_meanD05 + ///
inc`i'_meanD06+inc`i'_meanD07+inc`i'_meanD08+inc`i'_meanD09+inc`i'_meanD10)
}


forvalue i=1(1)4{
gen S20_inc`i'=(inc`i'_meanD01+inc`i'_meanD02)/total_inc`i'
gen S80_inc`i'=(inc`i'_meanD09+inc`i'_meanD10)/total_inc`i'
gen S80S20_inc`i'=S80_inc`i'/S20_inc`i'
gen LS80S20_inc`i'=log(S80S20_inc`i')

}


gen S80tax=(tax_meanD09+tax_meanD10)/total_inc4
gen S20tax=(tax_meanD01+tax_meanD02)/total_inc4
gen S80trans=(transfer_meanD09+transfer_meanD10)/total_inc4
gen S20trans=(transfer_meanD01+transfer_meanD02)/total_inc4

gen dLS80=log(S80_inc4)-log(S80_inc4+S80tax-S80trans)
gen dLS20=-log(S20_inc4+S20tax-S20trans)+log(S20_inc4)


gen top=(-tax_meanD09-tax_meanD10+transfer_meanD09+transfer_meanD10)/total_inc4
gen bottom=(-tax_meanD01-tax_meanD02+transfer_meanD01+transfer_meanD02)/total_inc4

twoway scatter top bottom if zone==1 & country!="Italy", mlabel(countryyear) yscale(reverse) aspectratio(1) ytitle(from the top quintile) ///
xtitle(toward the bottom quintile)


twoway scatter dLS80 dLS20 if zone==1 & country!="Italy", mlabel(countryyear) yscale(reverse)


