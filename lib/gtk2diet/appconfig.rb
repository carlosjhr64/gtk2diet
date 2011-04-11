module Gtk2Diet
  FOODS_FILE	= Gtk2AppLib::USERDIR	+ '/foods.txt'
  ROWS_FILE	= Gtk2AppLib::USERDIR	+ '/data_rows.txt'
  WEIGHTS_FILE	= Gtk2AppLib::USERDIR	+ '/weights.txt'
  PARAMETERS_FILE = Gtk2AppLib::USERDIR	+ '/parameters.txt'

  MMA = 7.0 # The modified moving average N
  MAXDIFF = 10.0 # The maximum allowed variation before reinitializing.
  STAGES = 6 # Number of daily meals

  # INITIAL DEFAULT VALUES
  # These should be edited by the user via the GUI
  CRASH_DIET	= 1500.0
  CRASH_DIET_N	= 5.0
  BASE_DIET	= 2000.0
  BUMPUP_DIET	= 3000.0
  BUMPUP_DIET_N	= 1.0
  WEIGHT	= 175.5

  notebook, window, vbox, hbox =
	'Gtk2AppLib::Widgets::Notebook',
	'Gtk2AppLib::Widgets::ScrolledWindow',
	'Gtk2AppLib::Widgets::VBox',
	'Gtk2AppLib::Widgets::HBox'

  COUNTER_LABELS = [
	[ :TimeStamp_Label,	'Time'		],
	[ :Label_Label,		'Label'		],
	[ :Calories_Label,	'Calories'	],
	[ :Fat_Label,		'Fat'		],
	[ :Protein_Label,	'Protein'	],
	[ :VitA_Label,		'Vit. A'	],
	[ :VitC_Label,		'Vit. C'	],
	[ :Calcium_Label,	'Calcium'	],
	[ :Iron_Label,		'Iron'		],
	]
  N = COUNTER_LABELS.length
  N1 = N - 1
  N2 = N - 2

  GUI = [
	[:Notebook,	notebook,
	[:CounterPage_Component, :Targets_Component]],

	# Counter Page
	[:CounterPage,	window,	[:CounterBox_Component]],
	[:CounterBox,	vbox,	[:CounterHeader_Component]],

	[:CounterHeader,hbox,	COUNTER_LABELS.map{|key_value| key_value.first}],

	# Targets Page
	[:Targets,	window,	[:TargetsBox_Component]],
	[:TargetsBox,	vbox,	[:WeightRow_Component,:TargetRow_Component,:ParametersRow_Component]],
	[:WeightRow,	hbox,	[:Weight_SpinButton,:Dot_Label,:Fraction_SpinButton,:Weight_Button,:MmaWeight_Entry,]],
	[:TargetRow,	hbox,	[:TargetCalories_Button,:TargetCalories_Label]],
	[:ParametersRow,hbox,
		[:Target_Label,:Target_Entry,:Crash_Label,
		:Crash_Entry,:CrashN_Entry,:Base_Label,:Base_Entry,:BumpUp_Label,:BumpUp_Entry,:BumpUpN_Entry]],
  	]

  APPEND_APP_MENU = [
	[	:save_data_rows,	'_Save'		],
	[	:restore,		'_Restore'	],
	[	:save_n_clear,		'_Clear'	],
	[	:edit_help,		'_Help'		],	# We're doing an editable help.
  ]
end

module Gtk2AppLib
module Configuration
  Gtk2Diet::FONT = (HILDON)? {:modify_font => FONT[:SMALL]} : {:modify_font => FONT[:NORMAL]}

  # Application Menu
  MENU[:dock]	= '_Dock'	if !HILDON
  MENU[:fs]	= '_Fullscreen'	if  HILDON


  PARAMETERS[:DELETE]			= ['Delete this row?', {:TITLE => 'Delete?'}]
  OPTIONS[:COUNTER_NARROW]		= { :width_request=	=> 75, }
  OPTIONS[:COUNTER_WIDE]		= { :width_request=	=> 125, }
  OPTIONS[:HELP_TEXT_VIEW]		= OPTIONS[:HELP] # same options as :HELP


  # Counter Page Configuration
  Gtk2Diet::COUNTER_LABELS.each{|key,label| PARAMETERS[key] = [label, (key==:Label_Label)? :COUNTER_WIDE : :COUNTER_NARROW]}
  PARAMETERS[:CounterPage_Component]	= ['Counter']
  PARAMETERS[:Counter_Narrow]		= ['',		:COUNTER_NARROW]
  PARAMETERS[:Counter_Wide]		= ['TOTALS:',		:COUNTER_WIDE]
  PARAMETERS[:Counter_SpinButtons]	= [[],		:COUNTER_NARROW, {:set_range  => [0,1000]}]
  PARAMETERS[:Counter_Button]		= ['Add',	:COUNTER_NARROW, 'clicked']
  # Note that PARAMETERS[:Counter_ComboBoxEntries][0] is set to Gtk2Diet.foods in lib/gtk2diet.rb
  PARAMETERS[:Counter_ComboBoxEntries]	= [nil,		:COUNTER_WIDE, 'changed']

  font = Gtk2Diet::FONT
  # Configuration Page Configuration
  PARAMETERS[:Targets_Component]	= ['Targets']
  PARAMETERS[:Weight_SpinButton]	= [[], {:set_range  => [0,999]}]
  PARAMETERS[:Dot_Label]		= ['.']
  PARAMETERS[:Fraction_SpinButton]	= [[], {:set_range  => [0,9]}]
  PARAMETERS[:Weight_Button]		= ["#{Gtk2Diet::MMA.to_i} Modified Moving Average Weight",'clicked']
  PARAMETERS[:MmaWeight_Entry]		= [Gtk2Diet::WEIGHT.to_s,	:COUNTER_NARROW]
  PARAMETERS[:Target_Label]		= ['Target Weight:',	font]
  PARAMETERS[:Target_Entry]		= [Gtk2Diet::WEIGHT.to_s,	:COUNTER_NARROW]
  PARAMETERS[:TargetCalories_Button]	= ['Calculate Target Calories','clicked']
  PARAMETERS[:TargetCalories_Label]	= ['']
  PARAMETERS[:Crash_Label]		= ['Crash:',	font]
  PARAMETERS[:Crash_Entry]		= [Gtk2Diet::CRASH_DIET.to_s,	:COUNTER_NARROW]
  PARAMETERS[:CrashN_Entry]		= [Gtk2Diet::CRASH_DIET_N.to_s,	:COUNTER_NARROW]
  PARAMETERS[:Base_Label]		= ['Base:',	font]
  PARAMETERS[:Base_Entry]		= [Gtk2Diet::BASE_DIET.to_s,	:COUNTER_NARROW]
  PARAMETERS[:BumpUp_Label]		= ['Bump:',	font]
  PARAMETERS[:BumpUp_Entry]		= [Gtk2Diet::BUMPUP_DIET.to_s,	:COUNTER_NARROW]
  PARAMETERS[:BumpUpN_Entry]		= [Gtk2Diet::BUMPUP_DIET_N.to_s,:COUNTER_NARROW]

end
end

