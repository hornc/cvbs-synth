(
var server = Server(\nrt,
	options: ServerOptions.new
	.numOutputBusChannels_(2)
	.numInputBusChannels_(2)
);

// Add CVBS SynthDefs
Object.defineCVBS;

x = Ppar([
	Pbind(
		\instrument, "linePAL",
		\color, 1,
		\dur, Pseq([2], 1),
	),
	Pbind(
		\instrument, "maskedPicture",
		\dur, Pseq([2], 1),
	),
	Pbind(
		\instrument, "vBar",
		\x, [0.0, 0.2, 0.5, 0.7, 0.9],
		\brightness, [1, 0.5, 0.25, 0.6, 0.8],
		\width, 0.1,
		\dur, Pseq([2], 1),
	),
/*
	Pbind(
		\instrument, "hBar",
		\y, [0.0, 0.3, 0.5, 0.9],
		\brightness, [1, 0.5],
		\height, 0.1,
		\dur, Pseq([2], 1),
	),
*/
	Pbind(
		\instrument, "hLine",
		\x, [0, 720 / 2, 1, 0, 10],
		\y, [0, 0, 4, 8, 10],  // max: 576, only even rows
		\length, [10, 50, 10, 10, 10],
		\dur, Pseq([2], 1),
	),
	Pbind(
		\instrument, "Box",
		\x, [0.35, 0.35, 0.35, 0.4],
		\y, [0, 0.5, 0.9, 0.2],
		\brightness, [1, 0.5],
		\width, [0.1, 0.1, 0.1, 0.35],
		\height, [0.1, 0.35, 0.1, 0.1],
		\dur, Pseq([2], 1),
	),
]).asScore(625 * 0.064 * 120, timeOffset: 0.001);

Object.namesCVBS.do { |name|
   x.add([0.0, [\d_recv, SynthDescLib.global.at(name).def.asBytes]]);
};

x.sort;

x.recordNRT(
	outputFilePath: "pal01.flac",
	sampleRate: 28636,
	headerFormat: "FLAC",
	sampleFormat: "int8",
	options: ServerOptions.new.numOutputBusChannels_(1),
	duration: x.endTime
);

server.remove;
"Script finished, quitting...".postln;
0.exit;
)
