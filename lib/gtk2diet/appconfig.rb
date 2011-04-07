module Gtk2Diet
  FOODS_FILE	= Gtk2AppLib::USERDIR	+ '/foods.txt'
  ROWS_FILE	= Gtk2AppLib::USERDIR	+ '/data_rows.txt'
  WEIGHTS_FILE	= Gtk2AppLib::USERDIR	+ '/weights.txt'
  PARAMETERS_FILE = Gtk2AppLib::USERDIR	+ '/parameters.txt'

  MMA = 7.0 # The modified moving average N
  MAXDIFF = 10.0 # The maximum allowed variation before reinitializing.

  # INITIAL DEFAULT VALUES
  # These should be edited by the user via the GUI
  CRASH_DIET	= 1500.0
  CRASH_DIET_N	= 5.0
  BASE_DIET	= 2000.0
  BUMPUP_DIET	= 3000.0
  BUMPUP_DIET_N	= 1.0
  WEIGHT	= 175.2
end

module Gtk2AppLib
module Configuration
  Gtk2Diet::FONT = (HILDON)? {:modify_font => FONT[:SMALL]} : {:modify_font => FONT[:NORMAL]}

  # Application Menu
  MENU[:help]	= '_Help'
  MENU[:dock]	= '_Dock'	if !HILDON
  MENU[:fs]	= '_Fullscreen'	if  HILDON


  PARAMETERS[:DELETE]			= ['Delete this row?', {:TITLE => 'Delete?'}]
  OPTIONS[:COUNTER_LABELS]		= { :width_request=	=> 90, }


  # Counter Page Configuration
  PARAMETERS[:CounterPage_Component]	= ['Counter']
  PARAMETERS[:Label_Label]		= ['Label',	:COUNTER_LABELS]
  PARAMETERS[:Calorie_Label]		= ['Calories',	:COUNTER_LABELS]
  PARAMETERS[:Protein_Label]		= ['Protein',	:COUNTER_LABELS]
  PARAMETERS[:VitA_Label]		= ['Vit. A',	:COUNTER_LABELS]
  PARAMETERS[:VitC_Label]		= ['Vit. C',	:COUNTER_LABELS]
  PARAMETERS[:Calcium_Label]		= ['Calcium',	:COUNTER_LABELS]
  PARAMETERS[:Iron_Label]		= ['Iron',	:COUNTER_LABELS]
  PARAMETERS[:TimeStamp_Label]		= ['Time',	:COUNTER_LABELS]
  PARAMETERS[:Counter_Labels]		= ['',		:COUNTER_LABELS]
  PARAMETERS[:Counter_SpinButtons]	= [[],		:COUNTER_LABELS, {:set_range  => [0,1000]}]
  PARAMETERS[:Counter_Button]		= ['Add',	:COUNTER_LABELS, 'clicked']
  # Note that PARAMETERS[:Counter_ComboBoxEntries][0] is set to Gtk2Diet.foods in lib/gtk2diet.rb
  PARAMETERS[:Counter_ComboBoxEntries]	= [nil,		:COUNTER_LABELS, 'changed']

  font = Gtk2Diet::FONT
  # Configuration Page Configuration
  PARAMETERS[:Targets_Component]	= ['Targets']
  PARAMETERS[:Weight_SpinButton]	= [[], {:set_range  => [0,999]}]
  PARAMETERS[:Dot_Label]		= ['.']
  PARAMETERS[:Fraction_SpinButton]	= [[], {:set_range  => [0,9]}]
  PARAMETERS[:Weight_Button]		= ["#{Gtk2Diet::MMA.to_i} Modified Moving Average Weight",'clicked']
  PARAMETERS[:MmaWeight_Entry]		= [Gtk2Diet::WEIGHT.to_s,	:COUNTER_LABELS]
  PARAMETERS[:Target_Label]		= ['Target Weight:',	font]
  PARAMETERS[:Target_Entry]		= [Gtk2Diet::WEIGHT.to_s,	:COUNTER_LABELS]
  PARAMETERS[:Calories_Button]		= ['Calculate Target Calories','clicked']
  PARAMETERS[:Calories_Label]		= ['',	:COUNTER_LABELS]
  PARAMETERS[:Crash_Label]		= ['Crash:',	font]
  PARAMETERS[:Crash_Entry]		= [Gtk2Diet::CRASH_DIET.to_s,	:COUNTER_LABELS]
  PARAMETERS[:CrashN_Entry]		= [Gtk2Diet::CRASH_DIET_N.to_s,	:COUNTER_LABELS]
  PARAMETERS[:Base_Label]		= ['Base:',	font]
  PARAMETERS[:Base_Entry]		= [Gtk2Diet::BASE_DIET.to_s,	:COUNTER_LABELS]
  PARAMETERS[:BumpUp_Label]		= ['Bump:',	font]
  PARAMETERS[:BumpUp_Entry]		= [Gtk2Diet::BUMPUP_DIET.to_s,	:COUNTER_LABELS]
  PARAMETERS[:BumpUpN_Entry]		= [Gtk2Diet::BUMPUP_DIET_N.to_s,:COUNTER_LABELS]

end
end

