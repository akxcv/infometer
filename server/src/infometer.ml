let seed = 213453

let percentage info =
  (Hashtbl.seeded_hash seed info) mod 100 + 1
