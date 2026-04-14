									COMPTE RENDU

Partie 1 : 

J’ai commencé par utiliser Terraform pour déployer une machine virtuelle Debian sur VirtualBox. La configuration respecte les2 Go de mémoire. 
Ensuite j ai fait l'installation de k3s sur la vm.
Étant donné que la VM utilise le protocole DHCP pour obtenir son adresse réseau, j’ai créé un script Bash nommé get_ip.sh. Ce script utilise
 la commande VBoxManage guestproperty get pour extraire dynamiquement l'adresse IP de la machine sans aucune intervention manuelle. Une fois
 l'IP récupérée, le script génère automatiquement un fichier d'inventaire Ansible nommé hosts.ini. 
Enfin, pour valider la connectivité et l'accès SSH (sécurisé par clé publique), j’ai utilisé la commande ansible k3s_nodes -i hosts.ini -m ping. 
Le message "SUCCESS" a confirmé que l'infrastructure était prête à être pilotée. 



Partie 2 : 

Pour cette seconde phase, j’ai récupéré le code source de l'API Node.js depuis le dépôt GitHub donné. 
Afin d'optimiser la taille de l'image, j’ai mis en place un build multi-étapes (multi-stage build) dans notre Dockerfile. 
	Dans la première phase, j’ai utilisé une image node:18-alpine (très légère)pour installer les dépendances avec npm install. 
	Dans la seconde phase, je conserve que les fichiers strictement nécessaires à l'exécution de l'API, ce qui permet de supprimer 
tous les fichiers inutiles. 
En quelque sorte J'utilise une première image (AS builder) pour copier les fichiers package.json et exécuter la commande npm install. Cette 
étape génère de nombreux fichiers qui sont lourds et inutiles pour faire tourner l'application puis Je repars d'une image Alpine vierge. 
Grâce à la commande COPY --from=builder, je ne récupère que le dossier node_modules et le code source depuis l'étape précédente.

J’ai également créé un fichier .dockerignore qui se lance avant le dockerfile contenant node_modules et .git pour éviter d'alourdir 
inutilement le contexte de construction. Il permet de lister tous les fichiers et dossiers présents sur ma machine (ou dans le dépôt Git) 
qui ne doivent pas être envoyés au "contexte de build" de Docker.

Une fois le fichier prêt, j’ai construit l'image avec la commande docker build -t leoherault/node-api:v1 . Après s’être authentifié via docker 
login -u leoherault, j’ai publié l'image sur le Docker Hub avec la commande docker push leoherault/node-api:v1. Le résultat final 
est une image plus légère (environ 200 Mo)

PARTIE 3

J’ai commencé par préparer la persistance des données pour MySQL en créant un PersistentVolumeClaim, garantissant la survie des données en cas de redémarrage du pod. Le fichier db-deployment.yaml définit le déploiement de la base (image mysql:5.7) et un service interne pour l'accessibilité. L'initialisation a été gérée via le script init_database.sql intégré au cluster par une ConfigMap, permettant à MySQL de créer automatiquement la base my_db et la table users au démarrage.

Pour l'API (leoherault/node-api:v1), j’ai configuré le fichier api-deployment.yaml en l'exposant via un service ClusterIP. Une phase de test a été nécessaire pour identifier les variables d'environnement exactes attendues par l'image (via l'inspection du fichier config/default.js dans le conteneur), assurant ainsi la liaison avec MySQL. Afin de garantir la scalabilité, j’ai ajouté un Horizontal Pod Autoscaler (HPA) configuré pour maintenir entre 1 et 3 pods selon l'usage CPU.

Le déploiement a été automatisé par un playbook Ansible (deploy.yml) gérant la copie des fichiers et l'application des manifests. Avec tout ca on a donc l'état Running des pods, la présence des tables en base de données, et les logs de l'API confirmant : 'MySQL database connected!'.

