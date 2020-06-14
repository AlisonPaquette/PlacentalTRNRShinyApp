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
        data[, df_column_order]
    })

    # Generate results of enrichment analysis
    enrichment_results <- reactive({

        req(input$file1)
        req(input$module_min)
        req(input$module_max)
        req(input$min_significant)

        # Get gene list for enrichment analysis
        gene_list <- read.table(input$file1$datapath)

        # Load gene and transcription factor data
        data <- file_data()

        # Generate enrichment results
        TFTableFunction(data, gene_list$V1, input$module_min, input$module_max, input$min_significant)

    })

    # Get gene names (unique)
    gene_choices <- reactive({
        data <- file_data()
        levels(factor(data$targetGene))
    })

    # Get R2 value for gene association results
    gene_r2 <- reactive({
        data <- file_data()
        data <- group_by(data, targetGene)
        summarise(data, r2 = round(min(RSquared), digits = 3))
    })

    # Get TF names (unique)
    tf_choices <- reactive({
        data <- file_data()
        levels(factor(data$TF))
    })
    
    # Get the filter-by-gene table (of transcription factors) to display
    gene_filtered_results <- reactive({
        
        # Get gene-TF association data
        gene_data <- file_data()
            
        # Get gene choice and return if NULL
        gene_choice <- input$gene_choice
        if( is.null(gene_choice) ) return(NULL)

        gene_data <- filter(gene_data, targetGene == gene_choice)
        
        # Filter by correlation value range (if selected)
        if( dt_column_labels[3] %in% input$gene_filter_by ) {
            
            # Filter for correlation values inside specified range
            if( input$gene_range_type == range_type_options[1] ){
                gene_data <- filter(gene_data, (Cor >= input$gene_corr[1]) & (Cor <= input$gene_corr[2]))
            }
            
            # Filter for values outside specified range
            if(input$gene_range_type == range_type_options[2]) {
                gene_data <- filter(gene_data, (Cor <= input$gene_corr[1]) | (Cor >= input$gene_corr[2]))
            }
        }
        
        # Filter by P-value (if selected)
        if( dt_column_labels[4] %in% input$gene_filter_by ) {
            gene_data <- filter(gene_data, P <= 10^input$gene_p_value)
        }
        
        # Filter by Q-value (if selected)
        if( dt_column_labels[5] %in% input$gene_filter_by ) {
            gene_data <- filter(gene_data, Q <= 10^input$gene_q_value)
        }
        
        return(gene_data[df_column_order[-c(1, 6)]])
    })

    # Selection input if specifying gene
    output$gene_choice_input <- renderUI({
        div(
          tags$b("Gene Selection:"),
          tags$br(),
            tags$em("Type in a target gene or scroll to find and select"),
            selectInput("gene_choice", label = NULL, gene_choices())
        )
    })
    
    # Filter by Correlation
    output$gene_filter_by_correlation <- renderUI({
        div(
            tags$hr(),
            
            # Used to specify a minimum and maximum range of correlation values to filter for
            sliderInput("gene_corr", "Correlation", min = -1, max = 1,
                        value = c(-1, 1), step = 0.1, ticks = TRUE),
            
            # Explains what the range filtering option does
            tags$em("Keep results for which correlation is:"),
            
            # Select whether to filter for results inside or outside the range
            radioButtons("gene_range_type", label = NULL,
                         choices = range_type_options, selected = range_type_options[1],
                         inline = TRUE)
        )
    })
    
    # Filter by P-value
    output$gene_filter_by_pvalue <- renderUI({
        div(
            tags$hr(),
            
            # Used to specify a maximum p-value cutoff
            sliderInput("gene_p_value", "P-value (log base 10)", min = -50, max = 0,
                        value = 0, step = 2, ticks = TRUE),
            
            # Explains what the p-value filtering option does
            tags$em("Keep results for which the P-value is less than or equal to this value")
        )
    })
    
    # Filter by Q-value
    output$gene_filter_by_qvalue <- renderUI({
        div(
            tags$hr(),
            
            # Used to specify a maximum Q-value cutoff
            sliderInput("gene_q_value", "Q-value (log base 10)", min = -50, max = 0,
                        value = 0, step = 2, ticks = TRUE),
            
            # Explains what the Q-value filtering option does
            tags$em("Keep results for which the Q-value is less than or equal to this value")
        )
    })
    
    # Data table shows filtered results for a specified gene
    output$gene_results_table <- DT::renderDataTable({
        # Data table options
        dt_options <- list(paging = FALSE, searching = FALSE)
        
        # Get data for display
        gene_data <- gene_filtered_results()

        # Display if there is data available
        if( !is.null(gene_data) ){
            
            # Format the table and displays
            gene_data <- format(gene_data, digit = 3)
            DT::datatable(gene_data, options = dt_options, colnames = dt_column_labels[-c(1, 6)],
                          caption = HTML(paste0('<b>R<sup>2</sup> value:</b> ',
                                               filter(gene_r2(), targetGene == input$gene_choice)$r2)))
        }
        
    })
    
    # Results download functionality (filtered results for a specified gene)
    output$gene_download <- downloadHandler(
        
        # Generate a default file name
        filename = function() {
            
            # Get user selection (gene or TF) to go into file name
            user_selection <- input$gene_choice
            
            # File name
            paste0("GeneSearch-", user_selection, "-", Sys.Date(), ".csv")
        },
        
        # Write filtered results out to file
        content = function(file) {
            write.csv(gene_filtered_results(), file)
        }
    )

    # Get the filter-by-TF table (of genes) to display
    tf_filtered_results <- reactive({

        # Get gene-TF association data
        tf_data <- file_data()

        # Get TF choice and return if NULL
        tf_choice <- req(input$tf_choice)
        if( is.null(tf_choice) ) return(NULL)

        tf_data <- filter(tf_data, TF == tf_choice)

        # Filter by correlation value range (if selected)
        if( dt_column_labels[3] %in% input$tf_filter_by ) {

            # Get low and high cutoffs for correlation filter
            tf_corr <- req(input$tf_corr)

            # Filter for correlation values inside specified range
            if( input$tf_range_type == range_type_options[1] ){
                tf_data <- filter(tf_data, (Cor >= tf_corr[1]) & (Cor <= tf_corr[2]))
            }

            # Filter for values outside specified range
            if(input$tf_range_type == range_type_options[2]) {
                tf_data <- filter(tf_data, (Cor <= tf_corr[1]) | (Cor >= tf_corr[2]))
            }
        }

        # Filter by P-value (if selected)
        if( dt_column_labels[4] %in% input$tf_filter_by ) {
            tf_data <- filter(tf_data, P <= 10^req(input$tf_p_value))
        }

        # Filter by Q-value (if selected)
        if( dt_column_labels[5] %in% input$tf_filter_by ) {
            tf_data <- filter(tf_data, Q <= 10^req(input$tf_q_value))
        }

        # Filter by R-squared value (if selected)
        if( dt_column_labels[6] %in% input$tf_filter_by ) {
            tf_data <- filter(tf_data, RSquared >= req(input$tf_r2_value))
        }

        # Return results, dropping TF column and ordering by Q in ascending order)
        return(tf_data[df_column_order[-2]] %>% arrange(Q))
    })

    # Selection input if specifying gene
    output$tf_choice_input <- renderUI({
        div(
            tags$b("Transcription Factor Selection:"),
            tags$br(),
            tags$em("Type in a TF or scroll to find and select"),
            selectInput("tf_choice", label = NULL, tf_choices())
        )
    })

    # Filter by Correlation
    output$tf_filter_by_correlation <- renderUI({
        div(
            tags$hr(),

            # Used to specify a minimum and maximum range of correlation values to filter for
            sliderInput("tf_corr", "Correlation", min = -1, max = 1,
                        value = c(-1, 1), step = 0.1, ticks = TRUE),

            # Explains what the range filtering option does
            tags$em("Keep results for which correlation is:"),

            # Select whether to filter for results inside or outside the range
            radioButtons("tf_range_type", label = NULL,
                         choices = range_type_options, selected = range_type_options[1],
                         inline = TRUE)
        )
    })

    # Filter by P-value
    output$tf_filter_by_pvalue <- renderUI({
        div(
            tags$hr(),

            # Used to specify a maximum p-value cutoff
            sliderInput("tf_p_value", "P-value (log base 10)", min = -50, max = 0,
                        value = 0, step = 2, ticks = TRUE),

            # Explains what the p-value filtering option does
            tags$em("Keep results for which the P-value is less than or equal to this value")
        )
    })

    # Filter by Q-value
    output$tf_filter_by_qvalue <- renderUI({
        div(
            tags$hr(),

            # Used to specify a maximum Q-value cutoff
            sliderInput("tf_q_value", "Q-value (log base 10)", min = -50, max = 0,
                        value = 0, step = 2, ticks = TRUE),

            # Explains what the Q-value filtering option does
            tags$em("Keep results for which the Q-value is less than or equal to this value")
        )
    })

    # Filter by R2-value
    output$tf_filter_by_r2value <- renderUI({
        div(
            tags$hr(),

            # Used to specify a minimum R-squared cutoff
            sliderInput("tf_r2_value", HTML("R<sup>2</sup> value"), min = 0, max = 1,
                        value = 0, step = 0.1, ticks = TRUE),

            # Explains what the R-squared filtering option does
            HTML("<em>Keep results for which R<sup>2</sup> is greater than or equal to this value</em>")
        )
    })

    # Data table shows filtered results for a specified TF
    output$tf_results_table <- DT::renderDataTable({
        # Data table options
        dt_options <- list(pageLength = 10,
                           lengthMenu = list(c(-1, 10, 20, 50, 100), c('All', '10', '20', '50', '100')),
                           searching = TRUE,
                           language = list(search = "Search results for target gene:"))

        # Get data for display
        tf_data <- tf_filtered_results()

        # Display if there is data available
        if( !is.null(tf_data) ){

            # Format the table and display
            tf_data <- format(tf_data, digit = 3)
            DT::datatable(tf_data, options = dt_options,
                          colnames = list(dt_column_labels[1],
                                          dt_column_labels[3],
                                          dt_column_labels[4],
                                          dt_column_labels[5],
                                          HTML("R<sup>2</sup>")))
        }

    })

    # Results download functionality (filtered results for a specified TF)
    output$tf_download <- downloadHandler(

        # Generate a default file name
        filename = function() {

            # Get user selection (gene or TF) to go into file name
            user_selection <- input$tf_choice

            # File name
            paste0("TFSearch-", user_selection, "-", Sys.Date(), ".csv")
        },

        # Write filtered results out to file
        content = function(file) {
            write.csv(tf_filtered_results(), file)
        }
    )

    # Data table shows enrichment results
    output$enrich_results_table <- DT::renderDataTable({

        data <- enrichment_results()

       # Data table options
        dt_options <- list(pageLength = 10,
                           lengthMenu = list(c(-1, 10, 20, 50, 100), c('All', '10', '20', '50', '100')),
                           searching = TRUE,
                           language = list(search = "Search results for transcription factor:"))

        column_names <- list(dt_column_labels[2], "Num Targets",
                            "Significant Genes", "Fisher Test", "Fisher Adj P-value")

        # Display if there is data available
        if( !is.null(data) ){

            # Format the table and display
            data <- format(data, digit = 3)
            DT::datatable(data, options = dt_options, colnames = column_names)
        }

    })

    # Enrichment results download functionality
    output$enrich_download <- downloadHandler(

        # Generate a default file name
        filename = function() {

            # Get input file name to use for output file name
            input_file_root <- strsplit(input$file1$name, "\\.")[[1]]

            # File name
            paste0(input_file_root, "_EnrichResults_", Sys.Date(), ".csv")
        },

        # Write filtered results out to file
        content = function(file) {
            write.csv(enrichment_results(), file)
        }
    )

})
