clear all
global num "19" // Dataset number
global directory "/Users/matthewolckers/Desktop"


import delimited "$directory/LIS Reducing Inequality - $num - Decile.csv"

encode decile, gen(dnum)

label variable countryyear "Dataset identifier"
label variable country "Country"
label variable year "Year"
label variable decile "Decile"
label variable dnum "Decile number"

label variable inc1_mean "Primary income"
label variable inc2_mean "Market income"
label variable inc3_mean "Gross income"
label variable inc4_mean "Disposable income"

label variable inc1_min "Primary income"
label variable inc2_min "Market income"
label variable inc3_min "Gross income"
label variable inc4_min "Disposable income"

label variable inc1_max "Primary income"
label variable inc2_max "Market income"
label variable inc3_max "Gross income"
label variable inc4_max "Disposable income"

label var  transfer_mean "Social transfers"
label var tax_mean "Taxes and social security contributions"
label var  transfer_min "Social transfers"
label var tax_min "Taxes and social security contributions"
label var  transfer_max "Social transfers"
label var tax_max "Taxes and social security contributions"

label var datatype "Income recorded gross, net, or some combination (mixed)"

save "$directory/LIS Reducing Inequality - $num - Decile.dta" , replace
saveold "$directory/LIS Reducing Inequality - $num - Decile (Stata 12).dta", version(12) replace


*===============================================================================
clear all

import delimited "/Users/matthewolckers/Desktop/LIS Reducing Inequality - $num - Country.csv"

label variable countryyear "Dataset identifier"
label variable country "Country"
label variable year "Year"

label variable inc1_gini "Primary Income"
label variable inc2_gini "Market Income"
label variable inc3_gini "Gross Income"
label variable inc4_gini "Disposable Income"
label var dhi_gini "Disposable household income (from the LIS variable dhi)"

label variable transfer_conc_inc1 "Transfer Concentration Coeffiicient (Primary Income)"
label variable transfer_conc_inc2 "Transfer Concentration Coeffiicient (Market Income)"
label variable transfer_conc_inc3 "Transfer Concentration Coeffiicient (Gross Income)"
label variable transfer_conc_inc4 "Transfer Concentration Coeffiicient (Disposable Income)"

label variable tax_conc_inc1 "Tax Concentration Coefficient (Primary Income)"
label variable tax_conc_inc2 "Tax Concentration Coefficient (Market Income)"
label variable tax_conc_inc3 "Tax Concentration Coefficient (Gross Income)"
label variable tax_conc_inc4 "Tax Concentration Coefficient (Disposable Income)"

label var inc1_mean "Primary Income"
label var inc2_mean "Market income"
label var inc3_mean "Gross Income"
label var inc4_mean "Disposable Income"
label var dhi_mean "Disposable household income (from the LIS variable dhi)"

label var transfer_mean "Social transfers"
label var tax_mean "Taxes and social security contributions"
label var allpension_mean "Public and private pensions"
label var pubpension_mean "Public pensions"
label var pripension_mean "Private pensions"

label var datatype "Income recorded gross, net, or some combination (mixed)"

label var inc1_conc_inc1 "Primary Income Concentration Coefficient (Primary Income)"
label var inc1_conc_inc2 "Primary Income Concentration Coefficient (Market Income)"
label var inc1_conc_inc3 "Primary Income Concentration Coefficient (Gross Income)"
label var inc1_conc_inc4 "Primary Income Concentration Coefficient (Disposable Income)"
label var inc2_conc_inc1 "Market Income Concentration Coefficient (Primary Income)"
label var inc2_conc_inc2 "Market Income Concentration Coefficient (Market Income)"
label var inc2_conc_inc3 "Market Income Concentration Coefficient (Gross Income)"
label var inc2_conc_inc4 "Market Income Concentration Coefficient (Disposable Income)"
label var inc3_conc_inc1 "Gross Income Concentration Coefficient (Primary Income)"
label var inc3_conc_inc2 "Gross Income Concentration Coefficient (Market Income)"
label var inc3_conc_inc3 "Gross Income Concentration Coefficient (Gross Income)"
label var inc3_conc_inc4 "Gross Income Concentration Coefficient (Disposable Income)"
label var inc4_conc_inc1 "Disposable Income Concentration Coefficient (Primary Income)"
label var inc4_conc_inc2 "Disposable Income Concentration Coefficient (Market Income)"
label var inc4_conc_inc3 "Disposable Income Concentration Coefficient (Gross Income)"
label var inc4_conc_inc4 "Disposable Income Concentration Coefficient (Disposable Income)"


label var allpension_conc_inc1 "Pension Concentation Coefficient (Primary Income)"
label var allpension_conc_inc2 "Pension Concentation Coefficient (Market Income)"
label var allpension_conc_inc3 "Pension Concentation Coefficient (Gross Income)"
label var allpension_conc_inc4 "Pension Concentation Coefficient (Disposable Income)"
label var pubpension_conc_inc1 "Public Pension Concentation Coefficient (Primary Income)"
label var pubpension_conc_inc2 "Public Pension Concentation Coefficient (Market Income)"
label var pubpension_conc_inc3 "Public Pension Concentation Coefficient (Gross Income)"
label var pubpension_conc_inc4 "Public Pension Concentation Coefficient (Disposable Income)"
label var pripension_conc_inc1 "Private Pension Concentation Coefficient (Primary Income)"
label var pripension_conc_inc2 "Private Pension Concentation Coefficient (Market Income)"
label var pripension_conc_inc3 "Private Pension Concentation Coefficient (Gross Income)"
label var pripension_conc_inc4 "Private Pension Concentation Coefficient (Disposable Income)"

label variable hxits_mean "Employee Social Security Contributions (LIS and Imputations)"
label variable hsscee_mean "Employee Social Security Contributions (Imputed)"
label variable hsscer_mean "Employer Social Security Contributions (Imputed)"
label variable hssc_mean "Social Security Contributions (Imputed)"

label variable hxitsconc_inc3 "Social Security Contributions"
label variable hssceeconc_inc3 "Employee Social Security Contributions"
label variable hssceeconc_inc3 "Employee Social Security Contributions (Imputed)"
label variable hsscerconc_inc3 "Employer Social Security Contributions (Imputed)"
label variable hsscconc_inc3 "Social Security Contributions (Imputed)"

gen tax_kakwani = tax_conc_inc3 - inc3_gini
gen transfer_kakwani = transfer_conc_inc2 - inc2_gini
label var tax_kakwani "Kakwani tax progressivity index (Gross income)"
label var transfer_kakwani "Kakwani transfer progressivity index (Market income)"

save "$directory/LIS Reducing Inequality - $num - Country.dta",replace
saveold "$directory/LIS Reducing Inequality - $num - Country (Stata 12).dta", version(12) replace
