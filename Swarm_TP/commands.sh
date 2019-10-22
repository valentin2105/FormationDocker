sudo apt update
sudo apt install openssh-server


## On configure le DNS de notre cluster, node01,2,3

(node1)# cat /etc/hosts
127.0.0.1       localhost
192.168.2.100   node1
192.168.2.101   node2
192.168.2.102   node3

(node2)# cat /etc/hosts
127.0.0.1       localhost
192.168.2.100   node1
192.168.2.101   node2
192.168.2.102   node3

(node3)# cat /etc/hosts
127.0.0.1       localhost
192.168.2.100   node1
192.168.2.101   node2
192.168.2.102   node3

## Sur chaque noeuds,
apt update && apt install glusterfs-server

(node1)# mkdir -p /gluster/bricks/1/
(node1)# mkdir -p /mnt/gluster
(node2)# mkdir -p /gluster/bricks/2/
(node2)# mkdir -p /mnt/gluster
(node3)# mkdir -p /gluster/bricks/3/
(node3)# mkdir -p /mnt/gluster

## > 
(node1)# gluster peer probe node2
peer probe: success.
(node1)# gluster peer probe node3
peer probe: success.
(node1)# gluster peer status
Number of Peers: 2

Hostname: node2
Uuid: 60861905-6adc-4841-8f82-216c661f9fe2
State: Peer in Cluster (Connected)

Hostname: node3
Uuid: 572fed90-61de-40dd-97a6-4255ed8744ce
State: Peer in Cluster (Connected)

# On créer notre volume répliqué (sur le node1)
$ gluster volume create gfs \
replica 3 \
node1:/gluster/bricks/1 \
node2:/gluster/bricks/2 \
node3:/gluster/bricks/3

gluster volume start gfs

gluster volume status gfs

gluster volume info gfs

# On all nodes
mkdir -p /mnt/gluster

(node1)# mount.glusterfs localhost:/gfs /mnt/gluster
(node2)# mount.glusterfs localhost:/gfs /mnt/gluster
(node3)# mount.glusterfs localhost:/gfs /mnt/gluster


# On vérifie
df -h 

(gluster1)# echo "Hello World!" | sudo tee /mnt/gluster/test.txt
(gluster2)# cat /mnt/gluster/test.txt
"Hello World!"

rm  /mnt/gluster/test.txt

########################################
#Docker Swarm
#######################################

gluster1:~# mkdir /mnt/gluster/wp-content
gluster1:~# mkdir /mnt/gluster/mysql


swarm-manager:~# cat wordpress-stack.yml
# wordpress-stack.yml
version: '3.1'
services:
  wordpress:
    image: wordpress
    restart: always
    ports:
      - 8080:80
    environment:
      WORDPRESS_DB_HOST: db
      WORDPRESS_DB_USER: exampleuser
      WORDPRESS_DB_PASSWORD: examplepass
      WORDPRESS_DB_NAME: exampledb
    volumes:
      - "/mnt/gluster/wp-content:/var/www/html/wp-content"
    deploy:
      placement:
        constraints: [node.role == worker]
  db:
    image: mysql:5.7
    restart: always
    environment:
      MYSQL_DATABASE: exampledb
      MYSQL_USER: exampleuser
      MYSQL_PASSWORD: examplepass
      MYSQL_RANDOM_ROOT_PASSWORD: '1'
    volumes:
      - "/mnt/gluster/mysql:/var/lib/mysql"
    deploy:
      placement:
        constraints: [node.role == worker]


$ docker stack deploy -c wordpress-stack.yml wordpress

$ docker stack ps wordpress
