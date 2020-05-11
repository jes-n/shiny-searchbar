demoui <- function(name, title, msg=NULL, ...) {
  searchbarid = paste(name, "sb", sep="_")
  textid = paste(name, "text", sep="_")

  wellPanel(
    fluidRow(
      column(width=4,
        tags$h4(title),
        if (!is.null(msg)) tags$p(HTML(msg), class="text-muted"),

        searchbar(searchbarid, context=textid, 
          placeholder="Search text here...", ...
        )
      ),

      column(width=8, textOutput(
        textid,
        container = function(...) 
          tags$div(..., style="border: 1px solid #ccc; background-color: #fff; height: 125px; overflow-y: scroll; white-space: pre-wrap;")
      ))
    )
  )
}

ui <- function(id) {
  ns <- shiny::NS(id)

  tagList(
    demoui(ns("full"),
      title = "Shiny Searchbar is an interactive and responsive widget to search and highlight text",
      msg   = paste(
        "Highly configurable, automatic scrolling, and result count feedback,",
        "try searching for shinySearchbar!",
        sep="<br>"
      ),
      cycler=TRUE, counter=TRUE
    ),

    demoui(ns("basic"),
      title = "Basic search term highlighting",
      msg   = sprintf("Highlighting is done using %s.", tags$a("mark.js", href="https://markjs.io/", target="_blank"))
    ),

    demoui(ns("cycler"),
      title = "Cycle through the matches (now with automatic scrolling!)",
      msg   = "Cycling works with the buttons or Enter (next) and Shift+Enter (prev).",
      cycler=TRUE
    ),

    demoui(ns("counter"),
      title = "Display the number of search term matches",
      msg   = "Try not matching anything! (Hint: the coloring is done with CSS)",
      counter=TRUE
    )
  )
}

server <- function(input, output, session) {
  output$`full_text` <- renderText(addtext(lorem[6:8]))

  output$`basic_text` <- renderText(addtext(lorem[1:2]))
  output$`cycler_text` <- renderText(addtext(lorem[2:4]))
  output$`counter_text` <- renderText(addtext(lorem[4:6]))
}