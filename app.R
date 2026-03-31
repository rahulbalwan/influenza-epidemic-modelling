# app.R
# Influenza Epidemic Modelling Dashboard

library(shiny)
library(shinydashboard)
library(readr)
library(dplyr)
library(ggplot2)
library(tidyr)

# -----------------------------
# Load data
# -----------------------------
growth_summary <- read_csv("output/tables/growth_rate_summary.csv", show_col_types = FALSE)
r0_summary <- read_csv("output/tables/r0_summary.csv", show_col_types = FALSE)
seir_summary <- read_csv("output/tables/seir_summary.csv", show_col_types = FALSE)
sirs_summary <- read_csv("output/tables/sirs_model_summary.csv", show_col_types = FALSE)
fit_summary <- read_csv("output/tables/seir_model_fit_summary_growth_phase_2022_23.csv", show_col_types = FALSE)
comparison_summary <- read_csv("output/tables/seir_sirs_comparison_summary.csv", show_col_types = FALSE)
seasonal_sirs_summary <- read_csv("output/tables/seasonal_sirs_summary.csv", show_col_types = FALSE)
sensitivity_summary <- read_csv("output/tables/seir_sensitivity_analysis_summary.csv", show_col_types = FALSE)

flu_clean <- read_csv("data/processed/flu_clean.csv", show_col_types = FALSE)
flu_seasonal <- read_csv("data/processed/flu_seasonal.csv", show_col_types = FALSE)
fit_results <- read_csv("output/models/seir_model_fit_growth_phase_2022_23.csv", show_col_types = FALSE)
seir_output <- read_csv("output/models/seir_model_output.csv", show_col_types = FALSE)
sirs_output <- read_csv("output/models/sirs_model_output.csv", show_col_types = FALSE)
seasonal_sirs_output <- read_csv("output/models/seasonal_sirs_model_output.csv", show_col_types = FALSE)
sensitivity_outputs <- read_csv("output/models/seir_sensitivity_analysis_outputs.csv", show_col_types = FALSE)

# -----------------------------
# Add season variable to cleaned data
# -----------------------------
flu_clean <- flu_clean %>%
  mutate(
    season_start = ifelse(week >= 40, year, year - 1),
    season_end = season_start + 1,
    season = paste0(season_start, "-", season_end)
  )

# -----------------------------
# Helper function
# -----------------------------
save_current_plot <- function(plot_obj, file) {
  ggsave(filename = file, plot = plot_obj, width = 10, height = 6)
}

# -----------------------------
# UI
# -----------------------------
ui <- dashboardPage(
  dashboardHeader(title = "Influenza Modelling Dashboard"),

  dashboardSidebar(
    sidebarMenu(
      menuItem("Overview", tabName = "overview", icon = icon("house")),
      menuItem("EDA", tabName = "eda", icon = icon("chart-line")),
      menuItem("Growth and Fit", tabName = "fit", icon = icon("magnifying-glass-chart")),
      menuItem("Sensitivity Analysis", tabName = "sensitivity", icon = icon("sliders")),
      menuItem("Model Comparison", tabName = "comparison", icon = icon("scale-balanced")),
      br(),
      div(
        style = "padding: 12px; font-size: 12px; color: #b8c7ce;",
        HTML("Developed by Rahul")
      )
    )
  ),

  dashboardBody(
    tags$head(
      tags$style(HTML("
        .main-footer {
          background: #f9fafc;
          border-top: 1px solid #d2d6de;
          padding: 12px 18px;
          color: #444;
          font-size: 13px;
          margin-top: 20px;
        }
        .small-note {
          font-size: 13px;
          color: #555;
          line-height: 1.5;
        }
      "))
    ),

    tabItems(

      # -----------------------------
      # Overview
      # -----------------------------
      tabItem(
        tabName = "overview",
        fluidRow(
          valueBoxOutput("vb_growth", width = 3),
          valueBoxOutput("vb_r0", width = 3),
          valueBoxOutput("vb_fit_r0", width = 3),
          valueBoxOutput("vb_seasonal_peak", width = 3)
        ),
        fluidRow(
          box(
            width = 6, title = "Project summary", solidHeader = TRUE, status = "primary",
            p("This dashboard summarises the influenza epidemic modelling workflow, including exploratory analysis, wave detection, growth-rate estimation, reproduction number estimation, SEIR and SIRS simulations, model fitting, sensitivity analysis, and seasonal SIRS modelling.")
          ),
          box(
            width = 6, title = "Model comparison snapshot", solidHeader = TRUE, status = "primary",
            tableOutput("overview_comparison_table"),
            br(),
            downloadButton("download_overview_table", "Download table")
          )
        ),
        fluidRow(
          box(
            width = 6, title = "Key findings", solidHeader = TRUE, status = "info",
            tags$ul(
              tags$li("Influenza shows strong seasonal epidemic waves."),
              tags$li("The 2022–2023 season showed strong early exponential growth."),
              tags$li("Estimated reproduction number was slightly above 1."),
              tags$li("SEIR fits the early growth phase well."),
              tags$li("SIRS and seasonal SIRS provide more realistic long-term influenza dynamics.")
            )
          ),
          box(
            width = 6, title = "Notes for interpretation", solidHeader = TRUE, status = "warning",
            div(
              class = "small-note",
              p("SEIR fitting is based on the early epidemic growth phase of the 2022–2023 season."),
              p("SIRS and seasonal SIRS outputs are simulation-based model extensions."),
              p("Some model-comparison plots use scaled curves to compare epidemic shape and timing rather than literal fitted case counts.")
            )
          )
        )
      ),

      # -----------------------------
      # EDA
      # -----------------------------
      tabItem(
        tabName = "eda",
        fluidRow(
          box(
            width = 3, title = "Controls", solidHeader = TRUE, status = "primary",
            selectInput(
              "eda_plot",
              "Select plot",
              choices = c(
                "Weekly influenza time series",
                "Detected waves by season",
                "Seasonal wave overview"
              )
            ),
            selectInput(
              "season_select",
              "Select season",
              choices = sort(unique(flu_seasonal$season)),
              selected = "2022-2023"
            ),
            downloadButton("download_eda_plot", "Download plot"),
            br(), br(),
            downloadButton("download_eda_table", "Download table")
          ),
          box(
            width = 9, title = "EDA Plot", solidHeader = TRUE, status = "primary",
            plotOutput("eda_main_plot", height = "500px")
          )
        )
      ),

      # -----------------------------
      # Growth and Fit
      # -----------------------------
      tabItem(
        tabName = "fit",
        fluidRow(
          valueBoxOutput("vb_rmse", width = 4),
          valueBoxOutput("vb_mae", width = 4),
          valueBoxOutput("vb_peak_match", width = 4)
        ),
        fluidRow(
          box(
            width = 3, title = "Controls", solidHeader = TRUE, status = "primary",
            radioButtons(
              "fit_plot",
              "Select view",
              choices = c(
                "Observed vs fitted",
                "Residuals",
                "Fitted compartments"
              )
            ),
            downloadButton("download_fit_plot", "Download plot"),
            br(), br(),
            downloadButton("download_fit_table", "Download table")
          ),
          box(
            width = 9, title = "Growth-phase Fit", solidHeader = TRUE, status = "primary",
            plotOutput("fit_main_plot", height = "500px")
          )
        )
      ),

      # -----------------------------
      # Sensitivity Analysis
      # -----------------------------
      tabItem(
        tabName = "sensitivity",
        fluidRow(
          box(
            width = 3, title = "Controls", solidHeader = TRUE, status = "primary",
            selectInput(
              "sensitivity_plot",
              "Select sensitivity view",
              choices = c(
                "Peak infectious population",
                "Time to peak",
                "Final epidemic size",
                "Infectious curves"
              )
            ),
            selectInput(
              "sensitivity_parameter",
              "Highlight parameter",
              choices = c("beta", "latent_period", "infectious_period"),
              selected = "beta"
            ),
            downloadButton("download_sensitivity_plot", "Download plot"),
            br(), br(),
            downloadButton("download_sensitivity_table", "Download table")
          ),
          box(
            width = 9, title = "Sensitivity Analysis", solidHeader = TRUE, status = "primary",
            plotOutput("sensitivity_main_plot", height = "500px"),
            br(),
            tableOutput("sensitivity_table")
          )
        )
      ),

      # -----------------------------
      # Model Comparison
      # -----------------------------
      tabItem(
        tabName = "comparison",
        fluidRow(
          box(
            width = 3, title = "Controls", solidHeader = TRUE, status = "primary",
            radioButtons(
              "comparison_plot",
              "Select comparison",
              choices = c(
                "Observed vs SEIR and SIRS",
                "Observed vs Seasonal SIRS",
                "Peak comparison",
                "Final compartment comparison"
              )
            ),
            selectInput(
              "comparison_season",
              "Select season",
              choices = sort(unique(flu_seasonal$season)),
              selected = "2022-2023"
            ),
            downloadButton("download_comparison_plot", "Download plot"),
            br(), br(),
            downloadButton("download_comparison_table", "Download table")
          ),
          box(
            width = 9, title = "Model Comparison", solidHeader = TRUE, status = "primary",
            plotOutput("comparison_main_plot", height = "500px"),
            br(),
            tableOutput("comparison_table")
          )
        )
      )
    ),

    div(
      class = "main-footer",
      HTML("<strong>Developed by Rahul &nbsp;|&nbsp; Influenza Epidemic Modelling Dashboard </strong>")
    )
  )
)

# -----------------------------
# Server
# -----------------------------
server <- function(input, output, session) {

  # Value boxes
  output$vb_growth <- renderValueBox({
    valueBox(
      value = round(growth_summary$r_per_week[1], 3),
      subtitle = "Growth rate per week",
      icon = icon("chart-line"),
      color = "aqua"
    )
  })

  output$vb_r0 <- renderValueBox({
    valueBox(
      value = round(r0_summary$R0_est[1], 3),
      subtitle = "Estimated R₀",
      icon = icon("virus"),
      color = "green"
    )
  })

  output$vb_fit_r0 <- renderValueBox({
    valueBox(
      value = round(fit_summary$R0_est[1], 3),
      subtitle = "SEIR fitted R₀",
      icon = icon("microscope"),
      color = "yellow"
    )
  })

  output$vb_seasonal_peak <- renderValueBox({
    valueBox(
      value = round(seasonal_sirs_summary$peak_infectious[1], 0),
      subtitle = "Seasonal SIRS peak",
      icon = icon("wave-square"),
      color = "red"
    )
  })

  output$vb_rmse <- renderValueBox({
    valueBox(
      value = round(fit_summary$rmse[1], 1),
      subtitle = "Growth-phase RMSE",
      icon = icon("square-root-variable"),
      color = "purple"
    )
  })

  output$vb_mae <- renderValueBox({
    valueBox(
      value = round(fit_summary$mae[1], 1),
      subtitle = "Growth-phase MAE",
      icon = icon("ruler"),
      color = "teal"
    )
  })

  output$vb_peak_match <- renderValueBox({
    valueBox(
      value = as.character(fit_summary$date_peak_predicted[1]),
      subtitle = "Predicted peak date",
      icon = icon("calendar"),
      color = "navy"
    )
  })

  # Overview table
  output$overview_comparison_table <- renderTable({
    comparison_summary %>%
      mutate(across(where(is.numeric), ~ round(.x, 2)))
  })

  # EDA
  eda_data <- reactive({
    if (input$eda_plot == "Weekly influenza time series") {
      flu_clean %>% filter(season == input$season_select)
    } else {
      flu_seasonal %>% filter(season == input$season_select)
    }
  })

  eda_plot_obj <- reactive({
    df <- eda_data()

    if (input$eda_plot == "Weekly influenza time series") {
      ggplot(df, aes(x = date, y = positive)) +
        geom_line(linewidth = 1) +
        labs(
          title = paste("Weekly Influenza Cases:", input$season_select),
          x = "Date",
          y = "Positive cases"
        ) +
        theme_minimal()
    } else if (input$eda_plot == "Detected waves by season") {
      ggplot(df, aes(x = week, y = positive_smooth)) +
        geom_line(linewidth = 1) +
        labs(
          title = paste("Detected Influenza Wave:", input$season_select),
          x = "Week of year",
          y = "Smoothed positives"
        ) +
        theme_minimal()
    } else {
      ggplot(df, aes(x = date, y = positive_smooth)) +
        geom_line(linewidth = 1) +
        labs(
          title = paste("Seasonal Wave Overview:", input$season_select),
          x = "Date",
          y = "Smoothed positives"
        ) +
        theme_minimal()
    }
  })

  output$eda_main_plot <- renderPlot({
    eda_plot_obj()
  })

  # Fit
  fit_plot_obj <- reactive({
    if (input$fit_plot == "Observed vs fitted") {
      ggplot(fit_results, aes(x = date)) +
        geom_line(aes(y = positive_smooth, color = "Observed"), linewidth = 1) +
        geom_point(aes(y = positive_smooth, color = "Observed"), size = 2) +
        geom_line(aes(y = predicted_cases, color = "Fitted"), linewidth = 1, linetype = "dashed") +
        labs(
          title = "SEIR Fit to Early Growth Phase",
          x = "Date",
          y = "Cases",
          color = "Series"
        ) +
        theme_minimal()
    } else if (input$fit_plot == "Residuals") {
      ggplot(fit_results, aes(x = date, y = residual)) +
        geom_line(linewidth = 1) +
        geom_hline(yintercept = 0, linetype = "dashed") +
        labs(
          title = "Residuals from SEIR Growth-Phase Fit",
          x = "Date",
          y = "Residual"
        ) +
        theme_minimal()
    } else {
      fit_compartments <- fit_results %>%
        select(date, S, E, I, R) %>%
        pivot_longer(cols = c(S, E, I, R), names_to = "compartment", values_to = "value")

      ggplot(fit_compartments, aes(x = date, y = value, color = compartment)) +
        geom_line(linewidth = 1) +
        labs(
          title = "Fitted SEIR Compartments",
          x = "Date",
          y = "Number of individuals",
          color = "Compartment"
        ) +
        theme_minimal()
    }
  })

  output$fit_main_plot <- renderPlot({
    fit_plot_obj()
  })

  # Sensitivity
  sensitivity_filtered <- reactive({
    sensitivity_summary %>%
      filter(parameter_varied == input$sensitivity_parameter)
  })

  output$sensitivity_table <- renderTable({
    sensitivity_filtered() %>%
      mutate(across(where(is.numeric), ~ round(.x, 2)))
  })

  sensitivity_plot_obj <- reactive({
    if (input$sensitivity_plot == "Peak infectious population") {
      ggplot(sensitivity_filtered(), aes(x = scenario_value, y = peak_infectious)) +
        geom_line(linewidth = 1) +
        geom_point(size = 2) +
        labs(
          title = paste("Sensitivity Analysis:", input$sensitivity_parameter),
          x = "Scenario value",
          y = "Peak infectious population"
        ) +
        theme_minimal()
    } else if (input$sensitivity_plot == "Time to peak") {
      ggplot(sensitivity_filtered(), aes(x = scenario_value, y = time_to_peak)) +
        geom_line(linewidth = 1) +
        geom_point(size = 2) +
        labs(
          title = paste("Sensitivity Analysis:", input$sensitivity_parameter),
          x = "Scenario value",
          y = "Time to peak (days)"
        ) +
        theme_minimal()
    } else if (input$sensitivity_plot == "Final epidemic size") {
      ggplot(sensitivity_filtered(), aes(x = scenario_value, y = final_size)) +
        geom_line(linewidth = 1) +
        geom_point(size = 2) +
        labs(
          title = paste("Sensitivity Analysis:", input$sensitivity_parameter),
          x = "Scenario value",
          y = "Final epidemic size"
        ) +
        theme_minimal()
    } else {
      df <- sensitivity_outputs %>%
        filter(parameter_varied == input$sensitivity_parameter)

      ggplot(df, aes(x = time, y = I, group = scenario_value, color = as.factor(scenario_value))) +
        geom_line(linewidth = 1) +
        labs(
          title = paste("Sensitivity Curves:", input$sensitivity_parameter),
          x = "Time (days)",
          y = "Infectious individuals",
          color = "Scenario"
        ) +
        theme_minimal()
    }
  })

  output$sensitivity_main_plot <- renderPlot({
    sensitivity_plot_obj()
  })

  # Comparison
  comparison_observed <- reactive({
    flu_seasonal %>%
      filter(season == input$comparison_season) %>%
      arrange(date) %>%
      mutate(week_index = row_number())
  })

  comparison_seir_scaled <- reactive({
    obs <- comparison_observed()

    seir_output %>%
      mutate(week_index = floor(time / 7) + 1) %>%
      group_by(week_index) %>%
      summarise(I = mean(I), .groups = "drop") %>%
      filter(week_index <= nrow(obs)) %>%
      mutate(
        scaled_cases = I * max(obs$positive_smooth, na.rm = TRUE) / max(I, na.rm = TRUE),
        model = "SEIR"
      )
  })

  comparison_sirs_scaled <- reactive({
    obs <- comparison_observed()

    sirs_output %>%
      mutate(week_index = floor(time / 7) + 1) %>%
      group_by(week_index) %>%
      summarise(I = mean(I), .groups = "drop") %>%
      filter(week_index <= nrow(obs)) %>%
      mutate(
        scaled_cases = I * max(obs$positive_smooth, na.rm = TRUE) / max(I, na.rm = TRUE),
        model = "SIRS"
      )
  })

  comparison_seasonal_sirs_scaled <- reactive({
    obs <- comparison_observed()

    seasonal_sirs_output %>%
      mutate(week_index = floor(time / 7) + 1) %>%
      group_by(week_index) %>%
      summarise(I = mean(I), .groups = "drop") %>%
      filter(week_index <= nrow(obs)) %>%
      mutate(
        scaled_cases = I * max(obs$positive_smooth, na.rm = TRUE) / max(I, na.rm = TRUE),
        model = "Seasonal SIRS"
      )
  })

  output$comparison_table <- renderTable({
    obs <- comparison_observed()

    tibble(
      season = input$comparison_season,
      observed_peak = max(obs$positive_smooth, na.rm = TRUE),
      observed_peak_date = as.character(obs$date[which.max(obs$positive_smooth)]),
      seir_peak_scaled = max(comparison_seir_scaled()$scaled_cases, na.rm = TRUE),
      sirs_peak_scaled = max(comparison_sirs_scaled()$scaled_cases, na.rm = TRUE),
      seasonal_sirs_peak_scaled = max(comparison_seasonal_sirs_scaled()$scaled_cases, na.rm = TRUE)
    ) %>%
      mutate(across(where(is.numeric), ~ round(.x, 2)))
  })

  comparison_plot_obj <- reactive({
    obs <- comparison_observed()
    seir_df <- comparison_seir_scaled()
    sirs_df <- comparison_sirs_scaled()
    seasonal_df <- comparison_seasonal_sirs_scaled()

    if (input$comparison_plot == "Observed vs SEIR and SIRS") {
      ggplot() +
        geom_line(data = obs, aes(x = week_index, y = positive_smooth, color = "Observed"), linewidth = 1) +
        geom_line(data = seir_df, aes(x = week_index, y = scaled_cases, color = "SEIR"), linewidth = 1, linetype = "dashed") +
        geom_line(data = sirs_df, aes(x = week_index, y = scaled_cases, color = "SIRS"), linewidth = 1, linetype = "dotted") +
        labs(
          title = paste("Observed vs SEIR and SIRS:", input$comparison_season),
          x = "Week index within season",
          y = "Cases / scaled infections",
          color = "Series"
        ) +
        theme_minimal()
    } else if (input$comparison_plot == "Observed vs Seasonal SIRS") {
      ggplot() +
        geom_line(data = obs, aes(x = week_index, y = positive_smooth, color = "Observed"), linewidth = 1) +
        geom_line(data = seasonal_df, aes(x = week_index, y = scaled_cases, color = "Seasonal SIRS"), linewidth = 1, linetype = "dashed") +
        labs(
          title = paste("Observed vs Seasonal SIRS:", input$comparison_season),
          x = "Week index within season",
          y = "Cases / scaled infections",
          color = "Series"
        ) +
        theme_minimal()
    } else if (input$comparison_plot == "Peak comparison") {
      peak_df <- tibble(
        model = c("Observed", "SEIR", "SIRS", "Seasonal SIRS"),
        peak_value = c(
          max(obs$positive_smooth, na.rm = TRUE),
          max(seir_df$scaled_cases, na.rm = TRUE),
          max(sirs_df$scaled_cases, na.rm = TRUE),
          max(seasonal_df$scaled_cases, na.rm = TRUE)
        )
      )

      ggplot(peak_df, aes(x = model, y = peak_value, fill = model)) +
        geom_col() +
        labs(
          title = paste("Peak comparison:", input$comparison_season),
          x = "Model / observed",
          y = "Peak value"
        ) +
        theme_minimal() +
        theme(legend.position = "none")
    } else {
      comparison_long <- comparison_summary %>%
        pivot_longer(
          cols = c(final_susceptible, final_infectious, final_recovered),
          names_to = "compartment",
          values_to = "value"
        )

      ggplot(comparison_long, aes(x = compartment, y = value, fill = model)) +
        geom_col(position = "dodge") +
        labs(
          title = "Final compartment comparison (simulation summary)",
          x = "Compartment",
          y = "Number of individuals",
          fill = "Model"
        ) +
        theme_minimal()
    }
  })

  output$comparison_main_plot <- renderPlot({
    comparison_plot_obj()
  })

  # Downloads
  output$download_overview_table <- downloadHandler(
    filename = function() "overview_comparison_table.csv",
    content = function(file) {
      write.csv(comparison_summary, file, row.names = FALSE)
    }
  )

  output$download_eda_plot <- downloadHandler(
    filename = function() paste0("eda_plot_", input$season_select, ".png"),
    content = function(file) {
      save_current_plot(eda_plot_obj(), file)
    }
  )

  output$download_eda_table <- downloadHandler(
    filename = function() paste0("eda_table_", input$season_select, ".csv"),
    content = function(file) {
      write.csv(eda_data(), file, row.names = FALSE)
    }
  )

  output$download_fit_plot <- downloadHandler(
    filename = function() paste0("fit_plot_", gsub(" ", "_", tolower(input$fit_plot)), ".png"),
    content = function(file) {
      save_current_plot(fit_plot_obj(), file)
    }
  )

  output$download_fit_table <- downloadHandler(
    filename = function() "seir_fit_results.csv",
    content = function(file) {
      write.csv(fit_results, file, row.names = FALSE)
    }
  )

  output$download_sensitivity_plot <- downloadHandler(
    filename = function() paste0("sensitivity_", input$sensitivity_parameter, "_", gsub(" ", "_", tolower(input$sensitivity_plot)), ".png"),
    content = function(file) {
      save_current_plot(sensitivity_plot_obj(), file)
    }
  )

  output$download_sensitivity_table <- downloadHandler(
    filename = function() paste0("sensitivity_", input$sensitivity_parameter, ".csv"),
    content = function(file) {
      write.csv(sensitivity_filtered(), file, row.names = FALSE)
    }
  )

  output$download_comparison_plot <- downloadHandler(
    filename = function() paste0(
      "comparison_",
      input$comparison_season, "_",
      gsub(" ", "_", tolower(input$comparison_plot)),
      ".png"
    ),
    content = function(file) {
      save_current_plot(comparison_plot_obj(), file)
    }
  )

  output$download_comparison_table <- downloadHandler(
    filename = function() paste0("comparison_table_", input$comparison_season, ".csv"),
    content = function(file) {
      obs <- comparison_observed()

      out <- tibble(
        season = input$comparison_season,
        observed_peak = max(obs$positive_smooth, na.rm = TRUE),
        observed_peak_date = as.character(obs$date[which.max(obs$positive_smooth)]),
        seir_peak_scaled = max(comparison_seir_scaled()$scaled_cases, na.rm = TRUE),
        sirs_peak_scaled = max(comparison_sirs_scaled()$scaled_cases, na.rm = TRUE),
        seasonal_sirs_peak_scaled = max(comparison_seasonal_sirs_scaled()$scaled_cases, na.rm = TRUE)
      )

      write.csv(out, file, row.names = FALSE)
    }
  )
}

# -----------------------------
# Run app
# -----------------------------
shinyApp(ui = ui, server = server)