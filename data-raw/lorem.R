# devtools::install_github("gadenbuie/lorem")
library("lorem")

lorem <- lorem::ipsum(paragraphs=20)
# save(data, file=file.path("..", "data", "lorem.Rdata"))
usethis::use_data(lorem, internal=TRUE)
