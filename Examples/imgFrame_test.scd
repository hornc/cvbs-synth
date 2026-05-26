(
var server = Server(\nrt,
	options: ServerOptions.new
	.numOutputBusChannels_(1)
	.numInputBusChannels_(1)
);

var amps = [1.0, 0.2, 0.5, 0.1];
var durs = [0.25, 0.25, 0.25, 0.25];

var totalDuration = 625 * 0.064 * 20;  // 625 PAL lines * 64 micro (audio milli) s * number of frames to output

// Add CVBS SynthDefs
Object.defineCVBS;

x = Ppar([
	Pbind(
		\instrument, "linePAL",
		\color, 0,
		\dur, Pseq([2], 1),
	),
	Pbind(
		\instrument, "imgFrame",
		\levelBuf, 0,
		\durationBuf, 1,
		\brightness, 1,
		\dur, Pseq([2], 1),
	),
]).asScore(totalDuration, timeOffset: 0.002);

Object.namesCVBS.do { |name|
	x.add([0.0, [\d_recv, SynthDescLib.global.at(name).def.asBytes]]);
};

// Add Buffers 0,1 (amps,durs) to the score
x.add([0.0, [\b_alloc, 0, amps.size, 1]]);
x.add([0.0, [\b_setn, 0, 0, amps.size] ++ amps]);
x.add([0.0, [\b_alloc, 1, durs.size, 1]]);
x.add([0.0, [\b_setn, 1, 0, durs.size] ++ durs]);

x.sort;

x.recordNRT(
	outputFilePath: "output.flac",
	sampleRate: 28636,
	headerFormat: "FLAC",
	sampleFormat: "int8",
	options: server.options,
	duration: totalDuration,
	action: {
		"CVBS-synth NRT render finished successfully.".postln;
		0.exit;
	}
);
)
