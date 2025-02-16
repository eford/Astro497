~~~
<!-- PlutoStaticHTML.Begin -->
<!--
    # This information is used for caching.
    [PlutoStaticHTML.State]
    input_sha = "f6325d711e8a6f07d4cb7c15ab5bdcc058d2958aa7119662a05aea47194d4c6a"
    julia_version = "1.8.2"
-->

<div class="markdown"><h1>Exploratory Data Analysis</h1>
<p><strong>Astro 497: Week 2, Monday</strong></p>
<h2>Logistics</h2>
<ul>
<li><p>Added due dates for reading questions &#40;through mid-term exam&#41; onto Canvas</p>
</li>
<li><p>Lab 2</p>
<ul>
<li><p>Added link to create Lab 2 starter repository</p>
</li>
<li><p>Will be time to start working on during class</p>
</li>
<li><p>Let me know by end-of-business Tuesday if have any breakout room requests</p>
</li>
</ul>
</li>
<li><p>First COVID close contacts reported</p>
<ul>
<li><p>Thanks for being cautious</p>
</li>
<li><p>Recording today&#39;s class for student&#40;s&#41; who miss</p>
</li>
<li><p>Will start posting</p>
</li>
</ul>
</li>
</ul>
</div>


<div class="markdown"><h2>Overview</h2>
<ol>
<li><p>Choose data to explore </p>
</li>
<li><p>Ingest data</p>
</li>
<li><p>Validate data</p>
</li>
<li><p>Clean data</p>
</li>
<li><p>Describe/Visualize data</p>
</li>
<li><p>Identify potential relationships in data</p>
</li>
<li><p>Make a plan</p>
</li>
</ol>
</div>


<div class="markdown"><h2>Choose data to Explore</h2>
<h3>Classical Astronomy approach:</h3>
<ol>
<li><p>Choose scientific problem</p>
</li>
<li><p>Decide what data is needed</p>
</li>
<li><p>Request telescope time</p>
</li>
<li><p>Conduct observations</p>
</li>
<li><p>Ingest data you collect</p>
</li>
</ol>
<h3>Classical archival science approach:</h3>
<ol>
<li><p>Choose scientific problem</p>
</li>
<li><p>Decide what data is needed</p>
</li>
<li><p>Learn about/query multiple surveys/datasets that might have data to address your question. </p>
</li>
<li><p>Prioritize which to consider first</p>
</li>
<li><p>Query archive&#40;s&#41; to ingest data others collected.</p>
</li>
</ol>
<h3>Survey-science key-project approach:</h3>
<ol>
<li><p>Choose scientific problem</p>
</li>
<li><p>Decide what data is needed</p>
</li>
<li><p>Obtain funding</p>
</li>
<li><p>Build observatory, telescope, detector, software pipeline, archive, etc. to meet your specifications</p>
</li>
<li><p>Conduct survey &#40;observations, calibration, data reduction, archiving, etc.&#41;</p>
</li>
<li><p>Query database&#40;s&#41; to ingest data from survey</p>
</li>
<li><p>Release data to public</p>
</li>
</ol>
<h3>Survey-science ancillary science approach:</h3>
<ol>
<li><p>Identify exciting dataset&#40;s&#41;</p>
</li>
<li><p>Learn about how they were collected, limitations, uncertainties, biases, etc.</p>
</li>
<li><p>Decide if they has the potential to addres your science question</p>
</li>
<li><p>Query database&#40;s&#41; to ingest data others have collected</p>
</li>
</ol>
<h3>Many variations</h3>
<ul>
<li><p>Spectrum of approaches for how to identify questions/datasets</p>
</li>
<li><p>Combine survey, archival and targeted approaches to address a common question.</p>
</li>
</ul>
</div>


<div class="markdown"><h2>Ingest Data</h2>
<ul>
<li><p>Construct a query</p>
</li>
<li><p>Download the results of that query</p>
</li>
<li><p>Store the data locally</p>
</li>
<li><p>Read the data into memory.</p>
</li>
</ul>
</div>

<pre class='language-julia'><code class='language-julia'>tip(md"""
**Options for storing/organizing your data**
- Vectors, Matrices and higher-dimensional arrays:   
- DataFrames & Tables: reduces risk of bookkeeping errors
- Databases (e.g., multiple talbes of different lengths)
""")</code></pre>
<div class="markdown"><div class="admonition is-tip">
  <header class="admonition-header">
    Tip
  </header>
  <div class="admonition-body">
    <p><strong>Options for storing/organizing your data</strong></p>
  </div>
<ul>
<li><p>Vectors, Matrices and higher-dimensional arrays:   </p>
</li>
<li><p>DataFrames &amp; Tables: reduces risk of bookkeeping errors</p>
</li>
<li><p>Databases &#40;e.g., multiple talbes of different lengths&#41;</p>
</li>
</ul>

</div>
</div>


<div class="markdown"><h2>Validate Data</h2>
<ul>
<li><p>What is the size and shape of the data?</p>
</li>
<li><p>What are the types of data?</p>
</li>
<li><p>What are the ranges of values?</p>
</li>
<li><p>Is there missing data?</p>
</li>
<li><p>Check if a representative subset of the data is consistent with expectations.</p>
</li>
<li><p>Are some entries suspiciously discrepant from expectations/other data?</p>
</li>
<li><p>What is the approximate empirical distribution of value?</p>
</li>
<li><p>Are values self-consistent?</p>
</li>
</ul>
</div>


<div class="markdown"><h2>Clean Data</h2>
<p>Are some data values:</p>
<ul>
<li><p>missing?</p>
</li>
<li><p>clearly erroneous? </p>
</li>
<li><p>susipicously discrepant from expectations?</p>
</li>
<li><p>susipicously discrepant from other data?</p>
</li>
</ul>
</div>

<pre class='language-julia'><code class='language-julia'>tip(md"""
**Any large dataset is likely to have some suspicious data!**
- Could these issues affect my analysis?
- Could these values interfere even exploratory data analysis?
- Should I try to understand my data source better before I proceed?
- Should I fix the issues now or proceed with caution?
   - 80%/20% rule
- If proceeding, how will I make sure that I (and my team) don't forget these concerns?
""")</code></pre>
<div class="markdown"><div class="admonition is-tip">
  <header class="admonition-header">
    Tip
  </header>
  <div class="admonition-body">
    <p><strong>Any large dataset is likely to have some suspicious data&#33;</strong></p>
  </div>
<ul>
<li><p>Could these issues affect my analysis?</p>
</li>
<li><p>Could these values interfere even exploratory data analysis?</p>
</li>
<li><p>Should I try to understand my data source better before I proceed?</p>
</li>
<li><p>Should I fix the issues now or proceed with caution?</p>
<ul>
<li><p>80&#37;/20&#37; rule</p>
</li>
</ul>
</li>
<li><p>If proceeding, how will I make sure that I &#40;and my team&#41; don&#39;t forget these concerns?</p>
</li>
</ul>

</div>
</div>


<div class="markdown"><h2>Describe/Visualize Data</h2>
<ul>
<li><p>Location: mean, median, mode</p>
</li>
<li><p>Scale: standard deviation, quantiles, bounds</p>
</li>
<li><p>Higher-order moments:  skewness, kurtosis, behavior of tails</p>
</li>
<li><p>Transformations </p>
<ul>
<li><p>Linear transformations &#40;shift, scale, rotate&#41;</p>
</li>
<li><p>Non-linear transformations for visualization &#40;e.g., log, sqrt&#41;</p>
</li>
<li><p>Power transforms to standardize distributions &#40;e.g., Box-Cox transform&#41;  </p>
</li>
</ul>
</li>
<li><p>Ohter strategies</p>
<ul>
<li><p>Clamping data to limit effects of outliers</p>
</li>
<li><p>Imputing missing data to allow for fast exploratory analysis</p>
</li>
</ul>
</li>
<li><p>Statistical tests</p>
<ul>
<li><p>Test for normality</p>
</li>
</ul>
</li>
</ul>
</div>


<div class="markdown"><h2>Identify potential relationships in Data</h2>
<p>Look for relationships between values:</p>
<ul>
<li><p>For each object</p>
</li>
<li><p>Across objects</p>
</li>
<li><p>In space</p>
</li>
<li><p>In time</p>
</li>
</ul>
<h3>Statistics</h3>
<ul>
<li><p>Correlation coefficients</p>
</li>
<li><p>Rank correlation coefficient</p>
</li>
<li><p>Dangers of statistics</p>
</li>
</ul>
<h3>Visualizations</h3>
<ul>
<li><p>Scatter plot </p>
</li>
<li><p>2-d histograms or density estimates</p>
</li>
<li><p>Limitations of visualizations</p>
</li>
</ul>
</div>


<div class="markdown"><h2>Make a Plan</h2>
<ul>
<li><p>Is this question/dataset combination worthy of more of my time?</p>
</li>
<li><p>Should I consider combining with other dataset&#40;s&#41; to fill gaps?</p>
</li>
<li><p>What needs to done before begining quantiative analysis?</p>
</li>
<li><p>What apparent relationships should be evaluted quantiatively?</p>
</li>
<li><p>What potential concerns should be kept in mind? </p>
</li>
</ul>
</div>


<div class="markdown"><h1>Helper Code</h1>
</div>

<pre class='language-julia'><code class='language-julia'>ChooseDisplayMode()</code></pre>
<!-- https://github.com/fonsp/Pluto.jl/issues/400#issuecomment-695040745 -->
<input
        type="checkbox"
        id="width-over-livedocs"
        name="width-over-livedocs"
    onclick="window.plutoOptIns.toggle_width(this)"
        >
<label for="width-over-livedocs">
        Full Width Mode
</label>
<style>
        body.width-over-docs #helpbox-wrapper {
        display: none !important;
        }
        body.width-over-docs main {
               max-width: none !important;
               margin: 0 !important;
                #max-width: 1100px;
                #max-width: calc(100% - 4rem);
                #align-self: flex-star;
                #margin-left: 50px;
                #margin-right: 2rem;
        }
</style>
<script>
        const toggle_width = function(t) {
                t.checked
                ? document.body.classList.add("width-over-docs")
                : document.body.classList.remove("width-over-docs") }
        window.plutoOptIns = window.plutoOptIns || {}
        window.plutoOptIns.toggle_width = toggle_width
        
</script>
&nbsp; &nbsp; &nbsp;
<input
        type="checkbox"
        id="present-mode"
        name="present-mode"
        onclick="present()"
        >
<label for="present_mode">
        Present Mode
</label>



<pre class='language-julia'><code class='language-julia'>TableOfContents(aside=true)</code></pre>
<script>const getParentCell = el => el.closest("pluto-cell")

const getHeaders = () => {
	const depth = Math.max(1, Math.min(6, 3)) // should be in range 1:6
	const range = Array.from({length: depth}, (x, i) => i+1) // [1, ..., depth]
	
	const selector = range.map(i => `pluto-notebook pluto-cell h${i}`).join(",")
	return Array.from(document.querySelectorAll(selector))
}

const indent = true
const aside = true

const clickHandler = (event) => {
	const path = (event.path || event.composedPath())
	const toc = path.find(elem => elem?.classList?.contains?.("toc-toggle"))
	if (toc) {
		event.stopImmediatePropagation()
		toc.closest(".plutoui-toc").classList.toggle("hide")
	}
}

document.addEventListener("click", clickHandler)


const render = (el) => html`${el.map(h => {
	const parent_cell = getParentCell(h)

	const a = html`<a 
		class="${h.nodeName}" 
		href="#${parent_cell.id}"
	>${h.innerText}</a>`
	/* a.onmouseover=()=>{
		parent_cell.firstElementChild.classList.add(
			'highlight-pluto-cell-shoulder'
		)
	}
	a.onmouseout=() => {
		parent_cell.firstElementChild.classList.remove(
			'highlight-pluto-cell-shoulder'
		)
	} */
	a.onclick=(e) => {
		e.preventDefault();
		h.scrollIntoView({
			behavior: 'smooth', 
			block: 'start'
		})
	}

	return html`<div class="toc-row">${a}</div>`
})}`

const tocNode = html`<nav class="plutoui-toc">
	<header>
     <span class="toc-toggle open-toc">📖</span>
     <span class="toc-toggle closed-toc">📕</span>
	Table of Contents</header>
	<section></section>
</nav>`

tocNode.classList.toggle("aside", aside)
tocNode.classList.toggle("indent", indent)

const updateCallback = () => {
	tocNode.querySelector("section").replaceWith(
		html`<section>${render(getHeaders())}</section>`
	)
}
updateCallback()
setTimeout(updateCallback, 100)
setTimeout(updateCallback, 1000)
setTimeout(updateCallback, 5000)

const notebook = document.querySelector("pluto-notebook")


// We have a mutationobserver for each cell:
const observers = {
	current: [],
}

const createCellObservers = () => {
	observers.current.forEach((o) => o.disconnect())
	observers.current = Array.from(notebook.querySelectorAll("pluto-cell")).map(el => {
		const o = new MutationObserver(updateCallback)
		o.observe(el, {attributeFilter: ["class"]})
		return o
	})
}
createCellObservers()

// And one for the notebook's child list, which updates our cell observers:
const notebookObserver = new MutationObserver(() => {
	updateCallback()
	createCellObservers()
})
notebookObserver.observe(notebook, {childList: true})

// And finally, an observer for the document.body classList, to make sure that the toc also works when if is loaded during notebook initialization
const bodyClassObserver = new MutationObserver(updateCallback)
bodyClassObserver.observe(document.body, {attributeFilter: ["class"]})

// Hide/show the ToC when the screen gets small
let m = matchMedia("(max-width: 1000px)")
let match_listener = () => 
	tocNode.classList.toggle("hide", m.matches)
match_listener()
m.addListener(match_listener)

invalidation.then(() => {
	notebookObserver.disconnect()
	bodyClassObserver.disconnect()
	observers.current.forEach((o) => o.disconnect())
	document.removeEventListener("click", clickHandler)
	m.removeListener(match_listener)
})

return tocNode
</script><style>@media not print {

.plutoui-toc {
	--main-bg-color: unset;
	--pluto-output-color: hsl(0, 0%, 36%);
	--pluto-output-h-color: hsl(0, 0%, 21%);
}

@media (prefers-color-scheme: dark) {
	.plutoui-toc {
		--main-bg-color: hsl(0deg 0% 21%);
		--pluto-output-color: hsl(0, 0%, 90%);
		--pluto-output-h-color: hsl(0, 0%, 97%);
	}
}

.plutoui-toc.aside {
	color: var(--pluto-output-color);
	position:fixed;
	right: 1rem;
	top: 5rem;
	width: min(80vw, 300px);
	padding: 10px;
	border: 3px solid rgba(0, 0, 0, 0.15);
	border-radius: 10px;
	box-shadow: 0 0 11px 0px #00000010;
	/* That is, viewport minus top minus Live Docs */
	max-height: calc(100vh - 5rem - 56px);
	overflow: auto;
	z-index: 40;
	background-color: var(--main-bg-color);
	transition: transform 300ms cubic-bezier(0.18, 0.89, 0.45, 1.12);
}

.plutoui-toc.aside.hide {
	transform: translateX(calc(100% - 28px));
}
.plutoui-toc.aside.hide section {
	display: none;
}
.plutoui-toc.aside.hide header {
	margin-bottom: 0em;
	padding-bottom: 0em;
	border-bottom: none;
}
}  /* End of Media print query */
.plutoui-toc.aside.hide .open-toc,
.plutoui-toc.aside:not(.hide) .closed-toc,
.plutoui-toc:not(.aside) .closed-toc {
	display: none;
}

@media (prefers-reduced-motion) {
  .plutoui-toc.aside {
    transition-duration: 0s;
  }
}

.toc-toggle {
	cursor: pointer;
	padding: 1em;
	margin: -1em;
    margin-right: -0.7em;
}

.plutoui-toc header {
	display: block;
	font-size: 1.5em;
	margin-top: -0.1em;
	margin-bottom: 0.4em;
	padding-bottom: 0.4em;
	margin-left: 0;
	margin-right: 0;
	font-weight: bold;
	border-bottom: 2px solid rgba(0, 0, 0, 0.15);
}

.plutoui-toc section .toc-row {
	white-space: nowrap;
	overflow: hidden;
	text-overflow: ellipsis;
	padding-bottom: 2px;
}

.highlight-pluto-cell-shoulder {
	background: rgba(0, 0, 0, 0.05);
	background-clip: padding-box;
}

.plutoui-toc section a {
	text-decoration: none;
	font-weight: normal;
	color: var(--pluto-output-color);
}
.plutoui-toc section a:hover {
	color: var(--pluto-output-h-color);
}

.plutoui-toc.indent section a.H1 {
	font-weight: 700;
	line-height: 1em;
}

.plutoui-toc.indent section a.H1 {
	padding-left: 0px;
}
.plutoui-toc.indent section a.H2 {
	padding-left: 10px;
}
.plutoui-toc.indent section a.H3 {
	padding-left: 20px;
}
.plutoui-toc.indent section a.H4 {
	padding-left: 30px;
}
.plutoui-toc.indent section a.H5 {
	padding-left: 40px;
}
.plutoui-toc.indent section a.H6 {
	padding-left: 50px;
}
</style>

<pre class='language-julia'><code class='language-julia'>begin
    using PlutoUI, PlutoTeachingTools
end</code></pre>

<div class='manifest-versions'>
<p>Built with Julia 1.8.2 and</p>
PlutoTeachingTools 0.1.5<br>
PlutoUI 0.7.39
</div>

<!-- PlutoStaticHTML.End -->
~~~

_To run this tutorial locally, download [this file](/notebooks/week2day1.jl) and open it with
[Pluto.jl](https://plutojl.org)._


_To run this tutorial locally, download [this file](/notebooks/week2day1.jl) and open it with
[Pluto.jl](https://plutojl.org)._


_To run this tutorial locally, download [this file](/notebooks/week2day1.jl) and open it with
[Pluto.jl](https://plutojl.org)._
