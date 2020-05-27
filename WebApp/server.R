#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(dplyr)
library(DT)

# Load global variables
source("global.R")

# Define server logic required to display associated TFs or genes
shinyServer(function(input, output) {
    
    # Load TF/gene association data (assumes file is in same location as server.R)
    # Also, load R-squared table and merge with TF/Gene association data
    file_data <- reactive({
        
        # TF/Gene association data
        file_name <- "Data/Placental_Gene_TF_Associations.csv"
        data <- read.csv(file_name)
        
        # Target gene R-squared data
        file_name <- "Data/Target_Gene_Rsquared.csv"
        rsquared <- read.csv(file_name)
        
        # Left-join TF/Gene association data with R-squared data
        data <- left_join(data, rsquared, by = 'targetGene')
        
        # Now get just the desired columns
        data <- data[, df_column_order]
    })
    
    # Get TF names (unique)
    tf_choices <- reactive({
        data <- file_data()
        levels(factor(data$TF))
    })
    
    # Get gene names (unique)
    gene_choices <- reactive({
        data <- file_data()
        levels(factor(data$targetGene))
    })
    
    # Get the filtered table to display
    filtered_results <- reactive({
        
        # Get gene-TF association data
        data <- file_data()
        
        # Get TFs for a specified gene
        if( input$tf_or_gene == search_options[1] ){
            
            # Get gene choice and return if NULL
            choice <- input$gene_choice
            if( is.null(choice) ) return(NULL)
            
            data <- filter(data, targetGene == choice)
            
        }
        
        # Get genes for a specified TF
        if( input$tf_or_gene == search_options[2] ) {
            
            # Get TF choice and return if NULL
            choice <- input$tf_choice
            if( is.null(choice) ) return(NULL)
            
            data <- filter(data, TF == choice)
        }
        
        # Filter by correlation value range (if selected)
        if( dt_column_labels[3] %in% input$filter_by ) {
            
            # Filter for correlation values inside specified range
            if( input$range_type == range_type_options[1] ){
                data <- filter(data, (Cor >= input$corr[1]) & (Cor <= input$corr[2]))
            }
            
            # Filter for values outside specified range
            if(input$range_type == range_type_options[2]) {
                data <- filter(data, (Cor <= input$corr[1]) | (Cor >= input$corr[2]))
            }
        }
        
        # Filter by P-value (if selected)
        if( dt_column_labels[4] %in% input$filter_by ) {
            data <- filter(data, P <= 10^input$p_value)
        }
        
        # Filter by Q-value (if selected)
        if( dt_column_labels[5] %in% input$filter_by ) {
            data <- filter(data, Q <= 10^input$q_value)
        }
        
        # Filter by R-squared value (if selected)
        if( dt_column_labels[6] %in% input$filter_by ) {
            data <- filter(data, RSquared >= input$r2_value)
        }
        
        return(data)
    })
    
    # Selection input if specifying gene
    output$gene_choice_input <- renderUI({
        selectInput("gene_choice", label = NULL, gene_choices())
    })
    
    # Selection input if specifying transcription factor
    output$tf_choice_input <- renderUI({
        selectInput("tf_choice", label = NULL, tf_choices())
    })
    
    # Filter by Correlation
    output$filter_by_correlation <- renderUI({
        div(
            tags$hr(),
            
            # Used to specify a minimum and maximum range of correlation values to filter for
            sliderInput("corr", "Correlation", min = -1, max = 1,
                        value = c(-1, 1), step = 0.1, ticks = TRUE),
            
            # Explains what the range filtering option does
            tags$em("Keep results for which correlation is:"),
            
            # Select whether to filter for results inside or outside the range
            radioButtons("range_type", label = NULL,
                         choices = range_type_options, selected = range_type_options[1],
                         inline = TRUE)
        )
    })
    
    # Filter by P-value
    output$filter_by_pvalue <- renderUI({
        div(
            tags$hr(),
            
            # Used to specify a maximum p-value cutoff
            sliderInput("p_value", "P-value (log base 10)", min = -50, max = 0, 
                        value = 0, step = 2, ticks = TRUE),
            
            # Explains what the p-value filtering option does
            tags$em("Keep results for which the P-value is less than or equal to this value")
        )
    })
    
    # Filter by Q-value
    output$filter_by_qvalue <- renderUI({
        div(
            tags$hr(),
            
            # Used to specify a maximum Q-value cutoff
            sliderInput("q_value", "Q-value (log base 10)", min = -50, max = 0, 
                        value = 0, step = 2, ticks = TRUE),
            
            # Explains what the Q-value filtering option does
            tags$em("Keep results for which the Q-value is less than or equal to this value")
        )
    })
    
    # Filter by R2-value
    output$filter_by_r2value <- renderUI({
        div(
            tags$hr(),
            
            # Used to specify a minimum R-squared cutoff
            sliderInput("r2_value", "R-squared", min = 0, max = 1, 
                        value = 0, step = 0.1, ticks = TRUE),
            
            # Explains what the R-squared filtering option does
            tags$em("Keep results for which the R-squared value is greater than or equal to this value")
        )
    })
    
    # Data table shows filtered results
    output$results_table <- DT::renderDataTable({
        # Data table options
        dt_options <- list(pageLength = 10, 
                           lengthMenu = list(c(-1, 10, 20, 50, 100), c('All', '10', '20', '50', '100')),
                           searching = TRUE)
        
        # Get data for display
        data <- filtered_results()
        
        # Display if there is data available
        if( !is.null(data) ){
            
            # Format the table and display
            data <- format(data, digit = 3)
            DT::datatable(data, options = dt_options, colnames = dt_column_labels)
            
        }
        
    })
    
    # Results download functionality
    output$download <- downloadHandler(
        
        # Generate a default file name
        filename = function() {
            
            # Get user selection (gene or TF) to go into file name
            user_selection <- ifelse( input$tf_or_gene == search_options[1], 
                                      input$gene_choice, input$tf_choice )
            
            # File name
            paste("echo-data-", user_selection, "-", Sys.Date(), ".csv", sep = "")
        },
        
        # Write filtered results out to file
        content = function(file) {
            write.csv(filtered_results(), file)
        }
    )

})

