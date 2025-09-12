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
pal = SynthDef("linePAL", { arg color = 0;
	var burst = Select.ar(color, [ DC.ar(center),
		LFPulse.ar(freq: 15.625, width: 15625 / (283.75 * 15625 + 25) *
10, iphase: -0.09, mul: SinOsc.ar(freq: (283.75 * 15625 + 25) / 1000, phase: 0.0, mul: 0.1,
add: 0.0), add: center )
	]);
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
		SinOsc.ar(freq: 10, mul: 1)) +   // modulate color amplitude
		LFPulse.kr(freq: 1/60, width: 0.076, iphase: 0.4) +  // static bar
		LFPulse.kr(freq: 1/61, width: 0.076, mul: 0.2) *     // moving bar
		maskpicture.value
	)
});

// add defs to SynthDescLib
pal.add;
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
]).asScore(625 * 0.064 * 20, timeOffset: 0.001);


x.add([0.0, [\d_recv, pal.asBytes]]);
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
"Script finished, quitting...".postln;
0.exit;
)
