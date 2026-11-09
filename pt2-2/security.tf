###############################################################################
# Grup de seguretat
###############################################################################

resource "aws_security_group" "main" {
  name        = "VPC-03-sg"
  description = "SSH des de qualsevol lloc, ICMP des de la VPC i sortida total"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH des de qualsevol lloc"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "ICMP des de dins de la VPC"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    description = "Tot el transit sortint"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "VPC-03-sg"
  }
}
