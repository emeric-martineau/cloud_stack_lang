# Cloud Stack Lang - Language tour

Cloud Stack Lang is experimanltal purpose to create cloud stack by using native
cloud provider language like **CloudFormation** for **AWS**.

Cloud Stack Lang (CSL) provide more easy language to write your template.

A full example provided in
[examples](EXAMPLES.md).

*Thanks to [Gleam](https://gleam.run) for documentation inspiration.*

## Comments

CSL allows you to write comments in your code.

Here’s a simple comment:
```
// Hello, world!
```

In CSL, comments must start with two slashes and continue until the end of the
line. For comments that extend beyond a single line, you’ll need to include
`//` on each line, like this:

```
// Hello, world! I have a lot to say, so much that it will take multiple
// lines of text. Therefore, I will start each line with // to denote it
// as part of a multi-line comment.
```

Comments can also be placed at the end of lines containing code:

```
x =  1 + 2 // here we are adding two values together
```

Comments may also be indented:

```
  // here we are multiplying 1 by 2
  x = 1 * 2
```

## Strings

CLS's has strings, written as text surrounded by double quotes or single quote.
```
"Hello, CSL!"
```

Strings can span multiple lines.
```
"Hello
CSL!"
```

Special characters such as " or ' need to be escaped with a \ character.
```
"Here is a double quote -> \" <-"
```

In double quotes string, you can use `\\ \n \r \t \e`. Double quotes allow
interpolation:
```
x = 1
e = "x = ${x}" // x = 1
f = 'x = ${x}' // x = ${x}
```

## Bools

A CSL can be either `true` or `false`.

## Atom

Atoms are constants whose values are their own name.
```
:this_is_an_atom
```

## Ints & Floats

CSL's main number types are Int and Float.

### Ints

Ints are "whole" numbers.
```
1
2
-3
4001
```

Ints can also write in octal notation `0o777` and hexa notation `0x123`. You
can also have human notation `1_000_000`.

### Floats

Floats are numbers that have a decimal point.
```
1.5
2.0
-0.1
1.7e5
```

## Array

CSL support array.

Array are non homogeneous. Elements are separate **only** by space.
```
[1 2 3 4]  // Array of int
[1.22 2.30]  // Array of float
[1.22 3 4]  // Array of int and float
[[1 2 3] 4 5] // Array can contain array, map or whatever
```

You can access to element by using square brackets:
```
a[1] // Get second element
```

## Map

CSL support array.

Map are non homogeneous. Elements are separate **only** by space.
Key can be `string`, `atom` or variable name.

```
{
  'key1' = 1
  "key2" = 2
  :key3 = 3
  my_var = 4
}
```

You can access to element by using square brackets:
```
a["key2"]
```

## Variable

A variable provides us with named storage that our programs can manipulate.
Each variable in CSL has a specific type; a set of operations that can be
applied to the variable.

```
this_is_a_variable = 2
```

## Operators

You can apply set of operation of element:
 - int: support `+`, `-`, `/`, `*`, `^` (also with float);
 - float: support `+`, `-`, `/`, `*`, `^` (also with float);
 - array: support `+`;
 - map: support `+`;
 - string: support `+` (also with float and int).

## Module

CSL have module notation to declare cloud element. To create module just write:
```
<cloud_provider>::<type>::<cloud_type>(<name>) {
}

AWS::Resource::EC2::Instance(:my_instance) {
  availability_zone = "eu-west-1a"
  image_id = "ami-0713f98de93617bb4"
  instance_type = my_instance_type
  security_groups = [:ssh_security_group]
}
```

When your are in module, map key name can be a **name**. That means, you cannot
have variable for key name.

Name of module **must be** an atom. This atom will be use to link module
between them.

Properties name is snake case of read cloud properties.

## Intrinsec function

CSL provide these functions:
 - base64.decode(string);
 - base64.encode(string);
 - log.debug(string);
 - log.info(string);
 - log.warning(string);
 - log.error(string).
