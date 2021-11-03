use "promises"
use "http"
use "files"
use "net_ssl"

// This is based on an example in the http project codebase
// https://github.com/ponylang/http/blob/main/examples/httpget/httpget.pony

actor Client
  """
  Issue get requests towards the aoc api to
  GET input data
  """
  let _env: Env
  // where to cache GET request
  let _p: Promise[String]

  new create(env: Env, year: U16, day: U8, token: String, p: Promise[String]) =>
    _env = env
    _p = p
    let url = try URL.build("https://adventofcode.com/"
                             + year.string()
                             + "/day/"
                             + day.string()
                             + "/input")?
      else
        _env.out.print("Invalid year: "
                       + year.string()
                       + "and/or day: "
                       + day.string())
        _env.exitcode(1)
        return
      end

    // Get certificate for HTTPS
    let sslctx = try
    recover
        SSLContext
          .>set_client_verify(true)
          .>set_authority(FilePath(env.root as AmbientAuth, "cacert.pem"))?
        end
      end

    try
      let client = HTTPClient(env.root as AmbientAuth, consume sslctx)
      // The Notify Factory will create HTTPHandlers as required
      let dumpMaker = recover val _HandlerFactory.create(this) end

      try
        // Build request.
        let req = Payload.request("GET", url)
        req("Cookie") = "session=" + token
        // Submit the request
        client(consume req, dumpMaker)?.body()?

      else
        _env.out.print("unable to send request")
        _env.exitcode(1)
      end
    else
      _env.out.print("unable to use network")
      _env.exitcode(1)
    end

  be failed(reason: HTTPFailureReason) =>
    match reason
    | AuthFailed =>
      _env.err.print("-- auth failed --")
    | ConnectFailed =>
      _env.err.print("-- connect failed --")
    | ConnectionClosed =>
      _env.err.print("-- connection closed --")
    end
    _env.exitcode(1)

  be have_response(response: Payload val) =>
    """
    Process return the the response message.
    """
    if response.status == 0 then
      _env.out.print("Failed")
      _env.exitcode(1)
      return
    end

    try
      var body: String iso = recover String end
      for piece in response.body()?.values() do
         body.append(piece)
       end
       _p(consume body)
    end

  be cancelled() => _env.out.print("-- response cancelled --")

  be have_body(data: ByteSeq val) => None

  be finished() => None

class _HandlerFactory is HandlerFactory
  let _main: Client

  new iso create(main': Client) =>
    _main = main'

  fun apply(session: HTTPSession): HTTPHandler ref^ =>
    _HttpHandler.create(_main, session)

class _HttpHandler is HTTPHandler
  """
  Handle the arrival of responses from the HTTP server.  These methods are
  called within the context of the HTTPSession actor.
  """
  let _main: Client
  let _session: HTTPSession

  new ref create(main': Client, session: HTTPSession) =>
    _main = main'
    _session = session

  fun ref apply(response: Payload val) =>
    """
    Start receiving a response.  We get the status and headers.  Body data
    *might* be available.
    """
    _main.have_response(response)

  fun ref chunk(data: ByteSeq val) =>
    """
    Receive additional arbitrary-length response body data.
    """
    _main.have_body(data)

  fun ref finished() =>
    """
    This marks the end of the received body data.  We are done with the
    session.
    """
    _main.finished()
    _session.dispose()

  fun ref cancelled() =>
    _main.cancelled()

  fun ref failed(reason: HTTPFailureReason) =>
    _main.failed(reason)
