resource "tls_private_key" "public-key" {
 algorithm  = "RSA"
 rsa_bits   = 4096 
}

resource "aws_key_pair" "keypair" {
  key_name   = "skills-keypair"
  public_key = tls_private_key.public-key.public_key_openssh
}

resource "local_file" "ssh_key" {
  filename = "${aws_key_pair.keypair.key_name}.pem"
  content  = tls_private_key.public-key.private_key_pem
}

resource "aws_security_group" "bastion" {
  name        = "bastion_sg"
  description = "This is bastion ec2 security group"
  vpc_id      = aws_vpc.vpc.id
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "bastion_sg"
  }
}

resource "aws_instance" "bastion" {
 ami                    = var.amazonlinux
 key_name               = aws_key_pair.keypair.id
 subnet_id              = aws_subnet.public-subnet-a.id
 instance_type          = "t3.micro"
 iam_instance_profile   = aws_iam_instance_profile.bastion.name
 vpc_security_group_ids = [aws_security_group.bastion.id]
 user_data              = <<EOF
#!/bin/bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install
export PATH=/usr/local/bin:$PATH
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
yum install -y jq
yum install -y bash-completion
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv -v /tmp/eksctl /usr/local/bin
export AWS_REGION=$(curl -s 169.254.169.254/latest/dynamic/instance-identity/document | jq -r '.region')
export ACCOUNT_ID=$(curl -s 169.254.169.254/latest/dynamic/instance-identity/document | jq -r '.accountId')
export PUBLIC_SUBNET_A_ID=$(aws ec2 describe-subnets --region ap-northeast-2 --filters "Name=tag:Name,Values=skills-public-a" --query 'Subnets[].SubnetId[]' --output=text)
export PUBLIC_SUBNET_B_ID=$(aws ec2 describe-subnets --region ap-northeast-2 --filters "Name=tag:Name,Values=skills-public-b" --query 'Subnets[].SubnetId[]' --output=text)
export PUBLIC_SUBNET_C_ID=$(aws ec2 describe-subnets --region ap-northeast-2 --filters "Name=tag:Name,Values=skills-public-c" --query 'Subnets[].SubnetId[]' --output=text)
export PRIVATE_SUBNET_A_ID=$(aws ec2 describe-subnets --region ap-northeast-2 --filters "Name=tag:Name,Values=skills-private-a" --query 'Subnets[].SubnetId[]' --output=text)
export PRIVATE_SUBNET_B_ID=$(aws ec2 describe-subnets --region ap-northeast-2 --filters "Name=tag:Name,Values=skills-private-b" --query 'Subnets[].SubnetId[]' --output=text)
export PRIVATE_SUBNET_C_ID=$(aws ec2 describe-subnets --region ap-northeast-2 --filters "Name=tag:Name,Values=skills-private-c" --query 'Subnets[].SubnetId[]' --output=text)
source ~/.bash_profile
mkdir home/ec2-user/environment
 EOF

 tags = {
    Name = "skills-bastion"
 }
}
