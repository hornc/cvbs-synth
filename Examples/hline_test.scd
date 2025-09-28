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
		\color, 0,
		\dur, Pseq([2], 1),
	),
	Pbind(
		\instrument, "vBar",
		\x, [0.0, 0.9, 0.115],
		\brightness, [1, 0.8, 0.5],
		\width, [0.1, 0.1, 0.025],
		\dur, Pseq([2], 1),
	),
	Pbind(
		\instrument, "hBar",
		\y, [0.0, 0.9],
		\brightness, [1, 0.5],
		\height, 0.1,
		\dur, Pseq([2], 1),
	),
	// HELLO WORLD! .. horizontals only
	Pbind(
		\instrument, "hLine",
		\x, [100, 125, 125, 125, 150, 175, 207, 207, 250, 282, 282, 300, 325, 352, 352],
		\y, [190, 200, 190, 180, 200, 200, 200, 180, 200, 200, 180, 184, 200, 200, 180],  // max: 576, only even rows
		\length, [20, 20, 15, 20, 20, 20, 10, 10, 20, 10, 10, 18, 20, 10, 10],
		\dur, Pseq([2], 1)
	),
	Pbind(
		\instrument, "hLine",
		\x, 100,
		\y, [220, 240, 260, 280, 300],
		\length, [50, 100, 200, 400, 470],
		\dur, Pseq([2], 1)
	),
	// lines of length = 100, across the screen
	Pbind(
		\instrument, "hLine",
		\x, [0, 100, 200, 300, 400, 500, 600],
		\y, [350, 354, 358, 362, 366, 370, 374],
		\length, 100,
		\dur, Pseq([2], 1)
	),
	// y diff 1:
	Pbind(
		\instrument, "hLine",
		\x, 300,
		\y, [420, 421, 422, 423, 424],
		\length, 100,
		\dur, Pseq([2], 1)
	),
	// y diff 2:
	Pbind(
		\instrument, "hLine",
		\x, 400,
		\y, [420, 422, 424, 426, 428],
		\length, 100,
		\dur, Pseq([2], 1)
	),
	// y diff 4:
	Pbind(
		\instrument, "hLine",
		\x, 500,
		\y, [420, 424, 428, 432, 436],
		\length, 100,
		\dur, Pseq([2], 1)
	),
]).asScore(625 * 0.064 * 80, timeOffset: 0.001);  // 625 PAL lines * 64 micro (audio milli) s * number of frames to output
					          // TODO: first frame is dropped?? FIX

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
