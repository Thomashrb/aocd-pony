use "files"
use "promises"
use "net"

actor Aocd

  """
  Get your aoc data here!
  This is the intended library entrypoint.
  """
  let _cache_path: FilePath
  let _token: String
  let _tcp_auth: TCPAuth

  new create(cache_path: FilePath, token: String, tcp_auth: TCPAuth) =>
    _cache_path = cache_path
    _token = token
    _tcp_auth = tcp_auth

  be get_input(year: U16, day: U8, p: Promise[String]) =>
    """
    Attempt to load String input from cache and if not exists
    request input from api to cache then load it"
    """
    let cache: Cache val = recover val Cache(_cache_path, year, day) end

    try
      p(cache.cat()?)
    else
      Client(_tcp_auth, year, day, _token, p)
      p.next[None]({(s: String)? => p(cache.write_cat(s)?) })
    end
