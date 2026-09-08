# tscigraph: Period Means with Confidence Intervals Plotted Over Time in Stata

`tscigraph` is a Stata package that computes period means and exact normal-theory confidence intervals for a numerical variable (`yvar`) over time, drawing high-quality time series graphs with support for panel subgraphs (`by()`) and overlaid series (`overlay`).

---

## Installation

You can install `tscigraph` directly from GitHub in Stata:

```stata
net install tscigraph, from("https://raw.githubusercontent.com/emawbgit/tscigraph/main") replace
```

---

## Syntax

```stata
tscigraph yvar [timevar] [if] [in] [, by(varname) citype(string) overlay level(#) twoway_options]
```

### Arguments

- **`yvar`**: The numeric variable for which period means and confidence intervals are computed.
- **`timevar`** *(optional)*: Time variable for the x-axis. If omitted, `tscigraph` uses the time variable set by `tsset` or `xtset`.

---

## Description

`tscigraph` computes the mean of `yvar` within each value of `timevar` and plots that series with a confidence interval at each period. With `by(varname)`, one series is computed per group.

The interval is the normal-theory interval for a mean:

$$\bar{y} \pm t \times SE$$

where $SE$ is the standard error of the mean within the period and $t$ is the two-sided `level`% critical value of Student's $t$ on $n-1$ degrees of freedom ($n$ being the number of non-missing observations in that period). This reproduces `ci means` period by period.

Periods holding a single observation have no interval; they are reported in a note and their line segment is still drawn. Data in memory are not modified: the aggregation runs safely under `preserve`.

Confidence interval keys are automatically omitted from the legend. Each group's band takes the plot style of its own line, and all bands are drawn before any line so no series is obscured by another group's band.

---

## Options

| Option | Description |
| :--- | :--- |
| `by(varname)` | Computes a separate mean and interval for each category/level of `varname`. By default, these are drawn as separate subgraphs. |
| `citype(string)` | Interval display style: `rcap` (capped spikes, default; suited to few periods) or `rarea` (shaded band with reduced fill intensity; suited to many periods). |
| `overlay` | Places all group series on one single plot axis rather than creating separate subgraphs. Requires `by()`. |
| `level(#)` | Sets the confidence level (default is `level(95)` or as set by `set level`). |
| `twoway_options` | Any additional options allowed by Stata's `twoway` command (e.g. `title()`, `xtitle()`, `ytitle()`, `legend()`). A user-specified `legend()` replaces the default legend rather than colliding with it. |

---

## Remarks

- The interval describes the **precision of the period mean**, not the dispersion of `yvar` within the period. For a series that already has one observation per period, or for bounds produced by a model/bootstrap, build the graph with `twoway` directly.
- Plot styles cycle `p1`-`p15`. Beyond fifteen groups, colors repeat.

---

## Examples

### 1. Mean capital stock per year (Grunfeld dataset)

```stata
webuse grunfeld, clear
tscigraph kstock year
```

### 2. Shaded band at the 90% confidence level

```stata
tscigraph kstock year, citype(rarea) level(90)
```

### 3. Time variable inferred from `xtset`

```stata
xtset company year
tscigraph kstock
```

### 4. Overlaid groups on a single plot axis

```stata
generate big = mvalue > 1000
label define big 0 "Small firms" 1 "Large firms"
label values big big

tscigraph kstock year, by(big) overlay citype(rarea)
```

### 5. Subgraphs per group

```stata
tscigraph kstock year, by(big) title("Capital stock")
```

---

## Author

**Emanuele Clemente**  
University of Bari  
[emanueleclemente91@gmail.com](mailto:emanueleclemente91@gmail.com)  
[emanuele.clemente@uniba.it](mailto:emanuele.clemente@uniba.it)
