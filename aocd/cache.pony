use "files"

class Cache
  let _base: FilePath
  let _year: U16
  let _day: U8
  let _app_name: String = "aocd"
  let _fn: String = "input.txt"

  new create(base: FilePath, year: U16, day: U8) =>
    _year = year
    _day = day
    _base = base

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
    end

  fun _cache_dir(): Directory? =>
    Directory(_base)?

  fun _mkdir(): None?  =>
    _cache_dir()?
      .>mkdir(_year.string())
      .open(_year.string())?
      .mkdir(_day.string())
