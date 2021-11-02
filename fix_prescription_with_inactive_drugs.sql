
-- Encontra prescricoes com drugs que ja nao sao activas ou tem uuidopenmrs null

select pinfo.*, d.name, d.active, d.atccode_id, uuidopenmrs,regimeesquema ,  date_part('year',  pinfo.date::date) as ano  from (

select pd.id, drug, prescription, date, patient, patientid, p.regimeid, reg.regimeesquema
 from prescribeddrugs pd 
 inner join prescription p on p.id= pd.prescription 
 inner join patient pat on pat.id =p.patient
 inner join regimeterapeutico reg on reg.regimeid =p.regimeid
)  pinfo  

left  join  drug d on d.id =pinfo.drug


where date_part('year',  pinfo.date::date) in (2020,2021)  and (d.active=false or d.uuidopenmrs is null or d.uuidopenmrs='' )   ;

-- Solucao  do problema ( deve-se analisar manualmente os drugs inactivos e substituir pelos activos)
-- update prescribeddrugs set drug = 41197  where drug =45000;
-- update prescribeddrugs set drug = 41197  where drug =1218752;


-- Problema de regimenanswer nulls (regimesuuid nulls na tabela sync_openmrs_dispense cria erro http 400 )
-- Bagamoio 3 pacienteseve-se verificar  
-- deve-se verificar (regimesuuid nulls bagamoio tinha 3 pacientes nesta condicao )
select * from sync_openmrs_dispense where regimenanswer is null or regimenanswer ='' ;

-- Solucao 
-- update  sync_openmrs_dispense  set 
-- regimenanswer = '7bf5a88d-6db6-4899-a01a-bfd14ce77b53' where nid ='0111050701/2014/00607' and regimenanswer is null or regimenanswer ='' ;



  