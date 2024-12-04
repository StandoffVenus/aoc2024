import file_streams/file_stream_error
import gleam/io
import gleam/list
import gleam/result

import file_streams/file_stream

pub type Error {
  Message(String)
}

pub fn main() {
  let challenges = [challenge_1]
  list.each(challenges, fn(challenge) {
    case challenge() {
      Ok(nil) -> nil
      Error(err) -> {
        let reason = file_stream_error.describe(err)
        panic as reason
      }
    }
  })
}

pub fn challenge_1() -> Result(Nil, _) {
  let file_name = "challenge_1.txt"
  use file <- result.try(file_stream.open_read(file_name))

  for_each_line(file, io.println)
}

pub fn for_each_line(
  stream: file_stream.FileStream,
  func: fn(String) -> Nil,
) -> Result(Nil, _) {
  use result <- if_not_eof(file_stream.read_line(stream))
  use line <- result.try(result)
  func(line)
  for_each_line(stream, func)
}

fn if_not_eof(
  r: Result(a, file_stream_error.FileStreamError),
  func: fn(Result(a, file_stream_error.FileStreamError)) ->
    Result(Nil, file_stream_error.FileStreamError),
) -> Result(_, _) {
  case r {
    Ok(_) -> func(r)
    Error(err) -> {
      case err {
        file_stream_error.Eof -> Ok(Nil)
        _ -> Error(err)
      }
    }
  }
}
