use "files"
use "appdirs"

class Cache
  let _env: Env
  let _year: U16
  let _day: U8
  let _app_name: String = "aocd"
  let _fn: String = "input.txt"

  new create(env: Env, year: U16, day: U8) =>
    _env = env
    _year = year
    _day = day

  fun write_cat(input: String, readLen: USize = 999999999): String? =>
    _write(input, readLen)
    cat(readLen)?

  fun cat(readLen: USize = 999999999): String? =>
    _cache_dir()?
      .open(_year.string() + "/" + _day.string())?
      .open_file(_fn)?
      .read_string(readLen)

  fun _write(input: String, readLen: USize = 999999999) =>
    try
      _mkdir()?
      _cache_dir()?
        .open(_year.string() + "/" + _day.string())?
        .create_file(_fn)?
        .>write(input)
        .>flush()
      else
        _env.out.print("-- Cache/write failed --")
    end

  fun _cache_dir(): Directory? =>
    let path = AppDirs(_env.vars, _app_name).user_cache_dir()?
    let base = FilePath(_env.root as AmbientAuth, path).>mkdir()
    Directory(base)?

  fun _mkdir(): None?  =>
    _cache_dir()?
      .>mkdir(_year.string())
      .open(_year.string())?
      .mkdir(_day.string())
