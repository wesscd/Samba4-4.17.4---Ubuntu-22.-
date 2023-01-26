# Define a lista de pastas
pastas=("pasta1" "pasta2" "pasta3" "pasta4" "pasta5")

# Cria as pastas
for i in "${!pastas[@]}"
do
    mkdir -p "${pastas[i]}"
    if [ $? -eq 0 ]; then
        echo "Pasta ${pastas[i]} criada com sucesso"
    else
        echo "Erro ao criar a pasta ${pastas[i]}"
    fi
done
