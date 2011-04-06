module Gtk2Diet
  FOODS_FILE = Gtk2AppLib::USERDIR + '/foods.txt'
  ROWS_FILE = Gtk2AppLib::USERDIR + '/data_rows.txt'
end

module Gtk2AppLib
module Configuration

  # Application Menu
  MENU[:help] = '_Help'
  MENU[:dock] = '_Dock'	if !HILDON

  PARAMETERS[:Weight_Component]		= ['Weight']
  PARAMETERS[:Configuration_Component]	= ['Configuration']

  PARAMETERS[:Count_Label]		= ["AAA"]
  PARAMETERS[:Weight_Label]		= ["BBB"]
  PARAMETERS[:Configuration_Label]	= ["CCC"]

  PARAMETERS[:DELETE]	= ['Delete this row?']

  # Counter Page Configuration
  OPTIONS[:COUNTER_LABELS]		= { :width_request=	=> 90, }
  PARAMETERS[:CounterPage_Component]	= ['Counter']
  PARAMETERS[:Label_Label]		= ['Label',	:COUNTER_LABELS]
  PARAMETERS[:Calorie_Label]		= ['Calories',	:COUNTER_LABELS]
  PARAMETERS[:Protein_Label]		= ['Protein',	:COUNTER_LABELS]
  PARAMETERS[:VitA_Label]		= ['Vitamin A',	:COUNTER_LABELS]
  PARAMETERS[:VitC_Label]		= ['Vitamin C',	:COUNTER_LABELS]
  PARAMETERS[:Calcium_Label]		= ['Calcium',	:COUNTER_LABELS]
  PARAMETERS[:Iron_Label]		= ['Iron',	:COUNTER_LABELS]
  PARAMETERS[:TimeStamp_Label]		= ['Timestamp',	:COUNTER_LABELS]
  PARAMETERS[:Counter_Labels]		= ['',		:COUNTER_LABELS]
  PARAMETERS[:Counter_SpinButtons]	= [[],		:COUNTER_LABELS, {:set_range  => [0,1000]}]
  PARAMETERS[:Counter_Button]		= ['Add',	:COUNTER_LABELS, 'clicked']
  # Note that PARAMETERS[:Counter_ComboBoxEntries][0] is set to Gtk2Diet.foods in lib/gtk2diet.rb
  PARAMETERS[:Counter_ComboBoxEntries]	= [nil,		:COUNTER_LABELS, 'changed']

end
end

