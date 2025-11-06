# Photom-Alcohol_Social_Choice
Analysis pipeline used for paper titled "Anterior insula activity during alcohol and social reward self-administration and choice in male and female rats" Submitted October, 2025

> **Associated Publication:**
> Title: Anterior insula activity during alcohol and social reward self-administration and choice in male and female rats
> Authors: Yvar van Mourik, Dustin Schetters, Ilse Bassie, Mohamad El Samadhi, Huib Mansvelder, Taco J. De Vries, Nathan J. Marchant
> Journal: The Journal of Neuroscience
> Year: 2025
> DOI: coming soon

This repository contains the analysis code and figures for the publication listed above. 
1. BTN_1_ extracts the data and divides them into traces based on the timestamps saved by TDT.
2. BTN_2_ sorts traces and combines them where necessary. It also performs z-scoring of the traces
3. BTN_3_ The main plotting scripts. The collect the relevant data for a given trial type, performs the statistics, and plots these as output
4. BTN_4_ Calculates mean of the zScore traces in defined time windows


