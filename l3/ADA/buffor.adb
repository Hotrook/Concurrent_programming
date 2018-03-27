



package body Buffor is



    task body Bufor is
        first : Integer := 0;
        size : Integer := 0;
        buf : array( 0..N ) of Tuple;
    begin
        loop
          select
            when size /= 0 =>
              accept Give (TID, LID, priority: out Integer) do
                TID := buf(first).TID;
                LID := buf(first).LID;
                priority := buf(first).priority;
                size := size - 1;
                first := (first + 1) mod N;
              end Give;
          or
            when size /= N =>
              accept Take (TID, LID, priority: in Integer) do
                buf((first+size) mod N).TID := TID;
                buf((first+size) mod N).LID := LID;
                buf((first+size) mod N).priority := priority;
                size := size + 1;
              end Take;
          end select;
        end loop;
    end Bufor;




end Buffor;
