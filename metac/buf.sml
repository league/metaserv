structure Buf = struct
  datatype buf
    = S of string
    | L of buf list

  fun output bufs stream =
      let fun walk (S str) = TextIO.output(stream, str)
            | walk (L bs) = List.app walk bs
       in walk(L bufs)
      end

  fun toString bufs =
      let fun walk (S str) = str
            | walk (L bs) = String.concat(List.map walk bs)
       in String.toString(walk(L bufs))
      end
end
