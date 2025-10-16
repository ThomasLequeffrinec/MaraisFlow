library(shiny)
library(shinythemes)
library(dplyr)

server <- function(input, output) {
  
  # Affichage des paramètres
  output$txtout <- renderText({
    paste(
      "Coefficient de marée :", input$coeff, "\n",
      "Niveau NGF de la prise :", input$NGF_marais, "\n",
      "Volume initial :", input$V_init, "m³\n",
      "Surface initiale du marais :", input$surface_marais, "m²\n",
      "Coefficient de débit :", input$C, "\n",
      "Surface de l'orifice de la prise d'eau :", input$S1, "m²\n",
      if(input$ajout_entree) paste("Entrée 2 :", input$NGF_entree2, "m, surface =", input$S2, "m²") else ""
    )
  })
  
  # Sélection automatique du profil de marée selon le coefficient choisi
  h_mer_react <- reactive({
    h_mer %>%
      filter(coeff == input$coeff) %>%
      group_by(session) %>%
      slice_max(order_by = NGF, n = 721, with_ties = FALSE) %>%
      ungroup() %>%
      arrange(Date) %>%
      pull(NGF)
  })
  
  # Simulation
  simulation <- reactive({
    duree <- 720
    temps <- 0:duree
    h_mer_vect <- h_mer_react()
    
    V_marais <- numeric(length = duree + 1)
    V_marais[1] <- input$V_init
    volume_entrant <- numeric(length = duree)
    
    g <- 9.81
    C <- input$C
    
    for(t in 1:duree){
      V_t <- 0
      # Entrée 1
      if(h_mer_vect[t] > input$NGF_marais){
        delta_H <- h_mer_vect[t] - input$NGF_marais
        Q1 <- C * input$S1 * sqrt(2 * g * delta_H)
        V_t <- V_t + Q1 * 60
      }
      # Entrée 2
      if(input$ajout_entree){
        if(h_mer_vect[t] > input$NGF_entree2){
          delta_H2 <- h_mer_vect[t] - input$NGF_entree2
          Q2 <- C * input$S2 * sqrt(2 * g * delta_H2)
          V_t <- V_t + Q2 * 60
        }
      }
      V_marais[t + 1] <- V_marais[t] + V_t
      volume_entrant[t] <- V_t
    }
    
    h_marais <- V_marais / input$surface_marais
    idx_max_mer <- which.max(h_mer_vect)
    debit_max <- volume_entrant[idx_max_mer]  # débit au moment de la pleine mer
    
    list(temps = temps, h_mer = h_mer_vect, h_marais = h_marais,
         volume_entrant_total = sum(volume_entrant),
         h_marais_max = max(h_marais),
         debit_max = debit_max)
  })
  
  # Graphique
  output$hauteurPlot <- renderPlot({
    sim <- simulation()
    plot(sim$temps, sim$h_mer, type = "l", lwd = 3, col = "#173957",
         xlab = "Temps (minutes)", ylab = "NGF",
         main = "Évolution de la hauteur du marais soumis à une marée de 12h")
    lines(sim$temps, sim$h_marais, lwd = 3, col = "#379EC6")
    legend("topleft", legend = c("Marée (h_mer)", "Marais (h_marais)"),
           col = c("#173957", "#379EC6"), lwd = 3, bty = "n")
    grid()
  })
  
  output$volEntrant <- renderText({ round(simulation()$volume_entrant_total, 2) })
  output$volFinal <- renderText({ round(simulation()$h_marais_max, 3) })
  output$renouvellement <- renderText({
    round(simulation()$volume_entrant_total / (input$V_init + simulation()$volume_entrant_total) * 100, 1)
  })
  output$debitMax <- renderText({ round(simulation()$debit_max, 2) })
}
