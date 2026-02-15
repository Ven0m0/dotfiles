#!/bin/bash
export LC_ALL=C

# create dummy files
touch test.txt
echo '{"a":1}' > test.json
dd if=/dev/urandom of=test.bin bs=1024 count=1 2>/dev/null

count=100

echo "Benchmarking 'file --mime-type -b' ($count iterations)..."
start=$(date +%s%N)
for ((i=0; i<count; i++)); do
  file --mime-type -b test.txt >/dev/null
done
end=$(date +%s%N)
echo "file: $(( (end - start) / 1000000 )) ms total"

echo "Benchmarking '[[ -d ]]' + extension check ($count iterations)..."
start=$(date +%s%N)
for ((i=0; i<count; i++)); do
  if [[ -d test.txt ]]; then :;
  elif [[ test.txt == *.json ]]; then :;
  else :; fi
done
end=$(date +%s%N)
echo "bash checks: $(( (end - start) / 1000000 )) ms total"

echo "Benchmarking 'grep -qI .' (binary check) ($count iterations)..."
start=$(date +%s%N)
for ((i=0; i<count; i++)); do
  grep -qI . test.bin 2>/dev/null
done
end=$(date +%s%N)
echo "grep: $(( (end - start) / 1000000 )) ms total"

rm test.txt test.json test.bin
