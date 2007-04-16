module Gc = struct
let lift x = .<x>.
 open Gc let page  = .<fun req puts ->
let arg = Request.arg req in
puts "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\"\n    \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">\n<html xmlns=\"http://www.w3.org/1999/xhtml\">\n  <head>\n    <title>GC statistics</title>\n    <link href=\"/meta.css\" rel=\"stylesheet\" type=\"text/css\" />\n  </head>\n<body>\n<h1>GC statistics</h1>\n";
let st = stat()  in 
puts "<p>\nCurrent time is ";
puts (TimeStamp.now());
puts "<br/>\nServer up since ";
puts (.~(lift(TimeStamp.now())));
puts "<br/>\n";
puts (.~(lift(let i = Unix.open_process_in "uname -a" in
         let uname = input_line i in
         Printf.printf "UNAME\n%!";
         let _ = Unix.close_process_in i in
         uname)));
puts "<pre>\nminor_words <b>";
Printf.kprintf puts "%.0f" ( st.minor_words ) ;
puts "</b> \n(* Number of words allocated in the minor heap since\n   the program was started.  This number is accurate in\n   byte-code programs, but only an approximation in programs\n   compiled to native code. *)\n\npromoted_words <b>";
Printf.kprintf puts "%.0f" ( st.promoted_words ) ;
puts "</b>\n(* Number of words allocated in the minor heap that\n   survived a minor collection and were moved to the major heap\n   since the program was started. *)\n\nmajor_words <b>";
Printf.kprintf puts "%.0f" ( st.major_words ) ;
puts "</b>\n(* Number of words allocated in the major heap, including\n   the promoted words, since the program was started. *)\n\nminor_collections <b>";
Printf.kprintf puts "%d" ( st.minor_collections ) ;
puts "</b>\n(* Number of minor collections since the program was started. *)\n\nmajor_collections <b>";
Printf.kprintf puts "%d" ( st.major_collections ) ;
puts "</b>\n(* Number of major collection cycles completed since the program\n    was started. *)\n\nheap_words <b>";
Printf.kprintf puts "%d" ( st.heap_words ) ;
puts "</b>\n(* Total size of the major heap, in words. *)\n\nheap_chunks <b>";
Printf.kprintf puts "%d" ( st.heap_chunks ) ;
puts "</b>\n(* Number of contiguous pieces of memory that make up the major heap. *)\n\nlive_words <b>";
Printf.kprintf puts "%d" ( st.live_words ) ;
puts "</b>\n(* Number of words of live data in the major heap, including the header\n   words. *)\n\nlive_blocks <b>";
Printf.kprintf puts "%d" ( st.live_blocks ) ;
puts "</b>\n(* Number of live blocks in the major heap. *)\n\nfree_words <b>";
Printf.kprintf puts "%d" ( st.free_words ) ;
puts "</b>\n(* Number of words in the free list. *)\n\nfree_blocks <b>";
Printf.kprintf puts "%d" ( st.free_blocks ) ;
puts "</b>\n(* Number of blocks in the free list. *)\n\nlargest_free <b>";
Printf.kprintf puts "%d" ( st.largest_free ) ;
puts "</b>\n(* Size (in words) of the largest block in the free list. *)\n\nfragments <b>";
Printf.kprintf puts "%d" ( st.fragments ) ;
puts "</b>\n(* Number of wasted words due to fragmentation.  These are\n   1-words free blocks placed between two live blocks.  They\n   are not available for allocation. *)\n\ncompactions <b>";
Printf.kprintf puts "%d" ( st.compactions ) ;
puts "</b>\n(* Number of heap compactions since the program was started. *)\n\ntop_heap_words <b>";
Printf.kprintf puts "%d" ( st.top_heap_words ) ;
puts "</b>\n(* Maximum size reached by the major heap, in words. *)\n</pre></p>\n<hr/>\nMetaOCaml ";
puts (Sys.ocaml_version);
puts "</body>\n</html>\n";

>.
end
