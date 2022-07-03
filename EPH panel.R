library(eph) # Se descarga con install.packages("eph")
library(dplyr)
library(tidyr)
library(purrr)
library(ggplot2)
library(writexl)

# Se descarga la EPH de un trimestre
# year = Se pueden poner muchos años
# trimester = Se pueden poner muchos trimestres
# type = Puede ser "individual" o "hogar"
# variables = Se puede específicar que variables usar, por default se descargan todas
# No tiene el 1 trimestre de 2016, entonces (2015-2016) = F. Y además dice que solo son buenos desde
# diciembre de 2015 en adelante.
# En data-data6 defino las eph individual
data <- get_microdata(year = 2016, trimester = 2, type = "individual")
data2 <- get_microdata(year = 2016, trimester = 3, type = "individual")
data3 <- get_microdata(year = 2016, trimester = 4, type = "individual")
data4 <- get_microdata(year = 2017, trimester = 1, type = "individual")
data5 <- get_microdata(year = 2017, trimester = 2, type = "individual")
data6 <- get_microdata(year = 2017, trimester = 3, type = "individual")
data7 <- get_microdata(year = 2017, trimester = 4, type = "individual")
# en hogar-hogar6 defino las eph de hogar
hogar <- get_microdata(year = 2016, trimester = 2, type = "hogar")
hogar2 <- get_microdata(year = 2016, trimester = 3, type = "hogar")
hogar3 <- get_microdata(year = 2016, trimester = 4, type = "hogar")
hogar4 <- get_microdata(year = 2017, trimester = 1, type = "hogar")
hogar5 <- get_microdata(year = 2017, trimester = 2, type = "hogar")
hogar6 <- get_microdata(year = 2017, trimester = 3, type = "hogar")
hogar7 <- get_microdata(year = 2017, trimester = 4, type = "hogar")

# Junto todas las eph de hogar y de individuos todas en un data frame (append simple de STATA)
data <- rbind(data, data2, data3, data4, data5, data6, data7)
hogar <- rbind(hogar, hogar2, hogar3, hogar4, hogar5, hogar6, hogar7)

# Les agrego una columna que cuenta la cantidad de veces que se repiten los hogares/indiv en la muestra que tengo
# Teniendo en cuenta las columnas CODUSU, NRO_HOGAR y COMPONENTE para individual
# y las columnas CODUSU y NRO_HOGAR para hogar
data <- add_count(data, CODUSU, NRO_HOGAR, COMPONENTE, sort = TRUE,name = "n")
hogar <- add_count(hogar, CODUSU, NRO_HOGAR, sort = TRUE, name = "n")

# Elimino todas las filas que no cumplan con que aparezcan en 4 eph
data <- subset(data, data$n == 4)
hogar <- subset(hogar, hogar$n == 4)

# Mergeo la eph individual con la de hogar, los corchetes en hogar son para que no me duplique columnas
# Para el merge se fija en las columnas CODUSU, NRO_HOGAR, TRIMESTRE y ANO4
eph_panel <- merge(data, hogar[, c("CODUSU","NRO_HOGAR","TRIMESTRE","ANO4", setdiff(colnames(hogar),colnames(data)))],
                   by = c("CODUSU","NRO_HOGAR","TRIMESTRE","ANO4"), sort = TRUE)

# Ordeno la eph_panel para que me quede usable
# Sino quedaba ordenado por CODUSU, pero se intercalaban las personas de un mismo hogar
eph_panel <- arrange(eph_panel,CODUSU,NRO_HOGAR,COMPONENTE,ANO4,TRIMESTRE)

# Elimino la columna n que contaba las veces que aparecía la persona
eph_panel <- subset(eph_panel, select = -n)

# Guardo el archivo en un csv
write.csv(eph_panel,"C:\\Users\\felip\\Documents\\UdeSA\\Segundo semestre\\Pobreza II\\Trabajo\\eph_panel.csv",
          row.names = FALSE)
