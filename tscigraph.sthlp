{smcl}
{* *! version 1.2.0  06sep2026}{...}
{title:Title}

{phang}
{bf:tscigraph} {hline 2} Time series graph with confidence intervals and panel support


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd:tscigraph}
{it:yvar} {it:lb} {it:ub} [{it:timevar}]
{ifin}
[{cmd:,} {opt by(varname)} {opt citype(string)} {opt overlay} {it:twoway_options}]


{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{synopt :{opt by(varname)}}generate panel subgraphs or overlay series for each category of {it:varname}{p_end}
{synopt :{opt citype(string)}}confidence interval display type: {cmd:rcap} (default) or {cmd:rarea}{p_end}
{synopt :{opt overlay}}overlay all group series on a single plot axis, using group labels in the legend and excluding CI keys{p_end}
{synopt :{it:twoway_options}}any options allowed by {help twoway}{p_end}
{synoptline}


{marker description}{...}
{title:Description}

{pstd}
{cmd:tscigraph} creates a time series plot combining a line plot of {it:yvar} alongside confidence intervals
bounded by {it:lb} (lower bound) and {it:ub} (upper bound).

{pstd}
If {it:timevar} is not specified, {cmd:tscigraph} automatically uses the time variable set via {helpb tsset}
or {helpb xtset}. If no time variable is configured, observation indices ({cmd:_n}) are used. Confidence interval
keys ({it:lb}/{it:ub}) are automatically omitted from the legend.


{marker installation}{...}
{title:Installation}

{pstd}
To install {cmd:tscigraph} directly from GitHub in Stata:

{phang2}{cmd:. net install tscigraph, from("https://raw.githubusercontent.com/emawbgit/tscigraph/main") replace}{p_end}


{marker options}{...}
{title:Options}

{phang}
{opt by(varname)} specifies that series be generated for each value of {it:varname}. By default, separate panel subgraphs are created.

{phang}
{opt citype(string)} specifies the plot type for confidence intervals. Supported values are:
{break}{cmd:rcap} - capped spikes (default)
{break}{cmd:rarea} - shaded range area

{phang}
{opt overlay} overlays all group/panel series on a single plot axis rather than creating separate subgraphs per group.
Legend entries display each level or value label of {it:varname} and omit confidence interval keys.

{phang}
{it:twoway_options} options passed directly to {helpb twoway}, such as title, axis labels, legend, or graph schemes.


{marker examples}{...}
{title:Examples}

{pstd}
{bf:Example 1: Using native Grunfeld dataset}

{phang2}{cmd:. webuse grunfeld, clear}{p_end}
{phang2}{cmd:. generate lb = invest - 15}{p_end}
{phang2}{cmd:. generate ub = invest + 15}{p_end}
{phang2}{cmd:. tscigraph invest lb ub year if company <= 3, by(company)}{p_end}
{phang2}{cmd:. tscigraph invest lb ub year if company <= 3, by(company) overlay}{p_end}

{pstd}
{bf:Example 2: Simulated dataset with 5 countries over 40 years of monthly GDP data}

{phang2}{cmd:. clear}{p_end}
{phang2}{cmd:. set obs 2400}{p_end}
{phang2}{cmd:. egen country = seq(), block(480)}{p_end}
{phang2}{cmd:. egen mdate = seq(), f(1) t(480)}{p_end}
{phang2}{cmd:. replace mdate = ym(1984, 1) + mdate - 1}{p_end}
{phang2}{cmd:. format mdate %tm}{p_end}
{phang2}{cmd:. set seed 12345}{p_end}
{phang2}{cmd:. gen gdp = 100 + country*10 + rnormal(0, 5)}{p_end}
{phang2}{cmd:. gen lb = gdp - 2.5}{p_end}
{phang2}{cmd:. gen ub = gdp + 2.5}{p_end}
{phang2}{cmd:. tscigraph gdp lb ub mdate, by(country) overlay citype(rarea)}{p_end}


{marker author}{...}
{title:Author}

{pstd}
Emanuele Clemente
