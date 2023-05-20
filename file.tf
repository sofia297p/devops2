provider "aws" {
  access_key = "key_AWS"
  secret_access_key = "secret_key_AWS"
  region = "us-east-1"
}



resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16" }
 

resource "aws_security_group" "security_g" {
  name        = "security_group"
  description = "Security Group"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

 ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

   
}

resource "aws_subnet" "subnet_1" {
  vpc_id = aws_vpc.my_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a" 
 
}

resource "aws_subnet" "subnet_2" {
  vpc_id = aws_vpc.my_vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1b" 
 
}




resource "aws_instance" "instance1" {
  ami           = "ami-0c94855ba95c71c99"
  instance_type = "t2.micro"
  subnet_id  = aws_subnet.subnet_1.id
  key_name  = "key_pair"  
  vpc_security_group_ids = [aws_security_group.security_g.id]

  user_data = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y prometheus node-exporter cadvisor

              systemctl enable prometheus
              systemctl start prometheus

              systemctl enable node-exporter
              systemctl start node-exporter

              systemctl enable cadvisor
              systemctl start cadvisor
              EOF

  provisioner "remote-exec" {
    inline = [
      "sleep 30",
      "curl http://localhost:9090",
      "curl http://localhost:9100",
      "curl http://localhost:8080"
      
    ]
  }
}



resource "aws_instance" "instance2" {
  ami           = "ami-0c94855ba95c71c99"
  instance_type = "t2.micro"
  subnet_id  = aws_subnet.subnet_2.id
  key_name  = "key_pair"  
  vpc_security_group_ids = [aws_security_group.security_g.id]
  user_data = <<-EOF
              #!/bin/bash
              apt-get update

              
              apt-get install -y node-exporter
              systemctl enable node-exporter
              systemctl start node-exporter

             
              apt-get install -y cadvisor
              systemctl enable cadvisor
              systemctl start cadvisor
              EOF

 provisioner "remote-exec" {
    inline = [
      "sleep 30",
      "curl http://localhost:9100",
      "curl http://localhost:8080"
      
    ]
  }
}