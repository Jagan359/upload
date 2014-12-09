def chunker f_in
  n=20, m=0
  File.open(f_in,"r") do |fh_in|
    until fh_in.eof?
      x=IO.binread("f_in", n, m)
      IO.binwrite("a_op",x)
      n=n+20
      m=m+20
    end
  end
end


chunker "abc.txt"
