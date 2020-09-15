#' Normalizar determinada entrada
#'
#' @param x Variável que será normalizada
#'
#' @return Retorna a variável dentro da escala de 0 a 1
#' @export
#'
normalizar <- function(x) {

  return ((x - min(x)) / (max(x) - min(x)))

}

