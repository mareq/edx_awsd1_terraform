# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# terraform import 'aws_vpc.edx-build-aws-vpc' 'vpc-<id>'
# terraform state show -no-color 'aws_vpc.edx-build-aws-vpc' > ./state.dump/aws_vpc.edx-build-aws-vpc.hcl
resource "aws_vpc" "edx-build-aws-vpc" {
  cidr_block = "10.1.0.0/16"
  tags = {
    "edx_ex"  = "03"
    "project" = "edx_awsd1"
    "Name"    = "edx-build-aws-vpc"
  }

}

# terraform import 'aws_internet_gateway.edx-igw' 'igw-<id>'
# terraform state show -no-color 'aws_internet_gateway.edx-igw' > ./state.dump/aws_internet_gateway.edx-igw.hcl
resource "aws_internet_gateway" "edx-igw" {
  vpc_id = aws_vpc.edx-build-aws-vpc.id
  tags = {
    "edx_ex"  = "03"
    "project" = "edx_awsd1"
    "Name"    = "edx-igw"
  }
}

# terraform import 'aws_internet_gateway_attachment.edx-igw-vpc-attachment' 'igw-<id>:vpc-<id>'
# terraform state show -no-color 'aws_internet_gateway_attachment.edx-igw-vpc-attachment' > ./state.dump/aws_internet_gateway_attachment.edx-igw-vpc-attachment.hcl
resource "aws_internet_gateway_attachment" "edx-igw-vpc-attachment" {
  vpc_id              = aws_vpc.edx-build-aws-vpc.id
  internet_gateway_id = aws_internet_gateway.edx-igw.id
}

# terraform import 'aws_route_table.edx-routetable-public' 'rtb-<id>'
# terraform state show -no-color 'aws_route_table.edx-routetable-public' > ./state.dump/aws_route_table.edx-routetable-public.hcl
resource "aws_route_table" "edx-routetable-public" {
  depends_on = [
    aws_internet_gateway_attachment.edx-igw-vpc-attachment
  ]
  vpc_id = aws_vpc.edx-build-aws-vpc.id
  tags = {
    "edx_ex"  = "03"
    "project" = "edx_awsd1"
    "Name"    = "edx-routetable-public"
  }
}

# terraform import 'aws_route.edx-route-public' 'rtb-<id>_0.0.0.0/0'
# terraform state show -no-color 'aws_route.edx-route-public' > ./state.dump/aws_route.edx-route-public.hcl
resource "aws_route" "edx-route-public" {
  route_table_id         = aws_route_table.edx-routetable-public.id
  gateway_id             = aws_internet_gateway.edx-igw.id
  destination_cidr_block = "0.0.0.0/0"
}

# terraform import 'aws_subnet.edx-subnet-public-a' 'subnet-<id>'
# terraform state show -no-color 'aws_subnet.edx-subnet-public-a' > ./state.dump/aws_subnet.edx-subnet-public-a.hcl
resource "aws_subnet" "edx-subnet-public-a" {
  vpc_id                  = aws_vpc.edx-build-aws-vpc.id
  availability_zone       = data.aws_availability_zones.available.names[0]
  cidr_block              = "10.1.1.0/24"
  map_public_ip_on_launch = true
  tags = {
    "edx_ex"  = "03"
    "project" = "edx_awsd1"
    "Name"    = "edx-subnet-public-a"
  }
}

# terraform import 'aws_route_table_association.edx-routeassociation-public-a' 'subnet-<id>/rtb-<id>'
# terraform state show -no-color 'aws_route_table_association.edx-routeassociation-public-a' > ./state.dump/aws_route_table_association.edx-routeassociation-public-a.hcl
resource "aws_route_table_association" "edx-routeassociation-public-a" {
  route_table_id = aws_route_table.edx-routetable-public.id
  subnet_id      = aws_subnet.edx-subnet-public-a.id
}

# terraform import 'aws_subnet.edx-subnet-public-b' 'subnet-<id>'
# terraform state show -no-color 'aws_subnet.edx-subnet-public-b' > ./state.dump/aws_subnet.edx-subnet-public-b.hcl
resource "aws_subnet" "edx-subnet-public-b" {
  vpc_id                  = aws_vpc.edx-build-aws-vpc.id
  availability_zone       = data.aws_availability_zones.available.names[1]
  cidr_block              = "10.1.2.0/24"
  map_public_ip_on_launch = true
  tags = {
    "edx_ex"  = "03"
    "project" = "edx_awsd1"
    "Name"    = "edx-subnet-public-b"
  }
}

# terraform import 'aws_route_table_association.edx-routeassociation-public-b' 'subnet-<id>/rtb-<id>'
# terraform state show -no-color 'aws_route_table_association.edx-routeassociation-public-b' > ./state.dump/aws_route_table_association.edx-routeassociation-public-b.hcl
resource "aws_route_table_association" "edx-routeassociation-public-b" {
  route_table_id = aws_route_table.edx-routetable-public.id
  subnet_id      = aws_subnet.edx-subnet-public-b.id
}

# terraform import 'aws_subnet.edx-subnet-private-a' 'subnet-<id>'
# terraform state show -no-color 'aws_subnet.edx-subnet-private-a' > ./state.dump/aws_subnet.edx-subnet-private-a.hcl
resource "aws_subnet" "edx-subnet-private-a" {
  vpc_id            = aws_vpc.edx-build-aws-vpc.id
  availability_zone = data.aws_availability_zones.available.names[0]
  cidr_block        = "10.1.3.0/24"
  tags = {
    "edx_ex"  = "03"
    "project" = "edx_awsd1"
    "Name"    = "edx-subnet-private-a"
  }
}

# terraform import 'aws_subnet.edx-subnet-private-b' 'subnet-<id>'
# terraform state show -no-color 'aws_subnet.edx-subnet-private-b' > ./state.dump/aws_subnet.edx-subnet-private-b.hcl
resource "aws_subnet" "edx-subnet-private-b" {
  vpc_id            = aws_vpc.edx-build-aws-vpc.id
  availability_zone = data.aws_availability_zones.available.names[1]
  cidr_block        = "10.1.4.0/24"
  tags = {
    "edx_ex"  = "03"
    "project" = "edx_awsd1"
    "Name"    = "edx-subnet-private-b"
  }
}


