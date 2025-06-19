# README

This repository contains code and data to reproduce the results in the paper, "Measuring the Emperor's Clothes: Estimating Latent Opposition to Authoritarian Regimes with Randomized Response Questions" by Robert Kubinec and Amr Yakout. A working paper version can be accessed from this link: <https://osf.io/preprints/socarxiv/ejbns_v1>.

A brief explanation of the files and repo structure is as follows. For more questions, please email Robert Kubinec at rkubinec@mailbox.sc.edu. If you are just looking for how to fit the Bayesian version of randomized response/crosswise with `brms`, see this file: <https://github.com/saudiwin/emperors_clothes/blob/main/scripts/example_usage_Bayesian_RR.R>.

## Repo Structure & Required Packages

This repository uses the `renv` package to manage package dependencies and ensure reproducibility. This requires installing specific versions of R packages. You need to have the `renv` package installed from CRAN and then run the following command after downloading/cloning the repo in the project directory:

```
renv::restore()
```

to install the packages that are specific to this repository. This will help ensure reproducibility. Rstudio should do this automatically once you open the project in Rstudio.

The code also uses `cmdstanr` as a backend for fitting `brms` models. If you do not want to use `cmdstanr`, simply remove the `backend="cmdstanr"` option in the model calls. Otherwise, follow the installation instructions at the `cmdstanr` website: <https://mc-stan.org/cmdstanr/>.

## Files

1. `emperors_clothes_kubinec_yakout.qmd`: this Quarto document contains the full paper text along with embedded R code. It loads anonymized survey files from the `data/` folder, cleans them, and then fits `brms` models using the `data/brms_sens_reg_experiment.R` model definition for fitting the model described in the paper.
2. `scripts/brms_sens_reg_basic.R`: this R script defines a vanilla version of the Bayesian model of randomized response with `brms`. Use this if you want to fit a `brms` model of a crosswise/randomized response design that does not have an embedded experiment with a direct question as specified in the paper. Also see `scripts/example_usage_Bayesian_RR.R` for how to use this version of the model with simulated data.
3. `references.bib`: contains all references used in the paper.
4. `data` folder: contains anonymized survey files and saved `brms` model objects.