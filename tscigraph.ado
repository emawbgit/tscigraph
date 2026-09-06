*! version 1.2.0  06sep2026
*! tscigraph: Time series graph with confidence intervals and panel support

program define tscigraph
    version 17.0
    
    syntax varlist(min=3 max=4 numeric) [if] [in] [, BY(varname) CITYPE(string) OVERlay *]
    
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
    
    // Handle overlay option with by()
    if "`by'" != "" & "`overlay'" != "" {
        quietly levelsof `by' if `touse', local(levels)
        local isstr = 0
        capture confirm string variable `by'
        if _rc == 0 local isstr = 1
        
        local vallab : value label `by'
        
        local plots ""
        local legorder ""
        local keyidx = 1
        
        foreach lvl of local levels {
            if `isstr' {
                local cond `"`touse' & `by' == "`lvl'""'
                local lbl "`lvl'"
            }
            else {
                local cond "`touse' & `by' == `lvl'"
                if "`vallab'" != "" {
                    local lbl : label `vallab' `lvl'
                }
                else {
                    local lbl "`lvl'"
                }
            }
            
            // Plot CI (keyidx) and Line (keyidx+1)
            local plots "`plots' (`citype' `lb' `ub' `timevar' if `cond') (line `yvar' `timevar' if `cond')"
            
            local linekey = `keyidx' + 1
            local legorder `"`legorder' `linekey' "`lbl'""'
            local keyidx = `keyidx' + 2
        }
        
        twoway `plots', legend(order(`legorder')) `options'
    }
    else {
        // Construct by option for native subgraphs
        local byopt ""
        if "`by'" != "" {
            local byopt "by(`by')"
        }
        
        // Exclude CI from legend (key 1 = CI, key 2 = line)
        local ylbl : variable label `yvar'
        if "`ylbl'" == "" local ylbl "`yvar'"
        
        twoway (`citype' `lb' `ub' `timevar' if `touse') ///
               (line `yvar' `timevar' if `touse'), ///
               legend(order(2 "`ylbl'")) `byopt' `options'
    }

end
