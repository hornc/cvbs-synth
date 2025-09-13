(
var server = Server(\nrt,
	options: ServerOptions.new
	.numOutputBusChannels_(2)
	.numInputBusChannels_(2)
),
h = 0.2,
center = -0.250,
v = -0.00135,
maskpicture = {
	LFPulse.ar(freq: 15.625, width: 1-(120/640), iphase: 1-(120/640) + 0.04,
              mul: LFPulse.kr(freq: 1/20,
              width: 0.976 - 0.004 - 0.008, iphase: -0.003 - 0.006,
              mul: 0.32))
},
vbar = SynthDef("vBar", {arg brightness = 1, width = 0.1, x = 0.0;
	var scale = 0.8;
	Out.ar(0, LFPulse.ar(freq: 125/8, width: width * scale, iphase: -1 * scale * x - 0.161, mul: brightness) * maskpicture.value)
}),
hbar = SynthDef("hBar", {arg brightness = 1, height = 0.1, y = 0.0;
	var scale = 0.9145;
	Out.ar(0, LFPulse.ar(freq: 1/20, width: height * scale, iphase: -1 *
scale * y - 0.055, mul: brightness) * maskpicture.value)
}),
//  x : 0 to 720, y : 0 to 567 (PAL)
hline = SynthDef("hLine", {arg brightness = 1, length = 1, x = 0, y = 0;
	var scale = 0.74;
	Out.ar(0, LFPulse.ar(freq: 1/40, width: length / (576 * 720) * scale, iphase: -1 *
 (x / 576 / 720 * scale) - (y / 576 / 2) * 0.9218 - 0.02906, mul: brightness) * maskpicture.value)
}),
pal = SynthDef("linePAL", { arg color = 0;
	var burst = LFPulse.ar(freq: 15.625, width: 15625 / (283.75 * 15625 + 25) *
10, iphase: -0.09, mul: SinOsc.ar(freq: (283.75 * 15625 + 25) / 1000, phase: 0.0, mul: 0.1,
add: 0.0)) * color + center;
	Out.ar(0, LFPulse.ar(freq: 15.625, width: 47/640, 
	mul: LFPulse.kr(freq: 1/20, width: 0.976, iphase: -0.001, mul: -1 * h),
	add: Mix( [ LFPulse.ar(freq: 125/4, width: 1-0.140625, iphase: 0.15, mul:
LFPulse.ar(freq: 1/20, width: 0.992, mul: h, add: -1 * h, iphase: 0.008 + v) , add:
0.0), LFPulse.ar(freq: 125/4, width: [0.078125], iphase: 0.151, mul: Mix(LFPulse.ar(freq: 1/20,
width: 0.992, mul: h, add: -1 * h, iphase:[0.0 + v, 0.016 + v])),
	 add: burst)]),
	))
}),
picture = SynthDef("maskedPicture", {
	Out.ar(0,
		SinOsc.ar(freq: 124.005, phase: 0.0, mul: 0.32, add: 0.25) +
		// WhiteNoise.kr(mul: 0.2, add: 0.0) +
		(SinOsc.ar(freq: (283.75 * 15625 + 25) / 1000, phase: -0.25, mul:
0.5,  // color signal
add: 0.0) *
		SinOsc.ar(freq: 16, mul: 1)) +   // modulate color amplitude
		(SinOsc.ar(freq: (283.75 * 15625 + 25) / 1000, phase: 0.25, mul:
0.5,  // color signal
add: 0.0) *
		SinOsc.ar(freq: 10, mul: 1)) *   // modulate color amplitude
		//LFPulse.kr(freq: 1/60, width: 0.076, iphase: 0.4) +  // static bar
		//LFPulse.kr(freq: 1/61, width: 0.076, mul: 0.2) *     // moving bar
		maskpicture.value
	)
});

// add defs to SynthDescLib
pal.add;
picture.add;
hbar.add;
hline.add;
vbar.add;

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
]).asScore(625 * 0.064 * 20, timeOffset: 0.001);


x.add([0.0, [\d_recv, pal.asBytes]]);
x.add([0.0, [\d_recv, picture.asBytes]]);
x.add([0.0, [\d_recv, hbar.asBytes]]);
x.add([0.0, [\d_recv, hline.asBytes]]);
x.add([0.0, [\d_recv, vbar.asBytes]]);

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
