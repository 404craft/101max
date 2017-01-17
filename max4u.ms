--max to unity mass exporter

sel = selection as array
tmp = #()
for s in sel do
(
	n = substring s.name 1 (s.name.count-3)
	print ("tmp_count=" + tmp.count as string)
	if tmp.count == 0 do 
	(
	print ("1-fired")
	arr = #()
	append arr n
	append tmp arr
	)
	for t = tmp.count to 1 by -1 do
	(
		print ("tmp_count=" + tmp.count as string)
		print ("tmp_t1=" + tmp[t][1])
		if t == tmp.count AND tmp[t][1] != n do 
			(
			print ("2-fired")
			arr = #()
			append arr n
			append tmp arr
			)
	)
	for t in tmp do 
		if findItem t n != undefined do appendifunique t s
)
