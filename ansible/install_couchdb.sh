# Team 20
# Class: COMP90024 ASSIGNMENT 2 - Semester 2, 2019


ARGNUM=$#
MASTERNODE=$1

echo "number of arguments {$ARGNUM}"

echo "====== getting ip ======"
NODENAME=$(/sbin/ip -o -4 addr list eth0 | awk '{print $4}' | cut -d/ -f1)
echo "nodename couchdb@{$NODENAME}"

# Update cache.
sudo apt-get update
sudo bash -c "cat cluster_kernel.txt >> /opt/couchdb/etc/vm.args"
sudo apt install python-pip
sudo pip install docker-compose
sudo apt update && sudo apt upgrade
sudo read -t 10
curl -L https://couchdb.apache.org/repo/bintray-pubkey.asc | sudo apt-key add 
echo "deb https://apache.bintray.com/couchdb-deb bionic main" | sudo tee -a /etc/apt/sources.list
sudo apt update


# Set the password variable.
echo "== setting password for couchdb ===="
COUCHDB_PASSWORD=admin

# Bindaddress: 0.0.0.0 (does not bind to anything).
echo "== Setting up cluster variable for couch =="
echo "couchdb couchdb/mode select clustered
couchdb couchdb/mode seen true
couchdb couchdb/nodename string couchdb@${NODENAME}
couchdb couchdb/nodename seen true
couchdb couchdb/cookie string magiccookie
couchdb couchdb/cookie seen true
couchdb couchdb/bindaddress string 0.0.0.0
couchdb couchdb/bindaddress seen true
couchdb couchdb/adminpass password ${COUCHDB_PASSWORD}
couchdb couchdb/adminpass seen true
couchdb couchdb/adminpass_again password ${COUCHDB_PASSWORD}
couchdb couchdb/adminpass_again seen true" | sudo debconf-set-selections

# We enter non-interactive mode instead of interactive mode here.
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y couchdb
systemctl enable couchdb
systemctl status couchdb
curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
sudo apt-get install -y nodejs
sudo apt install node-grunt-cli
sudo docker pull ibmcom/couchdb3:3.0.0
sudo apt update

sudo docker create\
      --name couchdb$NODENAME\
      --env COUCHDB_USER=admin\
      --env COUCHDB_PASSWORD=admin\
      --env COUCHDB_SECRET=magiccookie\
      --env ERL_FLAGS="-setcookie \"magiccookie\" -name \"couchdb@$NODENAME\""\
      ibmcom/couchdb3:3.0.0
	  
curl -XPOST "http://admin:admin@$MASTERNODE:5984/_cluster_setup" \
      --header "Content-Type: application/json"\
      --data "{\"action\": \"enable_cluster\", \"bind_address\":\"0.0.0.0\",\
             \"username\": \"admin\", \"password\":\"admin\", \"port\": \"5984\",\
             \"remote_node\": \"$NODENAME\", \"node_count\": \"3\",\
             \"remote_current_user\":\"admin\", \"remote_current_password\":\"admin\"}"
