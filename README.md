# tscigraph: Time Series Graphs with Confidence Intervals and Panel Support in Stata

`tscigraph` is a Stata package for creating time series plots that combine main variable estimates with lower and upper confidence interval bounds, with full support for panel data subgraphs (`by()`), overlaying group series on a single plot axis (`overlay`), and custom interval display types (`rcap` or `rarea`).

CI bounds (`lb`/`ub`) are automatically hidden from legend keys, while overlaid series display clean group labels corresponding to the levels or value labels of the `by()` variable.

---

## Installation

You can install `tscigraph` directly from GitHub in Stata:

```stata
net install tscigraph, from("https://raw.githubusercontent.com/emawbgit/tscigraph/main") replace
```

---

## Syntax

```stata
tscigraph yvar lb ub [timevar] [if] [in] [, by(varname) citype(string) overlay twoway_options]
```

### Arguments

- **`yvar`**: The primary variable to plot (line plot).
- **`lb`**: Lower bound variable for confidence interval.
- **`ub`**: Upper bound variable for confidence interval.
- **`timevar`** *(optional)*: Time variable for the x-axis. If omitted, `tscigraph` automatically checks for `tsset` or `xtset` settings, falling back to observation indices (`_n`) if unassigned.

---

## Options

| Option | Description |
| :--- | :--- |
| `by(varname)` | Generates series for each distinct value/category of `varname`. |
| `citype(string)` | Confidence interval display style: `rcap` (capped spikes, default) or `rarea` (shaded range area). |
| `overlay` | Overlays all group series on a single plot axis, using level value labels in the legend while excluding CI keys. |
| `twoway_options` | Any additional options supported by Stata's `twoway` command (e.g. `title()`, `xtitle()`, `ytitle()`, `scheme()`, `legend()`). |

---

## Examples

### Example 1: Native Grunfeld Panel Dataset

```stata
webuse grunfeld, clear
generate lb = invest - 15
generate ub = invest + 15

* Separate subgraphs for each company
tscigraph invest lb ub year if company <= 3, by(company)

* Overlay companies on a single plot (legend displays Company 1, Company 2, Company 3 without lb/ub)
tscigraph invest lb ub year if company <= 3, by(company) overlay
```

### Example 2: Simulated 5-Country, 40-Year Monthly GDP Dataset

```stata
clear
set obs 2400
egen country = seq(), block(480)
egen mdate = seq(), f(1) t(480)
replace mdate = ym(1984, 1) + mdate - 1
format mdate %tm
set seed 12345

gen gdp = 100 + country*10 + rnormal(0, 5)
gen lb = gdp - 2.5
gen ub = gdp + 2.5

* Overlay all countries' monthly GDP and confidence bands on a single plot
tscigraph gdp lb ub mdate, by(country) overlay citype(rarea)
```

---

## Author

**Emanuele Clemente**
