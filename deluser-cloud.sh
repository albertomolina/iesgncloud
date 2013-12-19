#!/bin/bash

#Definir la variable usuario con el nombre de usuario en el argumento 1 del programa
usuario=$1
#Guardo la ubicación del fichero en la variable archivo por si la necesito más adelante
archivo=/openrc.sh
#Compruebo si existe
if [ -e $archivo ]
# Si existe lo cargo y procedo a eliminar el usuario
then
	#Carcargar variables de entorno
	source /openrc.sh

	# obtener ID de un usuario 
	id=`keystone user-list | grep $1 |awk '{print $2}'`
	#creo un vector con los proyectos del usuario
	tenants_id=(`keystone tenant-list |grep -v ^\+|grep -v id | awk '{print $2}'`)	
	users_id=(`keystone user-list |grep -v ^\+|grep -v id | awk '{print $2}'`)	
	
	for id_tenant in tenants_id;
		do
			cont = 0
			for id_user in users_id;
				keystone role-list --user-id $id_user --tenant-id $id_tenant
				[ $? = 0] cont = cont + 1
			done
		
		
		
		
		done
	
	
	
	
	
	

	# obtener ID de un usuario
        id=`keystone user-list | grep $1 |awk '{print $2}'`
        #creo un vector con los proyectos del usuario
        tenants=(`keystone tenant-list | grep $1 | awk '{print $2}'`)
	#Borrar usuario
	echo -e "\nDeleting user "$usuario"...."
        keystone user-delete $usuario

	#Pasos que necesitamos en este programa(Asignarselos) -- Da un error cuando intentamos borrar un grupo
	#que esta en uso en alguna instancia. Por lo que habra que borrar antes la instancia.

	#borrar_grupos(Adrian Jimenez Blanes)
	for i in `nova secgroup-list |grep -v ^\+|grep -v Name| awk '{print $2}'`;
		do `nova secgroup-delete $i` ;
		echo "Eliminado el grupo de seguridad: "$i
	done

	#borrar_pares_de_claves(Carlos Miguel Hernandez Romero)(Funciona)
	for i in `nova keypair-list |grep -v ^\+|grep -v Name| awk '{print $2}'`;
		do `nova keypair-delete $i` ;
		echo "Eliminada el par de claves" $i
	done

	#borrar_IPs_flotantes(Carlos Miguel Hernandez Romero)(Funciona)
	for i in `nova floating-ip-list |grep -v ^\+|grep -v Ip| awk '{print $2}'`;
		do `nova floating-ip-delete $i` ;
		echo "Eliminada la IP flotante" $i
	done

	#borrar_subredes(Adrián Cid)
	#borrar_redes(Adrián Cid)
	#borrar_routers(Miguel Angel Martin Serrano)
	for i in `quantum router-list |grep -v ^\+| awk '{print $2}'| grep -v 'id'`;
                do `quantum router-delete $i` ;
                echo "Eliminanando router: " $i
        done
	#borrar_volumenes 
	#borrar_instantaneasInstancias

	#borrar_volumenes (Miguel Ángel Ávila Ruiz)
	for i in `nova volume-list |grep -v ^\+|grep -v ID| awk '{print $2}'`;
		do `nova volume-delete $i` ;
		echo "Eliminado el volumen " $i
	done
	#borrar_instantaneasvolumen(Jose Alejandro Perea)
	for i in `cinder snapshot-list | grep -v ^\+|grep -v ID | awk '{print $2}'`;
	do
		`cinder snapshot-delete $i`;
		echo "Eliminadas las instantaneas de volumenes"
	done
	#borrar_imagenes (Carlos Mejías)
	for i in `nova image-list |grep -v ^\+|grep -v ID| awk '{print $2}'`;
	do
		`nova image-delete $i`;
		echo "Eliminada la imagen" $i
	done

	#borrar_instancias(Fracnisco Javier Gimenez)
	for i in `nova list | grep -v ^\+|grep -v ID | awk '{print $2}'`;
	do
		`nova delete $i;`
	done

	#borrar_proyecto(Fracnisco Javier Gimenez)
	#borro todos los proyectos de un usuario
	for i in '${tenants[*]}';
	do
		`nova scrub $i;`
		`keystone tenant-delete $i;`
	done
# Si no existe le indico a el usuario el problema
else
	echo -e "No existe el archivo /openrc.sh es necesario para borrar el usuario"
	exit 0
fi
