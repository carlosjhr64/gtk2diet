module Gtk2Diet # Gtk2Diet defined
  # Gtk2AppLib defined
  # HILDON defined
  # Gtk defined
  # MENU defined
  # PARAMETERS defined
  # OPTIONS defined
  # File defined
  # Time defined
  # IO defined

  FOODS_FILE	= Gtk2AppLib::USERDIR	+ '/foods.txt'
  ROWS_FILE	= Gtk2AppLib::USERDIR	+ '/data_rows.txt'
  WEIGHTS_FILE	= Gtk2AppLib::USERDIR	+ '/weights.txt'
  PARAMETERS_FILE = Gtk2AppLib::USERDIR	+ '/parameters.txt'

  MMA = 7.0 # The modified moving average N
  STAGES = 6 # Number of daily meals

  DATE_STAMP = '%Y-%m-%d %H:%M:%S'
  TIME_STAMP = '%H:%M:%S'

  CALORIES = "\tCleared Calories: "

  # INITIAL DEFAULT VALUES
  # These should be edited by the user via the GUI
  CRASH_DIET	= 1500.0
  CRASH_DIET_N	= 5.0
  BASE_DIET	= 2000.0
  BUMPUP_DIET	= 3000.0
  BUMPUP_DIET_N	= 1.0
  WEIGHT	= 175.5

  WEIGHTS_DEFAULT = <<EOT
# Enter your daily weights, line by line.
# Use "#" for comment lines.
EOT

  notebook, window, vbox, hbox =
	'Gtk2AppLib::Widgets::Notebook',
	'Gtk2AppLib::Widgets::ScrolledWindow',
	'Gtk2AppLib::Widgets::VBox',
	'Gtk2AppLib::Widgets::HBox'

  if Gtk2AppLib::HILDON then
    # On the hand held...
    COUNTER_LABELS = [
	[ :TimeStamp_Label,	'Time'		],
	[ :Label_Label,		'Label'		],
	[ :Calories_Label,	'Calories'	],
	[ :Protein_Label,	'Protein'	],
	]
  else
    # On the desktop...
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
  end
  N = COUNTER_LABELS.length
  N1 = N - 1
  N2 = N - 2

  # Notebook defined here
  GUI = [
	[:Notebook,	notebook,
	[:CounterPage_Component, :Targets_Component]],

	# Counter Page
	[:CounterPage,	window,	[:CounterBox_Component]],
	[:CounterBox,	vbox,	[:CounterHeader_Component]],

	[:CounterHeader,hbox,	COUNTER_LABELS.map{|key_value| key_value.first}],

	# Targets Page
	[:Targets,	window,	[:TargetsBox_Component]],
	[:TargetsBox,	vbox,
		[:WeightRow_Component,:MmaRow_Component,:TargetRow_Component,:ParametersRow1_Component,:ParametersRow2_Component,:ParametersRow3_Component,:ParametersRow4_Component]],
	[:WeightRow,	hbox,	[:Weight_SpinButton,:Dot_Label,:Fraction_SpinButton,:Weight_Button,]],
        [:MmaRow,	hbox,	[:MmaIs_Label,:MmaWeight_Label,]],
	[:TargetRow,	hbox,	[:TargetCalories_Button,:TargetCalories_Label]],
	[:ParametersRow1,hbox, [:Target_Label,:Target_Entry]],
	[:ParametersRow2,hbox, [:Crash_Label,:Crash_Entry,:CrashN_Entry]],
	[:ParametersRow3,hbox, [:Base_Label,:Base_Entry]],
	[:ParametersRow4,hbox, [:BumpUp_Label,:BumpUp_Entry,:BumpUpN_Entry]],
  	]

  APPEND_APP_MENU = [
	[	:edit_help,		'_Help'		],	# We're doing an editable help.
	[	:edit_weights,		'_Weights'	],
	[	:save_data_rows,	'_Save'		],
	[	:restore,		'_Restore'	],
	[	:save_n_clear,		'_Clear'	],
  ]
end

module Gtk2AppLib
module Configuration
  # Application Menu
  MENU[:dock]	= '_Dock'	if !HILDON
  MENU[:fs]	= '_Fullscreen'	if  HILDON

  PARAMETERS[:DELETE]			= ['Delete this row?', {:TITLE => 'Delete?'}]
  OPTIONS[:COUNTER_NARROW]		= { :width_request=	=> (HILDON)? 125 : 75, }
  OPTIONS[:COUNTER_WIDE]		= { :width_request=	=> (HILDON)? 200 : 125, }
  OPTIONS[:HELP_TEXT_VIEW]		= OPTIONS[:HELP] # same options as :HELP
  OPTIONS[:WEIGHTS_TEXT_VIEW]		= Gtk2AppLib::KeyValues.new({:TITLE => 'Weights'},OPTIONS[:HELP])

  # Counter Page Configuration
  Gtk2Diet::COUNTER_LABELS.each{|key,label| PARAMETERS[key] = [label, (key==:Label_Label)? :COUNTER_WIDE : :COUNTER_NARROW]}
  PARAMETERS[:CounterPage_Component]	= ['Counter']
  PARAMETERS[:Counter_Narrow]		= ['',		:COUNTER_NARROW]
  PARAMETERS[:Counter_Wide]		= ['TOTALS:',		:COUNTER_WIDE]
  PARAMETERS[:Counter_SpinButtons]	= [[],		:COUNTER_NARROW, {:set_range  => [0,1000]}]
  PARAMETERS[:Counter_Button]		= ['Add',	:COUNTER_NARROW, 'clicked']
  # Note that PARAMETERS[:Counter_ComboBoxEntries][0] is set to Gtk2Diet.foods in lib/gtk2diet.rb
  PARAMETERS[:Counter_ComboBoxEntries]	= [nil,		:COUNTER_WIDE, 'changed']

  # Some of these value setting are redundant (overwritten later),
  # but I use them here just to start things with a reasonable value.
  weight = Gtk2Diet::WEIGHT
  weight_s = weight.to_s
  weight_i = weight.to_i
  fraction = (0.5 + 10.0*(weight - weight_i)).to_i

  # Configuration Page Configuration
  PARAMETERS[:Targets_Component]	= ['Targets']
  PARAMETERS[:Weight_SpinButton]	= [[], {:set_range  => [0,999], :value= => weight_i}]	# value here is overwritten later
  PARAMETERS[:Dot_Label]		= ['.']
  PARAMETERS[:Fraction_SpinButton]	= [[], {:set_range  => [0,9], :value= => fraction}]	# value here is overwritten later
  PARAMETERS[:Weight_Button]		= ['Append Daily Weight','clicked']
  PARAMETERS[:MmaIs_Label]		= ['Modified Moving Average:']
  PARAMETERS[:MmaWeight_Label]		= [weight_s,	:COUNTER_NARROW]	# text label is overwritten later
  PARAMETERS[:Target_Label]		= ['Target Weight:',	:COUNTER_WIDE]
  PARAMETERS[:Target_Entry]		= [weight_s,	:COUNTER_NARROW]
  PARAMETERS[:TargetCalories_Button]	= ['Calculate Target Calories','clicked']
  PARAMETERS[:TargetCalories_Label]	= ['']
  PARAMETERS[:Crash_Label]		= ['Crash:',	:COUNTER_WIDE]
  PARAMETERS[:Crash_Entry]		= [Gtk2Diet::CRASH_DIET.to_s,	:COUNTER_NARROW]
  PARAMETERS[:CrashN_Entry]		= [Gtk2Diet::CRASH_DIET_N.to_s,	:COUNTER_NARROW]
  PARAMETERS[:Base_Label]		= ['Base:',	:COUNTER_WIDE]
  PARAMETERS[:Base_Entry]		= [Gtk2Diet::BASE_DIET.to_s,	:COUNTER_NARROW]
  PARAMETERS[:BumpUp_Label]		= ['Bump:',	:COUNTER_WIDE]
  PARAMETERS[:BumpUp_Entry]		= [Gtk2Diet::BUMPUP_DIET.to_s,	:COUNTER_NARROW]
  PARAMETERS[:BumpUpN_Entry]		= [Gtk2Diet::BUMPUP_DIET_N.to_s,:COUNTER_NARROW]

end
end

