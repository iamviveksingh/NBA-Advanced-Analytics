# Court Intelligence: NBA Advanced Analytics Engine

![R](https://img.shields.io/badge/r-%23276DC3.svg?style=for-the-badge&logo=r&logoColor=white)
![Shiny](https://img.shields.io/badge/Shiny-Data_Dashboard-blue?style=for-the-badge)
![Plotly](https://img.shields.io/badge/Plotly-Interactive_Visuals-orange?style=for-the-badge)

An enterprise-grade, interactive web application built with **R Shiny** that performs advanced statistical analysis and unsupervised machine learning on the 2024 NBA player dataset.

## 🌟 Key Features

*   **Machine Learning (K-Means Clustering):** Utilizes an unsupervised K-Means algorithm to dynamically categorize NBA players into distinct archetypes (e.g., "Primary Engines", "High-Impact Starters") based on a normalized multi-dimensional statistical profile.
*   **Advanced Efficiency Metrics:** Engineered custom features beyond traditional box score stats, including **True Shooting Percentage (TS%)** and **Effective Field Goal Percentage (eFG%)** to accurately measure scoring efficiency vs. volume.
*   **Head-to-Head Radar Comparisons:** A dedicated analytical tool that calculates league-wide percentiles and generates interactive polar/radar charts for direct player-to-player statistical comparisons.
*   **Team Net Rating Analysis:** Aggregates individual game data to evaluate team performance via Net Rating vs. Win Percentage scatter plots.
*   **Premium Interactive UI:** Designed with a clean, minimalist SaaS aesthetic using `bslib`, Google's Poppins font, and fully interactive `plotly` charts (hover tooltips, zooming, and dynamic rendering).

## 🛠️ Technology Stack

*   **Language:** R
*   **Web Framework:** Shiny, `bslib`
*   **Data Engineering:** `tidyverse` (dplyr, tidyr, readr)
*   **Time Series & Math:** `lubridate`, `zoo`
*   **Data Visualization:** `ggplot2`, `plotly` (interactive web charts)
*   **Data Tables:** `DT`

## 🚀 How to Run Locally

1. Clone this repository to your local machine.
2. Open `CourtIntelligence.Rproj` in RStudio.
3. Open `app.R`.
4. Click the **"Run App"** button in RStudio. (The script will automatically detect and install any missing packages).

## 📊 Dashboard Preview

> **Note to Author:** Take screenshots of the "Head-to-Head" tab and the "Machine Learning" tab and drag them into this README once you upload it to GitHub!

## 👨‍💻 Author

**[Your Name Here]** 
*Data Analyst / Data Scientist*
*   [LinkedIn](https://linkedin.com/in/yourprofile)
*   [GitHub](https://github.com/yourusername)
