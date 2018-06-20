# Notes on data capturing

We extracted social security rates and ceilings from the [OECD Taxing Wages series](http://www.oecd.org/tax/taxing-wages-20725124.htm). Since tax systems vary widely across countries we were forced to make ad hoc decisions for certain country-years. These notes document the decisions.

## Employer Social Security Contributions

### Australia
#### 2001
OECD do not include the state payroll taxes in the 2001 report, but these taxes still existed at this time. (See http://archive.treasury.gov.au/documents/1156/HTML/docshell.asp?URL=01_Brief_History.asp)
#### 2010
Australia applies a state payroll tax. OECD uses the tax from New South Wales, the state with the largest population. Australia's tax year runs from July to June. For 2010, we use the rates for the 2009-2010 tax year. There are very large thresholds for the payroll tax so this rate will be largely overstated.

### Austria
#### 2000
I have not taken into account taxation of Christmas and leave bonuses. Employer contributions include social security contributions and payroll taxes.
#### 2004
The taxes includes employer social security contributions and payroll taxes. " A new program has been introduced as of January 1, 2004 for severance payments. Employers are required to pay 1.53 per cent of gross wages to the Social Health Security Fund (“Krankenkassen”) for those whose employment starts after January 1, 2004 or where the employer and employee opt to participate in the new program. It is assumed that the wage earners considered in the Report do not participate in this new program."

### Belgium
#### 2000
This was a period of transition to the Euro (40.3399 BEF = 1 EUR).

### Canada
#### 2000
OECD does include the rates for sickness and work injury for this year. These provincial level taxes are merely mentioned. I am pretty sure the sickness rate will stay constant at 1.95 percent, but I need to find the rate and the ceiling of the work injury contribution.
#### 2004
Ontario is used as the reference province for work injury compensation contributions.

### Czech Republic
#### 2010
The ceiling was introduced in 2010

### Estonia
#### 2010
There is a lump sum of EEK 1486 per month (17832 per year) in addition to this formula

### France
#### 2000
For this year, the OECD do not assume a rate for work accident social insurance.
#### 2005
Reduction in rate up to 1.6 times the minimum wage
#### 2010
The rebates for low wage occupations are significant, I must not forget these.

### Finland
#### 2000, 2004, 2007, 2010
OECD use an average rate of employer contributions. I assume the rates can differ across firms.

### Germany
###	2000
Idea: As a rule the employer pays the same as the employee so you could set employer contributions equal to employee contributions
#### 2004, 2007
Work injury contributions are not included in the OECD calculations.
#### 2010
If the salary is below 4800 EUR, the employer pays both the employee and employer contributions. For amounts between 4800 EUR and 9600 EUR, there is a sliding scale as employees begin to pay their contributions.  


### Greece
#### 2004
Apparently, in 2004 there was not a second ceiling for those who were employed after 1993. And the wording implies that you merely have to start paying social security contributions before 1993 for the the lower cap to apply to you. I think I need to do a manual adjustment based on age.  
###	2007
The rate is an average rate calculated by OECD, and the ceiling assumes that the worker started at his employer after 1993 (before which a lower ceiling applied).
#### 2010
The rate is an average rate calculated by OECD, and the ceiling assumes that the worker started at his employer after 1993 (before which a lower ceiling applied).

### Hungary
#### 1999
Lump sum health SSC paid by employers is 2100 HUF per month.
#### 2005
"The lump sum health contribution amounted to 3 450 HUF per month and 1 950 HUF per month applicable as of 1 November 2005."
###	2007
There is also a lump sum health insurance contribution of HUF 1950 per month.
#### 2009
There are different rates in the first and second half of the year. I will take the rates from the first half, but I need to check when the survey was collected in LIS.  There is also a lump sum health insurance contribution of HUF 1950 per month.
###	2012
There are employer SSC and payroll taxes. From 2012 to 2014, there was also tax incentives introduced for firms who raise the wages of their employees, and other types of deductions. I will have to use a manual adjustment.

### Ireland
###	2000
Reduced to 8.5 percent for employees earning less than IEP 280 per week.
###	2004, 2007, 2010
Reduced to 8.5 percent for employees earning less than 356 per week (18 512 per year).
#### 2010
There is a deduction for superannuation (pension) contributions. I am not sure how to take this into account.

### Italy
###	2000
Tax rates do differ by firm characteristics so this is an average rate assumed by OECD.

### Japan
#### 2008
World accident insurance varies greatly by industry. I assumed all workers pay the lowest rate of 0.45 percent.

### Mexico
#### 1998
I am not sure if 1998 is accurate, because the system is different to subsequent years.
###	2000
Work injury rate is taken from 1998 and is 5.19 percent.
###	2002, 2004
Work injury rate is 3.2 percent
###	2008
Work injury rate is 2.12 percent
###	2010
Work injury rate is 2.04 percent
###	2012
The work injury amount of 1.98 percent is an average rate. The actual rate differs by industry.

### Netherlands
#### 1999, 2004
Did not include health insurance
#### 2007
Medical care contributions are not included in 2010 Taxing Wages (they are not categorised as a tax) so I will not include them in 2007 either.
#### 2010
There are some complex tax credits that I can't work out how to include.

### Norway
#### 2000
There is definitely some inconsistency with the Norwegian system from 2000 to 2010. I need to look at it in more detail.
###	2004
Employers must pay a supplementary pension SSC amount of 12.5 percent on high incomes. OECD: The employer’s social security contributions for employees aged 62 years and older are 4 percentage points lower than the standard rates
###	2007
Does this apply to this year only? OECD "The employer’s social security contributions for employees aged 62 years and older are 3 percentage points lower than the standard rates"
###	2010
Norway's employer social security contributions vary geographically. The rate here is a weighted average.

### Poland
#### 2004
I suspect they forgot about the ceiling, unless it was introduced later.
###	2007
There seems to be an inconsistency here over time.
###	2013
The description is confusing. I don't know if I should use 20.43 percent or 16.77 percent for the first rate. By checking their formula, seems 16.77 percent is correct.

### Slovak Republic
#### 2004
They do not take into account the ceilings. I will need to look these up.

###	2010
In 2005, Slovak Republic introduced defined contribution private pensions funded by SSC. These contributions are not included.

### Slovenia
#### 2007
Slovenia is not included in the 2007 OECD report, but there is a suggestion in the 2010 report that there have been no changes in the system for many years. I quote: "The only change to these rates since 1996 has been the 0.2 per cent increase in the employers’ contribution rates for health insurance in 2002."

### Spain
#### 2013
The OECD report does not take into account the lower contribution ceiling. In fact, they assume that if your income is below the lower ceiling (8978.4 EUR) then you pay SSC as if you were at the lower ceiling.  

### Sweden
#### 2005
This rate includes employer SSC and payroll taxes. OECD: "A general discount applies both for employers and self-employed. The discount amounts to 5 per cent of the base and cannot exceed SEK 37 080 (it is not included in the calculations underlying this Report). The social security contributions are not applicable for employees or self-employed aged 65 or more. For the latter a special wage tax, which amounts to 24.26 per cent, is applicable."

### United States
#### 2004
Another inconsistency, because the unemployment SSC is not included at all.
###	2007
Here there is a definite inconsistency. They do not include the state unemployment SSC, but they do include the deduction for state unemployment SSC against federal SSC.
###	2013
OECD mentioned a deduction of state unemployment SSC against federal unemployment SSC, but the deduction is not included in the formula.


## Employee Social Security Contributions

### Austria
#### 2000
I am putting a zero here for rate4, but I am not sure this is correct. There is likely some rates that get charged above the ceiling.
###	2004
I am putting a zero here for rate4, but I am not sure this is correct. There is likely some rates that get charged above the ceiling.

### Belgium
#### 2000
Two manual adjustments: There are SSC deductions, and a special SSC which is calculated on joint income.

### Denmark
#### 2007
Lump sum unemployment SSC of 8 052 DKK and 975.6 DKK.
###	2010
There is a lump sum for unemployment benefits of 10 244 (might be a typo and is actually 10 544)

### Greece
#### 2000
Manual adjustment for lower ceiling
###	2004
Apparently, at this stage there was no higher cap for workers starting after 1993. I still need to mode the lower cap though.
###	2007
For this year they use the 1993 ceiling, but I changed it to be consistent with the 2010 report.  
###	2010
Rate is average of white-collar employees. There is a lower ceiling for workers who started before 1993, I will need to model this with age.

### Iceland
#### 2004
Lump sum SSC of 5 576 if income above threshold
###	2007
Lump sum SSC of 6 314 if above threshold
###	2010
Lump sum SSC of 25 600 ISK if above threshold

### Ireland
#### 2000
I need to check this. I got the 16952 from adding 11752 to the non cumulative allowance of 5200.

### Italy
#### 2000
These rates reflect average rates assumed by OECD

### Mexico
#### 2008
The second ceiling of 25 times the minimum wage was introduced in 2008.

### Netherlands
#### 2010
The unemployment contributions are quite complicated, with a range of rates. I need to look into this in more detail. The pension contributions do not apply to people aged 65 and older.

### Slovak Republic
#### 2004
I need to check what happened to the ceilings. Did OECD overlook them, or did they not exist?

### Slovenia
#### 2007
Slovenia is not included in the 2007 OECD Taxing Wages report.

### Spain
#### 2013
I have not made adjustment for the lower ceiling, but this is unlikely to have a major impact on wage earners.
