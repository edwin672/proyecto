data = {
    0: "00000000",
    1: "00000000",
    2: "00000000",
    3: "11000000",
    4: "11000000",
    5: "00000000",
    6: "00000000",
    7: "00000000"
}

# Guardar los primeros tres valores
temp = [data[0], data[1], data[2]]

# Mover los valores del índice 3 al 7 hacia arriba
for i in range(3, 8):
    data[i - 3] = data[i]

# Colocar los valores guardados en las últimas tres posiciones
for i in range(3):
    data[5 + i] = temp[i]

# Imprimir el diccionario en el formato solicitado
for key in data:
    print(f"{key} => \"{data[key]}\",")