ui <- function(id) {
  ns <- shiny::NS(id)

  tagList(
    sidebarPanel(
      uiOutput(ns("sb_ui")),

      tags$hr(),
      tags$h4("Searchbar Functionality"),

      checkboxInput(ns("counter"), label="Counter", value=FALSE),
      checkboxInput(ns("cycler"), label="Cycler", value=FALSE),
      uiOutput(ns("cycler_options")),

      tags$hr(),
      tags$h4("mark.js Options"),
      tags$p(class="text-muted",
        HTML(sprintf("See the mark.js %s and the %s for more details.",
          tags$a("Configurator", href="https://markjs.io/configurator.html", target="_blank"),
          tags$a("documentation", href="https://markjs.io/#api", target="_blank")
        ))
      ),

      selectInput(ns("accuracy"), 'Accuracy',
        c("exactly", "partially", "complementary"), selected="partially", selectize=TRUE
      ),

      selectInput(ns("wildcards"), 'Wild cards',
        c("disabled", "enabled", "withSpaces"), selected="disabled", selectize=TRUE
      ),

      checkboxInput(ns("separateWordSearch"), label="Seperate word search", value=TRUE),
      checkboxInput(ns("diacritics"), label="Diacritics", value=TRUE),
      checkboxInput(ns("caseSensitive"), label="Case sensitive", value=FALSE),
      checkboxInput(ns("ignoreJoiners"), label="Ignore joiners", value=FALSE),
      checkboxInput(ns("acrossElements"), label="Across elements", value=FALSE),
      checkboxInput(ns("debug"), label="Debug", value=FALSE)
    ),

    mainPanel(
      fluidRow(
        textOutput(ns("text"),
          container = function(...) 
            tags$div(..., style="border: 1px solid #ccc; height: 500px; overflow-y: scroll; white-space: pre-wrap;")
        )
      ),

      tags$hr(),

      fluidRow(
        tags$h4("Shiny Searchbar Call:"),
        verbatimTextOutput(ns("call"))
      )
    )
  )
}

chunk <- function(x, base=3) split(x, ceiling(seq_along(x)/base))

server <- function(input, output, session) {
  options <- reactiveValues(markOpts=shinySearchbar:::configurator)

  output$text <- renderText(paste(lorem[8:20], collapse="\n\n"))

  output$sb_ui <- renderUI({
    keyword <- isolate(input$sb$keyword)
    tags$div(style="height: 60px;",
      searchbar(session$ns("sb"), value=keyword, context=session$ns("text"), placeholder="Search text here...",
        counter=input$counter, cycler=input$cycler,
        scrollBehavior = if (is.null(input$scrollBehavior)) "smooth" else input$scrollBehavior,
        markOpts=options$markOpts
      )
    )
  })

  output$cycler_options <- renderUI({
    if (input$cycler) {
      selectInput(session$ns("scrollBehavior"), 'Scroll Behavior',
        c("auto", "smooth"), selected="smooth", selectize=TRUE
      )
    }
  })

  options <- reactiveValues()

  observe({
    options$markOpts$accuracy = input$accuracy
    options$markOpts$wildcards = input$wildcards

    options$markOpts$separateWordSearch = input$separateWordSearch
    options$markOpts$diacritics = input$diacritics
    options$markOpts$caseSensitive = input$caseSensitive
    options$markOpts$ignoreJoiners = input$ignoreJoiners
    options$markOpts$acrossElements = input$acrossElements
    options$markOpts$debug = input$debug

    updateMarkOptions(session$ns("sb"),
      markOpts=options$markOpts,
      session=session
    )
  })

  output$call <- renderText({
    # function(inputId, context, value=NULL, label=NULL, width=NULL, placeholder=NULL,
    #   counter=FALSE, cycler=FALSE, scrollBehavior=c("smooth", "auto"),
    #   markOpts=configurator
    # )

    args <- c()

    
    if (input$counter)
      args <- c(args, "counter=TRUE")
    
    if (input$cycler)
      args <- c(args, "cycler=TRUE", sprintf('scrollBehavior="%s"', input$scrollBehavior))


    markOpts <- c()
    for (opt in names(options$markOpts)) {
      value <- input[[opt]]

      default <- shinySearchbar:::configurator[[opt]]
      if (length(default) > 1)
        default <- default[[1]]

      if (value != default) {
        fmt <- if (is.logical(value)) '%s=%s' else '%s="%s"'
        markOpts <- c(markOpts, sprintf(fmt, opt, value))
      }
    }

    call <- c('searchbar(id, context, value=NULL, label=NULL, width=NULL, placeholder=NULL')
    
    if (length(args)) {
      call <- c(call,
        sprintf('  %s', paste(args, collapse=", "), "")
      )
    }

    if (length(markOpts)) {
      if (length(markOpts) > 3) {
        chunks <- chunk(markOpts)
        call <- c(call,
          '  markOpts=list(',
          paste('    ', lapply(chunks, paste, collapse=", "), collapse="\n"),
          ')'
        )
      } else {
        call <- c(call,
          sprintf('  markOpts=list(%s)', paste(markOpts, collapse=", ")),
          ')'
        )
      }
    } else if (length(args)) {
      call <- c(call, ')')
    }

    if (length(call) > 1)
      call[1] = paste0(call[1], ",")
    else
      call[1] = paste0(call[1], ")")

    return(paste(call, collapse="\n"))
  })
}