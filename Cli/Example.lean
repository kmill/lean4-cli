import Cli

open Cli

def doNothing (p : Parsed) : IO UInt32 :=
  return 0

def runExampleCmd (p : Parsed) : IO UInt32 := do
  let input   : String       := p.positionalArg! "input" |>.as! String
  let outputs : Array String := p.variableArgsAs! String
  IO.println <| "Input: " ++ input
  IO.println <| "Outputs: " ++ toString outputs

  if p.hasFlag "verbose" then
    IO.println "Flag `--verbose` was set."
  if p.hasFlag "invert" then
    IO.println "Flag `--invert` was set."
  if p.hasFlag "optimize" then
    IO.println "Flag `--optimize` was set."

  let priority : Nat := p.flag! "priority" |>.as! Nat
  IO.println <| "Flag `--priority` always has at least a default value: " ++ toString priority

  if let some setPathsFlag := p.flag? "set-paths" then
    IO.println <| toString <| setPathsFlag.as! (Array String)
  return 0

def installCmd := `[Cli|
  installCmd VIA doNothing; ["0.0.1"]
  "installCmd provides an example for a subcommand without flags or arguments."
]

def testCmd := `[Cli|
  testCmd VIA doNothing; ["0.0.1"]
  "testCmd provides another example for a subcommand without flags or arguments."
]

def exampleCmd : Cmd := `[Cli|
  exampleCmd VIA runExampleCmd; ["0.0.1"]
  "This string denotes the description of `exampleCmd`."

  FLAGS:
    verbose;                    "Declares a flag `--verbose`. This is the description of the flag."
    i, invert;                  "Declares a flag `--invert` with an associated short alias `-i`."
    o, optimize;                "Declares a flag `--optimize` with an associated short alias `-o`."
    p, priority : Nat;          "Declares a flag `--path` with an associated short alias `-p` " ++
                                "that takes an argument of type `Nat`."
    "set-paths" : Array String; "Declares a flag `--set-priorities` " ++
                                "that takes an argument of type `Array Nat`. " ++
                                "Quotation marks allow the use of hyphens."

  ARGS:
    input : String;      "Declares a positional argument <input> " ++
                         "that takes an argument of type `String`."
    ...outputs : String; "Declares a variable argument <output>... " ++
                         "that takes an arbitrary amount of arguments of type `String`."

  SUBCOMMANDS:
    installCmd;
    testCmd

  -- The EXTENSIONS section denotes features that
  -- were added as an external extension to the library.
  -- `./Cli/Extensions.lean` provides some commonly useful examples.
  EXTENSIONS:
    author "mhuisi";
    defaultValues! #[("priority", "0")]
]

def main (args : List String) : IO UInt32 :=
  exampleCmd.validate! args

#eval main <| "exampleCmd -i -o -p 1 --set-paths=path1,path2,path3 input output1 output2".splitOn " "
/-
Yields:
  Input: input
  Outputs: #[output1, output2]
  Flag `--invert` was set.
  Flag `--optimize` was set.
  Flag `--priority` always has at least a default value: 1
  #[path1, path2, path3]
-/

-- Short parameterless flags can be grouped,
-- short flags with parameters do not need to be separated from
-- the corresponding value.
#eval main <| "exampleCmd -io -p1 input".splitOn " "
/-
Yields:
  Input: input
  Outputs: #[]
  Flag `--invert` was set.
  Flag `--optimize` was set.
  Flag `--priority` always has at least a default value: 1
-/

#eval main <| "exampleCmd --version".splitOn " "
/-
Yields:
  0.0.1
-/


#eval main <| "exampleCmd -h".splitOn " "
/-
Yields:
  exampleCmd [0.0.1]
  mhuisi
  This string denotes the description of `exampleCmd`.

  USAGE:
      exampleCmd [SUBCOMMAND] [FLAGS] <input> <outputs>...

  FLAGS:
      -h, --help                  Prints this message.
      --version                   Prints the version.
      --verbose                   Declares a flag `--verbose`. This is the
                                  description of the flag.
      -i, --invert                Declares a flag `--invert` with an associated
                                  short alias `-i`.
      -o, --optimize              Declares a flag `--optimize` with an associated
                                  short alias `-o`.
      -p, --priority : Nat        Declares a flag `--path` with an associated
                                  short alias `-p` that takes an argument of type
                                  `Nat`. [Default: `0`]
      --set-paths : Array String  Declares a flag `--set-priorities` that takes an
                                  argument of type `Array Nat`. Quotation marks
                                  allow the use of hyphens.

  ARGS:
      input : String    Declares a positional argument <input> that takes an
                        argument of type `String`.
      outputs : String  Declares a variable argument <output>... that takes an
                        arbitrary amount of arguments of type `String`.

  SUBCOMMANDS:
      installCmd  installCmd provides an example for a subcommand without flags or
                  arguments.
      testCmd     testCmd provides another example for a subcommand without flags
                  or arguments.
-/