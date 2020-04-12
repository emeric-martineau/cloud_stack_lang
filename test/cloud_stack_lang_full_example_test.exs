defmodule CloudStackLang.Parser.FullTest do
  use ExUnit.Case
  import CloudStackLang.Parser, only: [parse_and_eval: 5]

  test "all valide syntax" do
    text = ~S"""
    // Interger
    int0 = -1
    int1 = 1
    int2 = int1 + 1
    int3 = 1 + 1 *2
    int4 = 4 / 2 + 2
    int5 = 4 / (2 + 2)
    int6 = 4 - 2

    int7 = int1 + int2 + int3 + int5 + int4 * 10 / 2

    int8 = 10 + 6 / 3 * 20 / 4

    int9 = 1_0_00

    // Atom
    atom1 = :toto

    // String
    string1 = 'coucou c\'est cool'
    string2 = "coucou
        ${int1}"
    string3 = "\n\r\t\s\e"
    string4 = 1 + "hello"
    string5 = "hello" + 1
    string6 = 1.0 + "hello"
    string7 = "hello" + 1.0
    string8 = "hello" + " wolrd!"
    string9 = '\\ \n \r \s \' \t \g'

    // Float
    float1 = 1.3

    float2 = float1 * 2
    float3 = 2 * float1
    float4 = 2.6 * 5.67
    float5 = 1 + 1.3
    float6 = 1.3 + 1
    float7 = 2.6 / 2
    float8 = 1.3 ^ 2

    float9 = 1.2_34_5
    float10 = 1.2_34_5e1_2

    // Map
    map1 = {}
    map2 = {
      :a = "hello"
      "key1" = 'value'
      "key2" = float1
      'key3' = {
        "other_map" = "cool"
      }
    }
    map3 = { :a = 1 } + { :b = 2 :c = 3 }

    // Array
    array1 = []
    array2 = [
      1
      float1
    ]
    array3 = array2[0]
    array4 = [
      array2
    ]
    array5 = array4[0][1]
    array6 = [ 1 ] + [ 2 3 ]

    // Function
    base64.encode("1")
    function1 = base64.encode("1")

    // Hexa
    hexa1 = 0x1234

    // Octal
    octal1 = 0o1234

    // Boolean
    boolean1 = true
    boolean2 = false
    """

    result = %{
      int0: {:int, -1},
      int1: {:int, 1},
      int2: {:int, 2},
      int3: {:int, 3},
      int4: {:int, 4},
      int5: {:int, 1},
      int6: {:int, 2},
      int7: {:int, 27},
      int8: {:int, 20},
      int9: {:int, 1000},
      atom1: {:atom, :toto},
      string1: {:string, "coucou c'est cool"},
      string2: {:string, "coucou\n    1"},
      string3: {:string, "\n\r\t\s\e"},
      string4: {:string, "1hello"},
      string5: {:string, "hello1"},
      string6: {:string, "1.0hello"},
      string7: {:string, "hello1.0"},
      string8: {:string, "hello wolrd!"},
      string9: {:string, "\\ \\n \\r \\s ' \\t \\g"},
      float1: {:float, 1.3},
      float2: {:float, 2.6},
      float3: {:float, 2.6},
      float4: {:float, 14.742},
      float5: {:float, 2.3},
      float6: {:float, 2.3},
      float7: {:float, 1.3},
      float8: {:float, 1.6900000000000002},
      float9: {:float, 1.2345},
      float10: {:float, 1.2345e12},
      map1: {:map, %{}},
      map2:
        {:map,
         %{
           :a => {:string, "hello"},
           "key1" => {:string, "value"},
           "key2" => {:float, 1.3},
           "key3" => {:map, %{"other_map" => {:string, "cool"}}}
         }},
      map3: {:map, %{a: {:int, 1}, b: {:int, 2}, c: {:int, 3}}},
      array1: {:array, []},
      array2: {:array, [{:int, 1}, {:float, 1.3}]},
      array3: {:int, 1},
      array4: {:array, [array: [int: 1, float: 1.3]]},
      array5: {:float, 1.3},
      array6: {:array, [int: 1, int: 2, int: 3]},
      function1: {:string, "1"},
      hexa1: {:int, 4660},
      octal1: {:int, 668},
      boolean1: {:bool, true},
      boolean2: {:bool, false}
    }

    fct = %{
      :base64 => %{
        :encode => {:fct, [:string], fn x -> {:string, x} end}
      }
    }

    assert parse_and_eval(text, false, %{}, fct, %{})[:vars] == result
  end

  test "variable not found for addition" do
    text = ~S"""
    var1 = 1 + var0
    """

    assert parse_and_eval(text, false, %{}, %{}, %{}) ==
             {:error, 1, "Variable name 'var0' is not declared"}
  end

  test "variable not found for substitution" do
    text = ~S"""
    var1 = 1 - var0
    """

    assert parse_and_eval(text, false, %{}, %{}, %{}) ==
             {:error, 1, "Variable name 'var0' is not declared"}
  end

  test "variable not found for multiplication" do
    text = ~S"""
    var1 = 1 * var0
    """

    assert parse_and_eval(text, false, %{}, %{}, %{}) ==
             {:error, 1, "Variable name 'var0' is not declared"}
  end

  test "variable not found for division" do
    text = ~S"""
    var1 = 1 / var0
    """

    assert parse_and_eval(text, false, %{}, %{}, %{}) ==
             {:error, 1, "Variable name 'var0' is not declared"}
  end

  test "variable not found for exponent" do
    text = ~S"""
    var1 = 1 ^ var0
    """

    assert parse_and_eval(text, false, %{}, %{}, %{}) ==
             {:error, 1, "Variable name 'var0' is not declared"}
  end

  test "variable not found in map" do
    text = ~S"""
    var1 = {
      :a = var0
    }
    """

    assert parse_and_eval(text, false, %{}, %{}, %{}) ==
             {:error, 2, "Variable name 'var0' is not declared"}
  end

  test "variable not found in array" do
    text = ~S"""
    var1 = [ var0 ]
    """

    assert parse_and_eval(text, false, %{}, %{}, %{}) ==
             {:error, 1, "Variable name 'var0' is not declared"}
  end

  test "variable not found in function" do
    text = ~S"""
    base64_encode(var0)
    """

    assert parse_and_eval(text, false, %{}, %{}, %{}) ==
             {:error, 1, "Variable name 'var0' is not declared"}
  end

  test "substitution type error" do
    text = ~S"""
    var1 = 1 - "hello"
    """

    assert parse_and_eval(text, false, %{}, %{}, %{}) ==
             {:error, 1, "'-' operator not supported for {:int, 1}, {:string, \"hello\"}"}
  end

  test "multiplication type error" do
    text = ~S"""
    var1 = 1 * "hello"
    """

    assert parse_and_eval(text, false, %{}, %{}, %{}) ==
             {:error, 1, "'*' operator not supported for {:int, 1}, {:string, \"hello\"}"}
  end

  test "division type error" do
    text = ~S"""
    var1 = 1 / "hello"
    """

    assert parse_and_eval(text, false, %{}, %{}, %{}) ==
             {:error, 1, "'/' operator not supported for {:int, 1}, {:string, \"hello\"}"}
  end

  test "exponent type error" do
    text = ~S"""
    var1 = 1 ^ "hello"
    """

    assert parse_and_eval(text, false, %{}, %{}, %{}) ==
             {:error, 1, "'^' operator not supported for {:int, 1}, {:string, \"hello\"}"}
  end

  test "get value map error" do
    text = ~S"""
    var0 = "hello"
    var1 = var0[:a]
    """

    assert parse_and_eval(text, false, %{}, %{}, %{}) ==
             {:error, 2, "Trying get a value with key 'a' on non-map value"}
  end

  test "get value map with error in key" do
    text = ~S"""
    var0 = {
    "eee" = "ererere"
    }

    var1 = var0[e]
    """

    assert parse_and_eval(text, false, %{}, %{}, %{}) ==
             {:error, 5, "Variable name 'e' is not declared"}
  end

  test "call function not found" do
    text = ~S"""
    function_not_found()
    """

    assert parse_and_eval(text, false, %{}, %{}, %{}) ==
             {:error, 1, "Function 'function_not_found' not found"}
  end

  test "call function not found in assignation" do
    text = ~S"""
    var0 = function_not_found()
    """

    assert parse_and_eval(text, false, %{}, %{}, %{}) ==
             {:error, 1, "Function 'function_not_found' not found"}
  end

  test "array out of bound" do
    text = ~S"""
    var0 = [ 1 2 3 ]
    var1 = var0[5]
    """

    assert parse_and_eval(text, false, %{}, %{}, %{}) ==
             {:error, 2, "Index '5' is out of range (3 items in array)"}
  end

  test "check var is resolve in map key" do
    text = ~S"""
    var0 = "my_key"
    var1 = {
      var0 = "my_value"
    }
    """

    var_result = %{
      var0: {:string, "my_key"},
      var1:
        {:map,
         %{
           "my_key" => {:string, "my_value"}
         }}
    }

    state = parse_and_eval(text, false, %{}, %{}, %{})

    assert state[:vars] == var_result
  end
end
