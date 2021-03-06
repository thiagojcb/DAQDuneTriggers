local moo = import "moo.jsonnet";
local cmd = import "sourcecode/appfwk/schema/appfwk-cmd-make.jsonnet";
local TPsGeneratorFromFileMake = import "sourcecode/triggermodules/schema/triggermodules-TriggerPrimitiveFromFile-make.jsonnet";
local TAsGeneratorMake = import "sourcecode/triggermodules/schema/triggermodules-DAQTriggerActivityMaker-make.jsonnet";
local TCsGeneratorMake = import "sourcecode/triggermodules/schema/triggermodules-DAQTriggerCandidateMaker-make.jsonnet";
local TDsGeneratorMake = import "sourcecode/triggermodules/schema/triggermodules-DAQTriggerDecisionMaker-make.jsonnet";

///////////	Queues
local queues = {
	TPsQueue: cmd.qspec("TPsQueue",
		"FollyMPMCQueue",
		1000),
			
	TAsQueue: cmd.qspec("TAsQueue",
		"FollyMPMCQueue",
		100),
		
	TCsQueue: cmd.qspec("TCsQueue",
		"FollyMPMCQueue",
		10),

	TDsQueue: cmd.qspec("TDsQueue",
		"FollyMPMCQueue",
		10),
};

///////////	Modules
local modules = {
	TPsGenerator: cmd.mspec("TPsGenerator",
		"TriggerPrimitiveRadiological",
		[cmd.qinfo("output",
			"TPsQueue",
			cmd.qdir.output)]),

	TPsGenerator2: cmd.mspec("TPsGenerator2",
		"TriggerPrimitiveSupernova",
		[cmd.qinfo("output",
			"TPsQueue",
			cmd.qdir.output)]),

	TPsGenerator3: cmd.mspec("TPsGenerator3",
		"TriggerPrimitiveFromFile",
		[cmd.qinfo("output",
			"TPsQueue",
			cmd.qdir.output)]),

	TAsGenerator: cmd.mspec("TAsGenerator",
		"DAQTriggerActivityMaker",
		[cmd.qinfo("input",
			"TPsQueue",
			cmd.qdir.input),
		cmd.qinfo("output",
			"TAsQueue",
			cmd.qdir.output)]),
	
	TCsGenerator: cmd.mspec("TCsGenerator",
		"DAQTriggerCandidateMaker",
		[cmd.qinfo("input",
			"TAsQueue",
			cmd.qdir.input),
		cmd.qinfo("output",
			"TCsQueue",
			cmd.qdir.output)]),

	TDsGenerator: cmd.mspec("TDsGenerator",
		"DAQTriggerDecisionMaker",
		[cmd.qinfo("input",
			"TCsQueue",
			cmd.qdir.input),
		cmd.qinfo("output",
			"TDsQueue",
			cmd.qdir.output)]),
};


///////////	Conf
[
	cmd.init([queues.TPsQueue,queues.TAsQueue,queues.TCsQueue,queues.TDsQueue],
		[modules.TPsGenerator3, modules.TAsGenerator, modules.TCsGenerator,modules.TDsGenerator])
		{ waitms: 1000},
	cmd.conf(
		[cmd.mcmd("TPsGenerator3",TPsGeneratorFromFileMake.conf("/tmp/test2.csv")),
		cmd.mcmd("TAsGenerator",TAsGeneratorMake.conf(250,2)),
		cmd.mcmd("TCsGenerator",TCsGeneratorMake.conf(500000000,1,1)),
		cmd.mcmd("TDsGenerator",TDsGeneratorMake.conf(500000000,1,1))])
		{ waitms: 1000},
	cmd.start(40){ waitms: 1000},
	cmd.stop(){ waitms: 1000},
]
