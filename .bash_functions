function prompt
{

local GRAY="\[\033[1;30m\]"
local LIGHT_GRAY="\[\033[0;37m\]"
local CYAN="\[\033[0;36m\]"
local LIGHT_CYAN="\[\033[1;36m\]"

local NORMAL="\[\033[0m\]"
local VERT="\[\033[0;32m\]"
local ROUGE="\[\033[0;31m\]"
local ROSE="\[\033[1;31m\]"

#si c'est root, c'est different
if [ "`id -u`" -eq 0 ]; then
      local COULEUR_LOGO=$VERT
      local U1=$ROSE
      local U2=$NORMAL
      local LOGO='#'
else
      local COULEUR_LOGO=$GRAY
      local U1=""
      local U2=""
      local LOGO='$'
fi

PS1="$GRAY[$LIGHT_GRAY\t$GRAY]$NORMAL ${debian_chroot:+($debian_chroot)}$U1\u$U2@\h:\w $COULEUR_LOGO$LOGO$NORMAL "
}

function mkcd () #Crée un dossier avec le nom passé en paramétre et va dedans
{                                                                            
  mkdir $1 && cd $1                                                          
}                                                                            

function bak () #Crée une sauvegarde du fichier passé en paramètre, en rajoutant l'heure et la date
{                                                                                                  
  cp $1 $1_`date +%H:%M:%S_%d-%m-%Y`                                                               
}                                                                                                  

function cpbak () #Idem, mais la copie est dans le dossier Sauvegarde
{                                                                    
  cp $1 ~/Sauvegarde/$1_`date +%H:%M:%S_%d-%m-%Y`                    
}

function gainsbourg() {
    ssh lagaline
}

function mep(){    
    case "$1" in
    images)
        echo "$(tput setaf 6)Mise en prod des images ...$(tput sgr0)"
        cd /cygdrive/d/wamp/www/images.gainsbourg.net/
    
        echo "$(tput setaf 2)Maj branche master local ...$(tput sgr0)"
        git checkout master
        git pull origin master
    
        echo "$(tput setaf 2)Maj branche prod local ...$(tput sgr0)"
        git checkout prod
        git rebase master
    
        echo "$(tput setaf 1)Maj branche prod distante ...$(tput sgr0)"
        git push origin prod
        ssh lougaou@gainsbourg.net "cd gainsbourg.net/scripts-mep ; ./mep-images.sh ; exit "
    
        echo "$(tput setaf 2)Passage en branche master local ...$(tput sgr0)"
        git checkout master
        
        echo "$(tput setaf 6)Mise en prod des images done$(tput sgr0)"
        ;;
    front)
        echo "$(tput setaf 6)Mise en prod du front ...$(tput sgr0)"
        cd /cygdrive/d/wamp/www/www.gainsbourg.net/
        
        echo "$(tput setaf 2)Suppression de l'ancienne version local de dist$(tput sgr0)"
        rm -rf /cygdrive/d/wamp/www/www.gainsbourg.net/dist
        
        echo "$(tput setaf 2)Build dist locale$(tput sgr0)"
        gulp build --env prod
                
        echo "$(tput setaf 1)Remote backup www.gainsbourg.net"
        ssh lougaou@gainsbourg.net "cd gainsbourg.net/scripts-mep ; ./backup-www.gainsbourg.net.sh ; exit "
        
        echo "$(tput setaf 1)Envoi au serveur de prod...$(tput sgr0)"
        scp dist/prod/*.* lougaou@gainsbourg.net:gainsbourg.net/www/
        
        echo "$(tput setaf 6)Mise en prod du front done$(tput sgr0)"
        ;;
    api)
        echo "$(tput setaf 6)Mise de l'API ...$(tput sgr0)"
        cd /cygdrive/d/wamp/www/api.gainsbourg.net/
        
        echo "$(tput setaf 2)Maj branche master local$(tput sgr0)"
        git checkout master
        git pull origin master
        
        echo "$(tput setaf 2)Maj branche prod local$(tput sgr0)"
        git checkout prod
        git rebase master
        
        echo "$(tput setaf 2)Push de la branche prod$(tput sgr0)"
        git push origin prod
        
        echo "$(tput setaf 1)Remote database backup"
        ssh lougaou@gainsbourg.net "cd gainsbourg.net/scripts-mep ; ./backup-db.sh ; exit "
        
        echo "$(tput setaf 1)Remote backup api.gainsbourg.net.sh"
        ssh lougaou@gainsbourg.net "cd gainsbourg.net/scripts-mep ; ./backup-api.gainsbourg.net.sh ; exit "
        
        echo "$(tput setaf 1)Maj branche prod distante$(tput sgr0)"            
        ssh lougaou@gainsbourg.net "cd gainsbourg.net/scripts-mep ; ./mep-api.sh ; exit "
        
        echo "$(tput setaf 2)Passage en branche master local$(tput sgr0)"
        git checkout master
        
        echo "$(tput setaf 6)Mise en prod API done$(tput sgr0)"
        ;;
    *)
        echo "$(tput setaf 1)Invalid option ($1)$(tput sgr0)"
        echo "Available options are [front|api|images]"
        ;;
    esac
}

dps (){                                                                       
    docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}\t{{.Image}}'
}  

dsta (){                                                                       
    docker-compose up -d;
}

dsto (){                                                                       
    docker-compose stop; docker-compose rm -f;
}   

dcl (){                                                               
    # Delete all running containers
    docker kill $(docker ps -q)  >/dev/null 2>&1

    # Delete all containers
    docker rm $(docker ps -qa)  >/dev/null 2>&1

    # Delete all network
    docker network ls | awk '{print $1}' | xargs docker network rm  >/dev/null 2>&1

    # Delete all images
    if [ "$2" = "-i" ] || [ "$2" = "--images" ]; then
        docker rmi -f $(docker images -q )
    fi
    
    docker system prune --all --volume;
}                                                                                