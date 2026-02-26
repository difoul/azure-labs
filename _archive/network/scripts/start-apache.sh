sudo apt update -y
sudo apt install net-tools -y
sudo apt install apache2 -y
sudo systemctl start apache2
sudo chown -R $USER:$USER /var/www
sudo echo "<h3>Hello from virtual machine : </h3> <h2><i>$(hostname -i)</i></h2>" > /var/www/html/index.html
