import file_streams/file_stream_error
import gleam/io
import gleam/list
import gleam/result
import gleam/string

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
        case err {
          Message(msg) -> panic as msg
        }
      }
    }
  })
}

pub fn challenge_1() -> Result(Nil, Error) {
  let file_name = "challenge_1.txt"
  let open_read_result =
    file_stream.open_read(file_name)
    |> result.map_error(file_stream_error_to_error)

  use file <- result.try(open_read_result)
  use line <- result.try(for_each_line(file))

  let r: Result(#(String, String), Nil) = string.split_once("", "")
  use #(left, right) <- result.try(r)

  Ok(Nil)
}

pub fn for_each_line(
  stream: file_stream.FileStream,
  func: fn(String) -> Result(a, e),
) -> Result(a, ForEachError(e)) {
  case file_stream.read_line(stream) {
    Error(file_stream_error.Eof) -> Error(Done)
    Ok(str) -> {
      use _ <- result.try(func(str) |> result.map_error(ForEachError))
      use a <- result.try(for_each_line(stream, func))
      Ok(a)
    }
    e -> Error(ForEachError(e))
  }
}

pub type ForEachError(err) {
  Done
  ForEachError(err)
}

fn file_stream_error_to_error(err: file_stream_error.FileStreamError) -> Error {
  Message(file_stream_error.describe(err))
}
