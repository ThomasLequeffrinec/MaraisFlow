library(shiny)
library(shinythemes)
library(dplyr)
library(readr)

h_mer <- read_csv("Maree.csv")
h_mer$NGF <- as.numeric(h_mer$NGF)

fluidPage(theme = shinytheme("cerulean"),
                navbarPage(
                  title = div(
                    style = "display: flex; justify-content: space-between; align-items: center; width: 100%;",
                    span("Maraisflow", style = "font-weight: bold; font-size: 20px;"),
                    tags$img(src = "logo_maraisflow.bmp", height = "40px")
                  ),
                  
                  # ---- Onglet Environnement ----
                  tabPanel("Environnement",
                           sidebarPanel(
                             tags$h3("Environnement :"),
                             
                             numericInput("NGF_marais", "Niveau NGF de la prise d'eau :", value = 1, step = 0.1),
                             numericInput("V_init", "Volume initial du marais (m³) :", value = 10000, min = 0, step = 100),
                             numericInput("surface_marais", "Surface initiale du marais (m²) :", value = 10000, min = 1, step = 1),
                             numericInput("C", "Coefficient de débit :", value = 0.1, min = 0, step = 0.01),
                             numericInput("S1", "Surface de l'orifice de la prise d'eau (m²) :", value = 0.30, min = 0, step = 0.001),
                             
                             checkboxInput("ajout_entree", "Ajouter une seconde prise d'eau ?", value = FALSE),
                             conditionalPanel(
                               condition = "input.ajout_entree == true",
                               numericInput("NGF_entree2", "NGF entrée 2 :", value = 1, step = 0.1),
                               numericInput("S2", "Surface orifice entrée 2 (m²) :", value = 0.2, step = 0.01)
                             ),
                             
                             selectInput("coeff", "Sélectionner le coefficient de marée :", 
                                         choices = sort(unique(h_mer$coeff)))
                           ),
                           mainPanel(
                             h4("Résumé des paramètres :"),
                             verbatimTextOutput("txtout")
                           )
                  ),
                  
                  # ---- Onglet Simulation ----
                  tabPanel("Simulation",
                           fluidRow(column(12, plotOutput("hauteurPlot", height = "500px"))),
                           hr(),
                           fluidRow(
                             column(3, h4("Volume entrant total (m³)"), verbatimTextOutput("volEntrant")),
                             column(3, h4("NGF maximal du marais"), verbatimTextOutput("volFinal")),
                             column(3, h4("Renouvellement de l'eau (%)"), verbatimTextOutput("renouvellement")),
                             column(3, h4("Débit max (m³/min) au moment de la pleine mer"), verbatimTextOutput("debitMax"))
                           )
                  ),
                  
                  # ---- Onglet Informations pratiques ----
                  tabPanel("Informations pratiques",
                           fluidRow(
                             column(12,
                                    h4("Postulat de base et précautions"),
                                    p("Cette simulation est une simplification du système d'un marais. Elle se base sur plusieurs postulats initiaux :"),
                                    tags$ul(
                                      tags$li("Le marais est de forme rectangulaire dont la largeur et la longueur sont fixes."),
                                      tags$li("Les échanges mer - marais s'exercent de manière directe, sans obstacle intermédiaire (étiers, barrage, etc.)."),
                                      tags$li("La prise d'eau se situe dans deux positions : noyé ou non."),
                                      tags$li("La simulation ne s'intéresse qu'au volume entrant dans le marais, elle ne tient pas compte des sorties d'eau et donc de la diminution du niveau du marais en phase de marée basse."),
                                      tags$li("Si une simulation comporte deux prises d'eau, le niveau NGF de la prise d'eau doit correspondre à celle disposant du niveau NGF le plus bas (autrement dit, celui qui conditionne le niveau d'eau du marais).")
                                    ),
                                    
                                    h4("Dynamique"),
                                    p("- Le coefficient de débit est à adapter selon la forme de la prise. Par défaut, il est paramétré à 0.1 pour tenir compte de la complexité des prises (longueur, frottement, etc.)."),
                                    p("- Pour plus de détails, voir Larinier 1994 : ", 
                                      a("https://www.fleuve-charente.net/wp-content/files/Poissons-migrateurs/Passes-A-Poissons-Expertise-Conception-Larinier-1994.pdf", href = "https://www.fleuve-charente.net/wp-content/files/Poissons-migrateurs/Passes-A-Poissons-Expertise-Conception-Larinier-1994.pdf", target="_blank")),
                                    p("- La mesure d'un débit réel au moment de la pleine mer, à l'aide d'un débitmètre, permettrait de valider ou corriger la simulation et d'ajuster le coefficient de débit pour une meilleure précision."),
                                    p("- Les courbes de marée NGF sont issues du marégraphe du port de Saint-Gilles-Croix-de-Vie, géré par le Pays de Saint-Gilles-Croix-de-Vie Agglomération, sur des marées suivies en 2024 et 2025. Les niveaux d'eau peuvent être sur- ou sous-estimés en fonction des conditions météorologiques locales.")
                             )
                           )
                  ),
                  
                  # ---- Onglet À propos ----
                  tabPanel("À propos",
                           fluidRow(
                             column(12,
                                    h4("Présentation de l'application"),
                                    p("Dans une démarche de gestion raisonnée des flux d’eau au sein d’un marais anthropisé, la simulation et la compréhension des échanges hydriques sont essentielles pour les gestionnaires. Elles permettent de maîtriser les niveaux d’eau, d’évaluer les renouvellements et d’estimer les volumes entrant dans le marais."),
                                    p("La mise en place d’un batardeau réglé à un niveau constant constitue un outil de gestion hydraulique plus ouvert, favorisant le passage des espèces aquatiques et la circulation de l’eau, tout en contribuant au maintien d’un cortège faunistique et floristique diversifié."),
                                    p("Cette application permet également de réaliser une première simulation adaptée aux caractéristiques spécifiques de chaque marais et de ses prises d’eau, offrant ainsi aux gestionnaires un outil personnalisable pour explorer différents scénarios de gestion hydraulique."),
                                    
                                    h4("Création"),
                                    p("Cette application est le fruit du travail et de la collaboration entre l'association LOGRAMI (Loire Grand Migrateurs) et le SMMVLJ (Syndicat Mixte des Marais de la Vie, du Ligneron et du Jaunay)."),
                                    tags$img(src = "logo_LOGRAMI_SMMVLJ.bmp", height = "60px"),
                                    p("Réalisé par Lequeffrinec Thomas, 2025.")
                             )
                           )
                  )
                )
)






