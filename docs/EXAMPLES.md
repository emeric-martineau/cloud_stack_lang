# Examples

## Language base examples

```
//
// Welcome to Cloud Stack Lang.
// This file show you full syntaxe.
//

// We declare a variables that is integer.
int1 = 0
int2 = 1_000_000
// Integer can also write into hexadecimal notation...
int3 = 0xddd
// ... or in octal notation, usefull for unix right management.
int4 = 0o777

// We can also declare float.
float1 = 1.7
float1 = 1.7e5

// Integer or float can be negative
int5 = -300

// We can make great operation.
op1 = (int1 + int2 - (int3 * int4)) / (int5^2)

// We have atom (thank to Erlang and Elixir lang)
atom1 = :toto

// String is also cool !
// String without interpolation and support concatenation !
string1 = 'This is great string.' + ' I put \' in this'
// String with interpolation put variable value
string2 = "Value of g: ${int5}"
// String with simple quote or double quote can be multi line
string3 = "This
is
multiline
"
// In string you can put \n \t \r \\ \s, but only parse in double quote string
string4 = "\nr\tg\\g\s\f"

// In double quote string, if you don't want parse ${xxx} use this
string5 = "\${int5}"

// We have map.
// Empty map
map1 = { }
// Map with multi key type support
key1 = "a"
map2 = {
  key1 = 1
  "b" = 'great'
  'c' = {
    'e' = int1
  }
  :d = [
    1
    2
    3
  ]
}
// Sorry, map don't support number to key.
// Note, that you don't put ',' between item. A space char (space, tab, newline) is the rule.

// To get value of map.
val1 = map2["b"]

// We have array.
// Empty array
array1 = [ ]
array2 = [
  1 + 1
  1 + 3
]
array3 = [
  {"a" = "b" }
  'eeeee'
]
```

## Amazon Web Service

### EC2

```
my_instance_type = "t2.micro"

AWS::Resource::EC2::Instance(:my_instance) {
  availability_zone = "eu-west-1a"
  image_id = "ami-0713f98de93617bb4"
  instance_type = my_instance_type
  security_groups = [:ssh_security_group]
}

AWS::Resource::EC2::SecurityGroup(:ssh_security_group) {
  group_description = "SSH and HTTP"
  security_group_ingress = [
    {
      cidr_ip = "0.0.0.0/0"
      from_port = 22
      ip_protocol = "tcp"
      to_port = 22
    }
    {
      cidr_ip = "0.0.0.0/0"
      from_port = 80
      ip_protocol = "tcp"
      to_port = 80
    }
  ]
}
```

### EC2 with user data

```
my_instance_type = "t2.micro"

AWS::Resource::EC2::Instance(:my_instance) {
  availability_zone = "eu-west-1a"
  image_id = "ami-0713f98de93617bb4"
  instance_type = my_instance_type
  security_groups = [:ssh_security_group]
  user_data = base64("#!/bin/bash -xe
                      yum update -y
                      yum install -y httpd
                      systemctl start httpd
                      systemctl enable httpd
                      echo 'Hello World from user data' > /var/www/html/index.html")
}

AWS::Resource::EC2::SecurityGroup(:ssh_security_group) {
  group_description = "SSH and HTTP"
  security_group_ingress = [
    {
      cidr_ip = "0.0.0.0/0"
      from_port = 22
      ip_protocol = "tcp"
      to_port = 22
    }
    {
      cidr_ip = "0.0.0.0/0"
      from_port = 80
      ip_protocol = "tcp"
      to_port = 80
    }
  ]
}
```

### EC2 with stack parameters

```
my_instance_type = "t2.micro"

AWS::Resource::EC2::Instance(:my_instance) {
  availability_zone = "eu-west-1a"
  image_id = "ami-0713f98de93617bb4"
  instance_type = my_instance_type
  security_groups = [:ssh_security_group]
}

AWS::Resource::EC2::SecurityGroup(:ssh_security_group) {
  group_description = "SSH and HTTP"
  security_group_ingress = [
    {
      cidr_ip = "0.0.0.0/0"
      from_port = 22
      ip_protocol = "tcp"
      to_port = 22
    }
    {
      cidr_ip = "0.0.0.0/0"
      from_port = 80
      ip_protocol = "tcp"
      to_port = 80
    }
  ]
}

// You can have multiple AWS::Stack that will be merge into single
AWS::Stack(:void) {
  // Convert to
  // Metadata:
  //   Instances:
  //     Description: "Information about the instances"
  //   Databases:
  //     Description: "Information about the databases"
  metadata = {
    instances = "Information about the instances"
    databases = "Information about the databases"
  }
  // Convert to Transform: [MyMacro, AWS::Serverless]
  transform = [
    "MyMacro"
    "AWS::Serverless"
  ]
}

AWS::Stack(:void) {
  // Convert to AWSTemplateFormatVersion: "2010-09-09"
  version = "2010-09-09-2"
  // Convert to Description: "my description"
  description = "my description-2"
}
```
 
### VPC

```
AWS::Resource::EC2::VPC(:example_vpc) {
  cidr_block = "10.0.0.0/16"
}

AWS::Resource::EC2::VPCCidrBlock(:ipv6_cidr_block) {
  amazon_provided_ipv6_cidr_block = true
  vpc_id = :example_vpc
}


AWS::Resource::EC2::Subnet(:example_subnet) {
  depends_on = :ipv6_cidr_block
  assign_ipv6_address_on_creation = true
  cidr_block =
    select(
      0
      cidr(
        "10.0.0.0/16"
        1
        8))
  ipv6_cidr_block =
    select(
      0
      cidr(
        select(
          0
          // First method:
          //   get_att(:example_vpc "Ipv6CidrBlocks")
          //
          // Second method:
          //   get_att('ExampleVpc' "Ipv6CidrBlocks")
          //
          // Third method:
          //   module.example_vpc.ipv6_cidr_block()
          module.example_vpc.ipv6_cidr_blocks())
        1
        64))
  vpc_id = :example_vpc
}
```

### Auto-scaling group

```
AWS::Resource::AutoScaling::AutoScalingGroup(:auto_scaling_group) {
  availability_zones = get_azs()
  launch_configuration_name = :launch_config
  desired_capacity = 3
  min_size = 1
  max_size = 4
  // Attribut of resource is same place that properties
  creation_policy = {
    resource_signal = {
      count = 3
      timeout = "PT15M"
    }
  }

  update_policy = {
    auto_scaling_scheduled_action = {
      ignore_unmodified_group_size_properties = true
    }
    auto_scaling_rolling_update = {
      min_instances_in_service = 1
      max_batch_size = 2
      pause_time = "PT1M"
      wait_on_resource_signals = true
    }
  }
}

AWS::Resource::AutoScaling::LaunchConfiguration(:launch_config) {
  image_id = "ami-06ce3edf0cff21f07"
  instance_type = "t2.micro"
  user_data = base64(sub("#!/bin/bash -xe
                          yum update -y aws-cfn-bootstrap
                          /opt/aws/bin/cfn-signal -e $? --stack \${AWS::StackName} --resource ${name(:auto_scaling_group)} --region \${AWS::Region}"))
}
```