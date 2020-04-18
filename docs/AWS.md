# Amazon Web Service for Cloud Stack Lang

Cloud Stack Lang support
[CloudFormation](https://aws.amazon.com/cloudformation/).

AWS CloudFormation have:
 - Format Version;
 - Description;
 - Metadata;
 - Parameters;
 - Mappings;
 - Conditions;
 - Transform;
 - Resources;
 - Outputs.

Cloud Stack Lang files are convert into YAML or Json CloudFormation files.

## Modules

### For Format Version, Description, Metadata, Transform, Resources

CloudFormation elements:
 - Format Version;
 - Description;
 - Metadata;
 - Transform;
 - Resources.

are declared in **one** module:
```
AWS::Stack(:void) {
  metadata = {
    instances = "Information about the instances"
    databases = "Information about the databases"
  }

  transform = [
    "MyMacro"
    "AWS::Serverless"
  ]

  version = "2010-09-09-2"

  description = "my description-2"
}
```

That is convert to:
```
Metadata:
  Instances:
    Description: "Information about the instances"
  Databases:
    Description: "Information about the databases"
Transform: [MyMacro, AWS::Serverless]
AWSTemplateFormatVersion: "2010-09-09"
Description: "my description"
```

You can have multiple `AWS::Stack` that will be merge into single.

The name of this module is ignored.

### For resources

Declare resource is really easy. Take CloudFormation type and insert word
`Resource` after `AWS::`.

For example if we have this CloudFormation:
```
Resources:
  MyInstance:
    Type: AWS::EC2::Instance
    Properties:
      AvailabilityZone: eu-west-1a
      ImageId: ami-0713f98de93617bb4
      InstanceType: "t2.micro"
}
```

We write like this:
```
AWS::Resource::EC2::Instance(:my_instance) {
  availability_zone = "eu-west-1a"
  image_id = "ami-0713f98de93617bb4"
  instance_type = my_instance_type
}
```

### Resource attributs

In CloudFormation, you can have resource attributs:
 - CreationPolicy;
 - DeletionPolicy;
 - DependsOn;
 - Metadata;
 - UpdatePolicy;
 - UpdateReplacePolicy.

Because this attribut never be found in resource properties, in CSL there are
put in same level of properties:
```
AWS::Resource::EC2::VPC(:example_vpc) {
  cidr_block = "10.0.0.0/16"
}

// ...

AWS::Resource::EC2::Subnet(:example_subnet) {
  depends_on = :ipv6_cidr_block
  // ...
}
```

## Intrinsic function

In CLS some functions can only call in module context. This is module function.

### Fn::Base64

```
AWS::Resource::EC2::Instance(:my_instance) {
  //...
  user_data = base64("#!/bin/bash -xe
                      yum update -y
                      yum install -y httpd
                      systemctl start httpd
                      systemctl enable httpd
                      echo 'Hello World from user data' > /var/www/html/index.html")
}
```

Invoke:
 - `base64(data: string)`;
 - `base64(data: function call)`.

### Fn::Cidr

```
cidr(
  "10.0.0.0/16"
  1
  8)
}
```

Invoke: 
 - `cidr(ip_block: string, count: int, cidr_bits: int)`;
 - `cidr(ip_block: function call, count: int, cidr_bits: int)`.


### Fn::GetAtt

```
// First method:
get_att(:example_vpc "Ipv6CidrBlocks")

// Second method:
get_att('ExampleVpc' "Ipv6CidrBlocks")

// Third method:
module.example_vpc.ipv6_cidr_block()
```

Invoke: 
 - `get_att(logical_name_of_resource : string, attribute_name: string)`;
 - `get_att(logical_name_of_resource : atom, attribute_name: string)`.

Another possible invoke is using `module.<name_of_module>.<properties>()`.

### Fn::Join

```
join("," [ "a" "b" "c" ])
```

Invoke: 
 - `join(delimiter: string, data: array)`.

### Fn::Select

```
select(1 [ "a" "b" "c" ])


select(
  0
  cidr(
    select(
      0
      module.example_vpc.ipv6_cidr_blocks())
    1
    64))
```

Invoke: 
 - `select(index: int, data: array)`;
 - `select(index: int, data: function call)`.

### Fn::Split

```
split("," "a,b,c")

split("," module.example_vpc.name())
```

Invoke: 
 - `split(delimiter: string, data: string)`;
 - `split(delimiter: string, data: function call)`.
 

### Fn::Transform

```
transform(
  "my_macro"
  {
    data1 = "1"
    data2 = "2"
  })
```

Invoke: 
 - `transform(macro_name: string, data: map)`.

### FN::Sub

```
sub("my text")

sub(
  "my text"
  {
    data1 = "1"
    data2 = "2"
  })
```

Invoke: 
 - `sub(text: string)`;
 - `sub(text: string, data: map)`.

### FN::FindInMap

```
find_in_map(:my_mapping, :top_level_key, :second_level_key)

map.my_mapping.top_level_key.second_level_key()
```

Invoke: 
 - `find_in_map(mapping_name: atom, top_level_key: atom | string | fct call, second_level_key: atom | string | fct call)`.

Another possible invoke is using `map.<mapping name>.<top level key>.<second level key>()`.

### !Ref

CSL provide three equivalents functions. To do this, use atom.
```
AWS::Resource::EC2::Instance(:my_instance) {
  // ...
  security_groups = [:ssh_security_group]
}

AWS::Resource::EC2::SecurityGroup(:ssh_security_group) {
  // ...
}
```

or you can use `ref()`.

Invoke: 
 - `ref(resource_name: atom)`;
 - `ref(resource_name: string)`.

If you use string for name, CSL can't detect dependency. Use it when you reference AWS parameter `AWS::xxx`.

### name()

Sometime, you need have the final CloudFormation resource name, for example to
use signal. To do this you can use `name()`. 

Invoke: 
 - `name(resource_name: atom)`.

## Mapping

AWS allow you to add mapping in CloudFormation file. To do this with Cloud
Stack Lang, just declare map like this:

```
AWS::Map(:my_map_name {
  "root_key" = {
    "key1" = "1"
    "key2" = "2"
  }
})

AWS::Resource::EC2::Instance(:my_instance) {
  image_id = find_in_map(:my_map_name "root_key" "key1")
  instance_type = "m1.small"
}

AWS::Resource::EC2::Instance(:my_instance) {
  image_id = map.my_map_name.root_key.key1()
  instance_type = "m1.small"
}
```

## Why atom name is so important ?

CSL use atom to get dependencies tree. Whe this, CSL can auto-generate
`DependsOn` attribut and check if no cyclic dependency found (not yet implemented).

CloudFormation have need `DependsOn` only if no `!Ref` on resource is used. CSL create
`DependsOn` to help us understand more quickly your resources dependencies.