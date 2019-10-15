# Provision a web server instance using the latest Ubuntu 16.04 on a
# t2.micro node with an AWS Tag naming it "web-server"
provider "aws" {
  region = "us-east-2"
}

# Create web server
resource "aws_instance" "web_server" {
  ami                    = data.aws_ami.ubuntu.id
  vpc_security_group_ids = [aws_security_group.web_server.id]
  instance_type          = "t2.micro"
  key_name               = "web_server"
  tags = {
    Name = "web-server"
  }

  connection {
    type        = "ssh"
    user        = "ubuntu" //Default Username
    host        = self.public_ip //Connects to provisioned IP
    private_key = file("~/.ssh/id_rsa") //If Public SSH key has not been created, please do so.
  }
  ### Install Apache Webserver
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install apache2 nginx -y",
      "sudo apt-get update",
      "sudo systemctl enable nginx", //Sets services to stay running
      "sudo systemctl start nginx", //Start Apache Services
      "sudo mkdir -p /var/www/wolfmeatsheep.com/html",
      "sudo chown -R $USER:$USER /var/www/wolfmeetsheep.com/html",
      "sudo chmod -R 755 /var/www/wolfmeatsheep.com"
    ]
  }

  provisioner "file" {
    source      = "index.html"
    destination = "/var/www/wolfmeatsheep.com/html/index.html"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo /etc/nginx/sichmod 644 /var/www/wolfmeatsheep.com/html/index.html"
    ]
  }

  # Save the public IP for testing
  provisioner "local-exec" {
    command = "echo ${aws_instance.web_server.public_ip} > public-ip.txt"
  }
}