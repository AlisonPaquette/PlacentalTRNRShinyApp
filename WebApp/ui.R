#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)

# Load global variables
source("global.R")

# Define UI for Pre-term Birth TF/Gene Association App
shinyUI(fluidPage(
  theme = "style.css",

  div(style = "padding: 1px 0px; width: '100%'",
          titlePanel(title = "", windowTitle = "Placental Gene-TF Associations")),

  navbarPage(

  # Application title
  title = div("Placental Gene-TF Associations"),

  tabPanel(

    "Gene Search",

    sidebarLayout(

      # Sidebar where inputs are specified
      sidebarPanel(

        # Selection input to specify by gene
        uiOutput("gene_choice_input"),

        # Select which filter options to use (if any)
        checkboxGroupInput("gene_filter_by", label = "Filter by:",
                           choices = dt_column_labels[-c(1:2, 6)], inline = TRUE),

        # Filter by Correlation
        conditionalPanel(
          condition = sprintf( "input.gene_filter_by.includes(\'%s\')", dt_column_labels[3] ),
          uiOutput("gene_filter_by_correlation")
        ),

        # Filter by P-value
        conditionalPanel(
          condition = sprintf( "input.gene_filter_by.includes(\'%s\')", dt_column_labels[4] ),
          uiOutput("gene_filter_by_pvalue")
        ),

        # Filter by Q-value
        conditionalPanel(
          condition = sprintf( "input.gene_filter_by.includes(\'%s\')", dt_column_labels[5] ),
          uiOutput("gene_filter_by_qvalue")
        ),

        tags$hr(),

        # Provide option to download the filtered results
        downloadButton("gene_download", label = "Download Results")
      ),

      # Generate a table of associated TFs (for specified gene)
      mainPanel(
        wellPanel(
            DT::dataTableOutput("gene_results_table")
        )
      )
    )
  ),

  tabPanel(

    "TF Search",

    sidebarLayout(

      # Sidebar where inputs are specified
      sidebarPanel(

        # Selection input to specify by TF
        uiOutput("tf_choice_input"),

        # Select which filter options to use (if any)
        checkboxGroupInput("tf_filter_by", label = "Filter by:",
                           choiceNames = list(
                             dt_column_labels[3],
                             dt_column_labels[4],
                             dt_column_labels[5],
                             HTML("R<sup>2</sup>")),
                           choiceValues = dt_column_labels[-(1:2)],
                           inline = TRUE),

        # Filter by Correlation
        conditionalPanel(
          condition = sprintf( "input.tf_filter_by.includes(\'%s\')", dt_column_labels[3] ),
          uiOutput("tf_filter_by_correlation")
        ),

        # Filter by P-value
        conditionalPanel(
          condition = sprintf( "input.tf_filter_by.includes(\'%s\')", dt_column_labels[4] ),
          uiOutput("tf_filter_by_pvalue")
        ),

        # Filter by Q-value
        conditionalPanel(
          condition = sprintf( "input.tf_filter_by.includes(\'%s\')", dt_column_labels[5] ),
          uiOutput("tf_filter_by_qvalue")
        ),

        # Filter by R2-value
        conditionalPanel(
          condition = sprintf( "input.tf_filter_by.includes(\'%s\')", dt_column_labels[6] ),
          uiOutput("tf_filter_by_r2value")
        ),

        tags$hr(),

        # Provide option to download the filtered results
        downloadButton("tf_download", label = "Download Results")
      ),

      # Generate a table of associated genes (for specified TF)
      mainPanel(
        wellPanel(
            DT::dataTableOutput("tf_results_table")
        )
      )
    )
  ),

  tabPanel(

    "Enrichment Analysis",

    sidebarLayout(

      # Sidebar where inputs are specified
      sidebarPanel(

        # File selection
        fileInput("file1", "Upload Gene List", multiple = FALSE,
                  accept = c("text/csv", "text/comma-separated-values,text/plain", ".txt")),

        tags$hr(),

        numericInput('module_min', 'Module Min:', 10, min = 2, max = 500),

        numericInput('module_max', "Module Max:", 1000, min = 10, max = 9000),

        numericInput('min_significant', "Min Significant Genes:", 5, min = 2, max = 200),

        tags$hr(),

        # Provide option to download the filtered results
        downloadButton("enrich_download", label = "Download Enrichment Results")
      ),

      # Generate a table of associated TFs (for specified gene)
      mainPanel(
        wellPanel(
            DT::dataTableOutput("enrich_results_table")
        )
      )
    )
  )

  )
))
