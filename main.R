# Packages que contem algumas funcoes a serem usadas 
require(RMySQL)
require(RPostgreSQL)
require(plyr)     ## instalar com install.packages("plyr")
require(dplyr)    ## instalar com install.packages("dplyr")
####################################### Configuracao de Parametros  #####################################################################
#########################################################################################################################################
wd <- '~/Git/idart-scripts/upgrade/'  
setwd(wd)

source('sql_querys.R')
source('genericFunctions.R')

# iDART Stuff - Configuracoes de variaveis de conexao 
postgres.user ='postgres'
postgres.password='postgres'
postgres.db.name='bagamoio'
postgres.host='172.18.0.3'
postgres.port=5432
# Objecto de connexao com a bd openmrs postgreSQL
con_local <-  dbConnect(PostgreSQL(),user = postgres.user,password = postgres.password, dbname = postgres.db.name,host = postgres.host)
############################################################################################################################################


## OpenMRS Stuff - Configuracoes de variaveis de conexao 
openmrs.user ='esaude'
openmrs.password='esaude'
openmrs.db.name='altomae'
openmrs.host='172.18.0.2'
openmrs.port=3306
#us.code= '0111040601' # CS 1 junho# modificar este parametro para cada US. Este e o Cod da US definido pelo MISAU e geralmente e a primeira parte do NID
# Objecto de connexao com a bd openmrs
con_openmrs = dbConnect(MySQL(), user=openmrs.user, password=openmrs.password, dbname=openmrs.db.name, host=openmrs.host, port=openmrs.port)

#   Buscar os drugs Terapeuticos na BD iDART
idart_drugs <- getIdartDrug(con_local)
# coluna status no df idart drugs
idart_drugs$status <- ""
idart_drugs$uuid_padronizado <- ""
idart_drugs$comp_uuid <- ""
openrms_drugs <- getDrugsOpenMRS(con_openmrs)





## Compara os regimes existentes com os regimes  Padronizados e faz actualizacao.
## Se o regime nao exite no iDART Faz-se uma insercao

for (i in 1:dim(idart_drugs)[1]) {
  
  id <- idart_drugs$id[i]
  idart_drugname <- idart_drugs$name[i]
  idart_uuid <- idart_drugs$uuidopenmrs[i]
  
  found <- FALSE
  
  for (v in 1:dim(openrms_drugs)[1]) {
     
      if(idart_drugname==openrms_drugs$name[v]){
        found <- TRUE
        idart_drugs$status[i] = "found"
        uuid_padronizado = openrms_drugs$uuid[v]
        idart_drugs$uuid_padronizado[i] = uuid_padronizado
         # ACtualiza o uuidopenmrs na tabela drug do iDART com base no uuiopenmrs do openmrs
        
        
        dbExecute(con_local,
          paste0( "update public.drug set uuidopenmrs ='",uuid_padronizado,"'", " where id = ", id," ;"      )  )
        
      } 
  }
  
  if(!found){
    idart_drugs$status[i] = "not found"
  }
  
}

    
idart_drugs = subset(idart_drugs, !grepl('D4T',x = idart_drugs$name,)  )
idart_drugs = subset(idart_drugs, !grepl('DRV',x = idart_drugs$name,)  )
idart_drugs = subset(idart_drugs, !grepl('DDI',x = idart_drugs$name,)  )
idart_drugs = subset(idart_drugs, !grepl('SQV',x = idart_drugs$name,)  )

df_notfound <- subset(idart_drugs, idart_drugs$status=='not found', )
