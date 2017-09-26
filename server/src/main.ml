open Opium.Std

type response = {
  percentage: int;
}

let add_cors_headers (headers: Cohttp.Header.t): Cohttp.Header.t =
  Cohttp.Header.add_list headers [
    ("access-control-allow-origin", "*");
    ("access-control-allow-headers", "Accept, Content-Type");
    ("access-control-allow-methods", "GET, HEAD, POST, DELETE, OPTIONS, PUT, PATCH")
  ]

let allow_cors =
  let open Core_kernel.Std in
  let filter handler req =
    handler req |> Lwt.map (fun response ->
      response
      |> Response.headers
      |> add_cors_headers
      |> Field.fset Response.Fields.headers response
    )
  in
  Rock.Middleware.create ~name:"allow cors" ~filter

let logger =
  let filter handler req =
    let meth = Cohttp.Code.string_of_method (Request.meth req) in
    let uri = Uri.path (Request.uri req) in
    req |> handler |> Lwt.map (fun res ->
      let code = Cohttp.Code.string_of_status (Response.code res) in
      print_endline (meth ^ " " ^ uri ^ " " ^ code);
      res
    )
  in
  Rock.Middleware.create ~filter ~name:"logger"

let calculate_percentage info =
  let seed = 213453 in
  (Hashtbl.seeded_hash seed info) mod 100 + 1

let json_response { percentage } =
  let open Ezjsonm in
  dict [ "percentage", (int percentage) ]

let print_percentage = post "/api/percentage" begin fun req ->
  req |> App.json_of_body_exn |> Lwt.map (fun data ->
    let message = Ezjsonm.(get_string (find (value data) ["message"])) in
    let response = {
      percentage = calculate_percentage message;
    } in
    `Json (response |> json_response) |> respond
  )
end

let accept_options = App.options "**" begin fun _ ->
  respond' (`String "OK")
end

let _ =
  App.empty
  |> middleware logger
  |> middleware allow_cors
  |> print_percentage
  |> accept_options
  |> App.run_command
