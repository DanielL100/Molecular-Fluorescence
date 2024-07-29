# Molecular-Fluorescence

Codes for generating linear and parabolic fits for (dis)confirming of Beer-Lambert law & for fitting for exciton-polariton energies dispersion.

## Description

> [!NOTE]
> In order for the code to run as expected, one should make the experiment in a dark room with minimal background lights.

#### Part A:
In general, this code calculates the integral of given spectrums and makes linear and parabolic fits for all the data and a linear fit for a chosen range of concentrations, for each fluorophore. It also plots all the fits on one figure for comparisons.

This part consists of the following blocks:
1. This block is provided with excel files with the wavenumbers and the intensity measured, and also with a noise measurement that is reduced form measurements with intensity larger than the noise. It plots $log(Intensity)$ as a function of wavenumber for each Material and concentration and calculates the area below the intensity using the trapz integration method.
2. This block plots a graph of all the concentration for the same fluorophore.
3. This block is provided with excel files, each contains the concentrations and the integrals for each fluorophore and their uncertainties. It makes a linear fit for all the data and plot each fluorophore on a different figure.
4. This block plots all the fluorophores from the previous stage on the same figure.
5. This block is provided with the starting and ending points in which the data is linear in order to confirm Beer-Lamber law. It makes and plot linear fits for each fluorophore in the chosen range of concentrations.
6. This block plots all the fluorophores from the previous stage on the same figure.
7. This block makes a parabolic fit for each fluorophore for all the data.
8. This block plots all the fluorophores from the previous stage on the same figure.

#### Part B:
In general, this code make a scaled color plot for each image from which it creates excel files that contains the wave numbers and the log of the intensity for a chosen row of pixles. For each image it fits a linear fit which is used to evaluate the absorption coefficient.

This part consists of the following blocks:
1. This block is provided with images of fluorescence. For each image, according to the fluorophore, it creates a scaled color image with the coressponding RGB channel.
> [!NOTE]
> You should make sure that the image contains the container in which the flurophore is in and also that there are minimal reflections in the image.
2. This block is provided with an excel file that has several sheets, each one is for different fluorophore. Each sheet contains 3 columns - the first one is for the starting pixel of the fluorescence, the second is for the maximum pixel of the fluorescence and the third one is for the row height pixel.
3. This block is 


## Getting Started

### Dependencies

* The code requires the `Statistics` folder in order to calculate statistical tests $\chi^2_{red}$ & $P_{probability}$ and to create residual plots.
* The code requires the `Fits` folder in order to make fits.

### Executing program

* In order for the code to run you should download all the files.
* For part A you sholud provide:
  * Excel files which contain in the first column $\lambda$ and in the second one the Intensity for different concentrations.
  * Optional - a noise sheet that contains the background noise measured by a spectrometer.
> [!WARNING]
> Our code requires a noise sheet and won't let the code run without it. However, it is not crucial for the experiment and can be removed from the code if needed.
* For part B you should provide:
  * Photos of fluorescence that contains the edges of the container.
* For part C you should provide:
  * Excel files which contain in the first column $\lambda$ and in the second one the Intensity for different angles.
