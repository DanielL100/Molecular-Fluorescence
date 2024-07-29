# Molecular-Fluorescence

Codes for generating linear and parabolic fits for (dis)confirming of Beer-Lambert law & for fitting for exciton-polariton energies dispersion.

## Description

#### Part A:
In general, this code calculates the integral of given spectrums and makes linear and parabolic fits for all the data and a linear fit for a chosen range of concentrations, for each fluorophore. It also plots all the fits on one figure for comparisons.

This part consists of the following blocks:
1. This block is provided with excel sheets with the wavenumbers and the intensity measured, and also with a noise measurement that is reduced form measurements with intensity larger than the noise. It plots $log(Intensity)$ as a function of wavenumber for each Material and concentration and calculates the area below the intensity using the trapz integration method.
2. This block plots a graph of all the concentration for the same fluorophore.
3. This block is provided with excel sheets, each contains the concentrations and the integrals for each fluorophore and their uncertainties. It makes a linear fit for all the data and plot each fluorophore on a different figure.
4. This block plots all the fluorophores from the previous stage on the same figure.
5. This block is provided with the starting and ending points in which the data is linear in order to confirm Beer-Lamber law. It makes and plot linear fits for each fluorophore in the chosen range of concentrations.
6. This block plots all the fluorophores from the previous stage on the same figure.
7. This block makes a parabolic fit for each fluorophore for all the data.
8. This block plots all the fluorophores from the previous stage on the same figure.

## Getting Started

### Dependencies

* The code requires the "Statistics" folder in order to calculate statistical tests $\chi^2_{red}$ & $P_{probability}$ and to create residual plots.
* The code requires the "Fits" folder in order to make fits.

### Executing program

* In order for the code to run you should download all the files.
* For part A you sholud provide:
  * Excel sheets which contain in the first column $\lambda$ and in the second one the Intensity for different concentrations.
  * Optional - a noise sheet that contains the background noise measured by a spectrometer.
   > **WARNING**
   > Our code requires a noise sheet and won't let the code run without it. However, it is not crucial for the experiment and can be removed from the code if needed.
> [!NOTE]
> Our code requires a noise sheet and won't let the code run without it. However, it is not crucial for the experiment and can be removed from the code if needed.
* For part B you should provide:
  * Photos of fluorescence that contains the edges of the container.
* For part C you should provide:
  * Excel sheets which contain in the first column $\lambda$ and in the second one the Intensity for different angles.
