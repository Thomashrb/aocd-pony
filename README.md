# Advent of code data | aocd

Get your advent of code input every day with a simple function call.

- download new advent of code input
- run advent of code input with a callback
- cache input so that you only need to download input once (and conforms to aocs "be nice" policy)

pony version of my [clojure version](https://github.com/Thomashrb/advent-of-code-data) of the [scala version](https://github.com/bbstilson/advent-of-code-data) by the same name that is in turn based on a python library.


## Installation
- Install [corral](https://github.com/ponylang/corral)
- `corral init`
- `corral add github.com/Thomashrb/aocd-pony.git --version 0.1.1`
- `corral fetch` to fetch your dependencies
- `use "aocd"` to include this package
- `corral run -- ponyc` to compile your application

Note: The net-ssl transitive dependency requires a C SSL library to be installed. Please see the net-ssl installation instructions for more information.


## Usage

### instanciate library class

The library class requires 3 arguments

- FilePath -- to store cache files
- String -- session token (see below)
- TCPAuth

``` pony
let file_path = FilePath(env.root as AmbientAuth, "/home/<user>/.cache/aocd").>mkdir()
let token = "<YOUR SESSION TOKEN>"
let tcp_auth = TCPAuth(env.root as AmbientAuth)

let aocd = Aocd(file_path, token, tcp_auth)
```

### use `get_input` to get data in Promise[String]

``` pony
let p = Promise[String]
aocd.get_input(2020, 1)

// use promise as you wish
p.next[None]({(s: String) =>
              env.out.print("Day1 part1 solve: " +
              Day1.solve_part1(s).string()) })
```

### Use your Promise[String]

If your aoc solve function takes a string directly something
like this can be done:


```pony
fun solve_part1(input: String, target_sum: USize = 2020): (USize val | None) =>
  let nums = _parse_entries(input)
  for x in nums.values() do
    for y in nums.values() do
      if ((x + y) == target_sum) then return x*y end
  end
end

``` 

_see examples/2020day1-example.pony for a full example_

## Run example

Add personal token (see below)

``` bash
❯ grep "let token" examples/2020day1-example.pony
    let token = "YOUR TOKEN"
```

Build and execute examples 

```bash
$ make run-examples
```


## Where are inputs cached

Inputs are cached as `input.txt` files in the directory set in the Aocd constructor
with <year> and <day> appended like so:

``` bash
# if my Aocd constructor base directory is $HOME/.cache/aocd 
# then my cache input is stored as follows
# $HOME/.cache/aocd/<year>/<day>/input.txt

❯ ls ~/.cache/aocd/2020/1/
input.txt
```


## How to get session token

1) Log in to advent of code.
2) Open any `input` link from
3) Open developer mode

![Session cookie from browser](session_token.png)

Above was taken from [here](https://github.com/wimglenn/advent-of-code-wim/issues/1)
