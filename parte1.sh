#!/bin/bash

USERS_FILE="usuario.txt"
SESSION_FILE="sesion.txt"
PRODUCTS_FILE="productos.txt"


if [ ! -f "$USERS_FILE" ]; then
	echo "admin:admin" > "$USERS_FILE"
	echo "Usuario admin creado por defecto (usuario: admin / password: admin)"
fi

crearUsuario(){
	echo
	echo "Crear nuevo usuario"
	echo "-------------------"
	read -p "Ingresar nombre de usuario: " user
	read -p "Ingresar password: " pass
	echo
	if grep -q "^$user:" "$USERS_FILE"; then
		echo "Usuario ya existente"
	elif [ -z "$user" ] || [ -z "$pass" ]; then
		echo "Usuario o password vacios"
	else
		echo "$user:$pass" >> "$USERS_FILE"
		echo "Usuario creado"
	fi
}

cambiar_Contra(){
	if [ ! -f "$SESSION_FILE" ]; then
		echo "Se debe iniciar sesion para cambiar el password."
		return
	fi
	usuario=$(cat "$SESSION_FILE")
	echo
	echo "Cambiar password de $usuario"
	echo "----------------------------"
	read -s -p "Password actual: " pass_actual
	echo
	if ! grep -q "^$usuario:$pass_actual$" "$USERS_FILE"; then
		echo "Password actual incorrecto"
		return
	fi
	read -s -p "Nuevo Password: " nueva_pass
	echo
	read -s -p "Confirmar nuevo Password: " confirm_pass
	echo
	if [ -z "$nueva_pass" ]; then
		echo "El password no puede estar vacio"
		return
	fi
	if [ "$nueva_pass" != "$confirm_pass" ]; then
		echo "Los password no coinciden."
		return
	fi
	sed -i "s/^$usuario:$pass_actual\$/$usuario:$nueva_pass/" "$USERS_FILE"

	echo "Password actualizado"
}

ingresar_producto(){
	if [ ! -f "$SESSION_FILE" ]; then
		echo "Se debe iniciar sesion"
		return
	fi
	echo
	echo "Ingreso de nuevo Producto"
	echo "-------------------------"
	read -p "Tipo de Pintura: " tipo
	read -p "Modelo: " modelo
	read -p "Descripcion: " descripcion
	read -p "Cantidad: " cantidad
	read -p "Precio unitario ($): " precio

	codigo=$(echo "$tipo" | cut -c1-3 | tr '[:lower:]' '[:upper:]')
	echo "$codigo - $tipo - $modelo - $descripcion - $cantidad - \$$precio" >> productos.txt
	echo "Producto agregado correctamente."
}

vender_prod(){
	if [ ! -f "$SESSION_FILE" ]; then
		echo "Se debe iniciar sesion"
		return
	fi
	if [ ! -s "productos.txt" ]; then
		echo "No hay productos cargados"
		return
	fi

	echo
	echo "Lista Productos"
	echo "------------------"
	i=1
	while IFS=" - " read -r codigo tipo modelo descripcion cantidad precio; do
		precio=$(echo "$precio" | tr -d '$')
		echo "$i) $tipo - $modelo - \$$precio (stock: $cantidad)"
		i=$((i+1))
	done < productos.txt

	echo "--------------------------------------------"
	echo "Ingrese numero de producto que desea comprar"
	read -a seleccionados

	total=0
	resumen=""

	for num in "${seleccionados[@]}"; do
		producto=$(sed -n "${num}p" productos.txt)

		if [ -z "$producto" ]; then
			echo "El numero $num no corresponde a ningun producto"
			continue
		fi
		IFS=" - " read -r codigo tipo modelo descripcion cantidad precio <<< "$producto"
		read -p "Cantidad a comprar de '$modelo': " cant_compra

		if (( cant_compra > cantidad )); then
			echo "no hay suficiente stock (disponible: $cantidad)"
			continue
		fi

		nuevo_stock=$((cantidad - cant_compra))
		precio_num=$(echo "$precio" | tr -d '$ ')
		subtotal=$((precio_num * cant_compra))
		total=$((total + subtotal))

		sed -i "${num}s/ - $cantidad - / - $nuevo_stock - /" productos.txt
		resumen+="$tipo - $modelo - $cant_compra unidades - $subtotal\n"
	done


	echo "---------------------"
	echo "Resumen de la compra"
	echo -e "$resumen"
	echo "Total a pagar: $total"
	echo "---------------------"
}

filtrar_prod(){
	if [ ! -f "$SESSION_FILE" ]; then
		echo "Se debe iniciar sesion"
		return
	fi
	if [ ! -s "productos.txt" ]; then
		echo "No hay productos cargados"
		return
	fi
	echo
	echo "Filtrar productos por Tipo"
	echo "--------------------------"

	read -p "Ingrese tipo de pintura (o presione enter para mostrar todos): " filtro
	echo "--------------------------"
	echo "Resultados: "
	echo "--------------------------"

	if [ -z "$filtro" ]; then
		cat productos.txt
	else
		grep -i " - $filtro - " productos.txt || echo "No se encontraron productos del tipo '$filtro'."
	fi
}

crear_repor(){
	if [ ! -f "$SESSION_FILE" ]; then
		echo "Se debe iniciar sesion"
		return
	fi
	if [ ! -s "productos.txt" ]; then
		echo "No hay productos cargados"
		return
	fi
	mkdir -p Datos
	Archivos="Datos/datos.csv"
	echo "Codigo,Tipo,Modelo,Descripcion,Cantidad,Precio" > "$Archivos"

	while IFS=" - " read -r codigo tipo modelo descripcion cantidad precio; do
		codigo=$(echo "$codigo" | tr -cd '[:alnum:]')
		tipo=$(echo "$tipo" | tr -cd '[:alnum:]')
		modelo=$(echo "$modelo" |  tr -cd '[:alnum:]')
		descripcion=$(echo "$descripcion" | tr -cd '[:alnum:]')
		cantidad=$(echo "$cantidad" | tr -cd '[:digit:]')
		precio_num=$(echo "$precio" | tr -cd '[:digit:]')
		echo "$codigo,$tipo,$modelo,$descripcion,$cantidad,$precio_num" >> "$Archivos"
	done < productos.txt

	echo "Reporte generado correctamente en '$Archivos'"
}


login(){
	echo
	echo "Iniciar Sesion"
	echo "--------------"
	read -p "Usuario: " user
	read -s -p "Password: " pass
	echo
	if grep -q "^$user:$pass$" "$USERS_FILE"; then
		echo "$user" > "$SESSION_FILE"
		echo "sesion iniciada correctamente como '$user'"
	else
		echo "Usuario o Password incorrectos."
	fi
}

logOut(){
	if [ -f "$SESSION_FILE" ]; then
		user=$(cat "$SESSION_FILE")
		rm "$SESSION_FILE"
		echo "Cerrando sesion de '$user'"
	else
		echo "No hay ninguna sesion activa."
	fi
}

while true; do
	echo
	echo "-----------------------"
	echo "1) Crear Usuario"
	echo "2) Iniciar Sesion"
	echo "3) Cerrar Sesion"
	echo "4) Cambiar Password"
	echo "5) Agregar Producto"
	echo "6) Vender Producto"
	echo "7) Filtrar Productos"
	echo "8) Crear Reporte CSV"
	echo "9) Salir"
	echo "-----------------------"
	echo
	read opcion

	case $opcion in
		1) crearUsuario ;;
		2) login ;;
		3) logOut ;;
		4) cambiar_Contra ;;
		5) ingresar_producto ;;
		6) vender_prod ;;
		7) filtrar_prod ;;
		8) crear_repor ;;
		9) echo "Saliendo..."; break ;;
		*) echo "Opcion invalida" ;;
	esac
done
