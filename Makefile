test:
	mkdir -p target
	iverilog -o target/test mul.v test.v
	vvp target/test

synth:
	mkdir -p target
	yosys synth.ys

test-synth: synth
	iverilog -o target/test_synth target/synth.v test.v
	vvp target/test_synth

clean:
	rm -rf target
