#!/bin/bash

# GRUPO_VITAL = DIRETORIO RAIZ
## CATU = DIRETORIO DENTRO DA RAIZ

# Define a lista de grupos
grupos=("GRP_MEDICO" "GRP_ENFERMAGEM" "GRP_ADMINISTRADOR" "GRP_FATURAMENTO" "GRP_RECEPCAO" "GRP_AUDITOR" "GRP_NUTRICAO" "GRP_RH" "GRP_HIGIENIZACAO" "GRP_FARMACIA" "GRP># Cria as OUs dentro de OU_SaoPaulo
for i in "${!grupos[@]}"
do
        samba-tool ou create 'ou='${grupos[i]}',ou=CATU,ou=GRUPO_VITAL,dc=HAGNUSDEI,dc=INTRA'
    if [ $? -eq 0 ]; then
        echo "OU ${grupos[i]} criada com sucesso dentro de OU=GRUPO_VITAL,OU=CATU"
    else
        echo "Erro ao criar a OU ${grupos[i]} dentro de OU=GRUPO_VITAL,OU=C"
    fi
done

# Cria os grupos nas OUs correspondentes
for i in "${!grupos[@]}"
do
    samba-tool group add ${grupos[i]} --groupou="OU=${grupos[i]},OU=CATU,OU=GRUPO_VITAL"
    if [ $? -eq 0 ]; then
        echo "Grupo ${grupos[i]} criado com sucesso dentro de ${grupos[i]},OU=CATU,OU=GRUPO_VITAL"
    else
        echo "Erro ao criar o grupo ${grupos[i]} dentro de ${grupos[i]},OU=CATU,OU=GRUPO_VITAL"
    fi
done
