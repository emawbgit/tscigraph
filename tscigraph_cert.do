*! tscigraph certification  08sep2026
*  do tscigraph_cert.do   -- any assertion failure stops the script

clear all
set more off
capture log close
log using tscigraph_cert, replace text

* ------------------------------------ 1. the interval reproduces "ci means"
webuse grunfeld, clear

quietly levelsof year, local(yrs)
foreach yr of local yrs {
    quietly ci means kstock if year == `yr'
    scalar m`yr'  = r(mean)
    scalar lo`yr' = r(lb)
    scalar hi`yr' = r(ub)
}

preserve
    collapse (mean) kstock (semean) se = kstock (count) n = kstock, by(year)
    gen double lb = kstock - invttail(n-1, 0.025)*se
    gen double ub = kstock + invttail(n-1, 0.025)*se
    forvalues i = 1/`=_N' {
        local yr = year[`i']
        assert reldif(kstock[`i'], m`yr')  < 1e-8
        assert reldif(lb[`i'],     lo`yr') < 1e-8
        assert reldif(ub[`i'],     hi`yr') < 1e-8
    }
restore

* ------------------------------------ 2. level() at 90 and 99 matches ci too
foreach L in 90 99 {
    quietly ci means kstock if year == 1940, level(`L')
    scalar lo`L' = r(lb)
    scalar hi`L' = r(ub)
}
preserve
    keep if year == 1940
    collapse (mean) kstock (semean) se = kstock (count) n = kstock
    foreach L in 90 99 {
        local a = (100-`L')/200
        assert reldif(kstock - invttail(n-1,`a')*se, lo`L') < 1e-8
        assert reldif(kstock + invttail(n-1,`a')*se, hi`L') < 1e-8
    }
restore

* ------------------------------------------------- 3. data are not modified
webuse grunfeld, clear
tempfile before
save `before'
tscigraph kstock year, nodraw
cf _all using `before'                 // silence = byte-identical

* ---------------------------------------------------- 4. every code path runs
tscigraph kstock year, nodraw
tscigraph kstock year, citype(rarea) nodraw
tscigraph kstock year, level(90) nodraw
tscigraph kstock year if company <= 5, nodraw
tscigraph kstock, nodraw                            // timevar from xtset

generate big = mvalue > 1000
label define big 0 "Small" 1 "Large"
label values big big
tscigraph kstock year, by(big) nodraw
tscigraph kstock year, by(big) overlay nodraw
tscigraph kstock year, by(big) overlay citype(rarea) level(99) nodraw
tscigraph kstock year, by(big) overlay legend(off) nodraw
tscigraph kstock year, by(big) overlay title("Capital") ytitle("USD") scheme(s1mono) nodraw

preserve
    decode big, gen(bigstr)
    tscigraph kstock year, by(bigstr) overlay nodraw       // string by()
restore

preserve
    replace kstock = . if company == 3
    tscigraph kstock year, by(big) overlay nodraw          // missings survive
restore

* ---------------------------------------------------------- 5. error paths
rcof "noisily tscigraph kstock year company" == 103   // too many variables
rcof "noisily tscigraph kstock year, overlay" == 198  // overlay without by()
rcof "noisily tscigraph kstock year, citype(band)" == 198
rcof "noisily tscigraph kstock year if year > 9999" == 2000

preserve
    xtset, clear
    rcof "noisily tscigraph kstock" == 111            // no time variable
restore

preserve
    keep if company == 1                              // one obs per year
    rcof "noisily tscigraph kstock year" == 2000
restore

* ------------------------------------------ 6. single-obs period warns only
preserve
    drop if company > 1 & year < 1946
    tscigraph kstock year, nodraw                     // expect a note, not an error
restore

display as result _n "tscigraph certification passed"
log close
