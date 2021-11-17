use "promises"
use "http"
use "files"
use "net"

// This is based on an example in the http project codebase
// https://github.com/ponylang/http/blob/main/examples/httpget/httpget.pony

actor Client
  """
  Issue get requests towards the aoc api to GET input data
  """
  let _p: Promise[String]

  new create(tcp_auth: TCPAuth, year: U16, day: U8, token: String, p: Promise[String]) =>
    _p = p
    let url = try
      URL.build("https://adventofcode.com/"
      + year.string()
      + "/day/"
      + day.string()
      + "/input")?
    else
      return
    end

    let client = HTTPClient(tcp_auth)
    // The Notify Factory will create HTTPHandlers as required
    let dumpMaker = recover val _HandlerFactory.create(this) end

    try
      // Build request.
      let req = Payload.request("GET", url)
      req("Cookie") = "session=" + token
      // Submit the request
      client(consume req, dumpMaker)?.body()?
    end

  be have_response(response: Payload val) =>
    """
    Process return the the response message.
    """
    if response.status == 0 then
      return
    end

    try
      var body: String iso = recover String end
      for piece in response.body()?.values() do
         body.append(piece)
       end
       _p(consume body)
    end

  // Only handle have_response

  be failed(reason: HTTPFailureReason) => None

  be cancelled() => None

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
