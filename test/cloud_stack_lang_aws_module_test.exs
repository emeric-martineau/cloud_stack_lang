defmodule CloudStackLang.Parser.AwsModuleTest do
  use ExUnit.Case
  import CloudStackLang.Parser, only: [parse_and_eval: 5]

  test "Create AWS module" do
    text = ~S"""
    my_instance_type = "t2.micro"

    AWS::EC2::Instance(:my_instance) {
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
      {"MyInstance", "AWS::EC2::Instance",
       %{
         "AvailabilityZone" => {:string, "eu-west-1a"},
         "ImageId" => {:string, "ami-0713f98de93617bb4"},
         "InstanceType" => {:string, "t2.micro"},
         "SecurityGroups" => {:atom, :ssh_security_group}
       }}
    ]

    fct = %{}

    state = parse_and_eval(text, false, %{}, fct, %{})

    assert state[:vars] == var_result
    assert state[:modules] == module_result
  end
end
