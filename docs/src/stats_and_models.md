# Statistics and Models

| Statistic/Model                    | OnlineStat                 |
|:-----------------------------------|:---------------------------|
| **Univariate Statistics:**         |                            |
| Mean                               | [`Mean`](@ref)             |
| Variance                           | [`Variance`](@ref)         |
| Quantiles                          | [`Quantile`](@ref), [`PQuantile`](@ref) |
| Maximum/Minimum                    | [`Extrema`](@ref)          |
| Skewness and kurtosis              | [`Moments`](@ref)          |
| Sum                                | [`Sum`](@ref)              |
| Difference                         | [`Diff`](@ref)             |
| **Multivariate Analysis:**         |                            |
| Covariance/correlation matrix      | [`CovMatrix`](@ref)        |
| Principal components analysis      | [`CovMatrix`](@ref)        |
| K-means clustering (SGD)           | [`KMeans`](@ref)           |
| Multiple univariate statistics     | [`MV{<:OnlineStat}`](@ref) |
| **Nonparametric Density Estimation:**|                          |
| Histograms                         | [`OHistogram`](@ref), [`IHistogram`](@ref) |
| Approximate order statistics       | [`OrderStats`](@ref)       |
| **Parametric Density Estimation:** |                            |
| Beta                               | [`FitBeta`](@ref)          |
| Categorical                        | [`FitCategorical`](@ref)   |
| Cauchy                             | [`FitCauchy`](@ref)        |
| Gamma                              | [`FitGamma`](@ref)         |
| LogNormal                          | [`FitLogNormal`](@ref)     |
| Normal                             | [`FitNormal`](@ref)        |
| Multinomial                        | [`FitMultinomial`](@ref)   |
| MvNormal                           | [`FitMvNormal`](@ref)      |
| **Statistical Learning:**          |                            |
| GLMs with regularization           | [`StatLearn`](@ref)        |
| Logistic regression                | [`StatLearn`](@ref)        |
| Linear SVMs                        | [`StatLearn`](@ref)        |
| Quantile regression                | [`StatLearn`](@ref)        |
| Absolute loss regression           | [`StatLearn`](@ref)        |
| Distance-weighted discrimination   | [`StatLearn`](@ref)        |
| Huber-loss regression              | [`StatLearn`](@ref)        |
| Linear (also ridge) regression     | [`LinReg`](@ref), [`LinRegBuilder`](@ref) |
| **Other:**                         |                            |
| Bootstrapping                      | [`Bootstrap`](@ref)        |
| Approx. count of distinct elements | [`HyperLogLog`](@ref)      |
| Reservoir sampling                 | [`ReservoirSample`](@ref)  |
| Callbacks                          | [`CallFun`](@ref), [`mapblocks`](@ref) |
