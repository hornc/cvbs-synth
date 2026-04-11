(
var server = Server(\nrt,
	options: ServerOptions.new
	.numOutputBusChannels_(1)
	.numInputBusChannels_(1)
);

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
		\freq, [440, 1603],
		\brightness, [1, 0.8, 0.5],
		\dur, Pseq([2], 1),
	),
]).asScore(625 * 0.064 * 80, timeOffset: 0.001);  // 625 PAL lines * 64 micro (audio milli) s * number of frames to output

Object.namesCVBS.do { |name|
	x.add([0.0, [\d_recv, SynthDescLib.global.at(name).def.asBytes]]);
};

x.sort;

x.recordNRT(
	outputFilePath: "output.flac",
	sampleRate: 28636,
	headerFormat: "FLAC",
	sampleFormat: "int8",
	options: ServerOptions.new.numOutputBusChannels_(1),
	duration: x.endTime,
	action: {
		"CVBS-synth NRT render finished successfully.".postln;
		0.exit;
	}
);
)
