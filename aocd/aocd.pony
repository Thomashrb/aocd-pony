use "promises"

actor Aocd

  """
  Get your aoc data here!
  This is the intended library entrypoint.
  """
  let _env: Env
  let _token: String

  new create(env: Env, token: String) =>
    _env = env
    _token = token

  be run_input(year: U16, day: U8, callback: {(String)} val) =>
    """
    Attempt to load String input from cache and if not exists
    request input from api to cache then load it"
    """
    let p = Promise[String]
    let cache: Cache val = recover val Cache(_env, year, day) end

    try
      callback(cache.cat()?)
    else
      Client(_env, year, day, _token, p)
      p.next[None]({(s: String)? => callback(cache.write_cat(s)?) })
    end
