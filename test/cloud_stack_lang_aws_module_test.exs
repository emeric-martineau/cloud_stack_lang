defmodule CloudStackLang.Parser.AwsModuleTest do
  use ExUnit.Case
  import CloudStackLang.Parser, only: [parse_and_eval: 5]

  alias CloudStackLang.Providers.AWS

  test "Create AWS module" do
    text = ~S"""
    my_instance_type = "t2.micro"

    AWS::Resource::EC2::Instance(:my_instance) {
      availability_zone = "eu-west-1a"
      image_id = "ami-0713f98de93617bb4"
      instance_type = my_instance_type
      security_groups = :ssh_security_group
    }
    """

    var_result = %{
      my_instance_type: {:string, "t2.micro"}
    }

    module_result = [
      {"MyInstance", ["AWS", "Resource", "EC2", "Instance"],
       {:map,
        %{
          "AvailabilityZone" => {:string, "eu-west-1a"},
          "ImageId" => {:string, "ami-0713f98de93617bb4"},
          "InstanceType" => {:string, "t2.micro"},
          "SecurityGroups" => {:atom, :ssh_security_group}
        }}}
    ]

    fct = %{}

    state = parse_and_eval(text, false, %{}, fct, %{})

    assert state[:vars] == var_result
    assert state[:modules] == module_result

    yaml_generate = AWS.Yaml.gen(module_result)

    yaml_test =
      "Resources:\n  MyInstance:\n    Properties:\n      AvailabilityZone: eu-west-1a\n      ImageId: ami-0713f98de93617bb4\n      InstanceType: t2.micro\n      SecurityGroups: !Ref SshSecurityGroup\n    Type: AWS::EC2::Instance"

    assert yaml_test == yaml_generate
  end

  test "Create AWS module global param" do
    text = ~S"""
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
    """

    var_result = %{}

    module_result = [
      {"Void", ["AWS", "Stack"],
       {:map,
        %{"Description" => {:string, "my description-2"}, "Version" => {:string, "2010-09-09-2"}}}},
      {"Void", ["AWS", "Stack"],
       {:map,
        %{
          "Metadata" =>
            {:map,
             %{
               "Databases" => {:string, "Information about the databases"},
               "Instances" => {:string, "Information about the instances"}
             }},
          "Transform" => {:array, [string: "MyMacro", string: "AWS::Serverless"]}
        }}}
    ]

    fct = %{}

    state = parse_and_eval(text, false, %{}, fct, %{})

    assert state[:vars] == var_result
    assert state[:modules] == module_result

    yaml_generate = AWS.Yaml.gen(module_result)

    yaml_test =
      "Description: my description-2\nMetadata:\n  Databases: Information about the databases\n  Instances: Information about the instances\nResources:\n\nTransform:\n  - MyMacro\n  - AWS::Serverless\nVersion: 2010-09-09-2"

    assert yaml_test == yaml_generate
  end

  test "Call ref method via method and atom" do
    text = ~S"""
    AWS::Resource::EC2::Instance(:my_instance) {
      availability_zone = "eu-west-1a"
      image_id = "ami-0713f98de93617bb4"
      instance_type = "t2.micro"
      security_groups = ref(:ssh_security_group)
    }
    """

    var_result = %{}

    module_result = [
      {"MyInstance", ["AWS", "Resource", "EC2", "Instance"],
       {:map,
        %{
          "AvailabilityZone" => {:string, "eu-west-1a"},
          "ImageId" => {:string, "ami-0713f98de93617bb4"},
          "InstanceType" => {:string, "t2.micro"},
          "SecurityGroups" => {:atom, :ssh_security_group}
        }}}
    ]

    fct = %{}

    modules_fct = %{
      AWS.prefix() => AWS.modules_functions()
    }

    state = parse_and_eval(text, false, %{}, fct, modules_fct)

    assert state[:vars] == var_result
    assert state[:modules] == module_result

    yaml_generate = AWS.Yaml.gen(module_result)

    yaml_test =
      "Resources:\n  MyInstance:\n    Properties:\n      AvailabilityZone: eu-west-1a\n      ImageId: ami-0713f98de93617bb4\n      InstanceType: t2.micro\n      SecurityGroups: !Ref SshSecurityGroup\n    Type: AWS::EC2::Instance"

    assert yaml_test == yaml_generate
  end

  test "Call ref method via method and string" do
    text = ~S"""
    AWS::Resource::EC2::Instance(:my_instance) {
      availability_zone = "eu-west-1a"
      image_id = "ami-0713f98de93617bb4"
      instance_type = "t2.micro"
      security_groups = ref("ssh_security_group")
    }
    """

    var_result = %{}

    module_result = [
      {"MyInstance", ["AWS", "Resource", "EC2", "Instance"],
       {:map,
        %{
          "AvailabilityZone" => {:string, "eu-west-1a"},
          "ImageId" => {:string, "ami-0713f98de93617bb4"},
          "InstanceType" => {:string, "t2.micro"},
          "SecurityGroups" => {:atom, :ssh_security_group}
        }}}
    ]

    fct = %{}

    modules_fct = %{
      AWS.prefix() => AWS.modules_functions()
    }

    state = parse_and_eval(text, false, %{}, fct, modules_fct)

    assert state[:vars] == var_result
    assert state[:modules] == module_result

    yaml_generate = AWS.Yaml.gen(module_result)

    yaml_test =
      "Resources:\n  MyInstance:\n    Properties:\n      AvailabilityZone: eu-west-1a\n      ImageId: ami-0713f98de93617bb4\n      InstanceType: t2.micro\n      SecurityGroups: !Ref SshSecurityGroup\n    Type: AWS::EC2::Instance"

    assert yaml_test == yaml_generate
  end

  test "Call ref method via method and wrong parameter" do
    text = ~S"""
    AWS::Resource::EC2::Instance(:my_instance) {
      availability_zone = "eu-west-1a"
      image_id = "ami-0713f98de93617bb4"
      instance_type = "t2.micro"
      security_groups = ref()
    }
    """

    fct = %{}

    modules_fct = %{
      AWS.prefix() => AWS.modules_functions()
    }

    state = parse_and_eval(text, false, %{}, fct, modules_fct)

    assert state == {:error, 5, "Wrong arguments for 'ref'. Waiting 1, given 0"}
  end

  test "Call ref method via method and wrong type" do
    text = ~S"""
    AWS::Resource::EC2::Instance(:my_instance) {
      availability_zone = "eu-west-1a"
      image_id = "ami-0713f98de93617bb4"
      instance_type = "t2.micro"
      security_groups = ref(1)
    }
    """

    fct = %{}

    modules_fct = %{
      AWS.prefix() => AWS.modules_functions()
    }

    state = parse_and_eval(text, false, %{}, fct, modules_fct)

    assert state ==
             {:error, 5,
              "Bad type argument for 'ref'. The argument n°0 waiting ':atom' or ':string' and given 'int'"}
  end

  test "Call base64 method with string" do
    text = ~S"""
    AWS::Resource::EC2::Instance(:my_instance) {
      availability_zone = "eu-west-1a"
      image_id = "ami-0713f98de93617bb4"
      instance_type = "t2.micro"
      security_groups = base64("ssh_security_group")
    }
    """

    var_result = %{}

    module_result = [
      {"MyInstance", ["AWS", "Resource", "EC2", "Instance"],
       {:map,
        %{
          "AvailabilityZone" => {:string, "eu-west-1a"},
          "ImageId" => {:string, "ami-0713f98de93617bb4"},
          "InstanceType" => {:string, "t2.micro"},
          "SecurityGroups" => {:module_fct, "base64", {:string, "ssh_security_group"}}
        }}}
    ]

    fct = %{}

    modules_fct = %{
      AWS.prefix() => AWS.modules_functions()
    }

    state = parse_and_eval(text, false, %{}, fct, modules_fct)

    assert state[:vars] == var_result
    assert state[:modules] == module_result

    yaml_generate = AWS.Yaml.gen(module_result)

    yaml_test =
      "Resources:\n  MyInstance:\n    Properties:\n      AvailabilityZone: eu-west-1a\n      ImageId: ami-0713f98de93617bb4\n      InstanceType: t2.micro\n      SecurityGroups: \n        Fn::Base64: ssh_security_group\n    Type: AWS::EC2::Instance"

    assert yaml_test == yaml_generate
  end

  test "Call base64 method with another method" do
    text = ~S"""
    AWS::Resource::EC2::Instance(:my_instance) {
      availability_zone = "eu-west-1a"
      image_id = "ami-0713f98de93617bb4"
      instance_type = "t2.micro"
      security_groups = base64(base64("ssh_security_group"))
    }
    """

    var_result = %{}

    module_result = [
      {"MyInstance", ["AWS", "Resource", "EC2", "Instance"],
       {:map,
        %{
          "AvailabilityZone" => {:string, "eu-west-1a"},
          "ImageId" => {:string, "ami-0713f98de93617bb4"},
          "InstanceType" => {:string, "t2.micro"},
          "SecurityGroups" =>
            {:module_fct, "base64", {:module_fct, "base64", {:string, "ssh_security_group"}}}
        }}}
    ]

    fct = %{}

    modules_fct = %{
      AWS.prefix() => AWS.modules_functions()
    }

    state = parse_and_eval(text, false, %{}, fct, modules_fct)

    assert state[:vars] == var_result
    assert state[:modules] == module_result

    yaml_generate = AWS.Yaml.gen(module_result)

    yaml_test =
      "Resources:\n  MyInstance:\n    Properties:\n      AvailabilityZone: eu-west-1a\n      ImageId: ami-0713f98de93617bb4\n      InstanceType: t2.micro\n      SecurityGroups: \n        Fn::Base64: \n          Fn::Base64: ssh_security_group\n    Type: AWS::EC2::Instance"

    assert yaml_test == yaml_generate
  end

  test "Call cidr method" do
    text = ~S"""
    AWS::Resource::EC2::Instance(:my_instance) {
      availability_zone = "eu-west-1a"
      image_id = "ami-0713f98de93617bb4"
      instance_type = "t2.micro"
      security_groups = cidr("192.168.0.0/24" 6 5)
      nothing = cidr(base64("cool") 6 5)
    }
    """

    var_result = %{}

    module_result = [
      {"MyInstance", ["AWS", "Resource", "EC2", "Instance"],
       {:map,
        %{
          "AvailabilityZone" => {:string, "eu-west-1a"},
          "ImageId" => {:string, "ami-0713f98de93617bb4"},
          "InstanceType" => {:string, "t2.micro"},
          "SecurityGroups" =>
            {:module_fct, "cidr", [{:string, "192.168.0.0/24"}, {:int, 6}, {:int, 5}]},
          "Nothing" =>
            {:module_fct, "cidr",
             [{:module_fct, "base64", {:string, "cool"}}, {:int, 6}, {:int, 5}]}
        }}}
    ]

    fct = %{}

    modules_fct = %{
      AWS.prefix() => AWS.modules_functions()
    }

    state = parse_and_eval(text, false, %{}, fct, modules_fct)

    assert state[:vars] == var_result
    assert state[:modules] == module_result

    yaml_generate = AWS.Yaml.gen(module_result)

    yaml_test =
      "Resources:\n  MyInstance:\n    Properties:\n      AvailabilityZone: eu-west-1a\n      ImageId: ami-0713f98de93617bb4\n      InstanceType: t2.micro\n      Nothing: \n        Fn::Cidr:\n          - \n            Fn::Base64: cool\n          - 6\n          - 5\n      SecurityGroups: \n        Fn::Cidr:\n          - 192.168.0.0/24\n          - 6\n          - 5\n    Type: AWS::EC2::Instance"

    assert yaml_test == yaml_generate
  end

  test "Call get_azs method" do
    text = ~S"""
    AWS::Resource::EC2::Instance(:my_instance) {
      availability_zone = "eu-west-1a"
      image_id = "ami-0713f98de93617bb4"
      instance_type = "t2.micro"
      security_groups = get_azs(cidr("192.168.0.0/24" 6 5))
      nothing = get_azs()
    }
    """

    var_result = %{}

    module_result = [
      {"MyInstance", ["AWS", "Resource", "EC2", "Instance"],
       {:map,
        %{
          "AvailabilityZone" => {:string, "eu-west-1a"},
          "ImageId" => {:string, "ami-0713f98de93617bb4"},
          "InstanceType" => {:string, "t2.micro"},
          "SecurityGroups" =>
            {:module_fct, "get_azs",
             {:module_fct, "cidr", [{:string, "192.168.0.0/24"}, {:int, 6}, {:int, 5}]}},
          "Nothing" => {:module_fct, "get_azs", {:string, ""}}
        }}}
    ]

    fct = %{}

    modules_fct = %{
      AWS.prefix() => AWS.modules_functions()
    }

    state = parse_and_eval(text, false, %{}, fct, modules_fct)

    assert state[:vars] == var_result
    assert state[:modules] == module_result

    yaml_generate = AWS.Yaml.gen(module_result)

    yaml_test =
      "Resources:\n  MyInstance:\n    Properties:\n      AvailabilityZone: eu-west-1a\n      ImageId: ami-0713f98de93617bb4\n      InstanceType: t2.micro\n      Nothing: \n        Fn::GetAZs: \"\"\n      SecurityGroups: \n        Fn::GetAZs: \n          Fn::Cidr:\n            - 192.168.0.0/24\n            - 6\n            - 5\n    Type: AWS::EC2::Instance"

    assert yaml_test == yaml_generate
  end

  test "Call select method" do
    text = ~S"""
    AWS::Resource::EC2::Instance(:my_instance) {
      availability_zone = "eu-west-1a"
      image_id = "ami-0713f98de93617bb4"
      instance_type = "t2.micro"
      security_groups = select(0 cidr("192.168.0.0/24" 6 5))
      nothing = select(0 [1 2 3])
    }
    """

    var_result = %{}

    module_result = [
      {"MyInstance", ["AWS", "Resource", "EC2", "Instance"],
       {:map,
        %{
          "AvailabilityZone" => {:string, "eu-west-1a"},
          "ImageId" => {:string, "ami-0713f98de93617bb4"},
          "InstanceType" => {:string, "t2.micro"},
          "SecurityGroups" =>
            {:module_fct, "select",
             [
               {:int, 0},
               {:module_fct, "cidr", [{:string, "192.168.0.0/24"}, {:int, 6}, {:int, 5}]}
             ]},
          "Nothing" =>
            {:module_fct, "select", [{:int, 0}, {:array, [{:int, 1}, {:int, 2}, {:int, 3}]}]}
        }}}
    ]

    fct = %{}

    modules_fct = %{
      AWS.prefix() => AWS.modules_functions()
    }

    state = parse_and_eval(text, false, %{}, fct, modules_fct)

    assert state[:vars] == var_result
    assert state[:modules] == module_result

    yaml_generate = AWS.Yaml.gen(module_result)

    yaml_test =
      "Resources:\n  MyInstance:\n    Properties:\n      AvailabilityZone: eu-west-1a\n      ImageId: ami-0713f98de93617bb4\n      InstanceType: t2.micro\n      Nothing: \n        Fn::Select:\n          - 0\n          - \n            - 1\n            - 2\n            - 3\n      SecurityGroups: \n        Fn::Select:\n          - 0\n          - \n            Fn::Cidr:\n              - 192.168.0.0/24\n              - 6\n              - 5\n    Type: AWS::EC2::Instance"

    assert yaml_test == yaml_generate
  end

  test "Call split method" do
    text = ~S"""
    AWS::Resource::EC2::Instance(:my_instance) {
      availability_zone = "eu-west-1a"
      image_id = "ami-0713f98de93617bb4"
      instance_type = "t2.micro"
      security_groups = split("," cidr("192.168.0.0/24" 6 5))
      nothing = split("0" "[1 2 3]")
    }
    """

    var_result = %{}

    module_result = [
      {"MyInstance", ["AWS", "Resource", "EC2", "Instance"],
       {:map,
        %{
          "AvailabilityZone" => {:string, "eu-west-1a"},
          "ImageId" => {:string, "ami-0713f98de93617bb4"},
          "InstanceType" => {:string, "t2.micro"},
          "SecurityGroups" =>
            {:module_fct, "split",
             [
               {:string, ","},
               {:module_fct, "cidr", [{:string, "192.168.0.0/24"}, {:int, 6}, {:int, 5}]}
             ]},
          "Nothing" => {:module_fct, "split", [{:string, "0"}, {:string, "[1 2 3]"}]}
        }}}
    ]

    fct = %{}

    modules_fct = %{
      AWS.prefix() => AWS.modules_functions()
    }

    state = parse_and_eval(text, false, %{}, fct, modules_fct)

    assert state[:vars] == var_result
    assert state[:modules] == module_result

    yaml_generate = AWS.Yaml.gen(module_result)

    yaml_test =
      "Resources:\n  MyInstance:\n    Properties:\n      AvailabilityZone: eu-west-1a\n      ImageId: ami-0713f98de93617bb4\n      InstanceType: t2.micro\n      Nothing: \n        Fn::Split:\n          - 0\n          - \"[1 2 3]\"\n      SecurityGroups: \n        Fn::Split:\n          - \",\"\n          - \n            Fn::Cidr:\n              - 192.168.0.0/24\n              - 6\n              - 5\n    Type: AWS::EC2::Instance"

    assert yaml_test == yaml_generate
  end
end
