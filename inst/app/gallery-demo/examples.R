demoui <- function(name, placeholder=NULL, title=NULL, msg=NULL, ...) {
  searchbarid = paste(name, "sb", sep="_")
  textid = paste(name, "text", sep="_")

  tags$form(class="well", style="margin: 10px",
    fluidRow(
      column(width=3,
        if (!is.null(title)) tags$h4(title),

        searchbar(searchbarid, contextId=textid, placeholder=placeholder, ...),

        tags$hr(),
        if (!is.null(msg)) tags$p(HTML(msg), class="text-muted"),
      ),

      column(width=9, textOutput(
        textid,
        container = function(...) 
          tags$div(..., style="border: 1px solid #ccc; background-color: #fff; height: 300px; overflow-y: scroll; white-space: pre-wrap;")
      ))
    )
  )
}

ui <- function(id) {
  ns <- shiny::NS(id)

  tagList(
    demoui(ns("full"),
      placeholder = "Try searching for shinySearchbar!",
      title = "Shiny Searchbar adds a widget for searching through and highlight text",
      msg   = paste(
        sprintf(
          "Highly configurable matching (using %s), automatic scrolling, and feedback on the number of matches.",
          tags$a("mark.js", href="https://markjs.io/", target="_blank")
        ),
        tags$ul(class="text-muted",
          tags$li("Cycle through matches with the buttons or Enter (next) and Shift+Enter (prev)"),
          tags$li("Try not matching anything (Hint: the coloring is done with CSS)")
        ),
        sep="<br>"
      )
    ),

    demoui(ns("basic"),
      value = "shinySearchbar",
      title = "Basic search term highlighting",
      msg   = "A default value can be passed to the widget to automatically highlight text for the user.",
      cycler=FALSE, counter=FALSE
    )
  )
}

server <- function(input, output, session) {
  output$`full_text` <- renderText(addtext(lorem[10:20]))
  output$`basic_text` <- renderText(addtext(lorem[1:10]))
}