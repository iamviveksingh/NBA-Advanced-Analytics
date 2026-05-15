# Court Intelligence: NBA Advanced Analytics Engine

![R](https://img.shields.io/badge/r-%23276DC3.svg?style=for-the-badge&logo=r&logoColor=white)
![Shiny](https://img.shields.io/badge/Shiny-Data_Dashboard-blue?style=for-the-badge)
![Plotly](https://img.shields.io/badge/Plotly-Interactive_Visuals-orange?style=for-the-badge)

**[🚀 View the Live Interactive Dashboard Here!](https://iamviveksingh.shinyapps.io/NBA-Advanced-Analytics/)**

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

<img width="1918" height="902" alt="Screenshot 2026-05-15 234052" src="https://github.com/user-attachments/assets/89f66e09-9baa-4803-80da-4bc29da4345c" />
<img width="1918" height="898" alt="Screenshot 2026-05-15 234202" src="https://github.com/user-attachments/assets/56c47926-3add-4d15-aca1-3a71d49db6f7" />
<img width="1918" height="900" alt="Screenshot 2026-05-15 234147" src="https://github.com/user-attachments/assets/3169ad32-5959-4f61-a12c-6d04de3f4864" />
<img width="1917" height="903" alt="Screenshot 2026-05-15 234119" src="https://github.com/user-attachments/assets/45be4165-06b5-4767-8836-422ddf17faae" />

## 👨‍💻 Author

**[Vivek Singh]** 

