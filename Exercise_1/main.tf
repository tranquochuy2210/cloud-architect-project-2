# TODO: Designate a cloud provider, region, and credentials
provider "aws" {
  region = "us-east-1"
}


# TODO: provision 4 AWS t2.micro EC2 instances named Udacity T2

resource "aws_instance" "udacity_t2" {
  count = 4
  ami = "ami-0742b4e673072066f"
  instance_type = "t2.micro"
  subnet_id = "subnet-03ebf73ecc4766045"
  tags = {
    Name = "Udacity T2-${count.index+1}"
  }
}
# TODO: provision 2 m4.large EC2 instances named Udacity M4
