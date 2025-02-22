type t = Run.t list

let empty = []

let add hd tl = hd :: tl

let count_all runs = List.length runs

let count_nothing runs =
  List.fold_left
    (fun count r -> match r.Run.res with Nothing _ -> succ count | _ -> count)
    0 runs

let count_reached runs =
  List.fold_left
    (fun count r -> match r.Run.res with Reached _ -> succ count | _ -> count)
    0 runs

let count_timeout runs =
  List.fold_left
    (fun count r -> match r.Run.res with Timeout _ -> succ count | _ -> count)
    0 runs

let count_other runs =
  List.fold_left
    (fun count r -> match r.Run.res with Other _ -> succ count | _ -> count)
    0 runs

let count_killed runs =
  List.fold_left
    (fun count r ->
      match r.Run.res with Signaled _ | Stopped _ -> succ count | _ -> count )
    0 runs

let keep_nothing = List.filter Run.is_nothing

let keep_reached = List.filter Run.is_reached

let keep_timeout = List.filter Run.is_timeout

let keep_other = List.filter Run.is_other

let keep_killed = List.filter Run.is_killed

let keep_if f runs = List.filter f runs

let min_clock runs =
  match runs with
  | [] -> 0.
  | hd :: runs ->
    List.fold_left
      (fun current_min r ->
        let clock = Run.clock r in
        min clock current_min )
      (Run.clock hd) runs

let max_clock runs =
  List.fold_left
    (fun current_max r ->
      let clock = Run.clock r in
      max clock current_max )
    0. runs

let median_clock runs =
  let n = List.length runs in
  let runs = List.sort compare @@ List.map (fun run -> Run.clock run) runs in
  if n = 0 then 0.
  else if n mod 2 = 0 then
    (List.nth runs (n / 2) +. List.nth runs ((n / 2) + 1)) /. 2.
  else List.nth runs (n / 2)

let sum_clock runs = List.fold_left (fun sum r -> Run.clock r +. sum) 0. runs

let mean_clock runs = sum_clock runs /. (count_all runs |> float_of_int)

let sum_utime runs = List.fold_left (fun sum r -> Run.utime r +. sum) 0. runs

let mean_utime runs = sum_utime runs /. (count_all runs |> float_of_int)

let sum_stime runs = List.fold_left (fun sum r -> Run.stime r +. sum) 0. runs

let mean_stime runs = sum_stime runs /. (count_all runs |> float_of_int)

let to_distribution ~max_time runs =
  List.init max_time (fun i ->
    List.fold_left
      (fun count r ->
        let clock = Run.clock r |> int_of_float in
        if clock = i then count +. 1. else count )
      0. runs )

let pp_quick_results fmt results =
  let nothing = ref 0 in
  let reached = ref 0 in
  let timeout = ref 0 in
  let killed = ref 0 in
  let other = ref 0 in
  List.iter
    (fun result ->
      match result.Run.res with
      | Nothing _ -> incr nothing
      | Reached _ -> incr reached
      | Timeout _ -> incr timeout
      | Signaled _ | Stopped _ -> incr killed
      | Other _ -> incr other )
    results;
  Format.fprintf fmt
    "Nothing: %6i    Reached: %6i    Timeout: %6i    Other: %6i    Killed: %6i"
    !nothing !reached !timeout !other !killed

let pp_table_results fmt results =
  let nothing = count_nothing results in
  let reached = count_reached results in
  let timeout = count_timeout results in
  let other = count_other results in
  let killed = count_killed results in
  let total = count_all results in
  Format.fprintf fmt
    "| Nothing | Reached | Timeout | Other | Killed | Total |@\n\
     |:-------:|:-------:|:-------:|:-----:|:------:|:-----:|@\n\
     | %6i | %6i | %6i | %6i | %6i | %6i |"
    nothing reached timeout other killed total

let pp_table_statistics fmt results =
  let total = sum_clock results in
  let mean = mean_clock results in
  let median = median_clock results in
  let min = min_clock results in
  let max = max_clock results in
  Format.fprintf fmt
    "| Total | Mean | Median | Min | Max |@\n\
     |:-----:|:----:|:------:|:---:|:---:|@\n\
     | %0.2f | %0.2f | %0.2f | %0.2f | %0.2f |@\n"
    total mean median min max

let map = List.map

let files = List.map (fun run -> run.Run.file)
