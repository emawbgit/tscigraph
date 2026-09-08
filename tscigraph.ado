*! version 3.0.0  08sep2026
*! tscigraph: period means of yvar with confidence intervals, plotted over time

program define tscigraph
    version 15.0

    syntax varlist(min=1 max=2 numeric) [if] [in] ///
        [, BY(varname) CITYPE(string) OVERlay Level(cilevel) LEGend(passthru) *]

    tokenize `varlist'
    local yvar `1'
    local timevar `2'

    // --- time variable ------------------------------------------------------
    if "`timevar'" == "" {
        capture tsset
        if _rc capture xtset
        if !_rc local timevar "`r(timevar)'"
        if "`timevar'" == "" {
            display as error "no timevar specified and data are not tsset or xtset"
            exit 111
        }
    }

    marksample touse
    markout `touse' `timevar' `by', strok
    quietly count if `touse'
    if r(N) == 0 {
        display as error "no observations"
        exit 2000
    }

    if "`overlay'" != "" & "`by'" == "" {
        display as error "overlay requires by()"
        exit 198
    }

    // --- citype -------------------------------------------------------------
    if "`citype'" == "" local citype "rcap"
    local citype = lower("`citype'")
    if !inlist("`citype'", "rcap", "rarea") {
        display as error "citype() must be rcap or rarea"
        exit 198
    }
    if "`citype'" == "rarea" local cistyle "fintensity(30) lwidth(none)"

    // --- carry metadata across the collapse ---------------------------------
    local tfmt : format `timevar'
    local tlab : variable label `timevar'
    local vlab : value label `by'
    local ylab : variable label `yvar'
    if `"`ylab'"' == "" local ylab "`yvar'"

    preserve
    quietly keep if `touse'

    // --- mean and interval per period ---------------------------------------
    tempvar se n lb ub
    collapse (mean) `yvar' (semean) `se' = `yvar' (count) `n' = `yvar', ///
        by(`timevar' `by')

    quietly {
        gen double `lb' = `yvar' - invttail(`n'-1, (100-`level')/200) * `se'
        gen double `ub' = `yvar' + invttail(`n'-1, (100-`level')/200) * `se'
        count if !missing(`lb')
    }
    if r(N) == 0 {
        display as error ///
            "no period has more than one observation; a mean-based interval cannot be computed"
        exit 2000
    }
    local ok = r(N)
    quietly count
    if `ok' < r(N) ///
        display as text "note: no interval for " r(N)-`ok' " period(s) with a single observation"

    format `timevar' `tfmt'
    if `"`tlab'"' != "" label variable `timevar' `"`tlab'"'
    if "`vlab'" != "" label values `by' `vlab'
    label variable `yvar' `"Mean `ylab'"'

    // --- overlay ------------------------------------------------------------
    if "`overlay'" != "" {
        quietly levelsof `by', local(levels)
        capture confirm string variable `by'
        local isstr = (_rc == 0)

        local g 0
        foreach lvl of local levels {
            local ++g
            if `isstr' {
                local cond `"`by' == "`lvl'""'
                local lbl`g' "`lvl'"
            }
            else {
                local cond "`by' == `lvl'"
                local lbl`g' "`lvl'"
                if "`vlab'" != "" local lbl`g' : label `vlab' `lvl'
            }
            // bands first, lines after: no group's series is painted over
            local cis `"`cis' (`citype' `lb' `ub' `timevar' if `cond', pstyle(p`g') `cistyle')"'
            local lns `"`lns' (line `yvar' `timevar' if `cond', pstyle(p`g'))"'
        }

        if `"`legend'"' == "" {
            forvalues j = 1/`g' {
                local k = `g' + `j'
                local order `"`order' `k' "`lbl`j''""'
            }
            local legend `"legend(order(`order'))"'
        }
        twoway `cis' `lns', `legend' `options'
        restore
        exit
    }

    // --- single series, or native by() subgraphs -----------------------------
    if "`by'" != "" local byopt "by(`by')"
    if `"`legend'"' == "" local legend `"legend(order(2 "Mean `ylab'"))"'

    twoway (`citype' `lb' `ub' `timevar', pstyle(p1) `cistyle') ///
           (line `yvar' `timevar', pstyle(p1)) ///
           , `legend' `byopt' `options'

    restore
end
