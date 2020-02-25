#!/bin/sh
#Debe tener postfix configurado en su sistema para poder utilizar este script
#Si lo va a probar con un dominio que no deje el proceso corriendo eternamente, podría
#terminar en spam

DOMINIO=""
ADMINISTRADOR=""
echo "Introduzca el nombre del dominio a consultar: "
read DOMINIO
echo "Introduzca la dirección de correo del administrador: "
read ADMINISTRADOR
while :
    do
        echo "Se comprobará si el dominio está arriba o presenta problemas: "
        if ping -c 1 $DOMINIO 1>/dev/null 2>/dev/null
            then
                echo "El dominio $DOMINIO está funcionando correctamente"
            else
                echo "Hay problemas en el dominio"
                if traceroute $DOMINIO > trace.txt
                    then
                        echo "Se realizará un diágnostico sobre la pérdida de paquetes y se guardará en un archivo log_fallas.txt"
                        traceroute $DOMINIO > log_fallas.txt
                        mail -s "Dominio caído" $ADMINISTRADOR <<EOF
Saludos cordiales,
El dominio $DOMINIO presenta problemas.
En el archivo log_fallas.txt se explica detalladamente la pérdida de paquetes
EOF
                    else
                        echo "El dominio está caído"
                fi
               mail -s "Dominio caído" $ADMINISTRADOR <<EOF
Saludos cordiales,
El dominio $DOMINIO está caído
Gracias por su atención
EOF
        fi

        sleep 60
    done