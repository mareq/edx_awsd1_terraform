# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

data "aws_ami" "amazon-linux" {
  most_recent = true
  owners      = ["amazon"]
  name_regex  = "^amzn2-ami-kernel"

  filter {
    name   = "state"
    values = ["available"]
  }
  filter {
    name   = "description"
    values = ["*Linux*"]
  }
}

locals {
  web-server-user-data = <<USER_DATA_EOF
#!/bin/bash -ex
sudo yum update -y
sudo yum install pip -y
sudo pip install flask
sudo pip install requests
mkdir PythonWebApp
cd PythonWebApp
sudo cat >> flaskApp.py << EOF
from flask import Flask
import requests
app = Flask(__name__)
@app.route("/")
def main():
  r = requests.get('http://169.254.169.254/latest/dynamic/instance-identity/document')
  text = "Welcome! Here is some info about me!\n\n" + r.text
  return text


if __name__ == "__main__":
  app.run(
    host='0.0.0.0',
    port=80,
    #debug=True
  )
EOF
sudo python flaskApp.py
USER_DATA_EOF
}

# terraform import 'aws_key_pair.aws-edx' 'aws-edx'
# terraform state show -no-color 'aws_key_pair.aws-edx' > ./state.dump/aws_key_pair.aws-edx.hcl
# terraform state rm aws_key_pair.aws-edx
#resource "aws_key_pair" "aws-edx" {
#  public_key = "ssh-rsa <key> aws-edx"
#}

# terraform import 'aws_security_group.edx-sg-ex03' 'sg-<id>'
# terraform state show -no-color 'aws_security_group.edx-sg-ex03' > ./state.dump/aws_security_group.edx-sg-ex03.hcl
resource "aws_security_group" "edx-sg-ex03" {
  vpc_id      = aws_vpc.edx-build-aws-vpc.id
  description = "edx-sg-ex03 created 2022-06-28T23:47:34.636Z"
  tags = {
    "edx_ex"  = "03"
    "project" = "edx_awsd1"
    "Name"    = "edx-sg-ex03"
  }
}

# terraform import 'aws_security_group_rule.eds-sg-ex03-ingress-ssh' 'sg-<id>_ingress_tcp_22_22_0.0.0.0/0'
# terraform state show -no-color 'aws_security_group_rule.eds-sg-ex03-ingress-ssh' > ./state.dump/aws_security_group_rule.eds-sg-ex03-ingress-ssh.hcl
resource "aws_security_group_rule" "eds-sg-ex03-ingress-ssh" {
  security_group_id = aws_security_group.edx-sg-ex03.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_blocks = [
    "0.0.0.0/0",
  ]
}

# terraform import 'aws_security_group_rule.eds-sg-ex03-ingress-http' 'sg-<id>_ingress_tcp_80_80_0.0.0.0/0'
# terraform state show -no-color 'aws_security_group_rule.eds-sg-ex03-ingress-http' > ./state.dump/aws_security_group_rule.eds-sg-ex03-ingress-http.hcl
resource "aws_security_group_rule" "eds-sg-ex03-ingress-http" {
  security_group_id = aws_security_group.edx-sg-ex03.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_blocks = [
    "0.0.0.0/0",
  ]
}

# terraform import 'aws_security_group_rule.eds-sg-ex03-egress-all' 'sg-<id>_egress_all_0_0_0.0.0.0/0'
# terraform state show -no-color 'aws_security_group_rule.eds-sg-ex03-egress-all' > ./state.dump/aws_security_group_rule.eds-sg-ex03-egress-all.hcl
resource "aws_security_group_rule" "eds-sg-ex03-egress-all" {
  security_group_id = aws_security_group.edx-sg-ex03.id
  type              = "egress"
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  cidr_blocks = [
    "0.0.0.0/0",
  ]
}

# terraform import 'aws_instance.edx-webserver-ex03' 'i-<id>'
# terraform state show -no-color 'aws_instance.edx-webserver-ex03' > ./state.dump/aws_instance.edx-webserver-ex03.hcl
resource "aws_instance" "edx-webserver-ex03" {
  instance_type = "t2.micro"
  ami           = data.aws_ami.amazon-linux.id
  key_name      = "aws-edx"
  subnet_id     = aws_subnet.edx-subnet-public-a.id
  vpc_security_group_ids = [
    aws_security_group.edx-sg-ex03.id
  ]
  user_data = local.web-server-user-data
  tags = {
    "edx_ex"  = "03"
    "project" = "edx_awsd1"
    "Name"    = "edx-webserver-ex03"
  }
}


