(
var server = Server(\nrt,
	options: ServerOptions.new
	.numOutputBusChannels_(1)
	.numInputBusChannels_(1)
),
picture = SynthDef("maskedPicture", {
	Out.ar(0,
		SinOsc.ar(freq: 124.005, phase: 0.0, mul: 0.32, add: 0.25) +
		WhiteNoise.kr(mul: 0.4, add: 0.0) +
		(SinOsc.ar(freq: (283.75 * 15625 + 25) / 1000, phase: -0.25, mul:
		0.5,  // color signal
		add: 0.0) *
		SinOsc.ar(freq: 16, mul: 1)) +   // modulate color amplitude
		(SinOsc.ar(freq: (283.75 * 15625 + 25) / 1000, phase: 0.25, mul:
		0.5,  // color signal
		add: 0.0) *
		SinOsc.ar(freq: 10, mul: 1)) *   // modulate color amplitude
		// LFPulse.kr(freq: 1/60, width: 0.076, iphase: 0.4) +  // static bar
		// LFPulse.kr(freq: 1/61, width: 0.076, mul: 0.7) *     // moving bar
		Object.maskpicture.value *
		LFPulse.kr(freq: 1/2, width: SinOsc.ar(freq: 111, mul: 0.7), iphase: 0.27)
	)
});

// Add CVBS SynthDefs
Object.defineCVBS;
// Add the 'picture' SynthDef defined above
picture.add;

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

// Add the CVBS Extension SynthDefs asBytes to the Score
Object.namesCVBS.do { |name|
	x.add([0.0, [\d_recv, SynthDescLib.global.at(name).def.asBytes]]);
};
// Add our one custom SynthDef asBytes
x.add([0.0, [\d_recv, picture.asBytes]]);

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
0.exit;
)
