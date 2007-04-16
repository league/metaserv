Sys.set_signal Sys.sigpipe Sys.Signal_ignore;;
Sys.catch_break true;;
Printf.printf "Ready...\n%!";
Server.start [CodeHandler.runc HofMap.map;
              FileHandler.root "."];;
