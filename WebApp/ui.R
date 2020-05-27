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
    
    # Application title
    titlePanel("Placental Gene-TF Associations"),
    
    sidebarLayout(
        
        # Sidebar where inputs are specified
        sidebarPanel(
            
            # Select option to specify TF or gene
            radioButtons("tf_or_gene", label = "Search by:", 
                         choices = search_options, selected = search_options[1],
                         inline = TRUE),
            
            # Selection input if specifying gene
            conditionalPanel(
                condition = sprintf("input.tf_or_gene == \'%s\'", search_options[1]),
                uiOutput("gene_choice_input")),
            
            # Selection input if specifying transcription factor
            conditionalPanel(
                condition = sprintf("input.tf_or_gene == \'%s\'", search_options[2]),
                uiOutput("tf_choice_input")),
            
            # Select which filter options to use (if any)
            checkboxGroupInput("filter_by", label = "Filter by:", 
                               choices = dt_column_labels[-(1:2)], inline = TRUE),
            
            # Filter by Correlation
            conditionalPanel(
                condition = sprintf( "input.filter_by.includes(\'%s\')", dt_column_labels[3] ),
                uiOutput("filter_by_correlation")
            ),
            
            # Filter by P-value
            conditionalPanel(
                condition = sprintf( "input.filter_by.includes(\'%s\')", dt_column_labels[4] ),
                uiOutput("filter_by_pvalue")
            ),
            
            # Filter by Q-value
            conditionalPanel(
                condition = sprintf( "input.filter_by.includes(\'%s\')", dt_column_labels[5] ),
                uiOutput("filter_by_qvalue")
            ),
            
            # Filter by R2-value
            conditionalPanel(
                condition = sprintf( "input.filter_by.includes(\'%s\')", dt_column_labels[6] ),
                uiOutput("filter_by_r2value")
            ),
            
            tags$hr(),
            
            # Provide option to download the filtered results
            downloadButton("download", label = "Download Results")
        ),

        # Generate a table of associated genes (for specified TF) or TFs (for specified gene)
        mainPanel(
            wellPanel(
                DT::dataTableOutput("results_table")
            )
        )
    )
))
