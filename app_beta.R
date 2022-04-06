# Clean workspace
rm(list =ls())

#Set up packages
library(shiny)
library(shinydashboard)
library(shinyWidgets)
library(DT)
library(tidyverse)
library(highcharter)
library(leaflet)
library(sp)
library(rgdal)
library(exactextractr)
library(readxl)

## Laterite colors for graphs
laterite_1 <- c("#D6EDD8", "#7DD9BA", "#ABE1B9") # to be used for single-select graphs
laterite_2 <- c("#7DD9BA") # to be used for multiple-select graphs
laterite_3 <- c("#DA302C", "#F27317", "#241F21") # to be used for multiple-select LINE graphs (over time)
laterite_maps <- c("#7DD9BA") # to be used for bubbles in maps


#-------------------------------------------------------------------------------
# User Interface Elements-------------------------------------------------------
#-------------------------------------------------------------------------------

ui <- fluidPage(
  
#Title
tags$head(tags$title("Laterite - Geospatial Data")),
              
#Social Media Icon Colors
tags$style(".fa-facebook{color:#000000}"),
tags$style(".fa-linkedin{color:#000000}"),
tags$style(".fa-twitter{color:#000000}"),
tags$style("a{color:black; font-size:13px;}"),
tags$style(".textbox{font-size:14px; text-align:justify; border: 2px solid #DA302C; padding: 5px; box-shadow: 4px 4px 10px 2px #E8C4AA;}"),

setBackgroundColor(color = "#C5E3C6"), #background color
theme = "bootstrap_flatly.css", #css theme used
useShinydashboard(), #"activating" the shinydashboard package

## Header ----------------------------------------------------------------------

titlePanel(fluidRow(column(width=3, 
                           img(src ="laterite-logo-dark.svg", 
                               height = 70, width = 130)))),

## Body ------------------------------------------------------------------------

tabsetPanel(type = c("tabs"),
   
               
                  
### Tab 1 : Introduction #######################################################
tabPanel(h5(strong("Introduction")),
         
    #code for a line of whitespace
    fluidRow(style = "background-color:#FFFFFF;", br()), 

    fluidRow(style = "background-color:#FFFFFF;", 
             column(width = 6, offset = 3,
                    
                   #Welcome to the dashboardd
                   h2(style = "text-align: center;", "Welcome to the Laterite geospatial data dashboard!"), 
                   
                   #horizontal line
                   hr(), 
                   
                   #Quick description of the dashboard (to remove ?)
                   tags$p(style = "font-size:16px; text-align:justify; border: 2px solid #DA302C; border-radius: 25px; padding: 20px;", 
                          "This tool will allow you to obtain data on many different geospatial variables for the four Laterite african countries. This data can be used to gain more insights on most research projects, so feel free to take a look. Geospatial data can be accessed in two ways : First, it can be accessed for specific GPS coordinates, for example ones you would get with survey data. Then, it can also be accessed for specific administrative units (e.g. regions, districts, or below) for which the resulting data is some descriptive statistics about how the geospatial variables are distributed in that unit.")))
), 



### Tab 2 : Variables ##########################################################
tabPanel(h5(strong("Variables")),
         
  fluidRow(style = "background-color:#FFFFFF;", br()),
  
  #Title : Variables description
  fluidRow(style = "background-color:#FFFFFF;", column(width = 8, offset = 1, br(h1("Variables description")))),
  
  #Instructions : Choose a country to get a description of ...
  fluidRow(style = "background-color:#FFFFFF;", column(width = 8, offset = 1, 
                                                       tags$p(class = "textbox", "Choose a country to get a description of all the geospatial variables that are available for that country. For each variable, you will get information such as its source, its theme and at what resolution it is available."))),
  
  fluidRow(style = "background-color:#FFFFFF;", br()),
  
  #Selecting the input country
  fluidRow(style = "background-color:#FFFFFF;", column(width = 3, offset = 1, 
                                                       selectInput("countrySelectVar", h4("Select Country"),c("Ethiopia", "Kenya",  "Rwanda", "Uganda")))),
  
  #outputing the corresponding datatable
  fluidRow(style = "background-color:#FFFFFF;", column(width = 10, offset = 1, 
                                                       DT::dataTableOutput("vardesc")))
  ),



### Tab 3 : From GPS coordinates ###############################################
tabPanel(h5(strong("From GPS coordinates")),
         
  fluidRow(style = "background-color:#FFFFFF;", br()),
  
  #Title : Loading GPS coordinates
  fluidRow(style = "background-color:#FFFFFF;", column(width = 8, offset = 1, 
                                                       br(h1("Loading GPS coordinates")))),
  
  #Instructions : Select a CSV file containing GPS coordinates for which ...
  fluidRow(style = "background-color:#FFFFFF;", column(width = 8, offset = 1, 
                                                       tags$p(class = "textbox", "Select a CSV file containing GPS coordinates for which you want to extract geospatial data, and the country they're situated in. Then, select the variables that represent the longitude and the latitude in your data."))),
  
  fluidRow(style = "background-color:#FFFFFF;", br()), 

  #Selecting the input country
  fluidRow(style = "background-color:#FFFFFF;", column(width = 3, offset = 1, 
                                                       selectInput("countryselect", h4("Select Country"),c("Ethiopia", "Kenya",  "Rwanda", "Uganda")))),
  
  #Row containing 4 columns :
  fluidRow(style = "background-color:#FFFFFF;", 
           
           #File choice
           column(width = 3, offset = 1,
                  fileInput("surveydata", label = h4("Enter survey data CSV"), buttonLabel = h4("Browse"), accept = c("text/csv", "text/comma-separated-values,text/plain",".csv"))), 
           
           #Selecting the longitude variable of the file
           column(width = 3, uiOutput("longitudevarSelect")), 
    
           #Selecting the latitude variable of the file
           column(width = 3, uiOutput("latitudevarSelect")), 
        
           #Go button
           column(width = 1, uiOutput("gobutton"))),
  
  #Leaflet map output
  fluidRow(style = "background-color:#FFFFFF;", 
           column(width = 10, offset = 1, conditionalPanel("input.gobtton", leafletOutput("map")))),
  
  
  uiOutput("variableSelectCoord"),
  
  uiOutput("varrep"),
  
  fluidRow(style = "background-color:#FFFFFF;", 
           column(width = 10, offset = 1, DT::dataTableOutput("summary"))),
  
  fluidRow(style = "background-color:#FFFFFF;", br()),
  
  fluidRow(style = "background-color:#FFFFFF;", 
           column(width = 10, offset = 1, conditionalPanel("input.plot", highchartOutput("varplot")))),
  
  #download button
  uiOutput("downloadCoord"),
  ),



### Tab 4 : By administrative units ############################################
tabPanel(h5(strong("By administrative units")),
         
  fluidRow(style = "background-color:#FFFFFF;", br()),
  
  #Title : Administrative Unit Selection
  fluidRow(style = "background-color:#FFFFFF;", column(width = 8, offset = 1, 
                                                       br(h1("Administrative Unit Selection")))),
  
  #Instructions : Select the country you're interested in and click ...
  fluidRow(style = "background-color:#FFFFFF;", column(width = 8, offset = 1, 
                                                       tags$p(class = "textbox", "Select the country you're interested in and click on the button. It may take some time because all the administrative units from that country have to be loaded."))),
  
  fluidRow(style = "background-color:#FFFFFF;", br()),
  
  #Row containing 2 columns
  fluidRow(style = "background-color:#FFFFFF;", 
           
           #Selecting input country
           column(width = 3, offset = 1, selectInput("countrySelectUnit",h4("Select Country"),c("Ethiopia", "Kenya",  "Rwanda", "Uganda"))), 
           
           #Go button
           actionButton("unitsbutton", h3("Load units"), icon("layer-group"), class = "btn-outline-success btn-lg")),
  
  uiOutput("unitchoice"),
  
  fluidRow(style = "background-color:#FFFFFF;", 
           column(width = 10, offset = 1, conditionalPanel("input.addUnitButton", leafletOutput("unitsMap")))),
  
  uiOutput("variableSelectUnit"),
  
  fluidRow(style = "background-color:#FFFFFF;", br()),
  
  fluidRow(style = "background-color:#FFFFFF;", column(width = 9, offset = 1, 
                                                       DT::dataTableOutput("unitStats"))),
  
  #download button
  uiOutput("downloadUnit")
  )


), 

## Footer ----------------------------------------------------------------------
fluidRow(style= "background-color:#C5E3C6;",column(width=2, br())),
fluidRow(style= "background-color:#C5E3C6;",column(width=2, br())),
fluidRow(style= "background-color:#C5E3C6;",column(width=2, br())),
fluidRow(style= "background-color:#C5E3C6;",column(width=2, br())),

#Row containing 3 columns
fluidRow(style = "background-color:#C5E3C6;",
         
         #Laterite logo and social media
         column(width=2, offset = 1, 
                tags$a(href= "https://www.laterite.com/", img(src ="laterite-logo-dark.svg", height = 80, width = 150)), 
                br(), 
                tags$a(href="https://web.facebook.com/Laterite/?_rdc=1&_rdr",icon("facebook", lib = "font-awesome")), 
                tags$a(href="https://twitter.com/LateriteAfrica", icon("twitter", lib = "font-awesome")), 
                tags$a(href="https://www.linkedin.com/company/laterite", icon("linkedin",lib = "font-awesome"))),
         
         #Contact us
         column(width=2, offset = 1, 
                br(),br(), 
                h3(strong("Get in touch")), 
                tags$a(href = "https://www.laterite.com/contact/", "Contact us")), 
         
         #Laterite's motto
         column(width = 2, offset = 2, 
                br(), br(), 
                h3(strong("From data to policy")), 
                tags$a(href="https://www.laterite.com/services/data-collection/", "Data |"), 
                tags$a(href="https://www.laterite.com/services/research-services/", "Research |"), 
                tags$a(href = "https://www.laterite.com/services/advisory-services/", "Advisory "))),

fluidRow(style= "background-color:#C5E3C6;",column(width=2, br())),
fluidRow(style= "background-color:#C5E3C6;",column(width=2, br())),
fluidRow(style= "background-color:#C5E3C6;",column(width=2, br())),
fluidRow(style= "background-color:#C5E3C6;",column(width=2, br())),
fluidRow(style= "background-color:#C5E3C6;")
)


#-------------------------------------------------------------------------------
#Server-------------------------------------------------------------------------
#-------------------------------------------------------------------------------

server <- shinyServer(function(input, output, session) {
  
#Introduction Page--------------------------------------------------------------
  
#Variables Page-----------------------------------------------------------------

#Computes the variable's table for the selected country
output$vardesc <- DT::renderDataTable({
  
  #Call to the datatable function (DT package)
  datatable(
    
    #fetching the data according to the selected country
    data = read.csv(paste0("Data/", input$countrySelectVar, "/", input$countrySelectVar, "_variables.csv")), 
    
    #other parameters
    class = "hover cell-border", 
    rownames = FALSE, 
    options = list(pageLength = 50, searchHighlight = TRUE, orderClasses = TRUE, initComplete = JS(
    "function(settings, json) {",
    "$(this.api().table().header()).css({'background-color': '#7DD9BA', 'color': '#fff'});",
    "}")
    )
  )
})


#From GPS coordinates Page------------------------------------------------------

#Loads the csv file chosen by the user
surveydata <- reactive({
  req(input$surveydata) #req() checks for required values
  filepath <- input$surveydata$datapath
  
  #if the file is a .csv
  if (grepl("\\.csv$", filepath)){
    read.csv(filepath)
  } 
  
  #if the file is a .xlsx
  else if (grepl("\\.xlsx$", filepath)){
    read_excel(filepath)
  }
})


#Chooses which is the Latitude Variable
output$latitudevarSelect = renderUI({
  req(surveydata())
  selectInput("lat", h4("Select Latitude Variable"), names(surveydata()))
})


#Chooses which is the Longitude Variable
output$longitudevarSelect = renderUI({
  req(surveydata())
  selectInput("lon", h4("Select Longitude Variable"), names(surveydata()))
})


#Go button
output$gobutton <- renderUI({
  req(input$surveydata)
  actionButton("gobtton", h3("Go!"), icon("globe-africa"), class = "btn-outline-success btn-lg")
})


#Upon activation of the Go button : modifies the csv table
surveydata_coord <- eventReactive(input$gobtton, {
  req(input$surveydata, input$lat, input$lon)
  
  #if the lat / long chosen variables are different : 
  if(input$lat != input$lon){
    
    #renames the lat/long columns
    rename(surveydata(), lat = input$lat, lon = input$lon) %>% 
      
      #removes any other column of the table other than those 2
      select(lon, lat) %>% 
      
      #convert them to numeric if they are character (from excel import)
      mutate_if(is.character,as.numeric)
  }
})


#Computes the leaflet map
output$map <- renderLeaflet({
  coord <- req(surveydata_coord())
  
  leaflet(coord) %>% 
    addTiles() %>% 
    addCircleMarkers(color = "#DA302C", radius = 1, opacity = 0.5)
})


#The chosen country is made into a new variable 
country <- eventReactive(input$gobtton, {
  req(input$countryselect)
})


### Giving the choice of variables to the user ###

getVarBox <- function(src, country, tab){
  # Function that returns a box which contains checkboxes for all the variables available from a given source
  # Inputs : scr : character indicating the source of the data
  #          country : character indicating the country
  #          tab : 
  
  #listing all resolution folders (in the Country-Src-Res-Variable architecture)
  res <- list.dirs(paste0("Data/", country, "/", src), full.names = FALSE)[-1]
  res <- res[!grepl("/", res)]
  
  #initialization of the variable lists
  vars_unique <- list()
  vars_multi <- list()
  
  #looping over resolution folders
  for(r in res){
    
    #Variables with multiple obs. are obtained based on folders in the res folder
    vars_multi[[r]] <- list.dirs(paste0("Data/", country, "/", src, "/", r), full.names = TRUE)[-1]
    names(vars_multi[[r]]) <- unname(sapply(vars_multi[[r]], 
                                            function(x){ substr(x, max(which(strsplit(x, "")[[1]]=="/")) + 1, nchar(x))}))
    
    #Unique variables are obtained from single files in the res folder
    vars_unique[[r]] <- setdiff(list.files(paste0("Data/", country, "/", src, "/", r), full.names = TRUE), vars_multi[[r]])
    names(vars_unique[[r]]) <- unname(sapply(vars_unique[[r]], 
                                             function(x){ substr(x, max(which(strsplit(x, "")[[1]]=="/")) + 1, nchar(x) - 4)}))
  }
  
  #initialization of the big checkbox, as a list object
  checkbox <- list()
  
  #looping over resolution folders
  for(r in res){
    
    ## checkbox group input for variables with single obs.
    checkbox[[length(checkbox)+1]] <- checkboxGroupInput(inputId = paste0(tab, "var", src, r), 
                                                         label = h3(r), 
                                                         choiceNames = names(vars_unique[[r]]), 
                                                         choiceValues = unname(vars_unique[[r]]))
    
    ## select inputs for variables with multiple obs.
    
    #looping over observations
    for(i in seq_len(length(vars_multi[[r]]))){
      
      #current obs
      v <- vars_multi[[r]][i]
      
      #listing files
      choices <- list.files(v, full.names = TRUE)
      
      #renaming the choices
      names(choices) <- unname(sapply(choices, 
                                      function(x){ substr(x, max(which(strsplit(x, "")[[1]]=="/")) + 1 + nchar(names(v)), nchar(x) - 4)}))
      
      #select input is appended to the big checkbox
      checkbox[[length(checkbox)+1]] <- selectInput(inputId = paste0(tab, "var", src, names(v)), 
                                                    choices = choices, 
                                                    multiple = TRUE, 
                                                    label = names(v))
    }
  }

#creating the big checkbox
box(title = h1(src, align = "center", style = "color: #FFFFFF"), width = NULL, solidHeader = TRUE, collapsible = TRUE, collapsed = TRUE, status = "success", checkbox)
}

#Managing variable selection
output$variableSelectCoord <- renderUI({
  req(surveydata_coord())
  
  #the output here is rendered as a tag list
  tags <- tagList()
  
  #Title and instructions for the selection of variables
  tags[[1]] <- fluidRow(style = "background-color:#FFFFFF;", br())
  tags[[2]] <- fluidRow(style = "background-color:#FFFFFF;", column(width = 8, offset = 1,  br(h1("Geospatial variables selection"))))
  tags[[3]] <- fluidRow(style = "background-color:#FFFFFF;", br(), column(width = 8, offset = 1, HTML("<p class = 'textbox'> Now, select the geospatial variables you want extracted for your data. The variables are sorted by sources and resolutions, and they can be selected by checking the box next to them. For variables with multiple time observations available, you can select any you want by clicking on the input bar.</p>")))
  tags[[4]] <- fluidRow(style = "background-color:#FFFFFF;", br())
  
  #listing the available sources
  src <- list.dirs(paste0("Data/", country()), recursive = FALSE, full.names = FALSE)
  
  #for each source, call to the getVarBox function, to create the checkbox
  box <- lapply(src, getVarBox, country = country(), tab = "coord")
  
  i <- 1
  #iterating over the box list, with the following condition:
  while(i+2 <= length(box)){ #controls the display of boxes (rows of 3 boxes)
    
     tags[[length(tags)+1]] <- fluidRow(style = "background-color:#FFFFFF;", 
                                        
                                        column(width = 3, offset = 1, box[[i]]), #box 1
                                        column(width = 3, box[[i+1]]), #box 2
                                        column(width = 3, box[[i+2]])) #box 3
     i <- i+3
  }
  
  #dealing with remaining boxes that did not make a complete row of 3
  if (i < length(box)){
    tags[[length(tags)+1]] <- fluidRow(style = "background-color:#FFFFFF;", 
                                       column(width = 3, offset = 1, box[[i]]), 
                                       column(width = 3, box[[i+1]]))}
  if(i == length(box)){
    tags[[length(tags)+1]] <- fluidRow(style = "background-color:#FFFFFF;", 
                                       column(width = 3, offset = 1, box[[i]]))}
  
  tags[[length(tags)+1]] <- fluidRow(style = "background-color:#FFFFFF;", br())
  
  #Extract action button
  tags[[length(tags)+1]] <- fluidRow(style = "background-color:#FFFFFF;", column(width = 3, offset = 1, actionButton("coordextractbutton", h3("Extract"), icon("table"), class = "btn-outline-success btn-lg")))
  
  tags #"returning" the rendered tag list
})


### Extracting the chosen geospatial variables for the loaded GPS coordinates ###

#Upon activation of the extract button : extracting the values of the chosen variables for the GPS coordinates
geoDataCoord <- eventReactive(input$coordextractbutton, {
  
  #initializing the loading bar
  progress <-  Progress$new()
  progress$set(message = "Please wait.", value = 0)
  progress$inc(1, detail = 'Extracting...')
  
  #Getting the variables that were checked and putting them in a list
  vars <- unname(unlist(isolate(reactiveValuesToList(input))[grepl("coordvar", names(input))])) 
  
  #Getting the resolutions of these variables
  res <- factor(unlist(lapply(vars, function(x){ slash <- gregexpr("/", x)[[1]]                   
                                   substr(x, slash[3]+1, slash[4]-1 )})))
  
  #Separating the variables per resolution to know which ones to stack together
  vars_res <- list()
  for(l in levels(res)){
    vars_res[[l]] <- vars[res==l]   
  }
  
  data <- surveydata_coord() #processed data from the csv
  stacks <- list()
  for(i in 1:length(levels(res))){
    
    #key step : extracting the extracting the values of the chosen variables for the GPS coordinates (raster package)
    stacks[[i]] <- raster::extract(raster::stack(vars_res[[i]]), data) 
  }
  
  #closing the progress widget
  progress$close()
  
  #merging the original survey data with the variables
  cbind(surveydata(), do.call("cbind", stacks))
})


### Making the user choose a geospatial variable from the extracted data to plot (histogram for continuous) and give a statistical summary ###

#Title and instructions for the section
output$varrep <- renderUI({
  req(geoDataCoord())
  
  tagList(
    fluidRow(style = "background-color:#FFFFFF;", br()),
    
    #Title : Geospatial variables distribution
    fluidRow(style = "background-color:#FFFFFF;", column(width = 8, offset = 1, 
                                                         br(h1("Geospatial variables distribution")))),
    
    fluidRow(style = "background-color:#FFFFFF;", br()),
    
    #Instructions : For each of the extracted variables ...
    fluidRow(style = "background-color:#FFFFFF;", column(width = 8, offset = 1, 
                                                         tags$p(class = "textbox", "For each of the extracted variables, you can check a statistical summary and an histogram of its distribution among the GPS coordinates loaded."))),
    
    fluidRow(style = "background-color:#FFFFFF;", br()),
    
    #selectInput for the choice of the variable
    fluidRow(style = "background-color:#FFFFFF;", column(width = 4, offset = 1, 
                                                         selectInput("plot", h4("Select Variable"), setdiff(names(geoDataCoord()), names(surveydata())))))
  )
})


#Rendering the statistical datatable for the chosen variable
output$summary <- DT::renderDataTable({
  req(geoDataCoord())
  req(input$plot)
  
  v <- geoDataCoord()[, input$plot]
  
  #building the statistical sumlary
  df <- data.frame(Minimum = min(v,na.rm = TRUE), 
                   `First Quartile` = quantile(v, 0.25,na.rm = TRUE), 
                   Median = median(v,na.rm = TRUE), 
                   Mean = mean(v,na.rm = TRUE), 
                   `Third Quartile` = quantile(v, 0.25,na.rm = TRUE), 
                   Maximum = max(v,na.rm = TRUE), 
                   `Standard Deviation` = sd(v,na.rm = TRUE))
  
  df <- apply(df, c(1,2), round, digits = 2) #rounding values
  
  #call to datatable function (DT package)
  datatable(data = df, 
            class = "hover cell-border", 
            rownames = FALSE, 
            options = list(ordering = FALSE, dom = "t", initComplete = JS(
              "function(settings, json) {",
              "$(this.api().table().header()).css({'background-color': '#7DD9BA', 'color': '#fff'});",
              "}")
  )
  )
})


#Rendering the histogram for the chosen variable
output$varplot <- renderHighchart({
  req(geoDataCoord())
  req(input$plot)
  
  #building histogram
  h <- hchart(hist(geoDataCoord()[, input$plot]), color = "#7DD9BA", name = input$plot, showInLegend = FALSE)
})


### Downloading the obtained geospatial data as a CSV ###

#Download handler
output$downloadDataCoord <- downloadHandler(
  filename = function() {
    paste0(substr(input$surveydata$name, 0, nchar(input$surveydata$name)-4), "_Geospatial.csv")
  },
  content = function(file) {
    
    #writing csv and replacing NAs to empty strings (issue n°8)
    write.csv(geoDataCoord(), file, row.names = FALSE)
  },
  contentType = "text/csv"
)

#Title and instructions for the section
output$downloadCoord <- renderUI({
  req(geoDataCoord())
  
  tagList(
    fluidRow(style = "background-color:#FFFFFF;", br()),
    
    #Title : Data Exportation
    fluidRow(style = "background-color:#FFFFFF;", column(width = 8, offset = 1, br(h1("Data Exportation")))),
    
    #Instructions : You can choose to export the extracted data as a CSV ...
    fluidRow(style = "background-color:#FFFFFF;", br(), column(width = 8, offset = 1, HTML("<p class = 'textbox'> You can choose to export the extracted data as a CSV. The CSV you obtain will be the original loaded CSV along with the variables you selected for each row.</p>"))),
    
    fluidRow(style = "background-color:#FFFFFF;", br()),
    
    #download button
    fluidRow(style = "background-color:#FFFFFF;", column(width = 6, offset = 1, downloadButton("downloadDataCoord", h3("Export as CSV"), class = "btn-outline-success btn-lg"))),
    
    fluidRow(style = "background-color:#FFFFFF;", br())
  )
})


#By administrative units Page---------------------------------------------------

#Names of the variable representing the name of the administrative units, to update if the shape files change
unitsvarnames <- eventReactive(input$unitsbutton, { #upon activation of the units button
  
  req(input$countrySelectUnit)
  switch(input$countrySelectUnit, "Ethiopia" = c("REGIONNAME", "ZONENAME", "WOREDANAME"),
         "Rwanda" = c("NAME_1", "NAME_2", "NAME_3", "NAME_4", "NAME_5"),
         "Kenya" = c("NAME_1", "NAME_2", "NAME_3", "NAME_4", "NAME_5"),
         "Uganda" = c("NAME_1", "NAME_2", "NAME_3", "NAME_4") 
  )
})

#Names of the variable representing the code of the administrative units, to update if the shape files change
unitsvarcodes <- eventReactive(input$unitsbutton, { #upon activation of the units button
  
  req(input$countrySelectUnit)
  switch(input$countrySelectUnit, "Ethiopia" = c("RID", "Z4ID", "WOREDANO_"),
         "Rwanda" = c("ID_1", "ID_2", "ID_3", "ID_4", "ID_5"),
         "Kenya" = c("ID_1", "ID_2", "ID_3", "ID_4", "ID_5"),
         "Uganda" = c("ID_1", "ID_2", "ID_3", "ID_4") 
  )
})

#Loads the shapefiles for the selected country into the variable 'units'
units <- eventReactive(input$unitsbutton, {
  req(input$countrySelectUnit)
  
  #initializing the loading bar
  progress <-  Progress$new()
  progress$set(message = "Please wait.", value = 0)
  
  #listing files for the country
  levels <- list.dirs(paste0("Data/shapes/", input$countrySelectUnit))[-1]
  
  units <- lapply(levels, function(l) {
    progress$inc(1/length(levels), detail = paste("Loading shapefile", l))
    shp <- list.files(l, full.names = FALSE)[1]
    readOGR(l, substr(shp, 0, nchar(shp) - 4))
  })
  names(units) <- lapply(levels, function(x) { substr(x, regexpr("_", x)[[1]] + 1, nchar(x))})
  
  #closing the loading widget
  progress$close()
  
  units
})

#Creates multiple dropdown select inputs allowing the user to choose the administrative units they're interested in
output$unitchoice <- renderUI({
  req(units())
  
  #importing objects
  units <- units()
  varnames <- unitsvarnames()
  varcodes <- unitsvarcodes()
  
  #the output here is rendered as a tag list
  tags <- tagList()
  
  tags[[1]] <- fluidRow(style = "background-color:#FFFFFF;", br())
  tags[[2]] <- fluidRow(style = "background-color:#FFFFFF;", br())
  
  #Instructions for the AU selection : You can now pick the administrative units ...
  tags[[3]] <- fluidRow(style = "background-color:#FFFFFF;", column(width = 8, offset = 1, HTML("<p class = 'textbox'>You can now pick the administrative units you want by selecting them through the dropdown menus and clicking the Add Unit button. As you add units to your selection, they will also appear on the map.</p>")))
  
  tags[[4]] <- fluidRow(style = "background-color:#FFFFFF;", br())
  
  #creating the selecting inputs in a list
  listUnits <- paste(names(units)[1], units[[1]][[varcodes[1]]], "-", units[[1]][[varnames[1]]], sep = " ")
  names(listUnits) <- units[[1]][[varnames[1]]] 
  select <- list(selectInput(inputId = paste0("unit", names(units)[1]), label = h4(paste0("Select ", names(units)[1])), choices = listUnits))
  
  if(input$countrySelectUnit != "Ethiopia"){
    
    for(i in 2:length(units)){
      namevar <- varnames[i]
      codevar <- varcodes[i]
      nametopvar <- varnames[i-1]
      codetopvar <- varcodes[i-1]
      output[[paste0("out", names(units)[i])]] <- eval(parse(text = paste0("renderUI({
        topunit <- req(input[[paste0('unit', names(units)[", i, "-1])]])
        if(topunit != 'None'){
              spaces <- gregexpr(' ', topunit)[[1]]
              topunitcode <- substr(topunit, spaces[1] + 1, spaces[2] - 1)
              subunits <- base::subset(units[[", i, "]], ", codetopvar, " == topunitcode)
              if(length(subunits) > 0) {
                listSubunits <- paste(names(units)[", i, "], subunits$", codevar, ", '-', subunits$", namevar, ", sep = ' ')
                names(listSubunits) <- subunits$", namevar, "
              }
              else listSubunitd <- c()
        }
        else listSubunits <- c()
        selectInput(inputId = paste0('unit', names(units)[", i, "]), label = h4(paste0('Select ', names(units)[", i, "])), choices = c('None', listSubunits), selected = 'None')
      })")))
      select[[i]] <- uiOutput(paste0("out", names(units)[i]))
    }
    
  } else {
    
    for(i in 2:length(units)){
      namevar <- varnames[i]
      codevar <- varcodes[i]
      output[[paste0("out", names(units)[i])]] <- eval(parse(text = paste0("renderUI({
        topunit <- req(input[[paste0('unit', names(units)[", i, "-1])]])
        if(topunit != 'None'){
              spaces <- gregexpr(' ', topunit)[[1]]
              topunitcode <- substr(topunit, spaces[1] + 1, spaces[2] - 1)
              subunits <- base::subset(units[[", i, "]], substr(", codevar, ", 0, 2*(", i, "-1)) == topunitcode)
              if(length(subunits) > 0) {
                listSubunits <- paste(names(units)[", i, "], subunits$", codevar, ", '-', subunits$", namevar, ", sep = ' ')
                names(listSubunits) <- subunits$", namevar, "
              }
              else listSubunits <- c()
        }
        else listSubunits <- c()
        selectInput(inputId = paste0('unit', names(units)[", i, "]), label = h4(paste0('Select ', names(units)[", i, "])), choices = c('None', listSubunits), selected = 'None')
      })")))
      select[[i]] <- uiOutput(paste0("out", names(units)[i]))
    }
    
  }
  
  i <- 1
  while(i+2 <= length(select)){
    tags[[length(tags)+1]] <- fluidRow(style = "background-color:#FFFFFF;", column(width = 3, offset = 1, select[[i]]), column(width = 3, select[[i+1]]), column(width = 3, select[[i+2]]))
    i <- i+3
  }
  if(i < length(select)) tags[[length(tags)+1]] <- fluidRow(style = "background-color:#FFFFFF;", column(width = 3, offset = 1, select[[i]]), column(width = 3, select[[i+1]]))
  if(i == length(select)) tags[[length(tags)+1]] <- fluidRow(style = "background-color:#FFFFFF;", column(width = 3, offset = 1, select[[i]]))
  tags[[length(tags)+1]] <- fluidRow(style = "background-color:#FFFFFF;", column(width = 3, offset = 1, actionButton("addUnitButton", h4("Add unit"), icon("map-marked"), class = "btn-outline-success btn-lg")))
  tags[[length(tags)+1]] <- fluidRow(style = "background-color:#FFFFFF;", br())
  tags[[length(tags)+1]] <- fluidRow(style = "background-color:#FFFFFF;", column(width = 3, offset = 1, selectInput("listChosenUnits", label = "Chosen units", choices = NULL, multiple = TRUE)))
  tags
})

#upon activation of the addUnit button : updates the "Chosen Units" field
observeEvent(input$addUnitButton, {
  
  #importing variables
  units <- req(units())
  varcodes <- unitsvarcodes()
  
  #initializing with None
  chosenunit <- "None"
  i <- length(units)
  
  #while the field is blank
  while(chosenunit == "None" & i>0) {
    chosenunit <- input[[paste0("unit", names(units)[i])]]
    i <- i-1
  }
  
  #if a unit was added
  if(chosenunit != "None") {
    newchosenunits <- c(input$listChosenUnits, chosenunit)
    updateSelectInput(session, inputId = "listChosenUnits", choices = c(chosenunit, input$listChosenUnits), selected = c(chosenunit, input$listChosenUnits))
  }
})

#computes chosen units
chosenUnits <- reactive({
  
  #importing R variables
  units <- req(units())
  listChosen <- req(input$listChosenUnits)
  varcodes <- req(unitsvarcodes())
  
  unitNames <- list()
  
  l <- lapply(listChosen, function(unit){
    spaces <- gregexpr(" ", unit)[[1]]
    unitType <- substr(unit, 0, spaces[1] - 1)
    unitID <- substr(unit, spaces[1] + 1, spaces[2] - 1)
    varcode <- varcodes[which(names(units) == unitType)]
    eval(parse(text = paste0("subset(units[[unitType]], ", varcode, " == unitID)")))
  })
  
  #setting listChosen's elements as names for l
  setNames(l, listChosen)
})

#Creates the polygons corresponding to the chosen units
chosenUnitsPolygons <- reactive({
  req(input$listChosenUnits)
  chosenunits <- req(chosenUnits())
  
  poly <- list() #initial list of polygons : empty
  
  for(i in seq_len(length(chosenunits))){
    poly[[i]] <- chosenunits[[i]]@polygons[[1]]
    poly[[i]]@ID <- as.character(i)
  }
  
  names <- lapply(names(chosenunits), function(x){
    spaces <- gregexpr(" ", x)[[1]]
    substr(x, spaces[3] + 1, nchar(x))
  })
  list(polygons = poly, names = names)
})

#Shows the chosen administrative units as polygons on a map
output$unitsMap <- renderLeaflet({
  chosenunitspoly <- req(chosenUnitsPolygons())
  
  #creating the leaflet map
  leaflet(SpatialPolygons(chosenunitspoly$polygons)) %>% 
    addTiles() %>% 
    addPolygons(label = chosenunitspoly$names, color = "#DA302C", weight = 4, 
                labelOptions = labelOptions(noHide = T, direction = "bottom", 
                                            style = list("color" = "#DA302C","font-family" = "serif","box-shadow" = "3px 3px rgba(0,0,0,0.25)","font-size" = "12px","border-color" = "rgba(0,0,0,0.5)")))
})

#Gives the choice of variables to the user, like in the GPS coordinates page and also the statistics they want for these variables
output$variableSelectUnit <- renderUI({
  req(units())
  
  #the output here is rendered as a tag list
  tags <- tagList()
  tags[[1]] <- fluidRow(style = "background-color:#FFFFFF;", br())
  
  #Title : Geospatial variables selection
  tags[[2]] <- fluidRow(style = "background-color:#FFFFFF;", column(width = 8, offset = 1,  br(h1("Geospatial variables selection"))))
  
  #Instructions : Now, select the geospatial variables...
  tags[[3]] <- fluidRow(style = "background-color:#FFFFFF;", br(), column(width = 8, offset = 1, HTML("<p class = 'textbox'> Now, select the geospatial variables you want extracted for your data. The variables are sorted by sources and resolutions, and they can be selected by checking the box next to them. For variables with multiple time observations available, you can select any you want by clicking on the input bar. For administrative units, the returned data represents statistics which have been computed on all the raster cells present in that unit. For that reason, you also have to select which one of these statistics you want to have.</p>")))
  
  tags[[4]] <- fluidRow(style = "background-color:#FFFFFF;", br())
  
  #listing the available sources
  src <- list.dirs(paste0("Data/", input$countrySelectUnit), recursive = FALSE, full.names = FALSE)
  
  #for each source, call to the getVarBox function, to create the checkbox
  box <- lapply(src, getVarBox, country = input$countrySelectUnit, tab = "unit")
  
  #iterating over the box list, with the following condition:
  i <- 1 
  while(i+2 <= length(box)){#controls the display of boxes (rows of 3 boxes)
    tags[[length(tags)+1]] <- fluidRow(style = "background-color:#FFFFFF;", column(width = 3, offset = 1, box[[i]]), column(width = 3, box[[i+1]]), column(width = 3, box[[i+2]]))
    i <- i+3
  }
  
  #dealing with remaining boxes that did not make a complete row of 3
  if(i < length(box)){
    tags[[length(tags)+1]] <- fluidRow(style = "background-color:#FFFFFF;", 
                                       column(width = 3, offset = 1, box[[i]]), 
                                       column(width = 3, box[[i+1]]))
  }
  
  if(i == length(box)){
    tags[[length(tags)+1]] <- fluidRow(style = "background-color:#FFFFFF;", 
                                       column(width = 3, offset = 1, box[[i]]))
  }
  
  tags[[length(tags)+1]] <- fluidRow(style = "background-color:#FFFFFF;", br())
  
  #choice of the statistics
  tags[[length(tags)+1]] <- fluidRow(style = "background-color:#FFFFFF;", column(width = 11, offset = 1, checkboxGroupInput("stats", label = h3("Choose statistics"), inline = TRUE, choiceValues = list("min", "max", "mean", "quantile", "median", "variance", "stdev"), choiceNames = list(h4("Min"), h4("Max"), h4("Mean"), h4("First and third quartile"), h4("Median"), h4("Variance"), h4("Standard Deviation")) )))
  
  tags[[length(tags)+1]] <- fluidRow(style = "background-color:#FFFFFF;", br())
  
  #extract button
  tags[[length(tags)+1]] <- fluidRow(style = "background-color:#FFFFFF;", column(width = 3, offset = 1, actionButton("unitextractbutton", h3("Extract"), icon("table"), class = "btn-outline-success btn-lg")))
  
  tags
})

#Extracts the chosen statistics for the chosen geospatial variables for each of the chosen administrative units
geoDataUnit <- eventReactive(input$unitextractbutton, {
  stats <- req(input$stats)
  chosenUnits <- req(chosenUnits())
  
  #initializing the loading bar
  progress <-  Progress$new()
  progress$set(message = "Please wait.", value = 0)
  progress$inc(1/1, detail = "Extracting...")
  
  #Getting the variables that were checked and putting them in a list
  vars <- unname(unlist(isolate(reactiveValuesToList(input))[grepl("unitvar", names(input))]))
  
  #Getting the resolutions of these variables
  res <- factor(unlist(lapply(vars, function(x){ slash <- gregexpr("/", x)[[1]] 
  
  substr(x, slash[3]+1, slash[4]-1 )})))
  vars_res <- list()
  for(l in levels(res)){
    vars_res[[l]] <- vars[res==l]   #Separating the variables per resolution to know which ones to stack together
  }
  
  stacks <- list()
  for(i in seq_len(length(levels(res)))){
    ras <- raster::stack(vars_res[[i]])
    values <- list()
    for(j in seq_len(length(chosenUnits))){
      values[[j]] <- exact_extract(ras, chosenUnits[[j]], fun = stats, full_colnames = TRUE, quantiles = c(0.25, 0.75))
    }
    stacks[[i]] <- do.call("rbind", values)
  }
  table <- do.call("cbind", stacks)
  row.names(table) <- names(chosenUnits)
  
  #closing progress widget
  progress$close()
  
  table
})


#Showing the results, i.e a table with one row for each chosen administrative units and the chosen statistics as columns
output$unitStats <- DT::renderDataTable({
  table <- req(geoDataUnit())
  table <- apply(table, c(1,2), round, digits = 2)
  datatable(table, class = "hover cell-border", options = list(ordering = FALSE, dom = "t", scrollX = TRUE,  initComplete = JS(
    "function(settings, json) {",
    "$(this.api().table().header()).css({'background-color': '#7DD9BA', 'color': '#fff'});",
    "}")
  )
  )
})

#Making these geospatial statistics available to download as a CSV
output$downloadDataUnit <- downloadHandler(
  filename = function() {
    paste0("Geospatial_Data_", input$countrySelectUnit, ".csv")
  },
  content = function(file) {
    write.csv(geoDataUnit(), file)
  },
  contentType = "text/csv"
)

#Generates the section for downloading the unit
output$downloadUnit <- renderUI({
  req(geoDataUnit())
  tagList(
    fluidRow(style = "background-color:#FFFFFF;", br()),
    fluidRow(style = "background-color:#FFFFFF;", br()),
    fluidRow(style = "background-color:#FFFFFF;", br()),
    fluidRow(style = "background-color:#FFFFFF;", br()),
    
    #Title : "Data exportation"
    fluidRow(style = "background-color:#FFFFFF;", column(width = 8, offset = 1, br(h1("Data Exportation")))),
    
    #Instructions : "You can choose to export the extracted.."
    fluidRow(style = "background-color:#FFFFFF;", br(), 
             column(width = 8, offset = 1, HTML("<p class = 'textbox'> You can choose to export the extracted data as a CSV. The CSV you obtain will be the summary table you can see above.</p>"))),
    
    fluidRow(style = "background-color:#FFFFFF;", br()),
    
    #download unit button
    fluidRow(style = "background-color:#FFFFFF;", column(width = 6, offset = 1, downloadButton("downloadDataUnit", h3("Export as CSV"), class = "btn-outline-success btn-lg"))),
    fluidRow(style = "background-color:#FFFFFF;", br())
  )
})


})

#Launching the app
shinyApp(ui = ui, server = server)

