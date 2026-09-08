{smcl}
{* *! version 3.0.0  08sep2026}{...}
{vieweralsosee "[R] ci" "help ci"}{...}
{vieweralsosee "[TS] tsline" "help tsline"}{...}
{vieweralsosee "[XT] xtline" "help xtline"}{...}
{vieweralsosee "[D] collapse" "help collapse"}{...}
{title:Title}

{phang}
{bf:tscigraph} {hline 2} Period means with confidence intervals, plotted over time


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd:tscigraph}
{it:yvar} [{it:timevar}]
{ifin}
[{cmd:,} {opt by(varname)} {opt citype(string)} {opt overlay} {opt level(#)} {it:twoway_options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{synopt :{opt by(varname)}}separate mean and interval for each category of {it:varname}{p_end}
{synopt :{opt citype(string)}}interval display: {cmd:rcap} (default) or {cmd:rarea}{p_end}
{synopt :{opt overlay}}overlay groups on one axis instead of subgraphs; requires {opt by()}{p_end}
{synopt :{opt level(#)}}confidence level; default is {cmd:level(95)} or as set by {helpb set level}{p_end}
{synopt :{it:twoway_options}}any options allowed by {help twoway}, including {opt legend()}{p_end}
{synoptline}


{marker description}{...}
{title:Description}

{pstd}
{cmd:tscigraph} computes the mean of {it:yvar} within each value of {it:timevar} and plots
that series with a confidence interval at each period. With {opt by()}, one series is
computed per group.

{pstd}
The interval is the normal-theory interval for a mean,
{it:ybar} +/- {it:t} * {it:se}, where {it:se} is the standard error of the mean within the
period and {it:t} is the two-sided {it:level}% critical value of Student's t on {it:n}-1
degrees of freedom, {it:n} being the number of non-missing observations in that period.
This reproduces {helpb ci means} period by period.

{pstd}
Periods holding a single observation have no interval; they are reported in a note and
their line segment is still drawn. If no period has more than one observation there is
nothing to compute and {cmd:tscigraph} exits with an error.

{pstd}
If {it:timevar} is omitted, the time variable set by {helpb tsset} or {helpb xtset} is
used. The data in memory are not modified: the aggregation runs under {helpb preserve}.

{pstd}
Interval keys are omitted from the legend. Each group's band takes the plot style of its
own line, and all bands are drawn before any line, so no series is obscured by another
group's band.


{marker options}{...}
{title:Options}

{phang}
{opt by(varname)} computes a separate mean and interval for each level of {it:varname}
within each period. By default these are drawn as separate subgraphs. Observations with
missing {it:varname} are excluded. Suboptions of {help by_option:by()} are not supported.

{phang}
{opt citype(string)} sets the interval plot type:
{break}{cmd:rcap} - capped spikes (default), suited to few periods
{break}{cmd:rarea} - shaded band at reduced fill intensity, suited to many periods

{phang}
{opt overlay} places all groups on one axis. Requires {opt by()}.

{phang}
{opt level(#)} sets the confidence level.

{phang}
{it:twoway_options} are passed to {help twoway}. A user-specified {opt legend()} replaces
the default legend rather than colliding with it.


{marker remarks}{...}
{title:Remarks}

{pstd}
The interval describes the precision of the period mean, not the dispersion of {it:yvar}
within the period. For a series that already has one observation per period, or for
bounds produced by a model, a bootstrap, or any other method, build the graph with
{helpb twoway} directly.

{pstd}
Plot styles cycle {cmd:p1}-{cmd:p15}. Beyond fifteen groups, colours repeat.


{marker examples}{...}
{title:Examples}

{pstd}{bf:Mean capital stock per year, Grunfeld data}

{phang2}{cmd:. webuse grunfeld, clear}{p_end}
{phang2}{cmd:. tscigraph kstock year}{p_end}

{pstd}{bf:Shaded band at the 90% level}

{phang2}{cmd:. tscigraph kstock year, citype(rarea) level(90)}{p_end}

{pstd}{bf:Time variable taken from xtset}

{phang2}{cmd:. xtset company year}{p_end}
{phang2}{cmd:. tscigraph kstock}{p_end}

{pstd}{bf:Two groups overlaid}

{phang2}{cmd:. generate big = mvalue > 1000}{p_end}
{phang2}{cmd:. label define big 0 "Small firms" 1 "Large firms"}{p_end}
{phang2}{cmd:. label values big big}{p_end}
{phang2}{cmd:. tscigraph kstock year, by(big) overlay citype(rarea)}{p_end}

{pstd}{bf:Subgraph per group}

{phang2}{cmd:. tscigraph kstock year, by(big) title("Capital stock")}{p_end}


{marker results}{...}
{title:Stored results}

{pstd}
{cmd:tscigraph} stores nothing beyond what {helpb twoway} stores.


{marker author}{...}
{title:Author}

{pstd}
Emanuele Clemente{break}
University of Bari
emanueleclemente91@gmail.com
emanuele.clemente@uniba.it