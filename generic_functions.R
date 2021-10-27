#' Busca todos drugs T na BD openmrs Da US
#' 
#' @param openmrs.con objecto de conexao com mysql    
#' @return df regimes openmrs
#' @examples
#' drug = resut_set(con_openmrs)
#' 
getDrugsOpenMRS <- function (openmrs.con){
  resut_set <- dbSendQuery(openmrs.con, "			
            
SELECT 
    
     drug_id, name, uuid
FROM
    drug
  ; ")
  data <- fetch(resut_set,n=-1)
  RMySQL::dbClearResult(resut_set)
  return (data)
  
}


#' Busca o nos regimes existentes na tabela regimeterapeutico
#' 
#' @param postgres.con objecto de conexao com mysql    
#' @return regimeterapeutico
#' @examples
#' df_regimes = getIdartDrug(postgres.con)
getIdartDrug <- function (postgres.con){
  
  drug <- dbGetQuery(postgres.con,"select id, name, atccode_id, uuidopenmrs from drug where active = true;")
  drug
}



#' Actualiza codRegime e  regimenopespecificado dum regimeter  na tabela regimeterapetico 
#' 
#' @param postgres.con objecto de conexao com mysql   
#' @param regimeid id do regime a ser actualizado na tabela regimeterapetico
#' @param cod.regime cod do regime por actualizar
#' @param regimenopespecificado  uuid  do regime no openmrs  
#' @return 1
#' 
#' @examples
#' res = actualizaRegimeTerapeutico(con_postgresregimeid,cod.regime,regimenopespecificado)
actualizaRegimeTerapeutico <- function(postges.con,regime.id,cod.regime,regimenopespecificado){
  
  dbExecute(postges.con,
            paste0(
              "update public.regimeterapeutico set regimenomeespecificado ='",
              regimenopespecificado,
              "'",
              " , codigoregime = '",
              cod.regime,
              "' where regimeid = ",
              regime.id
            )
  )
}

