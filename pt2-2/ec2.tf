resource "aws_instance" "ec2_a" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t3.micro"
  key_name               = "vockey"
  subnet_id              = aws_subnet.public_a.id
  vpc_security_group_ids = [aws_security_group.main.id]

  tags = {
    Name = "ec2-a"
  }
}

resource "aws_instance" "ec2_b" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t3.micro"
  key_name               = "vockey"
  subnet_id              = aws_subnet.public_b.id
  vpc_security_group_ids = [aws_security_group.main.id]

  tags = {
    Name = "ec2-b"
  }
}
