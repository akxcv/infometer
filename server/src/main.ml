open Opium.Std

type response = {
  percentage: int;
}

let percentage_json_response { percentage } =
  let open Ezjsonm in
  dict [ "percentage", (int percentage) ]

let post_percentage = post "/api/percentage" begin fun req ->
  req |> App.json_of_body_exn |> Lwt.map (fun data ->
    let message = Ezjsonm.(get_string (find (value data) ["message"])) in
    let response = {
      percentage = Infometer.percentage message;
    } in
    `Json (percentage_json_response response) |> respond
  )
end

let accept_options = App.options "**" begin fun _ ->
  respond' (`String "OK")
end

let _ =
  App.empty
  |> middleware Middlewares.logger
  |> middleware Middlewares.allow_cors
  |> post_percentage
  |> accept_options
  |> App.run_command
