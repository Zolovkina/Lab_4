# Упражнение 4 -----------------------------------------------------------------
# Вариант #2


# загрузка пакетов
install.packages('R.utils')
install.packages('dismo')
install.packages('raster')
install.packages('maptools')
install.packages('sp')
install.packages('RColorBrewer')
install.packages('rgdal')
install.packages('plyr')
install.packages('ggplot2')
install.packages('scales')
install.packages('mapproj')
install.packages('data.table')
#library('R.utils')               # gunzip() для распаковки архивов 
library('dismo')                 # gmap() для загрузки Google карты
library('raster')                # функции для работы с растровыми картами в R
library('maptools')              # инструменты для создания картограмм
library('sp')                    # функция spplot()
library('RColorBrewer')          # цветовые палитры
require('rgdal')                 # функция readOGR()
require('plyr')                  # функция join()
library('ggplot2')               # функция ggplot()
library('scales')                # функция pretty_breaks()
library('mapproj')
library('data.table')

#ссылка на файл
ShapeFileURL <- "http://biogeo.ucdavis.edu/data/gadm2.8/shp/RUS_adm_shp.zip"

#создаём директорию 'data' и скачиваем файл
if(!file.exists('/data')) dir.create('./data')
if (!file.exists('./data/RUS_adm_shp.zip')){
  download.file(ShapeFileURL,
                destfile = './data/RUS_adm_shp.zip')
}

#распаковать архив
unzip('./data/RUS_adm_shp.zip', exdir = './data/RUS_adm_shp')
#посмотреть список файлов распакованного архива
dir('./data/RUS_adm_shp')

# прочитать данные уровня 1 - границы регионов
Regions1 <- readShapePoly('./data/RUS_adm_shp/RUS_adm1.shp')
# Контурная карта 1-го уровня
plot(Regions1, main='adm1', asp=1.8)

# Имена слотов
slotNames(Regions1)
# слот "данные"
Regions1@data

#df <- data.table(Regions@data)

# делаем фактор из имён областей (т.е. нумеруем их)
Regions1@data$NAME_1 <- as.factor(Regions1@data$NAME_1 )
# Результат
Regions1@data$NAME_1

# строим картограмму
spplot(Regions1, 'NAME_1', scales = list(draw = T), col.regions = rainbow(n = 6))

#загружаем данные о труде с ФСГС
install.packages('XML')
library(XML)
fileURL1 <- 'http://www.gks.ru/free_doc/new_site/population/trud/trud3.xls'
if(!file.exists('./data')) dir.create('./data')
if(!file.exists('./data/trud3.xlsx')) {
  download.file(fileURL1,
                './data/trud3.xlsx')
}

stat.Regions <- read.csv('./data/trud3.csv', 
                         sep = ',', dec = '.', as.is = T)
stat.Regions

#stat.Regions2 <- read.csv('./data/trud.csv', 
#                          sep = ',', dec = '.', as.is = T)
#stat.Regions2

# вносим данные в файл карты
Regions@data <- merge(Regions1@data, stat.Regions,
                      by.x = 'NAME_1', by.y = 'NAME_1')

# загрузка пакета
library('RColorBrewer') # цветовые палитры
# задаём палитру
mypalette <- colorRampPalette(c('red', 'white'))

# картограмма безработных людей среди населения 
spplot(Regions1, 'Pop2016',
       col.regions = mypalette(20), # цветовая шкала
       # (20 градаций)
       col = 'coral4', # цвет контурных линий
       par.settings = list(axis.line = list(col = NA)) # без
       # осей
)

# то же - с названиями областей
spplot(Regions1, 'Pop2016',
       col.regions = mypalette(16), col = 'yellow',
       main = 'Число безработных',
       panel = function(x, y, z, subscripts, ...) {
         panel.polygonsplot(x, y, z, subscripts, ...)
         sp.text(coordinates(Regions1),
                 Regions1$NAME_1[subscripts])}
)


# Картограмма среднегодовой численности занятых населения
#spplot(Regions1, 'trud',
#      col.regions = mypalette(20),
#      col = 'green',
#      par.settings = list(axis.line = list(col = NA)))


# то же - с названиями областей
#spplot(Regions1, 'trud',
#       col.regions = mypalette(20),
#       col = 'black',
#       main = 'Среднегодовая численность занятых',
#       panel = function(x, y, z, subscripts, ...){
#         panel.polygonsplot(x, y, z, subscripts, ...)
#         sp.text(coordinates(Regions1),
#                 Regions$NAME_1[subscripts], cex = 0.3)
#       })