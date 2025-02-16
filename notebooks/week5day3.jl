### A Pluto.jl notebook ###
# v0.19.11

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
end

# ╔═╡ d1caecb5-346a-47b5-9ccc-6c4df5be7e60
begin
	using Transits
	using Distributions, StatsPlots # For questions
	using Plots, ColorSchemes
	using PlutoUI, PlutoTeachingTools
end

# ╔═╡ c3bf9feb-b047-469e-b043-18cfb69e66c7
md"""
# Orbital Inclinations
**Astro 497, Week 5, Friday**
"""

# ╔═╡ faca0b2c-e19a-4246-93dc-a6baa7a9718a
TableOfContents()

# ╔═╡ 76819951-3f3c-4adc-989f-04435b4ae060
md"""
# Questions
"""

# ╔═╡ e20c11e9-0df9-42b1-a531-914bfbb5ef7a
md"""
Degrees of Freedom for Student-t distribution: $(@bind dof_t Slider(2:0.5:20, default=4)) 
"""

# ╔═╡ 26c2ef9e-abc7-4c93-83e9-217dc0f74dae
let 
	plt = plot(xlabel="x", ylabel="pdf(x)", xlims=(-6,6))
	plot!(plt, Normal(0,1), label="Normal")
	plot!(plt, TDist(dof_t), label="Student-t dof=" * string(dof_t))
end

# ╔═╡ 85f01e40-d3d8-418c-99a4-e28cbe1b7b2e
md"""
Standard Deviation of t-Distribution w/ $dof_t degrees of freedom: $(round(std(TDist(dof_t)),sigdigits=5))
"""

# ╔═╡ 2fdaac21-0079-4c08-8d72-aecb6981889f
md"""
Fraction in Std Normal: $(@bind frac_in_std_normal Slider(0:0.1:1)) 
Scale Factor for outliers: $(@bind σ_outliers Slider(1:10))
"""

# ╔═╡ 697092dc-96f3-4f99-8e48-3919370d4125
let
	plt = plot(xlabel="x", ylabel="pdf(x)", xlims=(-5,5))
	plot!(plt, Normal(0,1), label="Normal")
		
	mix = MixtureModel(Normal[Normal(0.0, 1), Normal(0.0, σ_outliers)],
						[frac_in_std_normal, 1-frac_in_std_normal])
	x = -5:0.05:5
	plot!(plt, x, pdf.(mix,x), label="α N(0,1) + (1-α) N(0,σ)")
end

# ╔═╡ e3bdc4d2-f752-4be4-8bc9-7f5c69b8448d
md"""
Consider estimating mean and variance of a set of random normal variables, $x_i \sim N(\mu,\sigma^2)$ for $i\in 1...n$, with unknown mean and known variance.

The standard estimate of the mean would be $\bar{x_i} = \frac{1}{n} \sum_{i=1}^n x_i$.  But what if we had some prior knowledge about $\mu$?
If we adopt a prior 

$p(\mu) \sim N(\mu_0,\sigma_o^2),$ 

then the posterior for $x$ is
```math
p(\mu | x_i ) = N\left( 
		\frac{1}{\frac{1}{\sigma_o^2}+\frac{n}{\sigma^2}}  \left(\frac{\mu_0}{\sigma_o^2}+\frac{n \bar{x_i}}{\sigma^2}\right),
   		\left(\frac{1}{\sigma_o^2}+\frac{n}{\sigma^2}\right)^{-1}
	\right)
```
"""

# ╔═╡ d973ac70-5a8a-499c-9ba7-9cfab21ae012
md"""
prior mean: $(@bind μ₀ NumberField(0:0.2:5, default=1))
prior σ: $(@bind σ₀ NumberField(0.1:0.1:20, default=5))
true mean: $(@bind μ_true NumberField(0:0.2:5, default=1))
true σ: $(@bind σ NumberField(0.2:0.2:20, default=1))
"""

# ╔═╡ 2eafb469-92e8-4c96-93f6-38f5c77c3e84
begin
	ndraw = 100
	x_bayes_sample = μ_true .+ σ .* randn(ndraw)
end	;

# ╔═╡ dce22b0e-753e-4beb-a936-37bcf8c470a6
@bind n_bayes_plt NumberField(1:ndraw,default=1)

# ╔═╡ c3de61c9-5172-4004-9918-6f1f4fb4c842
begin
	sum_xs = sum(view(x_bayes_sample,1:n_bayes_plt))
	prefac = 1/(1/σ₀^2+n_bayes_plt/σ^2) 
	μ_post =  prefac*(μ₀/σ₀^2+sum_xs/σ^2)
	σ_post =  sqrt(prefac)
	prior = Normal(μ₀,σ₀)
	true_dist = Normal(μ_true,σ)
	posterior = Normal(μ_post,σ_post)
end;

# ╔═╡ 573698fa-7fe1-49db-8169-28919cdaecf7
let
	max_xplt = 10
	min_x_plt = μ_true-5*σ
	max_x_plt = μ_true+5*σ
	plt = plot(xlims=(min_x_plt,max_x_plt))
	xplt = -max_xplt:0.05:max_xplt
	plot!(plt, xplt, pdf.(prior,xplt), label="Prior")
	plot!(plt, xplt, pdf.(posterior,xplt), label="Posterior")
	plot!(plt, xplt, pdf.(true_dist,xplt), label="True distribution")
	plot!(plt,fill(sum_xs/n_bayes_plt,2), [0,ylims(plt)[2]], label="Mean xᵢ's")
end

# ╔═╡ a75f7af6-83cf-4201-8663-d5906e33fa5c
md"""
Show alternative periodicities:  $nbsp $nbsp 
P/2 $(@bind show_Po2 CheckBox())
2P $(@bind show_2P CheckBox())  $nbsp $nbsp 
3P $(@bind show_3P CheckBox())  $nbsp $nbsp 
$(@bind redraw_points Button("Redraw points"))
"""

# ╔═╡ 2a92b42b-21be-46e5-9172-88f61dd262ea
begin
	xmax = 10
	max_num_points = 100
end;

# ╔═╡ df2079a4-f89e-4645-8917-d2a62ed4ff55
md"""
Number of observations $(@bind num_obs NumberField(1:max_num_points))
"""

# ╔═╡ c1228db0-5dfd-46fd-b471-26cb563b6072
begin
	x_alias_plt = range(0,stop=xmax, step=0.05)
	y1 = cos.(2π.*x_alias_plt)
	xs = xmax.*rand(max_num_points)
	redraw_points 
end;

# ╔═╡ 57197cb0-1ff6-40f1-9225-aa5a259ab2aa
let
	x = x_alias_plt
	plt = plot(x, y1, lweight=2, label= "P")
	if show_2P
		y2 = cos.(4π.*x)
		plot!(plt, x, y2, linestyle=:dot, linecolor=2, label= "2P")
		ys = cos.(4π.*xs)
		scatter!(plt, xs[1:num_obs], ys[1:num_obs],  markercolor=2,  label= "2P")
	end
	if show_3P
		y3 = cos.(6π.*x)
		plot!(plt, x, y3, linestyle=:dot, linecolor=3, label= "3P")
		ys = cos.(6π.*xs)
		scatter!(plt, xs[1:num_obs], ys[1:num_obs],  markercolor=3,  label= "3P")
	end
	if show_Po2
		y1o2 = cos.(π.*x)
		plot!(plt, x, y1o2, linestyle=:dot, linecolor=4, label= "P/2")
		ys = cos.(π.*xs)
		scatter!(plt, xs[1:num_obs], ys[1:num_obs],  markercolor=4,  label= "P/2")
	end
	plt
end

# ╔═╡ 6f120424-f4e6-4b4e-a216-c97b8ae4e77e
md"""
- Fourier Transform
$S(f)=\int _{-\infty }^{\infty }s(t)\cdot e^{-i2\pi ft}\,dt$

- Discrete Fourier Transform
$X_k = \sum_{n=0}^N x_n e^{-\frac{i2\pi k n }{N}}$

- Periodogram
$\mathcal{P}(P) = \mathrm{argmax}_{\theta - P} \; \ell(\theta | \mathrm{data} )$ 
"""

# ╔═╡ d9ebea32-ec97-4a16-b3fa-abd5393b9b9a
TwoColumn(md"""
A true Doppler shift due to reflex motion from a single planet:
- Results in a simple shift of the spectrum
- Causes all lines to shift by an equal $\Delta\lambda/\lambda$
- Is strictly periodic with constant amplitude.
- Is strictly periodic with constant period & phase.
""",
md"""
Spurious RV measurements due to stellar variability:
- Affects line depths & shapes
- Affects some lines more than others
- Changes in magnitude with time
- May be quaesiperiodic (e.g., rotation), but not strictly periodic.
""")

# ╔═╡ 15727a3d-b305-43c5-a1a6-e76ba224428e
md"""
Traditional stellar activity indicators:
- Ca II H & K emission ($R'_{HK}$ or $S$)
- H $\alpha$ \emission
"""

# ╔═╡ 3b3bb91b-acf2-4e60-82a1-b7dc09222474
md"""
$(LocalResource("../_assets/week5/CaIIHK.png"))
Credit: [NEID Data Reduction Pipeline documentation](https://neid.ipac.caltech.edu/docs/NEID-DRP/algorithms.html#stellar-activity-info).
"""

# ╔═╡ cae9b7a3-a12a-42ba-ac71-8af0edb2bdba
md"""
Other Commons spectroscopic indicators:
- CCF depth or full width half maximum (FWHM)
- CCF Bisector velocity span
- CCF Bisector shape (e..g, slope between two points)
- Data-driven variability indicators
"""

# ╔═╡ 3f3f9c95-aeaa-478e-b199-8522e3beae53
md"""
$(LocalResource("../_assets/week5/ccf_spot.png"))
Credit: Hara & Ford (2022) ARAS, in press.
"""

# ╔═╡ 3c3fa58f-6500-4943-9934-3d04fdc5f4b4
md"""
# Rossiter-McLaughlin Effect
"""

# ╔═╡ 3ab9ca68-b7c9-4f1f-af39-8374d1cf10ff
md"""
## Resolved Stellar Disk
"""

# ╔═╡ 61ddefa1-6e30-465f-8b7d-ed0a52880d0a
md"""
## Interactive Plot
"""

# ╔═╡ dfc344a0-cd15-42bb-b76c-4f7a07a8421f
md"""
Time $(@bind t_plt Slider(-0.06:0.001:0.06, default=0))
b $(@bind b_plt Slider(0:0.05:1, default=0))
Ω $(@bind Ω_plt Slider(0:π/100:π, default=0))
Rₚ/R⋆ $(@bind r_ratio_plt NumberField(0.005:0.005:0.15,default=0.1))
"""

# ╔═╡ cff93461-b079-4894-afc9-4439f53a8deb
md"""
## Animations
"""

# ╔═╡ 7ae2f85e-52c4-4db3-9bf0-a509010b8e6a
@bind i_frame Clock(0.25, false)

# ╔═╡ 20019990-a424-445d-96ec-39cd6278cdc6
md"""
## Geometry of RM Measurements
"""

# ╔═╡ 6fc1ca2c-709f-4b1f-af98-5af84cd82784
LocalResource("../_assets/week5/figures/geometry.png")

# ╔═╡ 0eb53eea-289d-4f87-a3dc-747ff791e019
md"""
# Results of Rossiter-McLaughlin Observations
"""

# ╔═╡ d127279b-8f5c-47fd-83b2-601ed9a8a2d0
LocalResource("../_assets/week5/figures/Albrecht+2021_fig4.png")

# ╔═╡ 54a35812-22ad-49e2-bca2-8f80c6c47379
md"""
### Projected Obliquity vs Host Star Temperature
$(LocalResource("../_assets/week5/figures/teff_projected_obliquity_vsini.png"))
"""

# ╔═╡ fc00489e-7355-4c38-852e-538511806d85
md"""
### Projected Obliquity vs Host Star Age
$(LocalResource("../_assets/week5/figures/age_projected_obliquity.png"))
"""

# ╔═╡ 7ec579f4-dfbc-4320-af05-422391519aac
md"""
## Projected Obliquity vs Planet-Star Mass Ratio
$(LocalResource("../_assets/week5/figures/mass_ratio_projected_obliquity.png"))
"""

# ╔═╡ b4ed9eff-96f4-4f9f-94d4-6e9e23c02ec4
md"""
## Projected Obliquity vs Orbital Separation
$(LocalResource("../_assets/week5/figures/ar_projected_obliquity.png"))
"""

# ╔═╡ d52ded9c-4d01-4a48-94f7-d1002a2351ec
md"""
## Potential Formation Mechanisms
"""

# ╔═╡ 5f962986-00ad-4c8d-b440-885e34c2b471
LocalResource("../_assets/week5/figures/misalign_cartoon_darker.png")

# ╔═╡ d7b57c40-2cc7-4e7d-b21d-ff380218fcf4
md"""
Credit: [Albrecht, Dawson & Winn (2022)](https://ui.adsabs.harvard.edu/abs/2022PASP..134h2001A/abstract) 
[![CC-BY ](https://arxiv.org/icons/licenses/by-4.0.png)](http://creativecommons.org/licenses/by/4.0/)
"""

# ╔═╡ 17bcf51c-311c-4bc3-a464-03253a8d89a9
md"""
# Helper Code
"""

# ╔═╡ 41c71d22-163e-4ea2-b511-9f9c129253e6
ChooseDisplayMode()

# ╔═╡ ef38c415-e2e0-47a7-97ea-18268a960fea
#LocalResource("../_assets/week5/WinnFig8a.png")

# ╔═╡ 45decf90-9e71-4c9a-a2c3-2123c5047066
#LocalResource("../_assets/week5/WinnFig8b.png")

# ╔═╡ 26722319-eeb5-406f-bd64-e43a7375a4db
md"""
Credit: Fig 8 of [Winn & Fabrycky (2015) ARA&A 53, 409.](https://ui.adsabs.harvard.edu/abs/2015ARA%26A..53..409W/abstract)
"""

# ╔═╡ b34fa8df-87da-49fc-b0ac-f038f4c8612e
question(str; invite="Question") = Markdown.MD(Markdown.Admonition("tip", invite, [str]))

# ╔═╡ 7faa640f-a4a5-4b4e-aefe-15d9c1b37e06
question(md"""
What models other than Gaussian distributions are used for noise?
""")

# ╔═╡ c531d869-9aa4-410e-a0b4-a5149e1216e9
question(md"""
Do traditional methods and Bayesian methods yield the same results? Or, is one preferred over the other in terms of reliability and accuracy?
""")

# ╔═╡ 7323edea-b329-48c3-9dc0-89a4461a90e7
question(md"""From my understanding of periodograms, you are able to detect half periods, double periods, and even triple or quad periods.  Explain.""")

# ╔═╡ c84b73f2-252e-4266-96b1-9cb7323e5494
question(md"""Is there a difference between a periodogram and a fourier transform, and if there is, what is the advantage of finding planets using a periodogram as opposed to a fourier transform?""")

# ╔═╡ 85808945-e389-474a-a9e6-50ea5cedef95
question(md"""
- How can you remove the effects of stellar processes effects on RV on the data?
- What are ancillary indicators? 
""")

# ╔═╡ 6c0df45a-da40-4188-8149-124ab6c03038
question(md"""Would using space telescopes significantly improve data analysis?""")

# ╔═╡ 88e908e6-933d-4192-9ad2-c7802d038287
md"""
## Parameters
"""

# ╔═╡ 0589435c-25c8-44a8-8bb8-f159740ad59b
begin
	gridsize = min(100,round(Int64,8*(1/r_ratio_plt)))
	figsize = 400
	bigfigsize = 800
end

# ╔═╡ 39832015-1380-4a19-b35b-47a23a88b3bd
begin
	num_times_anim = 100
	num_times_movie = 200
	t_anim = range(-0.06, 0.06, length=num_times_anim) # days from t0
	t_movie = range(-0.06, 0.06, length=num_times_movie) # days from t0
end

# ╔═╡ 6bc459bc-62ec-4faf-8294-348ac499df60
begin
	u = [0.4, 0.26] # quad limb dark
	ld = PolynomialLimbDark(u)
end

# ╔═╡ cbbda00c-1d81-4e96-baea-368bd9d7d19b
md"""
## Precompute maps
"""

# ╔═╡ 3a9968c1-d259-4287-8147-0e35b8e9dffd
md"""
## Science Functions
"""

# ╔═╡ a045edac-c3b5-435c-bcf3-f13586af0734
function I(x::Real, y::Real; radius_ratio=1)
	r = sqrt(x^2+y^2)
	if r>1 return 0 end #missing end
	μ = cos(asin(r))
	ld(μ, radius_ratio)	
end

# ╔═╡ 806f9a87-3572-4d92-acd6-73e954609731
function rv_patch(x::Real, y::Real)
	r = sqrt(x^2+y^2)
	if r>1 return 0 end # missing end
	Rsol = 696_340_000
	sec_per_day = 24*60^2
	A = 14.713 
	B = -2.396
	C = -1.787
	vsini = (π/180) / sec_per_day * Rsol
	#sinφ = y
	#vsini *= (A + B * sinφ^2 + C * sinφ^4)
	vsini *= A # + B * sinφ^2 + C * sinφ^4)
	x*vsini
end

# ╔═╡ d16da790-8bbf-4f3c-8bf4-b6748418e813
begin
	x_plt = -1:(1//gridsize):1
	y_plt = -1:(1//gridsize):1
	grid_I = [ I(x,y) for x in x_plt, y in y_plt ]
	grid_rv = [rv_patch(x,y) for x in x_plt, y in y_plt ]
	sum_grid_I = sum(grid_I)
	grid_Irv = grid_I .* grid_rv ./ sum_grid_I
end;

# ╔═╡ b359a1f4-2f8a-4c19-8d13-966efb09d71e
heatmap(x_plt,y_plt,grid_I',clims=(0,1), size=(bigfigsize,bigfigsize), title="Intensity") 

# ╔═╡ 484dcad2-d4dd-4786-ae93-9dedf70cb754
heatmap(x_plt,y_plt,grid_rv',seriescolor=cgrad(ColorSchemes.balance), size=(bigfigsize,bigfigsize), title="RV") 

# ╔═╡ 0ecea71d-8e92-4d6a-91b5-6c2fc31327a5
heatmap(x_plt,y_plt,grid_Irv'.*gridsize^2,seriescolor=cgrad(ColorSchemes.balance), size=(bigfigsize,bigfigsize), title="Contribution to RV") 

# ╔═╡ 347a56d2-5bff-485a-aa70-a4fbf8beb430
begin
	workspace_map = zeros(size(grid_Irv))
	workspace_map_spectrum = zeros(size(grid_Irv))
	workspace_spectra = zeros(length(x_plt))
end;

# ╔═╡ cd9cca6c-aa26-4669-8659-bf604ba71680
v_grid = rv_patch.(x_plt,0.);

# ╔═╡ 375994ff-08ed-4c39-8938-dd1c92b91ea2
function get_iter_to_change(x,y,r, grid)
	x_lo = searchsortedfirst(grid,x-r-0.5*grid.step)
	x_hi = searchsortedlast(grid,x+r+0.5*grid.step)
	y_lo = searchsortedfirst(grid,y-r-0.5*grid.step)
	y_hi = searchsortedlast(grid,y+r+0.5*grid.step)
	Iterators.product(x_lo:x_hi, y_lo:y_hi)
end

# ╔═╡ 5065bcff-0307-4c20-a95b-fec7c046f181
begin
function planet_mask(x::Real, y::Real, xx::Real,yy::Real,r::Real)
	(xx-x)^2+(yy-y)^2<r^2 ? 0 : 1
end
function planet_mask(t, orbit::Transits.Orbits.AbstractOrbit, r; grid::AbstractVector = x_plt)
	x,y,z = Orbits.relative_position(orbit,t)
	[ planet_mask(x,y, xx,yy,r) for xx in grid, yy in grid ]
end
end

# ╔═╡ 3d297ed9-19b1-40e7-aed3-a269192dcf5a
function calc_map_inplace!(map, t, grid, orb, r_ratio)
	#map .= grid.*planet_mask(t,orb,r_ratio)
	x,y,z = Orbits.relative_position(orb,t)
	iter = get_iter_to_change(x,y,r_ratio, x_plt)
	map .= grid
	for (i,j) in iter
		map[i,j] = grid[i,j]*planet_mask(x,y,x_plt[i],y_plt[j], r_ratio)
	end
	map
end

# ╔═╡ 15bcb6e7-a9c1-41ee-a5b2-0d8468b5bcd1
function calc_rv_inplace(t, grid_Irv, orb, r_ratio, map=workspace_map)
	calc_map_inplace!(map, t, grid_Irv, orb, r_ratio)
	sum(map)
end

# ╔═╡ 2957f299-5304-429d-90f5-04142ff497a9
function calc_spectra_inplace!(spectrum, t, grid_I, orb, r_ratio, map=workspace_map_spectrum) 
	calc_map_inplace!(map, t, grid_I, orb, r_ratio)
	spectrum .= sum(map,dims=2)
end

# ╔═╡ ccbdce5a-ca45-4e61-bca4-af79addfbacf
function calc_all(t, orbit)
	rv = calc_rv_inplace(t, grid_Irv, orbit, r_ratio_plt)
	calc_spectra_inplace!(workspace_spectra, t, grid_I, orbit, r_ratio_plt, workspace_map_spectrum) 
	rv
end

# ╔═╡ 86dbb15c-22d4-483f-9955-5a4efb75535d
md"""
## Plotting functions
"""

# ╔═╡ 3c8d81fc-d2de-49cc-ac9d-b689723d5eeb
function plot_star_weighted_rv(t)
	plt = plot(xlims=(-1,1), ylims=(-1,1), size=(figsize,figsize), legend=:none);
	plt = heatmap!(plt,x_plt,y_plt,workspace_map',seriescolor=cgrad(ColorSchemes.balance))
end

# ╔═╡ c6ba7854-73e7-4fd5-85a0-154579dd708a
function plot_spectrum_frame(t)
	plot(v_grid, 1 .-workspace_spectra./sum(workspace_spectra), xlabel="v (m/s)", ylabel="Flux", legend=:none, size=(figsize,figsize//2))
end

# ╔═╡ 3c95bd05-135b-4c92-9ed8-7ba4d0db155a
function plot_rm_frame(t, rv, path_rv)
	plt = plot(t_anim.*24,path_rv, size=(figsize,figsize//2), label=:none)
	xlabel!(plt,"Time (hr)")
	ylabel!(plt,"ΔRV (m/s)")
	scatter!(plt,[t*24],[rv], mc=:blue, label=:none)
end

# ╔═╡ f594e0b5-bf25-44fb-93ca-14872b90841d
begin
	period_in_days = 3
	orbit = KeplerianOrbit(period=period_in_days, t0=0, b=b_plt, Omega=Ω_plt )
	rv_plt = calc_all(t_plt, orbit)
	fluxes = @. ld(orbit, t_anim, r_ratio_plt)

	plt_star = plot_star_weighted_rv(t_plt)
	plot!(plt_star,map(tt->Orbits.relative_position(orbit,tt)[1],t_anim),map(tt->Orbits.relative_position(orbit,tt)[2],t_anim), size=(figsize,figsize), color=:black)
	title!(plt_star,"Weighted RV w/ Planet")
	
	plt_spectrum = plot_spectrum_frame(t_plt)
	
	path_rv = map(tt->calc_rv_inplace(tt,grid_Irv,orbit,r_ratio_plt),t_anim);
	plt_rm = plot_rm_frame(t_plt,rv_plt,path_rv)
end;

# ╔═╡ af076195-9083-4147-af74-081cd43eaa76
plt_star

# ╔═╡ b1cd4ae5-657e-4c05-9fe7-e63f5992fc56
title!(plt_spectrum,"Absorption Line Profile")

# ╔═╡ 47ac1992-51c9-4d80-b6a0-2d16c253ccac
title!(plt_rm,"Rossiter-McLaughlin Effect\nOn Measured RV")

# ╔═╡ 3a938f17-9890-4ebd-ab96-f16cee2b7bf5
begin
	plot(t_anim.*24, fluxes, label=:none, size=(figsize,figsize//2))
	scatter!([t_plt.*24],[ld(orbit, t_plt, r_ratio_plt)], color=:blue, label=:none)
	xlabel!("Time (hr)")
	ylabel!("Flux")
	title!("Transit light curve")
end

# ╔═╡ 43a40de1-c8af-41cf-a580-6b249e2e70d9
begin
	radius_in_rearth = (r_ratio_plt/0.00916794)
	mass_in_mearth = min(radius_in_rearth^3,317.9)
	rv_amp = 0.09*mass_in_mearth * (365.25/period_in_days)^(1/3)
end;

# ╔═╡ 85506d9a-92ad-485e-baf9-59694b95876c
md"""
Min-to-Max Deviation due to RM effeect: **$(string(round(maximum(path_rv)-minimum(path_rv), sigdigits=2))) m/s**

Min-to-Max Deviation due to orbital motion: **$(string(round(rv_amp, sigdigits=2))) m/s** (assuming m = $(round(mass_in_mearth,sigdigits=2)) M_⊕)
"""

# ╔═╡ de0204a5-8b19-49a1-9715-ac9baeb3693e
path_rv_movie = map(tt->calc_rv_inplace(tt,grid_Irv,orbit,r_ratio_plt),t_anim);

# ╔═╡ 6055a655-8f99-40e9-8ddc-3e12406ca54d
begin
	t_frame = t_anim[mod(i_frame,length(t_anim))+1]
	rv_frame = calc_all(t_frame, orbit)

	plt_star_frame = plot_star_weighted_rv(t_plt)
	plot!(plt_star_frame,map(tt->Orbits.relative_position(orbit,tt)[1],t_anim),map(tt->Orbits.relative_position(orbit,tt)[2],t_anim), size=(figsize,figsize), color=:black)
	title!(plt_star_frame,"Weighted RV w/ Planet")
	
	plt_spectrum_frame = plot_spectrum_frame(t_plt)

	plt_rm_frame = plot_rm_frame(t_frame,rv_frame,path_rv_movie)
end;

# ╔═╡ e29c7134-f341-4706-a559-2fe13c7844ef
plt_star_frame

# ╔═╡ 2a2719bc-1d63-4c14-aba8-340c66639556
plt_spectrum_frame

# ╔═╡ bd409eaa-5017-41a1-bfe7-57b5e0a4ca87
plt_rm_frame

# ╔═╡ daf8814f-d73c-4efd-97a9-99bfba640697
md"""
## Movie
"""

# ╔═╡ 9e3cc49b-0646-4602-b5b5-8bf5a469a639
md"""
Save Movies: $(@bind make_anim CheckBox(default=false))
"""

# ╔═╡ ea188aa1-59c5-4e62-87a5-16ce9f136f3f
if make_anim
	anim_rm_rv = @animate for tt ∈ t_movie
	    #plot_rm_frame(tt)
		rv_frame = calc_all(tt, orbit)
		plt_rm_frame = plot_rm_frame(tt,rv_frame,path_rv_movie)
	end
	gif(anim_rm_rv, "anim_rm_rv_curve.gif", fps = 15)
	LocalResource("anim_rm_rv_curve.gif")
end

# ╔═╡ 62ca8025-a377-4919-bb1c-2d7b416cbe20
if make_anim
	anim_rm_star = @animate for tt ∈ t_movie
		rv_frame = calc_all(tt, orbit)
	    plot_star_weighted_rv(tt)
	end
	gif(anim_rm_star, "anim_rm_disk.gif", fps = 15)
	LocalResource("anim_rm_disk.gif")
end

# ╔═╡ 860458b6-5813-47f7-ba10-8b0199b6b8a9
if make_anim
	anim_rm_spectra = @animate for tt ∈ t_movie
		rv_frame = calc_all(tt, orbit)
	    plot_spectrum_frame(tt)
	end
	gif(anim_rm_spectra, "anim_rm_spectra.gif", fps = 15)
	LocalResource("anim_rm_spectra.gif")
end

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
ColorSchemes = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
Distributions = "31c24e10-a181-5473-b8eb-7969acd0382f"
Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
PlutoTeachingTools = "661c6b06-c737-4d37-b85c-46df65de6f69"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
StatsPlots = "f3b207a7-027a-5e70-b257-86293d7955fd"
Transits = "2e59a628-7bac-4d38-8059-3a73ba0928ab"

[compat]
ColorSchemes = "~3.19.0"
Distributions = "~0.25.71"
Plots = "~1.33.0"
PlutoTeachingTools = "~0.2.3"
PlutoUI = "~0.7.40"
StatsPlots = "~0.15.3"
Transits = "~0.3.9"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.7.1"
manifest_format = "2.0"

[[deps.AbstractFFTs]]
deps = ["ChainRulesCore", "LinearAlgebra"]
git-tree-sha1 = "69f7020bd72f069c219b5e8c236c1fa90d2cb409"
uuid = "621f4979-c628-5d54-868e-fcf4e3e8185c"
version = "1.2.1"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "8eaf9f1b4921132a4cff3f36a1d9ba923b14a481"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.1.4"

[[deps.Adapt]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "195c5505521008abea5aee4f96930717958eac6f"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "3.4.0"

[[deps.ArgCheck]]
git-tree-sha1 = "a3a402a35a2f7e0b87828ccabbd5ebfbebe356b4"
uuid = "dce04be8-c92d-5529-be00-80e4d2c0e197"
version = "2.3.0"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"

[[deps.Arpack]]
deps = ["Arpack_jll", "Libdl", "LinearAlgebra", "Logging"]
git-tree-sha1 = "91ca22c4b8437da89b030f08d71db55a379ce958"
uuid = "7d9fca2a-8960-54d3-9f78-7d1dccf2cb97"
version = "0.5.3"

[[deps.Arpack_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "OpenBLAS_jll", "Pkg"]
git-tree-sha1 = "5ba6c757e8feccf03a1554dfaf3e26b3cfc7fd5e"
uuid = "68821587-b530-5797-8361-c406ea357684"
version = "3.5.1+1"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.AstroLib]]
deps = ["Dates", "DelimitedFiles", "LinearAlgebra", "Printf", "StaticArrays"]
git-tree-sha1 = "283b723fa46dcfdaa758aa66e1b28fb25104ba1b"
uuid = "c7932e45-9af1-51e7-9da9-f004cd3a462b"
version = "0.4.1"

[[deps.AxisAlgorithms]]
deps = ["LinearAlgebra", "Random", "SparseArrays", "WoodburyMatrices"]
git-tree-sha1 = "66771c8d21c8ff5e3a93379480a2307ac36863f7"
uuid = "13072b0f-2c55-5437-9ae7-d433b7a33950"
version = "1.0.1"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.Bijectors]]
deps = ["ArgCheck", "ChainRulesCore", "ChangesOfVariables", "Compat", "Distributions", "Functors", "InverseFunctions", "IrrationalConstants", "LinearAlgebra", "LogExpFunctions", "MappedArrays", "Random", "Reexport", "Requires", "Roots", "SparseArrays", "Statistics"]
git-tree-sha1 = "a3704b8e5170f9339dff4e6cb286ad49464d3646"
uuid = "76274a88-744f-5084-9051-94815aaf08c4"
version = "0.10.6"

[[deps.Bzip2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "19a35467a82e236ff51bc17a3a44b69ef35185a2"
uuid = "6e34b625-4abd-537c-b88f-471c36dfa7a0"
version = "1.0.8+0"

[[deps.Cairo_jll]]
deps = ["Artifacts", "Bzip2_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "JLLWrappers", "LZO_jll", "Libdl", "Pixman_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "4b859a208b2397a7a623a03449e4636bdb17bcf2"
uuid = "83423d85-b0ee-5818-9007-b63ccbeb887a"
version = "1.16.1+1"

[[deps.Calculus]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "f641eb0a4f00c343bbc32346e1217b86f3ce9dad"
uuid = "49dc2e85-a5d0-5ad3-a950-438e2897f1b9"
version = "0.5.1"

[[deps.ChainRulesCore]]
deps = ["Compat", "LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "dc4405cee4b2fe9e1108caec2d760b7ea758eca2"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.15.5"

[[deps.ChangesOfVariables]]
deps = ["ChainRulesCore", "LinearAlgebra", "Test"]
git-tree-sha1 = "38f7a08f19d8810338d4f5085211c7dfa5d5bdd8"
uuid = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
version = "0.1.4"

[[deps.Clustering]]
deps = ["Distances", "LinearAlgebra", "NearestNeighbors", "Printf", "SparseArrays", "Statistics", "StatsBase"]
git-tree-sha1 = "75479b7df4167267d75294d14b58244695beb2ac"
uuid = "aaaa29a8-35af-508c-8bc3-b662a17a0fe5"
version = "0.14.2"

[[deps.CodeTracking]]
deps = ["InteractiveUtils", "UUIDs"]
git-tree-sha1 = "1833bda4a027f4b2a1c984baddcf755d77266818"
uuid = "da1fd8a2-8d9e-5ec2-8556-3022fb5608a2"
version = "1.1.0"

[[deps.CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "ded953804d019afa9a3f98981d99b33e3db7b6da"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.0"

[[deps.ColorSchemes]]
deps = ["ColorTypes", "ColorVectorSpace", "Colors", "FixedPointNumbers", "Random"]
git-tree-sha1 = "1fd869cc3875b57347f7027521f561cf46d1fcd8"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.19.0"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "eb7f0f8307f71fac7c606984ea5fb2817275d6e4"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.4"

[[deps.ColorVectorSpace]]
deps = ["ColorTypes", "FixedPointNumbers", "LinearAlgebra", "SpecialFunctions", "Statistics", "TensorCore"]
git-tree-sha1 = "d08c20eef1f2cbc6e60fd3612ac4340b89fea322"
uuid = "c3611d14-8923-5661-9e6a-0046d554d3a4"
version = "0.9.9"

[[deps.Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "417b0ed7b8b838aa6ca0a87aadf1bb9eb111ce40"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.12.8"

[[deps.CommonSolve]]
git-tree-sha1 = "332a332c97c7071600984b3c31d9067e1a4e6e25"
uuid = "38540f10-b2f7-11e9-35d8-d573e4eb0ff2"
version = "0.2.1"

[[deps.Compat]]
deps = ["Dates", "LinearAlgebra", "UUIDs"]
git-tree-sha1 = "5856d3031cdb1f3b2b6340dfdc66b6d9a149a374"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.2.0"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"

[[deps.ConcreteStructs]]
git-tree-sha1 = "f749037478283d372048690eb3b5f92a79432b34"
uuid = "2569d6c7-a4a2-43d3-a901-331e8e4be471"
version = "0.2.3"

[[deps.ConstructionBase]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "fb21ddd70a051d882a1686a5a550990bbe371a95"
uuid = "187b0558-2788-49d3-abe0-74a17ed4e7c9"
version = "1.4.1"

[[deps.Contour]]
git-tree-sha1 = "d05d9e7b7aedff4e5b51a029dced05cfb6125781"
uuid = "d38c429a-6771-53c6-b99e-75d170b6e991"
version = "0.6.2"

[[deps.DataAPI]]
git-tree-sha1 = "fb5f5316dd3fd4c5e7c30a24d50643b73e37cd40"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.10.0"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "d1fff3a548102f48987a52a2e0d114fa97d730f0"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.13"

[[deps.DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[deps.DataValues]]
deps = ["DataValueInterfaces", "Dates"]
git-tree-sha1 = "d88a19299eba280a6d062e135a43f00323ae70bf"
uuid = "e7dc6d0d-1eca-5fa6-8ad6-5aecde8b7ea5"
version = "0.4.13"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.DelimitedFiles]]
deps = ["Mmap"]
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"

[[deps.DensityInterface]]
deps = ["InverseFunctions", "Test"]
git-tree-sha1 = "80c3e8639e3353e5d2912fb3a1916b8455e2494b"
uuid = "b429d917-457f-4dbc-8f4c-0cc954292b1d"
version = "0.4.0"

[[deps.Distances]]
deps = ["LinearAlgebra", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "3258d0659f812acde79e8a74b11f17ac06d0ca04"
uuid = "b4f34e82-e78d-54a5-968a-f98e89d6e8f7"
version = "0.10.7"

[[deps.Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[deps.Distributions]]
deps = ["ChainRulesCore", "DensityInterface", "FillArrays", "LinearAlgebra", "PDMats", "Printf", "QuadGK", "Random", "SparseArrays", "SpecialFunctions", "Statistics", "StatsBase", "StatsFuns", "Test"]
git-tree-sha1 = "ee407ce31ab2f1bacadc3bd987e96de17e00aed3"
uuid = "31c24e10-a181-5473-b8eb-7969acd0382f"
version = "0.25.71"

[[deps.DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "5158c2b41018c5f7eb1470d558127ac274eca0c9"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.9.1"

[[deps.Downloads]]
deps = ["ArgTools", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"

[[deps.DualNumbers]]
deps = ["Calculus", "NaNMath", "SpecialFunctions"]
git-tree-sha1 = "5837a837389fccf076445fce071c8ddaea35a566"
uuid = "fa6b7ba4-c1ee-5f82-b5fc-ecf0adba8f74"
version = "0.6.8"

[[deps.Expat_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "bad72f730e9e91c08d9427d5e8db95478a3c323d"
uuid = "2e619515-83b5-522b-bb60-26c02a35a201"
version = "2.4.8+0"

[[deps.FFMPEG]]
deps = ["FFMPEG_jll"]
git-tree-sha1 = "b57e3acbe22f8484b4b5ff66a7499717fe1a9cc8"
uuid = "c87230d0-a227-11e9-1b43-d7ebe4e7570a"
version = "0.4.1"

[[deps.FFMPEG_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "JLLWrappers", "LAME_jll", "Libdl", "Ogg_jll", "OpenSSL_jll", "Opus_jll", "Pkg", "Zlib_jll", "libaom_jll", "libass_jll", "libfdk_aac_jll", "libvorbis_jll", "x264_jll", "x265_jll"]
git-tree-sha1 = "ccd479984c7838684b3ac204b716c89955c76623"
uuid = "b22a6f82-2f65-5046-a5b2-351ab43fb4e5"
version = "4.4.2+0"

[[deps.FFTW]]
deps = ["AbstractFFTs", "FFTW_jll", "LinearAlgebra", "MKL_jll", "Preferences", "Reexport"]
git-tree-sha1 = "90630efff0894f8142308e334473eba54c433549"
uuid = "7a1cc6ca-52ef-59f5-83cd-3a7055c09341"
version = "1.5.0"

[[deps.FFTW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c6033cc3892d0ef5bb9cd29b7f2f0331ea5184ea"
uuid = "f5851436-0d7a-5f13-b9de-f02708fd171a"
version = "3.3.10+0"

[[deps.FastGaussQuadrature]]
deps = ["LinearAlgebra", "SpecialFunctions", "StaticArrays"]
git-tree-sha1 = "58d83dd5a78a36205bdfddb82b1bb67682e64487"
uuid = "442a2c76-b920-505d-bb47-c5924d526838"
version = "0.4.9"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.FillArrays]]
deps = ["LinearAlgebra", "Random", "SparseArrays", "Statistics"]
git-tree-sha1 = "87519eb762f85534445f5cda35be12e32759ee14"
uuid = "1a297f60-69ca-5386-bcde-b61e274b549b"
version = "0.13.4"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[deps.Fontconfig_jll]]
deps = ["Artifacts", "Bzip2_jll", "Expat_jll", "FreeType2_jll", "JLLWrappers", "Libdl", "Libuuid_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "21efd19106a55620a188615da6d3d06cd7f6ee03"
uuid = "a3f928ae-7b40-5064-980b-68af3947d34b"
version = "2.13.93+0"

[[deps.Formatting]]
deps = ["Printf"]
git-tree-sha1 = "8339d61043228fdd3eb658d86c926cb282ae72a8"
uuid = "59287772-0a20-5a39-b81b-1366585eb4c0"
version = "0.4.2"

[[deps.FreeType2_jll]]
deps = ["Artifacts", "Bzip2_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "87eb71354d8ec1a96d4a7636bd57a7347dde3ef9"
uuid = "d7e528f0-a631-5988-bf34-fe36492bcfd7"
version = "2.10.4+0"

[[deps.FriBidi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "aa31987c2ba8704e23c6c8ba8a4f769d5d7e4f91"
uuid = "559328eb-81f9-559d-9380-de523a88c83c"
version = "1.0.10+0"

[[deps.Functors]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "a2657dd0f3e8a61dbe70fc7c122038bd33790af5"
uuid = "d9f16b24-f501-4c13-a1f2-28368ffc5196"
version = "0.3.0"

[[deps.Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"

[[deps.GLFW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libglvnd_jll", "Pkg", "Xorg_libXcursor_jll", "Xorg_libXi_jll", "Xorg_libXinerama_jll", "Xorg_libXrandr_jll"]
git-tree-sha1 = "d972031d28c8c8d9d7b41a536ad7bb0c2579caca"
uuid = "0656b61e-2033-5cc2-a64a-77c0f6c09b89"
version = "3.3.8+0"

[[deps.GR]]
deps = ["Base64", "DelimitedFiles", "GR_jll", "HTTP", "JSON", "Libdl", "LinearAlgebra", "Pkg", "Printf", "Random", "RelocatableFolders", "Serialization", "Sockets", "Test", "UUIDs"]
git-tree-sha1 = "cf0a9940f250dc3cb6cc6c6821b4bf8a4286cf9c"
uuid = "28b8d3ca-fb5f-59d9-8090-bfdbd6d07a71"
version = "0.66.2"

[[deps.GR_jll]]
deps = ["Artifacts", "Bzip2_jll", "Cairo_jll", "FFMPEG_jll", "Fontconfig_jll", "GLFW_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pixman_jll", "Pkg", "Qt5Base_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "3697c23d09d5ec6f2088faa68f0d926b6889b5be"
uuid = "d2c73de3-f751-5644-a686-071e5b155ba9"
version = "0.67.0+0"

[[deps.Gettext_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "9b02998aba7bf074d14de89f9d37ca24a1a0b046"
uuid = "78b55507-aeef-58d4-861c-77aaff3498b1"
version = "0.21.0+0"

[[deps.Glib_jll]]
deps = ["Artifacts", "Gettext_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Libiconv_jll", "Libmount_jll", "PCRE_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "a32d672ac2c967f3deb8a81d828afc739c838a06"
uuid = "7746bdde-850d-59dc-9ae8-88ece973131d"
version = "2.68.3+2"

[[deps.Graphite2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "344bf40dcab1073aca04aa0df4fb092f920e4011"
uuid = "3b182d85-2403-5c21-9c21-1e1f0cc25472"
version = "1.3.14+0"

[[deps.Grisu]]
git-tree-sha1 = "53bb909d1151e57e2484c3d1b53e19552b887fb2"
uuid = "42e2da0e-8278-4e71-bc24-59509adca0fe"
version = "1.0.2"

[[deps.HTTP]]
deps = ["Base64", "CodecZlib", "Dates", "IniFile", "Logging", "LoggingExtras", "MbedTLS", "NetworkOptions", "Random", "SimpleBufferStream", "Sockets", "URIs", "UUIDs"]
git-tree-sha1 = "59ba44e0aa49b87a8c7a8920ec76f8afe87ed502"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "1.3.3"

[[deps.HarfBuzz_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "Graphite2_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg"]
git-tree-sha1 = "129acf094d168394e80ee1dc4bc06ec835e510a3"
uuid = "2e76f6c2-a576-52d4-95c1-20adfe4de566"
version = "2.8.1+1"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "8d511d5b81240fc8e6802386302675bdf47737b9"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.4"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "c47c5fa4c5308f27ccaac35504858d8914e102f9"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.4"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "f7be53659ab06ddc986428d3a9dcc95f6fa6705a"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.2"

[[deps.IniFile]]
git-tree-sha1 = "f550e6e32074c939295eb5ea6de31849ac2c9625"
uuid = "83e8ac13-25f8-5344-8a64-a9f2b223428f"
version = "0.5.1"

[[deps.IntelOpenMP_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "d979e54b71da82f3a65b62553da4fc3d18c9004c"
uuid = "1d5cc7b8-4909-519e-a0f8-d0f5ad9712d0"
version = "2018.0.3+2"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.Interpolations]]
deps = ["Adapt", "AxisAlgorithms", "ChainRulesCore", "LinearAlgebra", "OffsetArrays", "Random", "Ratios", "Requires", "SharedArrays", "SparseArrays", "StaticArrays", "WoodburyMatrices"]
git-tree-sha1 = "f67b55b6447d36733596aea445a9f119e83498b6"
uuid = "a98d9a8b-a2ab-59e6-89dd-64a1c18fca59"
version = "0.14.5"

[[deps.InverseFunctions]]
deps = ["Test"]
git-tree-sha1 = "b3364212fb5d870f724876ffcd34dd8ec6d98918"
uuid = "3587e190-3f89-42d0-90ee-14403ec27112"
version = "0.1.7"

[[deps.IrrationalConstants]]
git-tree-sha1 = "7fd44fd4ff43fc60815f8e764c0f352b83c49151"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.1.1"

[[deps.IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[deps.JLLWrappers]]
deps = ["Preferences"]
git-tree-sha1 = "abc9885a7ca2052a736a600f7fa66209f96506e1"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.4.1"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "3c837543ddb02250ef42f4738347454f95079d4e"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.3"

[[deps.JpegTurbo_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b53380851c6e6664204efb2e62cd24fa5c47e4ba"
uuid = "aacddb02-875f-59d6-b918-886e6ef4fbf8"
version = "2.1.2+0"

[[deps.JuliaInterpreter]]
deps = ["CodeTracking", "InteractiveUtils", "Random", "UUIDs"]
git-tree-sha1 = "0f960b1404abb0b244c1ece579a0ec78d056a5d1"
uuid = "aa1ae85d-cabe-5617-a682-6adf51b2e16a"
version = "0.9.15"

[[deps.KernelDensity]]
deps = ["Distributions", "DocStringExtensions", "FFTW", "Interpolations", "StatsBase"]
git-tree-sha1 = "9816b296736292a80b9a3200eb7fbb57aaa3917a"
uuid = "5ab0869b-81aa-558d-bb23-cbf5423bbe9b"
version = "0.6.5"

[[deps.KeywordCalls]]
deps = ["Compat", "Tricks"]
git-tree-sha1 = "42feb5ec95dd43f99bb0437fcb5abccd14d9e67e"
uuid = "4d827475-d3e4-43d6-abe3-9688362ede9f"
version = "0.2.5"

[[deps.LAME_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "f6250b16881adf048549549fba48b1161acdac8c"
uuid = "c1c5ebd0-6772-5130-a774-d5fcae4a789d"
version = "3.100.1+0"

[[deps.LERC_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "bf36f528eec6634efc60d7ec062008f171071434"
uuid = "88015f11-f218-50d7-93a8-a6af411a945d"
version = "3.0.0+1"

[[deps.LZO_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e5b909bcf985c5e2605737d2ce278ed791b89be6"
uuid = "dd4b983a-f0e5-5f8d-a1b7-129d4a5fb1ac"
version = "2.10.1+0"

[[deps.LaTeXStrings]]
git-tree-sha1 = "f2355693d6778a178ade15952b7ac47a4ff97996"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.3.0"

[[deps.Latexify]]
deps = ["Formatting", "InteractiveUtils", "LaTeXStrings", "MacroTools", "Markdown", "OrderedCollections", "Printf", "Requires"]
git-tree-sha1 = "ab9aa169d2160129beb241cb2750ca499b4e90e9"
uuid = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"
version = "0.15.17"

[[deps.LazyArtifacts]]
deps = ["Artifacts", "Pkg"]
uuid = "4af54fe1-eca0-43a8-85a7-787d91b784e3"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"

[[deps.LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.Libffi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "0b4a5d71f3e5200a7dff793393e09dfc2d874290"
uuid = "e9f186c6-92d2-5b65-8a66-fee21dc1b490"
version = "3.2.2+1"

[[deps.Libgcrypt_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgpg_error_jll", "Pkg"]
git-tree-sha1 = "64613c82a59c120435c067c2b809fc61cf5166ae"
uuid = "d4300ac3-e22c-5743-9152-c294e39db1e4"
version = "1.8.7+0"

[[deps.Libglvnd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll", "Xorg_libXext_jll"]
git-tree-sha1 = "7739f837d6447403596a75d19ed01fd08d6f56bf"
uuid = "7e76a0d4-f3c7-5321-8279-8d96eeed0f29"
version = "1.3.0+3"

[[deps.Libgpg_error_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c333716e46366857753e273ce6a69ee0945a6db9"
uuid = "7add5ba3-2f88-524e-9cd5-f83b8a55f7b8"
version = "1.42.0+0"

[[deps.Libiconv_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "42b62845d70a619f063a7da093d995ec8e15e778"
uuid = "94ce4f54-9a6c-5748-9c1c-f9c7231a4531"
version = "1.16.1+1"

[[deps.Libmount_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "9c30530bf0effd46e15e0fdcf2b8636e78cbbd73"
uuid = "4b2f31a3-9ecc-558c-b454-b3730dcb73e9"
version = "2.35.0+0"

[[deps.Libtiff_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "LERC_jll", "Libdl", "Pkg", "Zlib_jll", "Zstd_jll"]
git-tree-sha1 = "3eb79b0ca5764d4799c06699573fd8f533259713"
uuid = "89763e89-9b03-5906-acba-b20f662cd828"
version = "4.4.0+0"

[[deps.Libuuid_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "7f3efec06033682db852f8b3bc3c1d2b0a0ab066"
uuid = "38a345b3-de98-5d2b-a5d3-14cd9215e700"
version = "2.36.0+0"

[[deps.LinearAlgebra]]
deps = ["Libdl", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.LogExpFunctions]]
deps = ["ChainRulesCore", "ChangesOfVariables", "DocStringExtensions", "InverseFunctions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "94d9c52ca447e23eac0c0f074effbcd38830deb5"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.18"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.LoggingExtras]]
deps = ["Dates", "Logging"]
git-tree-sha1 = "5d4d2d9904227b8bd66386c1138cf4d5ffa826bf"
uuid = "e6f89c97-d47a-5376-807f-9c37f3926c36"
version = "0.4.9"

[[deps.LoweredCodeUtils]]
deps = ["JuliaInterpreter"]
git-tree-sha1 = "dedbebe234e06e1ddad435f5c6f4b85cd8ce55f7"
uuid = "6f1432cf-f94c-5a45-995e-cdbf5db27b0b"
version = "2.2.2"

[[deps.MKL_jll]]
deps = ["Artifacts", "IntelOpenMP_jll", "JLLWrappers", "LazyArtifacts", "Libdl", "Pkg"]
git-tree-sha1 = "41d162ae9c868218b1f3fe78cba878aa348c2d26"
uuid = "856f044c-d86e-5d09-b602-aeab76dc8ba7"
version = "2022.1.0+0"

[[deps.MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "3d3e902b31198a27340d0bf00d6ac452866021cf"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.9"

[[deps.MappedArrays]]
git-tree-sha1 = "e8b359ef06ec72e8c030463fe02efe5527ee5142"
uuid = "dbb5928d-eab1-5f90-85c2-b9b0edb7c900"
version = "0.4.1"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS]]
deps = ["Dates", "MbedTLS_jll", "MozillaCACerts_jll", "Random", "Sockets"]
git-tree-sha1 = "6872f9594ff273da6d13c7c1a1545d5a8c7d0c1c"
uuid = "739be429-bea8-5141-9913-cc70e7f3736d"
version = "1.1.6"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"

[[deps.Measures]]
git-tree-sha1 = "e498ddeee6f9fdb4551ce855a46f54dbd900245f"
uuid = "442fdcdd-2543-5da2-b0f3-8c86c306513e"
version = "0.3.1"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "bf210ce90b6c9eed32d25dbcae1ebc565df2687f"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.0.2"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"

[[deps.MultivariateStats]]
deps = ["Arpack", "LinearAlgebra", "SparseArrays", "Statistics", "StatsAPI", "StatsBase"]
git-tree-sha1 = "efe9c8ecab7a6311d4b91568bd6c88897822fabe"
uuid = "6f286f6a-111f-5878-ab1e-185364afe411"
version = "0.10.0"

[[deps.NaNMath]]
deps = ["OpenLibm_jll"]
git-tree-sha1 = "a7c3d1da1189a1c2fe843a3bfa04d18d20eb3211"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "1.0.1"

[[deps.NearestNeighbors]]
deps = ["Distances", "StaticArrays"]
git-tree-sha1 = "0e353ed734b1747fc20cd4cba0edd9ac027eff6a"
uuid = "b8a86587-4115-5ab1-83bc-aa920d37bbce"
version = "0.4.11"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"

[[deps.Observables]]
git-tree-sha1 = "dfd8d34871bc3ad08cd16026c1828e271d554db9"
uuid = "510215fc-4207-5dde-b226-833fc4488ee2"
version = "0.5.1"

[[deps.OffsetArrays]]
deps = ["Adapt"]
git-tree-sha1 = "1ea784113a6aa054c5ebd95945fa5e52c2f378e7"
uuid = "6fe1bfb0-de20-5000-8ca7-80f57d26f881"
version = "1.12.7"

[[deps.Ogg_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "887579a3eb005446d514ab7aeac5d1d027658b8f"
uuid = "e7412a2a-1a6e-54c0-be00-318e2571c051"
version = "1.3.5+1"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"

[[deps.OpenLibm_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"

[[deps.OpenSSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e60321e3f2616584ff98f0a4f18d98ae6f89bbb3"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "1.1.17+0"

[[deps.OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "13652491f6856acfd2db29360e1bbcd4565d04f1"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.5+0"

[[deps.Opus_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "51a08fb14ec28da2ec7a927c4337e4332c2a4720"
uuid = "91d4177d-7536-5919-b921-800302f37372"
version = "1.3.2+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[deps.PCRE_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b2a7af664e098055a7529ad1a900ded962bca488"
uuid = "2f80f16e-611a-54ab-bc61-aa92de5b98fc"
version = "8.44.0+0"

[[deps.PDMats]]
deps = ["LinearAlgebra", "SparseArrays", "SuiteSparse"]
git-tree-sha1 = "cf494dca75a69712a72b80bc48f59dcf3dea63ec"
uuid = "90014a1f-27ba-587c-ab20-58faa44d9150"
version = "0.11.16"

[[deps.Parsers]]
deps = ["Dates"]
git-tree-sha1 = "3d5bf43e3e8b412656404ed9466f1dcbf7c50269"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.4.0"

[[deps.Pixman_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b4f5d02549a10e20780a24fce72bea96b6329e29"
uuid = "30392449-352a-5448-841d-b1acce4e97dc"
version = "0.40.1+0"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"

[[deps.PlotThemes]]
deps = ["PlotUtils", "Statistics"]
git-tree-sha1 = "8162b2f8547bc23876edd0c5181b27702ae58dce"
uuid = "ccf2f8ad-2431-5c83-bf29-c5338b663b6a"
version = "3.0.0"

[[deps.PlotUtils]]
deps = ["ColorSchemes", "Colors", "Dates", "Printf", "Random", "Reexport", "SnoopPrecompile", "Statistics"]
git-tree-sha1 = "21303256d239f6b484977314674aef4bb1fe4420"
uuid = "995b91a9-d308-5afd-9ec6-746e21dbc043"
version = "1.3.1"

[[deps.Plots]]
deps = ["Base64", "Contour", "Dates", "Downloads", "FFMPEG", "FixedPointNumbers", "GR", "JSON", "LaTeXStrings", "Latexify", "LinearAlgebra", "Measures", "NaNMath", "Pkg", "PlotThemes", "PlotUtils", "Printf", "REPL", "Random", "RecipesBase", "RecipesPipeline", "Reexport", "RelocatableFolders", "Requires", "Scratch", "Showoff", "SparseArrays", "Statistics", "StatsBase", "UUIDs", "UnicodeFun", "Unzip"]
git-tree-sha1 = "6062b3b25ad3c58e817df0747fc51518b9110e5f"
uuid = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
version = "1.33.0"

[[deps.PlutoHooks]]
deps = ["InteractiveUtils", "Markdown", "UUIDs"]
git-tree-sha1 = "072cdf20c9b0507fdd977d7d246d90030609674b"
uuid = "0ff47ea0-7a50-410d-8455-4348d5de0774"
version = "0.0.5"

[[deps.PlutoLinks]]
deps = ["FileWatching", "InteractiveUtils", "Markdown", "PlutoHooks", "Revise", "UUIDs"]
git-tree-sha1 = "0e8bcc235ec8367a8e9648d48325ff00e4b0a545"
uuid = "0ff47ea0-7a50-410d-8455-4348d5de0420"
version = "0.1.5"

[[deps.PlutoTeachingTools]]
deps = ["Downloads", "HypertextLiteral", "LaTeXStrings", "Latexify", "Markdown", "PlutoLinks", "PlutoUI", "Random"]
git-tree-sha1 = "d8be3432505c2febcea02f44e5f4396fae017503"
uuid = "661c6b06-c737-4d37-b85c-46df65de6f69"
version = "0.2.3"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "Markdown", "Random", "Reexport", "UUIDs"]
git-tree-sha1 = "a602d7b0babfca89005da04d89223b867b55319f"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.40"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "47e5f437cc0e7ef2ce8406ce1e7e24d44915f88d"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.3.0"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.Qt5Base_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Fontconfig_jll", "Glib_jll", "JLLWrappers", "Libdl", "Libglvnd_jll", "OpenSSL_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libxcb_jll", "Xorg_xcb_util_image_jll", "Xorg_xcb_util_keysyms_jll", "Xorg_xcb_util_renderutil_jll", "Xorg_xcb_util_wm_jll", "Zlib_jll", "xkbcommon_jll"]
git-tree-sha1 = "c6c0f690d0cc7caddb74cef7aa847b824a16b256"
uuid = "ea2cea3b-5b76-57ae-a6ef-0a8af62496e1"
version = "5.15.3+1"

[[deps.QuadGK]]
deps = ["DataStructures", "LinearAlgebra"]
git-tree-sha1 = "3c009334f45dfd546a16a57960a821a1a023d241"
uuid = "1fd47b50-473d-5c70-9696-f719f8f3bcdc"
version = "2.5.0"

[[deps.Quaternions]]
deps = ["DualNumbers", "LinearAlgebra", "Random"]
git-tree-sha1 = "b327e4db3f2202a4efafe7569fcbe409106a1f75"
uuid = "94ee1d12-ae83-5a48-8b1c-48b8ff168ae0"
version = "0.5.6"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.Ratios]]
deps = ["Requires"]
git-tree-sha1 = "dc84268fe0e3335a62e315a3a7cf2afa7178a734"
uuid = "c84ed2f1-dad5-54f0-aa8e-dbefe2724439"
version = "0.4.3"

[[deps.RecipesBase]]
git-tree-sha1 = "6bf3f380ff52ce0832ddd3a2a7b9538ed1bcca7d"
uuid = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
version = "1.2.1"

[[deps.RecipesPipeline]]
deps = ["Dates", "NaNMath", "PlotUtils", "RecipesBase"]
git-tree-sha1 = "e7eac76a958f8664f2718508435d058168c7953d"
uuid = "01d81517-befc-4cb6-b9ec-a95719d0359c"
version = "0.6.3"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.RelocatableFolders]]
deps = ["SHA", "Scratch"]
git-tree-sha1 = "22c5201127d7b243b9ee1de3b43c408879dff60f"
uuid = "05181044-ff0b-4ac5-8273-598c1e38db00"
version = "0.3.0"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "838a3a4188e2ded87a4f9f184b4b0d78a1e91cb7"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.0"

[[deps.Revise]]
deps = ["CodeTracking", "Distributed", "FileWatching", "JuliaInterpreter", "LibGit2", "LoweredCodeUtils", "OrderedCollections", "Pkg", "REPL", "Requires", "UUIDs", "Unicode"]
git-tree-sha1 = "dad726963ecea2d8a81e26286f625aee09a91b7c"
uuid = "295af30f-e4ad-537b-8983-00126c2a3abe"
version = "3.4.0"

[[deps.Rmath]]
deps = ["Random", "Rmath_jll"]
git-tree-sha1 = "bf3188feca147ce108c76ad82c2792c57abe7b1f"
uuid = "79098fc4-a85e-5d69-aa6a-4863f24498fa"
version = "0.7.0"

[[deps.Rmath_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "68db32dff12bb6127bac73c209881191bf0efbb7"
uuid = "f50d1b31-88e8-58de-be2c-1cc44531875f"
version = "0.3.0+0"

[[deps.Roots]]
deps = ["CommonSolve", "Printf", "Setfield"]
git-tree-sha1 = "50f945fb7d7fdece03bbc76ff1ab96170f64a892"
uuid = "f2b01f46-fcfa-551c-844a-d8ac1e96c665"
version = "2.0.2"

[[deps.Rotations]]
deps = ["LinearAlgebra", "Quaternions", "Random", "StaticArrays", "Statistics"]
git-tree-sha1 = "3d52be96f2ff8a4591a9e2440036d4339ac9a2f7"
uuid = "6038ab10-8711-5258-84ad-4b1120ba62dc"
version = "1.3.2"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"

[[deps.Scratch]]
deps = ["Dates"]
git-tree-sha1 = "f94f779c94e58bf9ea243e77a37e16d9de9126bd"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.1.1"

[[deps.SentinelArrays]]
deps = ["Dates", "Random"]
git-tree-sha1 = "db8481cf5d6278a121184809e9eb1628943c7704"
uuid = "91c51154-3ec4-41a3-a24f-3f23e20d615c"
version = "1.3.13"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.Setfield]]
deps = ["ConstructionBase", "Future", "MacroTools", "StaticArraysCore"]
git-tree-sha1 = "e2cc6d8c88613c05e1defb55170bf5ff211fbeac"
uuid = "efcf1570-3423-57d1-acb7-fd33fddbac46"
version = "1.1.1"

[[deps.SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"

[[deps.Showoff]]
deps = ["Dates", "Grisu"]
git-tree-sha1 = "91eddf657aca81df9ae6ceb20b959ae5653ad1de"
uuid = "992d4aef-0814-514b-bc4d-f2e9a6c4116f"
version = "1.0.3"

[[deps.SimpleBufferStream]]
git-tree-sha1 = "874e8867b33a00e784c8a7e4b60afe9e037b74e1"
uuid = "777ac1f9-54b0-4bf8-805c-2214025038e7"
version = "1.1.0"

[[deps.SnoopPrecompile]]
git-tree-sha1 = "f604441450a3c0569830946e5b33b78c928e1a85"
uuid = "66db9d55-30c0-4569-8b51-7e840670fc0c"
version = "1.0.1"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "b3363d7460f7d098ca0912c69b082f75625d7508"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.0.1"

[[deps.SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.SpecialFunctions]]
deps = ["ChainRulesCore", "IrrationalConstants", "LogExpFunctions", "OpenLibm_jll", "OpenSpecFun_jll"]
git-tree-sha1 = "d75bda01f8c31ebb72df80a46c88b25d1c79c56d"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "2.1.7"

[[deps.StaticArrays]]
deps = ["LinearAlgebra", "Random", "StaticArraysCore", "Statistics"]
git-tree-sha1 = "efa8acd030667776248eabb054b1836ac81d92f0"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.5.7"

[[deps.StaticArraysCore]]
git-tree-sha1 = "ec2bd695e905a3c755b33026954b119ea17f2d22"
uuid = "1e83bf80-4336-4d27-bf5d-d5a4f845583c"
version = "1.3.0"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[deps.StatsAPI]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "f9af7f195fb13589dd2e2d57fdb401717d2eb1f6"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.5.0"

[[deps.StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "d1bf48bfcc554a3761a133fe3a9bb01488e06916"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.33.21"

[[deps.StatsFuns]]
deps = ["ChainRulesCore", "InverseFunctions", "IrrationalConstants", "LogExpFunctions", "Reexport", "Rmath", "SpecialFunctions"]
git-tree-sha1 = "5950925ff997ed6fb3e985dcce8eb1ba42a0bbe7"
uuid = "4c63d2b9-4356-54db-8cca-17b64c39e42c"
version = "0.9.18"

[[deps.StatsPlots]]
deps = ["AbstractFFTs", "Clustering", "DataStructures", "DataValues", "Distributions", "Interpolations", "KernelDensity", "LinearAlgebra", "MultivariateStats", "NaNMath", "Observables", "Plots", "RecipesBase", "RecipesPipeline", "Reexport", "StatsBase", "TableOperations", "Tables", "Widgets"]
git-tree-sha1 = "3e59e005c5caeb1a57a90b17f582cbfc2c8da8f7"
uuid = "f3b207a7-027a-5e70-b257-86293d7955fd"
version = "0.15.3"

[[deps.SuiteSparse]]
deps = ["Libdl", "LinearAlgebra", "Serialization", "SparseArrays"]
uuid = "4607b0f0-06f3-5cda-b6b1-a6196a1729e9"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"

[[deps.TableOperations]]
deps = ["SentinelArrays", "Tables", "Test"]
git-tree-sha1 = "e383c87cf2a1dc41fa30c093b2a19877c83e1bc1"
uuid = "ab02a1b2-a7df-11e8-156e-fb1833f50b87"
version = "1.2.0"

[[deps.TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[deps.Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "OrderedCollections", "TableTraits", "Test"]
git-tree-sha1 = "4d5536136ca85fe9931d6e8920c138bb9fcc6532"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.8.0"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"

[[deps.TensorCore]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "1feb45f88d133a655e001435632f019a9a1bcdb6"
uuid = "62fd8b95-f654-4bbd-a8a5-9c27f68ccd50"
version = "0.1.1"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.TranscodingStreams]]
deps = ["Random", "Test"]
git-tree-sha1 = "8a75929dcd3c38611db2f8d08546decb514fcadf"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.9.9"

[[deps.Transits]]
deps = ["AstroLib", "Bijectors", "ChainRulesCore", "ConcreteStructs", "Distributions", "FastGaussQuadrature", "KeywordCalls", "LinearAlgebra", "Printf", "Random", "Reexport", "Rotations", "SpecialFunctions", "StaticArrays", "StatsFuns", "Unitful", "UnitfulAstro"]
git-tree-sha1 = "c62117692ec2c20ce18a84ee6aec946fe8ee79ee"
uuid = "2e59a628-7bac-4d38-8059-3a73ba0928ab"
version = "0.3.9"

[[deps.Tricks]]
git-tree-sha1 = "6bac775f2d42a611cdfcd1fb217ee719630c4175"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.6"

[[deps.URIs]]
git-tree-sha1 = "e59ecc5a41b000fa94423a578d29290c7266fc10"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.4.0"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.UnicodeFun]]
deps = ["REPL"]
git-tree-sha1 = "53915e50200959667e78a92a418594b428dffddf"
uuid = "1cfade01-22cf-5700-b092-accc4b62d6e1"
version = "0.4.1"

[[deps.Unitful]]
deps = ["ConstructionBase", "Dates", "LinearAlgebra", "Random"]
git-tree-sha1 = "b649200e887a487468b71821e2644382699f1b0f"
uuid = "1986cc42-f94f-5a68-af5c-568840ba703d"
version = "1.11.0"

[[deps.UnitfulAngles]]
deps = ["Dates", "Unitful"]
git-tree-sha1 = "d6cfdb6ddeb388af1aea38d2b9905fa014d92d98"
uuid = "6fb2a4bd-7999-5318-a3b2-8ad61056cd98"
version = "0.6.2"

[[deps.UnitfulAstro]]
deps = ["Unitful", "UnitfulAngles"]
git-tree-sha1 = "05adf5e3a3bd1038dd50ff6760cddd42380a7260"
uuid = "6112ee07-acf9-5e0f-b108-d242c714bf9f"
version = "1.2.0"

[[deps.Unzip]]
git-tree-sha1 = "ca0969166a028236229f63514992fc073799bb78"
uuid = "41fe7b60-77ed-43a1-b4f0-825fd5a5650d"
version = "0.2.0"

[[deps.Wayland_jll]]
deps = ["Artifacts", "Expat_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "3e61f0b86f90dacb0bc0e73a0c5a83f6a8636e23"
uuid = "a2964d1f-97da-50d4-b82a-358c7fce9d89"
version = "1.19.0+0"

[[deps.Wayland_protocols_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4528479aa01ee1b3b4cd0e6faef0e04cf16466da"
uuid = "2381bf8a-dfd0-557d-9999-79630e7b1b91"
version = "1.25.0+0"

[[deps.Widgets]]
deps = ["Colors", "Dates", "Observables", "OrderedCollections"]
git-tree-sha1 = "fcdae142c1cfc7d89de2d11e08721d0f2f86c98a"
uuid = "cc8bc4a8-27d6-5769-a93b-9d913e69aa62"
version = "0.6.6"

[[deps.WoodburyMatrices]]
deps = ["LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "de67fa59e33ad156a590055375a30b23c40299d3"
uuid = "efce3f68-66dc-5838-9240-27a6d6f5f9b6"
version = "0.5.5"

[[deps.XML2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "58443b63fb7e465a8a7210828c91c08b92132dff"
uuid = "02c8fc9c-b97f-50b9-bbe4-9be30ff0a78a"
version = "2.9.14+0"

[[deps.XSLT_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgcrypt_jll", "Libgpg_error_jll", "Libiconv_jll", "Pkg", "XML2_jll", "Zlib_jll"]
git-tree-sha1 = "91844873c4085240b95e795f692c4cec4d805f8a"
uuid = "aed1982a-8fda-507f-9586-7b0439959a61"
version = "1.1.34+0"

[[deps.Xorg_libX11_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxcb_jll", "Xorg_xtrans_jll"]
git-tree-sha1 = "5be649d550f3f4b95308bf0183b82e2582876527"
uuid = "4f6342f7-b3d2-589e-9d20-edeb45f2b2bc"
version = "1.6.9+4"

[[deps.Xorg_libXau_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4e490d5c960c314f33885790ed410ff3a94ce67e"
uuid = "0c0b7dd1-d40b-584c-a123-a41640f87eec"
version = "1.0.9+4"

[[deps.Xorg_libXcursor_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXfixes_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "12e0eb3bc634fa2080c1c37fccf56f7c22989afd"
uuid = "935fb764-8cf2-53bf-bb30-45bb1f8bf724"
version = "1.2.0+4"

[[deps.Xorg_libXdmcp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4fe47bd2247248125c428978740e18a681372dd4"
uuid = "a3789734-cfe1-5b06-b2d0-1dd0d9d62d05"
version = "1.1.3+4"

[[deps.Xorg_libXext_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "b7c0aa8c376b31e4852b360222848637f481f8c3"
uuid = "1082639a-0dae-5f34-9b06-72781eeb8cb3"
version = "1.3.4+4"

[[deps.Xorg_libXfixes_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "0e0dc7431e7a0587559f9294aeec269471c991a4"
uuid = "d091e8ba-531a-589c-9de9-94069b037ed8"
version = "5.0.3+4"

[[deps.Xorg_libXi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll", "Xorg_libXfixes_jll"]
git-tree-sha1 = "89b52bc2160aadc84d707093930ef0bffa641246"
uuid = "a51aa0fd-4e3c-5386-b890-e753decda492"
version = "1.7.10+4"

[[deps.Xorg_libXinerama_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll"]
git-tree-sha1 = "26be8b1c342929259317d8b9f7b53bf2bb73b123"
uuid = "d1454406-59df-5ea1-beac-c340f2130bc3"
version = "1.1.4+4"

[[deps.Xorg_libXrandr_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "34cea83cb726fb58f325887bf0612c6b3fb17631"
uuid = "ec84b674-ba8e-5d96-8ba1-2a689ba10484"
version = "1.5.2+4"

[[deps.Xorg_libXrender_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "19560f30fd49f4d4efbe7002a1037f8c43d43b96"
uuid = "ea2f1a96-1ddc-540d-b46f-429655e07cfa"
version = "0.9.10+4"

[[deps.Xorg_libpthread_stubs_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "6783737e45d3c59a4a4c4091f5f88cdcf0908cbb"
uuid = "14d82f49-176c-5ed1-bb49-ad3f5cbd8c74"
version = "0.1.0+3"

[[deps.Xorg_libxcb_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "XSLT_jll", "Xorg_libXau_jll", "Xorg_libXdmcp_jll", "Xorg_libpthread_stubs_jll"]
git-tree-sha1 = "daf17f441228e7a3833846cd048892861cff16d6"
uuid = "c7cfdc94-dc32-55de-ac96-5a1b8d977c5b"
version = "1.13.0+3"

[[deps.Xorg_libxkbfile_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "926af861744212db0eb001d9e40b5d16292080b2"
uuid = "cc61e674-0454-545c-8b26-ed2c68acab7a"
version = "1.1.0+4"

[[deps.Xorg_xcb_util_image_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "0fab0a40349ba1cba2c1da699243396ff8e94b97"
uuid = "12413925-8142-5f55-bb0e-6d7ca50bb09b"
version = "0.4.0+1"

[[deps.Xorg_xcb_util_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxcb_jll"]
git-tree-sha1 = "e7fd7b2881fa2eaa72717420894d3938177862d1"
uuid = "2def613f-5ad1-5310-b15b-b15d46f528f5"
version = "0.4.0+1"

[[deps.Xorg_xcb_util_keysyms_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "d1151e2c45a544f32441a567d1690e701ec89b00"
uuid = "975044d2-76e6-5fbe-bf08-97ce7c6574c7"
version = "0.4.0+1"

[[deps.Xorg_xcb_util_renderutil_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "dfd7a8f38d4613b6a575253b3174dd991ca6183e"
uuid = "0d47668e-0667-5a69-a72c-f761630bfb7e"
version = "0.3.9+1"

[[deps.Xorg_xcb_util_wm_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "e78d10aab01a4a154142c5006ed44fd9e8e31b67"
uuid = "c22f9ab0-d5fe-5066-847c-f4bb1cd4e361"
version = "0.4.1+1"

[[deps.Xorg_xkbcomp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxkbfile_jll"]
git-tree-sha1 = "4bcbf660f6c2e714f87e960a171b119d06ee163b"
uuid = "35661453-b289-5fab-8a00-3d9160c6a3a4"
version = "1.4.2+4"

[[deps.Xorg_xkeyboard_config_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xkbcomp_jll"]
git-tree-sha1 = "5c8424f8a67c3f2209646d4425f3d415fee5931d"
uuid = "33bec58e-1273-512f-9401-5d533626f822"
version = "2.27.0+4"

[[deps.Xorg_xtrans_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "79c31e7844f6ecf779705fbc12146eb190b7d845"
uuid = "c5fb5394-a638-5e4d-96e5-b29de1b5cf10"
version = "1.4.0+3"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"

[[deps.Zstd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e45044cd873ded54b6a5bac0eb5c971392cf1927"
uuid = "3161d3a3-bdf6-5164-811a-617609db77b4"
version = "1.5.2+0"

[[deps.libaom_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "3a2ea60308f0996d26f1e5354e10c24e9ef905d4"
uuid = "a4ae2306-e953-59d6-aa16-d00cac43593b"
version = "3.4.0+0"

[[deps.libass_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "5982a94fcba20f02f42ace44b9894ee2b140fe47"
uuid = "0ac62f75-1d6f-5e53-bd7c-93b484bb37c0"
version = "0.15.1+0"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl", "OpenBLAS_jll"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"

[[deps.libfdk_aac_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "daacc84a041563f965be61859a36e17c4e4fcd55"
uuid = "f638f0a6-7fb0-5443-88ba-1cc74229b280"
version = "2.0.2+0"

[[deps.libpng_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "94d180a6d2b5e55e447e2d27a29ed04fe79eb30c"
uuid = "b53b4c65-9356-5827-b1ea-8c7a1a84506f"
version = "1.6.38+0"

[[deps.libvorbis_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Ogg_jll", "Pkg"]
git-tree-sha1 = "b910cb81ef3fe6e78bf6acee440bda86fd6ae00c"
uuid = "f27f6e37-5d2b-51aa-960f-b287f2bc3b7a"
version = "1.3.7+1"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"

[[deps.x264_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4fea590b89e6ec504593146bf8b988b2c00922b2"
uuid = "1270edf5-f2f9-52d2-97e9-ab00b5d0237a"
version = "2021.5.5+0"

[[deps.x265_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "ee567a171cce03570d77ad3a43e90218e38937a9"
uuid = "dfaa095f-4041-5dcd-9319-2fabd8486b76"
version = "3.5.0+0"

[[deps.xkbcommon_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Wayland_jll", "Wayland_protocols_jll", "Xorg_libxcb_jll", "Xorg_xkeyboard_config_jll"]
git-tree-sha1 = "9ebfc140cc56e8c2156a15ceac2f0302e327ac0a"
uuid = "d8fb68d0-12a3-5cfd-a85a-d49703b185fd"
version = "1.4.1+0"
"""

# ╔═╡ Cell order:
# ╟─c3bf9feb-b047-469e-b043-18cfb69e66c7
# ╟─faca0b2c-e19a-4246-93dc-a6baa7a9718a
# ╟─76819951-3f3c-4adc-989f-04435b4ae060
# ╟─7faa640f-a4a5-4b4e-aefe-15d9c1b37e06
# ╟─26c2ef9e-abc7-4c93-83e9-217dc0f74dae
# ╟─85f01e40-d3d8-418c-99a4-e28cbe1b7b2e
# ╟─e20c11e9-0df9-42b1-a531-914bfbb5ef7a
# ╟─697092dc-96f3-4f99-8e48-3919370d4125
# ╟─2fdaac21-0079-4c08-8d72-aecb6981889f
# ╟─c531d869-9aa4-410e-a0b4-a5149e1216e9
# ╟─e3bdc4d2-f752-4be4-8bc9-7f5c69b8448d
# ╟─573698fa-7fe1-49db-8169-28919cdaecf7
# ╟─d973ac70-5a8a-499c-9ba7-9cfab21ae012
# ╟─dce22b0e-753e-4beb-a936-37bcf8c470a6
# ╟─2eafb469-92e8-4c96-93f6-38f5c77c3e84
# ╟─c3de61c9-5172-4004-9918-6f1f4fb4c842
# ╟─7323edea-b329-48c3-9dc0-89a4461a90e7
# ╟─57197cb0-1ff6-40f1-9225-aa5a259ab2aa
# ╟─a75f7af6-83cf-4201-8663-d5906e33fa5c
# ╟─df2079a4-f89e-4645-8917-d2a62ed4ff55
# ╟─2a92b42b-21be-46e5-9172-88f61dd262ea
# ╟─c1228db0-5dfd-46fd-b471-26cb563b6072
# ╟─c84b73f2-252e-4266-96b1-9cb7323e5494
# ╟─6f120424-f4e6-4b4e-a216-c97b8ae4e77e
# ╟─85808945-e389-474a-a9e6-50ea5cedef95
# ╟─d9ebea32-ec97-4a16-b3fa-abd5393b9b9a
# ╟─15727a3d-b305-43c5-a1a6-e76ba224428e
# ╟─3b3bb91b-acf2-4e60-82a1-b7dc09222474
# ╟─cae9b7a3-a12a-42ba-ac71-8af0edb2bdba
# ╟─3f3f9c95-aeaa-478e-b199-8522e3beae53
# ╟─6c0df45a-da40-4188-8149-124ab6c03038
# ╟─3c3fa58f-6500-4943-9934-3d04fdc5f4b4
# ╟─3ab9ca68-b7c9-4f1f-af39-8374d1cf10ff
# ╟─b359a1f4-2f8a-4c19-8d13-966efb09d71e
# ╟─484dcad2-d4dd-4786-ae93-9dedf70cb754
# ╟─0ecea71d-8e92-4d6a-91b5-6c2fc31327a5
# ╟─61ddefa1-6e30-465f-8b7d-ed0a52880d0a
# ╟─f594e0b5-bf25-44fb-93ca-14872b90841d
# ╟─af076195-9083-4147-af74-081cd43eaa76
# ╟─dfc344a0-cd15-42bb-b76c-4f7a07a8421f
# ╟─b1cd4ae5-657e-4c05-9fe7-e63f5992fc56
# ╟─47ac1992-51c9-4d80-b6a0-2d16c253ccac
# ╟─3a938f17-9890-4ebd-ab96-f16cee2b7bf5
# ╟─85506d9a-92ad-485e-baf9-59694b95876c
# ╟─43a40de1-c8af-41cf-a580-6b249e2e70d9
# ╟─cff93461-b079-4894-afc9-4439f53a8deb
# ╟─de0204a5-8b19-49a1-9715-ac9baeb3693e
# ╟─6055a655-8f99-40e9-8ddc-3e12406ca54d
# ╟─7ae2f85e-52c4-4db3-9bf0-a509010b8e6a
# ╟─e29c7134-f341-4706-a559-2fe13c7844ef
# ╟─2a2719bc-1d63-4c14-aba8-340c66639556
# ╟─bd409eaa-5017-41a1-bfe7-57b5e0a4ca87
# ╟─20019990-a424-445d-96ec-39cd6278cdc6
# ╟─6fc1ca2c-709f-4b1f-af98-5af84cd82784
# ╟─0eb53eea-289d-4f87-a3dc-747ff791e019
# ╟─d127279b-8f5c-47fd-83b2-601ed9a8a2d0
# ╟─54a35812-22ad-49e2-bca2-8f80c6c47379
# ╟─fc00489e-7355-4c38-852e-538511806d85
# ╟─7ec579f4-dfbc-4320-af05-422391519aac
# ╟─b4ed9eff-96f4-4f9f-94d4-6e9e23c02ec4
# ╟─d52ded9c-4d01-4a48-94f7-d1002a2351ec
# ╟─5f962986-00ad-4c8d-b440-885e34c2b471
# ╟─d7b57c40-2cc7-4e7d-b21d-ff380218fcf4
# ╟─17bcf51c-311c-4bc3-a464-03253a8d89a9
# ╟─41c71d22-163e-4ea2-b511-9f9c129253e6
# ╠═d1caecb5-346a-47b5-9ccc-6c4df5be7e60
# ╠═ef38c415-e2e0-47a7-97ea-18268a960fea
# ╠═45decf90-9e71-4c9a-a2c3-2123c5047066
# ╟─26722319-eeb5-406f-bd64-e43a7375a4db
# ╟─b34fa8df-87da-49fc-b0ac-f038f4c8612e
# ╟─88e908e6-933d-4192-9ad2-c7802d038287
# ╠═0589435c-25c8-44a8-8bb8-f159740ad59b
# ╠═39832015-1380-4a19-b35b-47a23a88b3bd
# ╠═6bc459bc-62ec-4faf-8294-348ac499df60
# ╟─cbbda00c-1d81-4e96-baea-368bd9d7d19b
# ╠═d16da790-8bbf-4f3c-8bf4-b6748418e813
# ╠═cd9cca6c-aa26-4669-8659-bf604ba71680
# ╠═347a56d2-5bff-485a-aa70-a4fbf8beb430
# ╟─3a9968c1-d259-4287-8147-0e35b8e9dffd
# ╠═a045edac-c3b5-435c-bcf3-f13586af0734
# ╠═806f9a87-3572-4d92-acd6-73e954609731
# ╠═375994ff-08ed-4c39-8938-dd1c92b91ea2
# ╠═5065bcff-0307-4c20-a95b-fec7c046f181
# ╠═3d297ed9-19b1-40e7-aed3-a269192dcf5a
# ╠═15bcb6e7-a9c1-41ee-a5b2-0d8468b5bcd1
# ╠═2957f299-5304-429d-90f5-04142ff497a9
# ╠═ccbdce5a-ca45-4e61-bca4-af79addfbacf
# ╟─86dbb15c-22d4-483f-9955-5a4efb75535d
# ╠═3c8d81fc-d2de-49cc-ac9d-b689723d5eeb
# ╠═c6ba7854-73e7-4fd5-85a0-154579dd708a
# ╠═3c95bd05-135b-4c92-9ed8-7ba4d0db155a
# ╟─daf8814f-d73c-4efd-97a9-99bfba640697
# ╟─ea188aa1-59c5-4e62-87a5-16ce9f136f3f
# ╟─62ca8025-a377-4919-bb1c-2d7b416cbe20
# ╟─860458b6-5813-47f7-ba10-8b0199b6b8a9
# ╟─9e3cc49b-0646-4602-b5b5-8bf5a469a639
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
