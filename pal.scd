(
var server = Server(\nrt,
	options: ServerOptions.new
	.numOutputBusChannels_(2)
	.numInputBusChannels_(2)
),
h = 0.2,
center = -0.250,
v = -0.00135,
def = SynthDef("linePAL", {
	Out.ar(0, LFPulse.ar(freq: 15.625, width: 47/640, 
	mul: LFPulse.kr(freq: 1/20, width: 0.976, iphase: -0.001, mul: -1 * h),
	add: Mix( [ LFPulse.ar(freq: 125/4, width: 1-0.140625, iphase: 0.15, mul:
LFPulse.ar(freq: 1/20, width: 0.992, mul: h, add: -1 * h, iphase: 0.008 + v) , add:
0.0), LFPulse.ar(freq: 125/4, width: [0.078125], iphase: 0.151, mul: Mix(LFPulse.ar(freq: 1/20,
width: 0.992, mul: h, add: -1 * h, iphase:[0.0 + v, 0.016 + v])), add: center)]),
	))
});


def.add;  // add def to SynthDescLib


x = Pbind(
	\instrument, "linePAL",
	\dur, Pseq([2], 1),
).asScore(625 * 0.064 * 6, timeOffset: 0.001);


x.add([0.0, [\d_recv, def.asBytes]]);
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
