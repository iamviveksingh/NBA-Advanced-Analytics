# app.R
# Enterprise-Grade NBA Advanced Analytics Dashboard
# Theme: Premium Journalistic (Serif Typography & Distinct Palettes)

required_packages <- c("shiny", "bslib", "tidyverse", "lubridate", "zoo", "viridis", "plotly", "bsicons", "DT")
new_packages <- required_packages[!(required_packages %in% installed.packages()[,"Package"])]
if(length(new_packages)) install.packages(new_packages, repos='https://cloud.r-project.org')

library(shiny)
library(bslib)
library(tidyverse)
library(lubridate)
library(zoo)
library(viridis)
library(plotly)
library(bsicons)
library(DT)

# ---------------------------------------------------------
# Data Engineering
# ---------------------------------------------------------
nba <- read_csv("data/nba_player_stats_2024.csv", show_col_types = FALSE) %>%
  mutate(game_date = ymd(game_date)) %>%
  filter(!is.na(points), !is.na(assists), !is.na(minutes))

player_season_stats <- nba %>%
  group_by(athlete_display_name) %>%
  summarise(
    games = n(),
    minutes_total = sum(minutes, na.rm = TRUE),
    points = sum(points, na.rm = TRUE),
    assists = sum(assists, na.rm = TRUE),
    rebounds = sum(rebounds, na.rm = TRUE),
    steals = sum(steals, na.rm = TRUE),
    blocks = sum(blocks, na.rm = TRUE),
    turnovers = sum(turnovers, na.rm = TRUE),
    fga = sum(field_goals_attempted, na.rm=TRUE),
    fgm = sum(field_goals_made, na.rm=TRUE),
    fta = sum(free_throws_attempted, na.rm=TRUE),
    fg3m = sum(three_point_field_goals_made, na.rm=TRUE),
    PPG = points / games, APG = assists / games, RPG = rebounds / games, SPG = steals / games, BPG = blocks / games,
    TS_pct = points / (2 * (fga + 0.44 * fta)),
    eFG_pct = (fgm + 0.5 * fg3m) / fga,
    .groups = "drop"
  ) %>%
  filter(games >= 15, minutes_total > 150) %>%
  mutate(TS_pct = ifelse(is.nan(TS_pct) | is.infinite(TS_pct), 0, TS_pct), eFG_pct = ifelse(is.nan(eFG_pct) | is.infinite(eFG_pct), 0, eFG_pct))

player_percentiles <- player_season_stats %>%
  mutate(
    `Scoring` = percent_rank(PPG) * 100, `Playmaking` = percent_rank(APG) * 100, `Rebounding` = percent_rank(RPG) * 100,
    `Defense` = percent_rank(SPG + BPG) * 100, `Efficiency` = percent_rank(TS_pct) * 100, `Volume` = percent_rank(fga) * 100
  )

cluster_data <- player_season_stats %>% select(PPG, APG, RPG, SPG, BPG, TS_pct) %>% scale()
set.seed(42)
kmeans_res <- kmeans(cluster_data, centers = 4, nstart = 25)
player_season_stats$Cluster <- as.factor(kmeans_res$cluster)

cluster_rank <- player_season_stats %>% group_by(Cluster) %>% summarise(avg_PPG = mean(PPG)) %>% arrange(desc(avg_PPG)) %>%
  mutate(Archetype = c("Superstars / Primary Engines", "High-Impact Starters", "Valuable Role Players", "Deep Rotation / Specialists"))

player_season_stats <- player_season_stats %>% left_join(cluster_rank %>% select(Cluster, Archetype), by="Cluster")
top15_players <- player_season_stats %>% arrange(desc(PPG)) %>% slice_head(n = 15)
all_players <- sort(unique(player_season_stats$athlete_display_name))

team_stats <- nba %>% distinct(game_id, team_id, .keep_all = TRUE) %>% group_by(team_display_name) %>%
  summarise(
    Games = n(), Wins = sum(team_winner == TRUE, na.rm=TRUE), Win_Pct = Wins / Games,
    Avg_Pts_For = mean(team_score, na.rm=TRUE), Avg_Pts_Against = mean(opponent_team_score, na.rm=TRUE), Net_Rating = Avg_Pts_For - Avg_Pts_Against
  ) %>% filter(!is.na(team_display_name))

# ---------------------------------------------------------
# UI - Premium Journalistic (Serif Typography & Distinct Palettes)
# ---------------------------------------------------------
ui <- page_navbar(
  title = "NBA Analytics",
  theme = bs_theme(
    version = 5, bg = "#F8F9FA", fg = "#212529", primary = "#000000", 
    base_font = font_google("Lora"), heading_font = font_google("Playfair Display")
  ),
  
  tags$head(
    tags$style(HTML("
      body { background-color: #F8F9FA; }
      .navbar { background-color: #FFFFFF !important; border-bottom: 2px solid #212529; box-shadow: none; }
      .navbar-brand { font-weight: 700; color: #000000 !important; letter-spacing: 0.5px; text-transform: uppercase; font-family: 'Playfair Display', serif; }
      .nav-link { font-weight: 500; color: #495057 !important; transition: all 0.2s; font-family: 'Lora', serif; }
      .nav-link:hover { color: #000000 !important; }
      .nav-link.active { color: #000000 !important; font-weight: 700; border-bottom: 2px solid #000000; }
      
      .card { background: #FFFFFF !important; border: 1px solid #DEE2E6 !important; border-radius: 4px !important; box-shadow: 0 2px 4px rgba(0,0,0,0.02) !important; margin-bottom: 1rem; transition: box-shadow 0.2s; }
      .card:hover { box-shadow: 0 4px 8px rgba(0,0,0,0.05) !important; }
      .card-header { background: #FFFFFF !important; border-bottom: 1px solid #E9ECEF !important; font-weight: 700; color: #212529; font-size: 1.1rem; border-top-left-radius: 4px !important; border-top-right-radius: 4px !important; font-family: 'Playfair Display', serif; }
      
      .bslib-sidebar-layout > .sidebar { border-right: 1px solid #DEE2E6; background-color: #F8F9FA; }
      
      /* DataTables Styling */
      .dataTables_wrapper { color: #212529 !important; font-family: 'Lora', serif; }
      .dataTables_length, .dataTables_filter, .dataTables_info, .dataTables_paginate { color: #495057 !important; }
      table.dataTable { border-collapse: collapse !important; font-family: 'Lora', serif; }
      table.dataTable thead th { border-bottom: 2px solid #212529 !important; color: #000000 !important; font-weight: 700; }
      table.dataTable tbody td { border-bottom: 1px solid #DEE2E6 !important; color: #212529 !important; }
      table.dataTable tbody tr:hover { background-color: #F8F9FA !important; }
      
      /* Tooltip icon styling */
      .info-icon { margin-left: 8px; cursor: help; color: #6C757D; font-size: 1.1rem; transition: color 0.2s; }
      .info-icon:hover { color: #000000; }
    "))
  ),
  
  nav_panel("Player Analytics", 
    layout_columns(col_widths = c(7, 5), 
      card(
        card_header(class="d-flex justify-content-between align-items-center", "Efficiency vs. Volume", tooltip(bs_icon("info-circle", class="info-icon"), "This chart shows how much a player scores (Volume) vs. how efficiently they score (True Shooting %). Players in the top-right corner are elite offensive engines.", placement="left")), 
        plotlyOutput("ts_scatter", height="550px")
      ), 
      card(
        card_header(class="d-flex justify-content-between align-items-center", "Top 15 Scorers", tooltip(bs_icon("info-circle", class="info-icon"), "The highest scoring players in the league. Color mapping indicates True Shooting efficiency.", placement="left")), 
        plotlyOutput("top15_plot", height="550px")
      )
    )
  ),
  
  nav_panel("Head-to-Head", 
    layout_sidebar(sidebar = sidebar(width = 300, selectInput("p1", "Player 1:", choices = all_players, selected = "LeBron James"), selectInput("p2", "Player 2:", choices = all_players, selected = "Stephen Curry")), 
      card(
        card_header(class="d-flex justify-content-between align-items-center", "Statistical Percentile Radar", tooltip(bs_icon("info-circle", class="info-icon"), "Compares players based on their percentile rank across the entire NBA. A score of 100 means they are the absolute best in the league at that specific skill. 50 is exactly league average.", placement="left")), 
        plotlyOutput("radar_plot", height="500px")
      )
    )
  ),
  
  nav_panel("Machine Learning", 
    card(
      card_header(class="d-flex justify-content-between align-items-center", "Unsupervised K-Means Clustering", tooltip(bs_icon("info-circle", class="info-icon"), "An AI-driven algorithm groups players into 4 Archetypes based on their statistical profile (Points, Assists, Defense). The size of the circle represents Rebounds Per Game.", placement="left")), 
        plotlyOutput("cluster_2d", height="600px")
    )
  ),
  
  nav_panel("Team Analytics", 
    card(
      card_header(class="d-flex justify-content-between align-items-center", "Team Power Rankings", tooltip(bs_icon("info-circle", class="info-icon"), "Net Rating is Team Points Scored minus Points Allowed. Teams in the top-right quadrant are Championship contenders. Teams in the bottom-left are struggling.", placement="left")), 
      plotlyOutput("team_plot", height="600px")
    )
  ),
  
  nav_panel("Data Explorer", 
    card(
      card_header(class="d-flex justify-content-between align-items-center", "Raw Advanced Stats Database", tooltip(bs_icon("info-circle", class="info-icon"), "Search, sort, and filter the raw advanced statistical data for every player in the dataset.", placement="left")), 
      DTOutput("raw_data_table")
    )
  )
)

# ---------------------------------------------------------
# Server
# ---------------------------------------------------------
server <- function(input, output, session) {
  
  plot_theme <- theme_minimal(base_size = 14) + 
    theme(text = element_text(color="#212529", family="Lora"), 
          axis.text = element_text(color="#495057"), 
          axis.title = element_text(color="#000000", face="bold", size=12),
          panel.grid.major = element_line(color="#E9ECEF"), panel.grid.minor = element_blank(),
          plot.background = element_rect(fill="#FFFFFF", color=NA), panel.background = element_rect(fill="#FFFFFF", color=NA))
  
  # Distinctive, contrast-heavy journalistic palette (Red, Orange, Teal, Navy)
  cat_colors <- c("#E63946", "#F4A261", "#2A9D8F", "#1D3557")
  
  output$ts_scatter <- renderPlotly({
    p <- ggplot(player_season_stats, aes(x = PPG, y = TS_pct, color = Archetype, size = minutes_total, text = paste("<b>", athlete_display_name, "</b><br>PPG:", round(PPG,1), "<br>TS%:", round(TS_pct*100,1), "%<br>Archetype:", Archetype))) +
      geom_point(alpha = 0.8) + geom_hline(yintercept = mean(player_season_stats$TS_pct), linetype="dashed", color="#ADB5BD") + geom_vline(xintercept = mean(player_season_stats$PPG), linetype="dashed", color="#ADB5BD") +
      scale_color_manual(values = cat_colors) + scale_y_continuous(labels = scales::percent) +
      labs(x = "Points Per Game (Volume)", y = "True Shooting Percentage (Efficiency)", color="") + plot_theme + theme(legend.position="none")
    ggplotly(p, tooltip="text") %>% layout(plot_bgcolor='#FFFFFF', paper_bgcolor='#FFFFFF', font=list(family="Lora")) %>% config(displayModeBar = FALSE)
  })
  
  output$top15_plot <- renderPlotly({
    p <- ggplot(top15_players, aes(x = reorder(athlete_display_name, PPG), y = PPG, fill = TS_pct, text = paste(athlete_display_name, "<br>PPG:", round(PPG,1), "<br>TS%:", round(TS_pct*100,1),"%"))) +
      geom_col(alpha=0.9, width=0.75) + coord_flip() + 
      scale_fill_viridis_c(option = "magma", direction = -1) + # Classic data science gradient
      labs(x = "", y = "Points Per Game") + plot_theme + theme(legend.position = "none")
    ggplotly(p, tooltip = "text") %>% layout(plot_bgcolor='#FFFFFF', paper_bgcolor='#FFFFFF', font=list(family="Lora")) %>% config(displayModeBar = FALSE)
  })
  
  output$radar_plot <- renderPlotly({
    req(input$p1, input$p2)
    p1_data <- player_percentiles %>% filter(athlete_display_name == input$p1) %>% select(Scoring, Playmaking, Rebounding, Defense, Efficiency, Volume) %>% pivot_longer(everything())
    p2_data <- player_percentiles %>% filter(athlete_display_name == input$p2) %>% select(Scoring, Playmaking, Rebounding, Defense, Efficiency, Volume) %>% pivot_longer(everything())
    
    plot_ly(type = 'scatterpolar', fill = 'toself') %>%
      add_trace(r = p1_data$value, theta = p1_data$name, name = input$p1, marker = list(color = "#E63946"), fillcolor = "rgba(230, 57, 70, 0.2)", line = list(color = "#E63946")) %>%
      add_trace(r = p2_data$value, theta = p2_data$name, name = input$p2, marker = list(color = "#1D3557"), fillcolor = "rgba(29, 53, 87, 0.2)", line = list(color = "#1D3557")) %>%
      layout(polar = list(radialaxis = list(visible = TRUE, range = c(0, 100), color="#6C757D", gridcolor="#DEE2E6", tickfont=list(color="#495057")), angularaxis = list(color="#212529", tickfont=list(size=13))),
             paper_bgcolor='#FFFFFF', plot_bgcolor='#FFFFFF', font=list(family="Lora", color="#212529"), legend = list(orientation="h", y=-0.1)) %>% config(displayModeBar = FALSE)
  })
  
  output$cluster_2d <- renderPlotly({
    p <- ggplot(player_season_stats, aes(x = PPG, y = APG, color = Archetype, size = RPG, text = paste("<b>", athlete_display_name, "</b><br>PPG:", round(PPG,1), "<br>APG:", round(APG,1), "<br>RPG:", round(RPG,1), "<br>Archetype:", Archetype))) +
      geom_point(alpha = 0.8) + scale_color_manual(values = cat_colors) + scale_size(range = c(3, 9), guide="none") +
      labs(x = "Points Per Game (Scoring)", y = "Assists Per Game (Playmaking)", color = "") + plot_theme + theme(legend.position="bottom")
    ggplotly(p, tooltip = "text") %>% layout(plot_bgcolor='#FFFFFF', paper_bgcolor='#FFFFFF', font=list(family="Lora"), legend = list(orientation="h", y=-0.2)) %>% config(displayModeBar = FALSE)
  })
  
  output$team_plot <- renderPlotly({
    p <- ggplot(team_stats, aes(x = Net_Rating, y = Win_Pct, color = Net_Rating, text = paste("<b>", team_display_name, "</b><br>Net Rating:", round(Net_Rating,1), "<br>Win%:", round(Win_Pct*100,1), "%"))) +
      geom_point(size = 5, alpha=0.9) + geom_hline(yintercept = 0.5, linetype="dashed", color="#ADB5BD") + geom_vline(xintercept = 0, linetype="dashed", color="#ADB5BD") +
      scale_color_gradient2(low="#E63946", mid="#F4A261", high="#2A9D8F", midpoint=0) +
      scale_y_continuous(labels = scales::percent) + labs(x = "Net Rating (Pts For - Pts Against)", y = "Win Percentage") + plot_theme + theme(legend.position="none")
    ggplotly(p, tooltip="text") %>% layout(plot_bgcolor='#FFFFFF', paper_bgcolor='#FFFFFF', font=list(family="Lora")) %>% config(displayModeBar = FALSE)
  })
  
  output$raw_data_table <- renderDT({
    data_display <- player_season_stats %>% select(Player = athlete_display_name, Archetype, Games = games, PPG, APG, RPG, SPG, BPG, TS_pct) %>%
      mutate(across(c(PPG, APG, RPG, SPG, BPG), ~round(., 1)), TS_pct = paste0(round(TS_pct * 100, 1), "%"))
    datatable(data_display, options = list(pageLength = 15, scrollX = TRUE, dom = 'Bfrtip'), class = 'display', rownames = FALSE) 
  })
}

shinyApp(ui = ui, server = server)
