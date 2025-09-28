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
		\instrument, "vBar",
		\x, [0.0, 0.9],
		\brightness, [1, 0.8],
		\width, 0.1,
		\dur, Pseq([2], 1),
	),
	Pbind(
		\instrument, "hBar",
		\y, [0.0, 0.9],
		\brightness, [1, 0.5],
		\height, 0.1,
		\dur, Pseq([2], 1),
	),
	// HELLO WORLD!
	Pbind(
		\instrument, "hLine",
		\x, [100, 125, 125, 125, 150, 175, 205, 205, 250, 280, 280, 300, 325, 352, 352],
		\y, [190, 200, 190, 180, 200, 200, 200, 180, 200, 200, 180, 184, 200, 200, 180],  // max: 576, only even rows
		\length, [20, 20, 15, 20, 20, 20, 10, 10, 20, 10, 10, 18, 20, 10, 10],
		\dur, Pseq([2], 1)
	),
	Pbind(
		\instrument, "Box",
		\x, [0.1389, 0.1667, 0.1736, 0.2083, 0.2431, 0.2778, 0.3056, 0.3472, 0.3611, 0.3750, 0.3819, 0.4097, 0.4167, 0.4514, 0.4861, 0.5139, 0.5347, 0.5347],
		\y, [0.3177, 0.3177, 0.3177, 0.3177, 0.3177, 0.3212, 0.3212, 0.3177, 0.3351, 0.3177, 0.3212, 0.3212, 0.3177, 0.3177, 0.3212, 0.3264, 0.3177, 0.3490],
		\brightness, 1,
		\width, [0.0028, 0.0028, 0.0028, 0.0028, 0.0028, 0.0028, 0.0028, 0.0028, 0.0028, 0.0028, 0.0028, 0.0028, 0.0028, 0.0028, 0.0028, 0.0028, 0.0028, 0.0028],
		\height, [0.0347, 0.0347, 0.0347, 0.0347, 0.0347, 0.0260, 0.0260, 0.0347, 0.0174, 0.0347, 0.0260, 0.0260, 0.0347, 0.0347, 0.0260, 0.0174, 0.0260, 0.0035],
		\dur, Pseq([2], 1)
	)
]).asScore(625 * 0.064 * 40, timeOffset: 0.001);

// Add the CVBS Extension SynthDefs asBytes to the Score
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
	duration: x.endTime
);

server.remove;
0.exit;
)
