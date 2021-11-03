use "../aocd"
use "collections"

actor Main
  new create(env: Env) =>
    let token = "YOUR TOKEN"
    let aocd = Aocd(env, token)
    let test_input = Day1.test_input()
    env.out.print("Day1 part1 test: " + Day1.solve_part1(test_input).string())
    aocd.run_input(2020, 1, {(s: String) =>
                              env.out.print("Day1 part1 solve: " +
                              Day1.solve_part1(s).string()) })


primitive Day1
  fun val test_input(): String => "1721\n979\n366\n299\n675\n145"

  fun solve_part1(input: String, target_sum: USize = 2020): (USize val | None) =>
    let nums = _parse_entries(input)
    for x in nums.values() do
      for y in nums.values() do
        if ((x + y) == target_sum) then return x*y end
      end
    end

  fun _parse_entries(input: String): List[USize] =>
    List[String].from(input.split())
      .map[USize]({(s: String) => try s.usize()? else 0 end})
