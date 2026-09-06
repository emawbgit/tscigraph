*! version 1.0.0  06sep2026
*! tscigraph: Time series graph with confidence intervals and panel support

program define tscigraph
    version 17.0
    
    syntax varlist(min=3 max=4 numeric) [if] [in] [, BY(varname) CITYPE(string) *]
    
    tokenize `varlist'
    local yvar `1'
    local lb   `2'
    local ub   `3'
    local timevar `4'
    
    marksample touse
    
    // If timevar is omitted, attempt to infer from tsset/xtset or default to _n
    if "`timevar'" == "" {
        capture tsset
        if _rc == 0 {
            local timevar "`r(timevar)'"
        }
        else {
            capture xtset
            if _rc == 0 {
                local timevar "`r(timevar)'"
            }
        }
        
        if "`timevar'" == "" {
            tempvar _timevar
            quietly gen `_timevar' = _n if `touse'
            local timevar "`_timevar'"
            label variable `_timevar' "Observation"
        }
        else {
            quietly replace `touse' = 0 if missing(`timevar')
        }
    }
    
    // Default CI type is rcap
    if "`citype'" == "" {
        local citype "rcap"
    }
    local citype = lower("`citype'")
    
    if "`citype'" != "rcap" & "`citype'" != "rarea" {
        display as error "citype() must be either rcap or rarea"
        exit 198
    }
    
    // Construct by option
    local byopt ""
    if "`by'" != "" {
        local byopt "by(`by')"
    }
    
    // Execute twoway graph
    if "`citype'" == "rcap" {
        twoway (rcap `lb' `ub' `timevar' if `touse') ///
               (line `yvar' `timevar' if `touse'), ///
               `byopt' `options'
    }
    else if "`citype'" == "rarea" {
        twoway (rarea `lb' `ub' `timevar' if `touse') ///
               (line `yvar' `timevar' if `touse'), ///
               `byopt' `options'
    }

end
