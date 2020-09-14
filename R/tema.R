#' Configuração do tema criado para a análise
#'
#' @return Configura o gráfico para determinado tema
#' @export
#'
tema_pokemon <- function() {
  theme(
    plot.title = element_text(
      hjust = 0.5,
      size = 15),
    plot.subtitle = element_text(
      hjust = 0.5,
      size = 10),
    axis.text.y = element_text(size = 10),
    #axis.text.x = element_blank(),
    #axis.title.x = element_blank(),
    panel.background = element_blank(),
    panel.grid.major.y = element_line(size = 0.1),
    panel.grid.minor = element_blank(),
    panel.grid.major.x = element_blank()
  )
}
