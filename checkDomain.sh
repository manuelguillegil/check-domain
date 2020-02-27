#!/bin/sh
#Debe tener postfix configurado en su sistema para poder utilizar este script

DOMINIO=""
ADMINISTRADOR=""
CELULAR=""
OPCION=""

echo "Introduzca el nombre del dominio a consultar: "
read DOMINIO
echo "Marque la opción que prefiere: "
echo "a- Notificar al administrador de las fallas a través de un email"
echo "b- Notificar al administrador de las fallas a través de un sms"
read OPCION

if [ "$OPCION" = "a" ]
    then
        echo "Introduzca la dirección de correo del administrador: "
        read ADMINISTRADOR
    else
        echo "Introduzca el número de celular del administrador: "
        read CELULAR

fi

while :
    do
        echo "Se comprobará si el dominio está arriba o presenta problemas: "
        if ping -c 1 $DOMINIO 1>/dev/null 2>/dev/null
            then
                echo "El dominio $DOMINIO está funcionando correctamente"
            else
                echo "Hay problemas en el dominio"
                echo "$(date) Caída del dominio $DOMINIO" > log_fallas.txt
                if traceroute $DOMINIO 1>/dev/null 2>/dev/null
                    then
                        echo "Se realizará un diágnostico sobre la pérdida de paquetes y se guardará en el system log"
                        ping -c 1 $DOMINIO 2>&1 | logger -s -t $(basename $0)
                        traceroute $DOMINIO 2>&1 | logger -s -t $(basename $0)
                    else
                        echo "El dominio está caído"
                fi

            if [ "$OPCION" = "a" ]
                then
                    mail -s "Dominio caído" $ADMINISTRADOR <<EOF
Saludos cordiales,
El dominio $DOMINIO está caído o presenta problemas
Gracias por su atención
EOF
            else
                curl -X POST https://textbelt.com/text \
                --data-urlencode phone=$CELULAR \
                --data-urlencode message='Saludos cordiales, El dominio $DOMINIO está caído o presenta problemas' \
                -d key=textbelt 
            fi
        exit 0
        fi

        sleep 60
    done