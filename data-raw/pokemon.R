library(tidyverse)
library(ggplot2)
library(gganimate)
library(gghighlight)

pokemon <- readr::read_rds("/Users/proje/Desktop/projetosR/pokemon/data-raw/pokemon.rds")

#Criando uma base normalizada, caso seja necessário
pokemon_normalizado <- pokemon %>%
  mutate(
    hp = normalizar(hp),
    ataque = normalizar(ataque),
    ataque_especial = normalizar(ataque_especial),
    defesa  = normalizar(defesa),
    defesa_especial = normalizar(defesa_especial),
    velocidade = normalizar(velocidade)
  )

#Dicionário dos dados
glimpse(pokemon)

#pokemon = nome
#exp_base = experiência
#hp = "vida"

#A primeira ação será retirar da base os Pokemons que não contém
#geração. Isso, pois, essa lista se refere a casos especiais de Pokemons.
#Dessa forma, poderia enviesar a análise.

pokemon <- pokemon %>%
  filter(!is.na(id_geracao))

#Montando o deck ideal para a jornada Pokemon da Curso-R.
#Há um espaço para escolher 6 pokemons. O formato ideal é variar nos
#tipos de Pokemons, já que o desafio passará por encarar diversos
#estádios e cidades, cada um com sua especialidade. Por isso, a busca, neste
#projeto, será de encontrar os melhores pokemons de acordo com os seus
#tipos.

#Quais são os tipos de Pokemons mais comuns?
pokemon %>%
  pivot_longer(
    cols = starts_with("tipo"),
    names_to = "tipos",
    values_to = "categoria"
  ) %>%
  filter(
    tipos == "tipo_1"
  ) %>%
  group_by(
    categoria,
    id_geracao
  ) %>%
  count(
    name = "quantidade"
  ) %>%
  ungroup() %>%
  mutate(categoria = forcats::fct_reorder(categoria,
                                          desc(categoria))
  ) %>%
  ggplot(
    aes(x = quantidade,
        y = categoria,
        fill = id_geracao)
  ) +
  geom_col() +
  scale_fill_continuous(low = "gray", high = "black") +
  scale_x_continuous(breaks = seq(0, 200, 10)) +
  labs(
    x = "Quantidade",
    y = "Tipo",
    title = "Quantidade de Pokemons",
    subtitle = "Contagem sobre da principal categoria das espécies",
    fill = "Geração"
  ) +
  tema_pokemon()

#Tabela da quantidade de pokemons por tipo ao longo das gerações
quantidade_pokemons <- pokemon %>%
  pivot_longer(
    cols = starts_with("tipo"),
    names_to = "tipos",
    values_to = "categoria"
  ) %>%
  filter(
    tipos == "tipo_1"
  ) %>%
  group_by(
    categoria,
    id_geracao
  ) %>%
  count(
    name = "quantidade"
  ) %>%
  pivot_wider(
    names_from = "id_geracao",
    values_from = "quantidade"
  ) %>%
  relocate("categoria","1") %>%
  ungroup()

#Distribuição dos atributos
pokemon %>%
  pivot_longer(
    cols = c("ataque",
             "defesa",
             "velocidade"),
    names_to = "caracteristica",
    values_to = "valor"
  ) %>%
  filter(!is.na(valor)) %>%
  ggplot(aes(valor, fill = caracteristica)) +
  geom_density(col = "white",
               alpha = .5) +
  scale_x_continuous(breaks = seq(0, 200, 50)) +
  facet_grid(vars(id_geracao)) +
  labs(
    x = "Distribuição",
    title = "Atributos dos Pokemons",
    subtitle = "Densidade dos principais itens para cada espécie por geração",
    fill = "Atributo"
  ) +
  tema_pokemon() +
  theme(
    axis.text.y = element_blank(),
    axis.title.y = element_blank(),
    axis.ticks.y = element_blank()
  )

#Observando os principais tipos para cada um dos atributos
pokemon %>%
  pivot_longer(
    cols = starts_with("tipo"),
    names_to = "tipos",
    values_to = "categoria"
  ) %>%
  pivot_longer(
    cols = c("ataque",
             "defesa",
             "velocidade"),
    names_to = "caracteristica",
    values_to = "valor"
  ) %>%
  filter(!is.na(valor),
         tipos == "tipo_1") %>%
  mutate(categoria = forcats::fct_reorder(categoria,
                                          desc(categoria))
  ) %>%
  ggplot(aes(x = valor,
             y = categoria,
             color = caracteristica)) +
  geom_boxplot(show.legend = FALSE) +
  #coord_flip() +
  facet_wrap(vars(caracteristica),
             strip.position = "top") +
  labs(
    y = "Tipo",
    title = "Poder dos Pokemons",
    subtitle = "Distribuição dos atributos de acordo com o tipo",
    color = "Atributo"
  ) +
  tema_pokemon() +
  theme(
    axis.text.x = element_blank(),
    axis.title.x = element_blank(),
    axis.ticks.x = element_blank()
  )

#Organiza a tabela para montar a correlação
cor_pokemon <- pokemon %>%
  select(
    where(is.numeric) & !starts_with("id") & !contains("especial")
  )

#Cria a correlação
cor_pokemon <- round(cor(cor_pokemon), 2)

#Plota a correlação entre as variáveis numéricas
corrplot::corrplot(cor_pokemon,
                   method = "color",
                   type = "lower",
                   addCoef.col = "black",
                   tl.col = "black",
                   tl.srt = 40)

#Lista de Pokemons de pelo atributo Velocidade
pokemon %>%
  pivot_longer(
    cols = starts_with("tipo"),
    names_to = "tipos",
    values_to = "categoria"
  ) %>%
  filter(tipos == "tipo_1") %>%
  ggplot(aes(x = ataque_especial,
             y = defesa_especial,
             size = velocidade,
             color = categoria)) +
  geom_point() +
  labs(
    y = "Defesa especial",
    x = "Ataque especial",
    title = "Pokemons velozes",
    subtitle = "Distribuição de acordo com o tipo",
    color = "Tipo",
    size = "Velocidade"
  ) +
  scale_x_continuous(breaks = seq(0, 200, 10)) +
  scale_y_continuous(breaks = seq(0, 200, 10)) +
  gghighlight(label_key = pokemon,
              categoria == "voador",
              unhighlighted_params = list(color = "gray87"),
              label_params = list(size = 5, color = "#A890F0")) +
  geom_point(col = "#A890F0") +
  tema_pokemon()



#Lista de Pokemons de pelo atributo defesa
pokemon %>%
  pivot_longer(
    cols = starts_with("tipo"),
    names_to = "tipos",
    values_to = "categoria"
  ) %>%
  filter(tipos == "tipo_1") %>%
  ggplot(aes(x = ataque_especial,
             y = defesa_especial,
             size = defesa,
             color = categoria)) +
  geom_point() +
  labs(
    y = "Defesa especial",
    x = "Ataque especial",
    title = "Pokemons defensivos",
    subtitle = "Distribuição de acordo com o tipo",
    color = "Tipo",
    size = "Defesa"
  ) +
  scale_x_continuous(breaks = seq(0, 300, 10)) +
  scale_y_continuous(breaks = seq(0, 300, 10)) +
  gghighlight(defesa > 120,
              label_key = pokemon,
              categoria == "aço",
              unhighlighted_params = list(color = "gray87"),
              label_params = list(size = 5, color = "black")) +
  geom_point(col = "black") +
  tema_pokemon()

#Lista de Pokemons de pelo atributo ataque
pokemon %>%
  pivot_longer(
    cols = starts_with("tipo"),
    names_to = "tipos",
    values_to = "categoria"
  ) %>%
  filter(tipos == "tipo_1") %>%
  ggplot(aes(x = ataque_especial,
             y = defesa_especial,
             size = ataque,
             color = categoria)) +
  geom_point() +
  labs(
    y = "Defesa especial",
    x = "Ataque especial",
    title = "Pokemons ofensivos",
    subtitle = "Distribuição de acordo com o tipo",
    color = "Tipo",
    size = "Ataque"
  ) +
  scale_x_continuous(breaks = seq(0, 200, 10)) +
  scale_y_continuous(breaks = seq(0, 300, 10)) +
  gghighlight(ataque > 120,
              categoria == "lutador",
              label_key = pokemon,
              unhighlighted_params = list(color = "gray87"),
              label_params = list(size = 5, color = "#C03028")) +
  geom_point(col = "#C03028") +
  tema_pokemon()


##Há relação entre o rating dos Pokemons e sua estrutura física?
#Por peso
pokemon %>%
  mutate(
    peso_categoria = case_when(
      peso < mean(peso) ~ "leve",
      peso >= mean(peso) ~ "pesado")
  ) %>%
  pivot_longer(
    cols = starts_with("tipo"),
    names_to = "tipos",
    values_to = "categoria"
  ) %>%
  filter(tipos == "tipo_1") %>%
  ggplot(aes(x = ataque,
             y = defesa,
             alpha = peso,
             size = peso,
             color = peso_categoria)) +
  scale_color_manual(values = c("lightskyblue","mediumorchid4")) +
  geom_point() +
  #facet_wrap(vars(peso_categoria)) +
  tema_pokemon() +
  labs(
    y = "Defesa",
    x = "Ataque",
    size = "Peso",
    alpha = "Peso",
    color = "Categoria do Peso",
    title = "Características dos Pokemons",
    subtitle = "Distribuição de acordo com os atributos e o peso"
  ) +
  tema_pokemon()


#Por altura
pokemon %>%
  mutate(
    altura_categoria = case_when(
      altura < mean(altura) ~ "pequeno",
      altura >= mean(altura) ~ "grande")
  ) %>%
  pivot_longer(
    cols = starts_with("tipo"),
    names_to = "tipos",
    values_to = "categoria"
  ) %>%
  filter(tipos == "tipo_1") %>%
  ggplot(aes(x = ataque,
             y = defesa,
             alpha = altura,
             size = altura,
             color = altura_categoria)) +
  scale_color_manual(values = c("mediumorchid4","lightskyblue")) +
  geom_point() +
  #facet_wrap(vars(peso_categoria)) +
  tema_pokemon() +
  labs(
    y = "Defesa",
    x = "Ataque",
    size = "Altura",
    alpha = "Altura",
    color = "Categoria da Altura",
    title = "Características dos Pokemons",
    subtitle = "Distribuição de acordo com os atributos e a altura"
  ) +
  tema_pokemon()


#Experiência e força
pokemon %>%
  pivot_longer(
    cols = starts_with("tipo"),
    names_to = "tipos",
    values_to = "categoria"
  ) %>%
  pivot_longer(
    cols = c("ataque",
             "defesa",
             "velocidade"),
    names_to = "caracteristica",
    values_to = "valor"
  ) %>%
  filter(tipos %in% "tipo_1") %>%
  ggplot() +
  geom_point(aes(y = valor,
                 x = exp_base,
                 color = caracteristica)) +
  facet_wrap(vars(caracteristica)) +
  tema_pokemon() +
  labs(
    x = "Experiência",
    y = "Força do atributo",
    size = "Altura",
    alpha = "Altura",
    color = "Atributo",
    title = "Experiência dos Pokemons",
    subtitle = "Distribuição de acordo com os atributos e a experiência"
  ) +
  tema_pokemon()

