# TODO about Gtk2Diet
module Gtk2Diet

  # Gnome About Dialog Configuration
  ABOUT = {
	'name'		=> 'Ruby-Gnome Diet',
	'authors'	=> ['carlosjhr64@gmail.com'],
	'website'	=> 'https://sites.google.com/site/gtk2applib/home/gtk2applib-applications/diet',
	'website-label'	=> 'Home Page',
	'license'	=> 'GPL',
	'copyright'	=> '2011-04-04 11:44:08',
  }

  SHARED		= {}
  SHARED[:SUMMARY]	= []
  SHARED[:ENTRIES]	= []

  def self.define_notebook
    notebook, window, vbox, hbox =
	'Gtk2AppLib::Widgets::Notebook', 'Gtk2AppLib::Widgets::ScrolledWindow',
	'Gtk2AppLib::Widgets::VBox', 'Gtk2AppLib::Widgets::HBox'

    [	[:Notebook,	notebook,
	[:CounterPage_Component, :Targets_Component]],

	# Counter Page
	[:CounterPage,	window,	[:CounterBox_Component]],
	[:CounterBox,	vbox,	[:CounterHeader_Component]],

	[:CounterHeader,hbox,
	[:Label_Label,:Calorie_Label,:Protein_Label,:VitA_Label,:VitC_Label,:Calcium_Label,:Iron_Label,:TimeStamp_Label]],

	# Targets Page
	[:Targets,	window,	[:TargetsBox_Component]],
	[:TargetsBox,	vbox,	[:WeightRow_Component,:TargetRow_Component,:ParametersRow_Component]],
	[:WeightRow,	hbox,	[:Weight_SpinButton,:Dot_Label,:Fraction_SpinButton,:Weight_Button,:MmaWeight_Entry,]],
	[:TargetRow,	hbox,	[:Calories_Button,:Calories_Label]],
	[:ParametersRow,hbox,
		[:Target_Label,:Target_Entry,:Crash_Label,
		:Crash_Entry,:CrashN_Entry,:Base_Label,:Base_Entry,:BumpUp_Label,:BumpUp_Entry,:BumpUpN_Entry]],

    ].each do |klass,sklass,keys|
      # That's class, super class, and keys
      code = Gtk2AppLib::Component.define(klass,sklass,keys)
      eval( code )
    end
  end
  Gtk2Diet.define_notebook

  def self._load(foods, file=File.open(FOODS_FILE,'r'))
    file.each do |line|
      data = line.strip.split(/\s+/)
      label = data.shift
      foods[label] = data
    end
    file.close
  end

  FOODS = {}

  def self.load_foods
    Gtk2Diet._load(FOODS) if File.exist?(FOODS_FILE)
  end

  def self.foods
    FOODS.keys.sort{|one,two| one.downcase <=> two.downcase }
  end


  def self._open(filename)
    File.rename(filename,filename+'.bak') if File.exist?(filename)
    File.open(filename,'w')
  end

  def self.save_foods
    file = Gtk2Diet._open(FOODS_FILE)
    FOODS.each{|key,values| file.puts "#{key}\t#{values.join(' ')}" }
    file.close
  end

  def self.counter_row
    Gtk2AppLib::Widgets::HBox.new(SHARED[:CounterBox])
  end

  def self.summary
    row = Gtk2Diet.counter_row
    8.times do
      SHARED[:SUMMARY].push( Gtk2AppLib::Widgets::Label.new(:Counter_Labels, row) )
    end
  end

  def self.summary_sum(rows,index)
    sum = rows.inject(0.0){|sum,row| sum + row.children[index].label.to_f    }
    SHARED[:SUMMARY][index].text = sum.to_s
  end

  def self.delete(row)
    SHARED[:CounterBox].remove(row)
    row.destroy
  end

  def self.update_entries( entries=Gtk2Diet.entries, label=entries.first )
    if label.strip.length > 0 then
      insert = (FOODS[label])? false: true
      FOODS[label] = entries[1..6]
      return [Gtk2Diet.foods.find_index(label),label] if insert
    end
    return nil
  end

  def self.set_entries(label)
    if values = FOODS[label] then
      entries = SHARED[:ENTRIES]
      0.upto(5){|index| entries[index+1].value = values[index].to_f}
    end
  end

  def self.entries
    SHARED[:ENTRIES].map{|entry| (entry.kind_of?(Gtk::SpinButton))? entry.value.to_s : entry.active_text}
  end

  def self.row_line(row)
    row.children.map{|label| (label.kind_of?(Gtk::Label))? label.text: label.label}.join("\t")
  end

  # TODO about Gtk2Diet::CounterBox
  class CounterBox
    def _init
      SHARED[:CounterBox] = self
    end
  end

  # TODO about WeightRow
  class WeightRow
    def _init
      self.weight_button.is		= :Weight_Button
      SHARED[:MmaWeight_Entry]		= self.mmaweight_entry
      SHARED[:Weight_SpinButton]	= self.weight_spinbutton
      SHARED[:Fraction_SpinButton]	= self.fraction_spinbutton
      self.load if File.exist?(WEIGHTS_FILE)
    end

    def load
      mma = self.get_mma
      units = mma.to_i
      fraction = (0.5 + 10.0*(mma - units)).to_i
      self.mmaweight_entry.text = mma.to_s
      self.weight_spinbutton.value = units
      self.fraction_spinbutton.value = fraction
    end

    def get_mma
      mma = nil
      file = File.open(WEIGHTS_FILE)
      file.each do |line|
        if !(line=~/^\s*#/) then
          weight = line.to_f
          if weight > MAXDIFF then
            mma = (mma)? (weight + (MMA-1)*MMA)/MMA : weight
          end
        end
      end
      file.close
      mma
    end
  end

  # TODO about TargetRow
  class TargetRow
    def _init
      SHARED[:Calories_Label] = self.calories_label
      self.calories_button.is = :Calories_Button
    end
  end

  PARAMETERS_ENTRIES = [:Target_Entry,:Crash_Entry,:CrashN_Entry,:Base_Entry,:BumpUp_Entry,:BumpUpN_Entry]
  def self.save_parameters
    file = File.open(PARAMETERS_FILE,'w')
    file.puts PARAMETERS_ENTRIES.map{|key| SHARED[key].text}.join(' ')
    file.close
  end

  # TODO about ParametersRow
  class ParametersRow
    def _init
      SHARED[:Target_Entry]	= self.target_entry
      SHARED[:Crash_Entry]	= self.crash_entry
      SHARED[:CrashN_Entry]	= self.crashn_entry
      SHARED[:Base_Entry]	= self.base_entry
      SHARED[:BumpUp_Entry]	= self.bumpup_entry
      SHARED[:BumpUpN_Entry]	= self.bumpupn_entry
      self.load	if File.exist?(PARAMETERS_FILE)
    end

    def load
      data = nil
      File.open(PARAMETERS_FILE,'r'){|file| data = file.gets.strip.split(/\s+/)}
      self.target_entry.text	= data.shift
      self.crash_entry.text	= data.shift
      self.crashn_entry.text	= data.shift
      self.base_entry.text	= data.shift
      self.bumpup_entry.text	= data.shift
      self.bumpupn_entry.text	= data.shift
    end
  end

  # TODO about Gtk2Diet::App
  class App

    def initialize(program)
      @program = program
      program.window do |window|
        @window = window
        @combo_box_entry = nil # gets set in build
        self.build
        window.show_all
      end
    end

    def rows
      SHARED[:CounterBox]
    end

    def data_rows
      self.rows.children[3..-1]
    end

    def update_summary
      rows = self.data_rows
      1.upto(6){|index| Gtk2Diet.summary_sum(rows,index) }
    end

    def clear
      self.data_rows.each{|row| Gtk2Diet.delete(row)}
      self.update_summary
    end

    def restore
      self.clear
      self.append_data_rows
    end

    def delete(row)
      if Gtk2AppLib::DIALOGS.question?(:DELETE) then
        Gtk2Diet.delete(row)
        self.update_summary
      end
    end

    def insert_counter_row
      row = Gtk2Diet.counter_row
      rows = self.rows
      rows.reorder_child(row,3)
      row
    end

    def update_entries
      index_label = Gtk2Diet.update_entries
      @combo_box_entry.insert_text(*index_label) if index_label
    end

    def update
      self.update_summary
      self.update_entries
    end

    def append( entries=Gtk2Diet.entries, timestamp=Time.now.strftime('%H:%I:%M'), row=self.insert_counter_row )
      Gtk2AppLib::Widgets::Label.new( entries.first, :COUNTER_LABELS, row )
      1.upto(6){|index| Gtk2AppLib::Widgets::Label.new( entries[index], :COUNTER_LABELS, row ) }
      Gtk2AppLib::Widgets::Button.new( timestamp, :COUNTER_LABELS, row, 'clicked' ){ self.delete(row) }
      self.update
      row.show_all
    end

    def set_entries
      Gtk2Diet.set_entries( @combo_box_entry.active_text )
    end

    def appender_comboboxentry(row)
      Gtk2Diet.load_foods
      Gtk2AppLib::Configuration::PARAMETERS[:Counter_ComboBoxEntries][0] = Gtk2Diet.foods
      @combo_box_entry = Gtk2AppLib::Widgets::ComboBoxEntry.new(:Counter_ComboBoxEntries, row){ self.set_entries }
    end

    def appender( row=Gtk2Diet.counter_row, entries=SHARED[:ENTRIES] )
      self.appender_comboboxentry(row)
      entries.push( @combo_box_entry )
      6.times do
        entries.push( Gtk2AppLib::Widgets::SpinButton.new(:Counter_SpinButtons, row) )
      end
      Gtk2AppLib::Widgets::Button.new(:Counter_Button, row){ self.append }
    end

    def save_data_rows
      file = Gtk2Diet._open(ROWS_FILE)
      self.data_rows.each do |row|
        file.puts Gtk2Diet.row_line(row)
      end
      file.close
    end

    def save
      Gtk2Diet.save_foods
      self.save_data_rows
      Gtk2Diet.save_parameters
    end

    def _append_data_rows(file)
      file.each do |line|
        entries = line.strip.split(/\s+/)
        timestamp = entries.pop
        self.append(entries,timestamp)
      end
    end

    def append_data_rows
      File.open(ROWS_FILE,'r'){|file| self._append_data_rows(file) } if File.exist?(ROWS_FILE)
    end

    def _build
      Gtk2Diet.summary
      self.appender
      self.append_data_rows
    end

    def _clear
      self.save_data_rows
      self.clear
    end

    def _build_app_menu
      @program.append_app_menu('_Save'){ self.save_data_rows }
      @program.append_app_menu('_Restore'){ self.restore }
      @program.append_app_menu('_Clear'){ self._clear }
    end

    def calories_button
      target = SHARED[:Target_Entry].text.to_f
      mma = SHARED[:MmaWeight_Entry].text.to_f
      diff = mma - target
      calories = nil
      if diff > 0 then
        calories = (BASE_DIET - (BASE_DIET - CRASH_DIET) * diff / CRASH_DIET_N).to_i
        calories = CRASH_DIET if calories < CRASH_DIET
      else
        calories = (BASE_DIET + (BASE_DIET - BUMPUP_DIET) * diff / BUMPUP_DIET_N).to_i
      end
      SHARED[:Calories_Label].text = calories.to_s
    end

    def weight_button
      weight = SHARED[:Weight_SpinButton].value.to_f + (SHARED[:Fraction_SpinButton].value.to_f / 10.0)
      if weight > MAXDIFF then
        File.open(WEIGHTS_FILE,'a') do |file|
          file.puts "# #{Time.now}"
          file.puts weight
        end
        mma = SHARED[:MmaWeight_Entry].text.to_f
        mma = weight if (weight - mma).abs > MAXDIFF # an obvious skip, re-initialize
        mma = (weight + (MMA-1.0)*mma)/MMA
        mma = (100.0*mma + 0.5).to_i / 100.0
        SHARED[:MmaWeight_Entry].text = mma.to_s
        self.calories_button
      end
    end

    def build
      self._build_app_menu
      @window.signal_connect('destroy'){ self.save }
      Notebook.new(@window) do |is,signal,*emits|
        case is
        when :Weight_Button then self.weight_button
        when :Calories_Button then self.calories_button
        end
      end
      self._build
    end

  end
end
