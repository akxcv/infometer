open Opium.Std

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
  Rock.Middleware.create ~filter ~name:"allow cors"

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

let serve_static_files =
  Middleware.static ~local_path:"./client" ~uri_prefix:"/"
