defmodule CloudStackLang.Parser.FullTest do
  use ExUnit.Case
  import CloudStackLang.Parser, only: [parse_and_eval: 1]

  test "all valide syntax" do
    text = ~S"""
    /*
     * This is a full example
     */
    // Interger
    var0 = -1
    var1 = 1
    var2 = var1 + 1
    var3 = 1 + 1 *2
    var4 = 4 / 2 + 2
    var5 = 4 / (2 + 2)
    var6 = 4 - 2

    var7 = var1 + var2 + var3 + var5 + var4 * 10 / 2

    var8 = 10 + 6 / 3 * 20 / 4

    var9 = :toto

    // String
    var10 = 'coucou c\'est cool'
    var11 = "coucou
        ${var1}"
    var12 = "\n\r\t\s"

    // Float
    var13 = 1.3

    var14 = var13 * 2
    var15 = 2 * var13
    var16 = 2.6 * 5.67
    var17 = 1 + 1.3
    var18 = 1.3 + 1
    var19 = 2.6 / 2
    var20 = 1.3 ^ 2

    // Map
    var21 = {}
    var22 = {
      :a = "hello"
      "key1" = 'value'
      "key2" = var13
      'key3' = {
        "other_map" = "cool"
      }
    }

    // Array
    var23 = []
    var24 = [
      1
      var13
    ]

    // Function
    base64_encode("1")
    var25 = base64_encode("1")

    // Hexa
    var26 = 0x1234

    // Octal
    var27 = 0o1234
    """

    result = %{
      var0: {:int, -1},
      var1: {:int, 1},
      var2: {:int, 2},
      var3: {:int, 3},
      var4: {:int, 4},
      var5: {:int, 1},
      var6: {:int, 2},
      var7: {:int, 27},
      var8: {:int, 20},
      var9: {:atom, :toto},
      var10: {:string, "coucou c'est cool"},
      var11: {:string, "coucou\n    1"},
      var12: {:string, "\n\r\t\s"},
      var13: {:float, 1.3},
      var14: {:float, 2.6},
      var15: {:float, 2.6},
      var16: {:float, 14.742},
      var17: {:float, 2.3},
      var18: {:float, 2.3},
      var19: {:float, 1.3},
      var20: {:float, 1.6900000000000002},
      var21: {:map, %{}},
      var22: {:map, %{
              :a => {:string, "hello"},
              "key1" => {:string, "value"},
              "key2" => {:float, 1.3},
              "key3" => {:map, %{"other_map" => {:string, "cool"}}}
      }},
      var23: {:array, []},
      var24: {:array, [ {:int, 1}, {:float, 1.3}]},
      var25: {:string, "MQ=="},
      var26: {:int, 4660},
      var27: {:int, 668},
    }

    assert parse_and_eval(text) == result
  end

  test "variable not found for addition" do
    text = ~S"""
    var1 = 1 + var0
    """

    assert parse_and_eval(text) == {:error, 1, "Variable name 'var0' is not declared"}
  end

  test "variable not found for substitution" do
    text = ~S"""
    var1 = 1 - var0
    """

    assert parse_and_eval(text) == {:error, 1, "Variable name 'var0' is not declared"}
  end

  test "variable not found for multiplication" do
    text = ~S"""
    var1 = 1 * var0
    """

    assert parse_and_eval(text) == {:error, 1, "Variable name 'var0' is not declared"}
  end

  test "variable not found for division" do
    text = ~S"""
    var1 = 1 / var0
    """

    assert parse_and_eval(text) == {:error, 1, "Variable name 'var0' is not declared"}
  end

  test "variable not found for exponent" do
    text = ~S"""
    var1 = 1 ^ var0
    """

    assert parse_and_eval(text) == {:error, 1, "Variable name 'var0' is not declared"}
  end

  test "variable not found in map" do
    text = ~S"""
    var1 = {
      :a = var0
    }
    """

    assert parse_and_eval(text) == {:error, 2, "Variable name 'var0' is not declared"}
  end

  test "variable not found in array" do
    text = ~S"""
    var1 = [ var0 ]
    """

    assert parse_and_eval(text) == {:error, 1, "Variable name 'var0' is not declared"}
  end

  test "variable not found in function" do
    text = ~S"""
    base64_encode(var0)
    """

    assert parse_and_eval(text) == {:error, 1, "Variable name 'var0' is not declared"}
  end

  test "addition type error" do
    text = ~S"""
    var1 = 1 + "hello"
    """

    assert parse_and_eval(text) == {:error, 1, "'+' operator not supported for {:int, 1}, {:string, \"hello\"}"}
  end

  test "substitution type error" do
    text = ~S"""
    var1 = 1 - "hello"
    """

    assert parse_and_eval(text) == {:error, 1, "'-' operator not supported for {:int, 1}, {:string, \"hello\"}"}
  end

  test "multiplication type error" do
    text = ~S"""
    var1 = 1 * "hello"
    """

    assert parse_and_eval(text) == {:error, 1, "'*' operator not supported for {:int, 1}, {:string, \"hello\"}"}
  end

  test "division type error" do
    text = ~S"""
    var1 = 1 / "hello"
    """

    assert parse_and_eval(text) == {:error, 1, "'/' operator not supported for {:int, 1}, {:string, \"hello\"}"}
  end

  test "exponent type error" do
    text = ~S"""
    var1 = 1 ^ "hello"
    """

    assert parse_and_eval(text) == {:error, 1, "'^' operator not supported for {:int, 1}, {:string, \"hello\"}"}
  end

  # TODO allow get on array
  test "get value map error" do
    text = ~S"""
    var0 = "hello"
    var1 = var0[:a]
    """

    assert parse_and_eval(text) == {:error, 2, "Trying get a value with key 'a' on non-map value"}
  end

  test "get value map with error in key" do
    text = ~S"""
    var0 = {
    "eee" = "ererere"
    }

    var1 = var0[e]
    """

    assert parse_and_eval(text) == {:error, 5, "Variable name 'e' is not declared"}
  end

  # TODO test error
  # Function not found
  # Function return error
end
