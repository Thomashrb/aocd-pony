# Advent of code data | aocd

Get your advent of code input every day with a simple function call.

- download new advent of code input
- run advent of code input with a callback
- cache input so that you only need to download input once (and conforms to aocs "be nice" policy)

pony version of my [clojure version](https://github.com/Thomashrb/advent-of-code-data) of the [scala version](https://github.com/bbstilson/advent-of-code-data) by the same name that is in turn based on a python library.


## Installation
- Install [corral](https://github.com/ponylang/corral)
- `corral init`
- `corral add github.com/Thomashrb/aocd-pony.git --version 0.1.0`
- `corral fetch` to fetch your dependencies
- `use "aocd"` to include this package
- `corral run -- ponyc` to compile your application

Note: The net-ssl transitive dependency requires a C SSL library to be installed. Please see the net-ssl installation instructions for more information.


## Usage

### construct your function so it takes a String as input 

```pony
fun solve_part1(input: String, target_sum: USize = 2020): (USize val | None) =>
  let nums = _parse_entries(input)
  for x in nums.values() do
    for y in nums.values() do
      if ((x + y) == target_sum) then return x*y end
  end
end

``` 

### instanciate library class with token
``` pony
let aocd = Aocd(env, <YOUR SESSION TOKEN>)
```

### use `run_input` to run your input in a callback

``` pony
aocd.run_input(2020, 1, {(s: String) => solve_part1(s).string())})
```

## Where are inputs cached

``` bash
# $HOME/.cache/aocd/<year>/<day>/input.txt

❯ ls ~/.cache/aocd/2020/1/
input.txt
```

## Run example

Add your own token (see below)

``` bash
❯ grep "let token" examples/2020day1-example.pony
    let token = "YOUR TOKEN"
```

Build and execute examples 
```bash
$ make run-examples
```

## How to get session token

1) Log in to advent of code.
2) Open any `input` link from
3) Open developer mode

![Session cookie from browser](session_token.png)

Above was taken from [here](https://github.com/wimglenn/advent-of-code-wim/issues/1)
