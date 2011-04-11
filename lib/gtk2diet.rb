# TODO about Gtk2Diet
module Gtk2Diet

  # Gnome About Dialog Configuration
  ABOUT = {
	'name'		=> 'Ruby-Gnome Diet',
	'authors'	=> ['carlosjhr64@gmail.com'],
	'website'	=> 'https://sites.google.com/site/gtk2applib/home/gtk2applib-applications/gtk2diet',
	'website-label'	=> 'Home Page',
	'license'	=> 'GPL',
	'copyright'	=> '2011-04-07 16:13:40',
  }

  GUI.each do |klass,sklass,keys|
    # That's class, super class, and keys
    code = Gtk2AppLib::Component.define(klass,sklass,keys)
    eval( code )
  end

  # STATELESS FUNCTIONS

  # get_mma interpretes each non-comment line from a file as a Float and
  # computes the modified moving average.
  #
  # @param [String] filename
  # @param [Float] n mma number
  # @return [Float] mma
  def self.get_mma(filename,n)
    mma = nil
    file = File.open(filename)
     file.each do |line|
      if !(line=~/^\s*#/) then
        weight = line.to_f
        mma = (mma)? (weight + (n-1)*mma)/n : weight
      end
    end
    file.close
    mma
  end

  # load_key_values reads a file
  # interprets the firts word in each line as a key
  # and subsequent words as values.
  #
  # @param [Hash] hash
  # @param [String] filename
  def self.load_key_values(hash, filename)
    file = File.new(filename,'r')
    file.each do |line|
      data = line.strip.split(/\s+/)
      label = data.shift
      hash[label] = data
    end
    file.close
  end

  # open is like File.open, except no block and
  # it moves filename to filename.bak if it pre-exists.
  #
  # @param [String] filename
  def self.open(filename)
    File.rename(filename,filename+'.bak') if File.exist?(filename)
    File.open(filename,'w')
  end

  # row_line is a String dump of the labels in row
  #
  # @param [Gtk::HBox] row
  # @return [String]
  def self.row_line(row)
    row.children.map{|label| (label.kind_of?(Gtk::Label))? label.text: label.label}.join("\t")
  end

  # CLASSES

  # Foods is a Hash of food labels and their nutritional values
  class Foods < Hash # Foods defined

    # load reads the key values from FOOD_FILE
    def load
      Gtk2Diet.load_key_values(self,FOODS_FILE)
    end

    def initialize
      super
      load	if File.exist?(FOODS_FILE)
    end

    # sorted_keys returns the sorted food labels
    #
    # @return [Hash] food labels
    def sorted_keys
      self.keys.sort{|one,two| one.downcase <=> two.downcase }
    end

    # save saves the key values into FOODS_FILE
    def save
      file = Gtk2Diet.open(FOODS_FILE)
      self.each{|key,values| file.puts "#{key}\t#{values.join(' ')}" }
      file.close
    end
  end


  # TODO about Gtk2Diet::App
  class App

    def initialize(program)
      @program = program
      @notebook = @combo_box_entry = nil # gets set later
      @foods = Foods.new
      @summary = []
      @entries = []
      program.window do |window|
        @window = window
        self.build # defined way down below
        window.show_all
      end
    end

    def rows
      @notebook[:counterbox_component]
    end

    def data_rows
      rows.children[3..-1]
    end

    def summary_sum(rows,index)
      sum = rows.inject(0.0){|sum,row| sum + row.children[index].label.to_f    }
      @summary[index].text = sum.to_s
    end

    def update_summary
      rows = data_rows
      2.upto(N1){|index| summary_sum(rows,index) }
    end

    def _delete(row)
      @notebook[:counterbox_component].remove(row)
      row.destroy
    end

    def clear
      data_rows.each{|row| _delete(row)}
      update_summary
    end

    def _entries
      @entries.map{|entry| (entry.kind_of?(Gtk::SpinButton))? entry.value.to_s : entry.active_text}
    end

    def counter_row
      Gtk2AppLib::Widgets::HBox.new( @notebook[:counterbox_component] )
    end

    def insert_counter_row
      row = counter_row
      rows.reorder_child(row,3)
      row
    end

    def delete(row)
      if Gtk2AppLib::DIALOGS.question?(:DELETE) then
        _delete(row)
        update_summary
      end
    end

    def _update_entries( entries=_entries, label=entries.first )
      if label.strip.length > 0 then
        insert = (@foods[label])? false: true
        @foods[label] = entries[1..-1]
        return [@foods.sorted_keys.find_index(label),label] if insert
      end
      return nil
    end

    def update_entries
      index_label = _update_entries
      @combo_box_entry.insert_text(*index_label) if index_label
    end

    def update
      update_summary
      update_entries
    end

    def append( entries=_entries, timestamp=Time.now.strftime('%H:%I:%M'), row=insert_counter_row )
      Gtk2AppLib::Widgets::Button.new( timestamp, row, :COUNTER_NARROW, FONT, 'clicked'){ delete(row) }
      Gtk2AppLib::Widgets::Label.new( entries.shift, row, :COUNTER_WIDE )
      entries.each{|entry| Gtk2AppLib::Widgets::Label.new( entry, row, :COUNTER_NARROW )}
      update
      row.show_all
    end

    def _append_data_rows(file)
      file.each do |line|
        entries = line.strip.split(/\s+/)
        timestamp = entries.shift
        append(entries,timestamp)
      end
    end

    def append_data_rows
      File.open(ROWS_FILE,'r'){|file| _append_data_rows(file) } if File.exist?(ROWS_FILE)
    end

    def restore
      clear
      append_data_rows
    end

    def save_data_rows
      file = Gtk2Diet.open(ROWS_FILE)
      data_rows.reverse.each do |row|
        file.puts Gtk2Diet.row_line(row)
      end
      file.close
    end

    PARAMETERS_ENTRIES = [:target_entry,:crash_entry,:crashn_entry,:base_entry,:bumpup_entry,:bumpupn_entry]
    def save_parameters
      file = Gtk2Diet.open(PARAMETERS_FILE)
      file.puts PARAMETERS_ENTRIES.map{|key| @notebook[key].text}.join(' ')
      file.close
    end

    def save
      @foods.save
      save_data_rows
      save_parameters
    end

    def save_n_clear
      save_data_rows
      clear
    end

    def edit_help
      filename = Gtk2AppLib::UserSpace.readme
      text0 = (File.exist?(filename))? IO.read(filename): ''
      if text1 = Gtk2AppLib::DIALOGS.text_view(text0, :HELP_TEXT_VIEW) then
        if text1 != text0 then
          file = Gtk2Diet.open(filename)
          file.puts text1
          file.close
        end
      end
    end

    def init_parameters
      data = nil
      File.open(PARAMETERS_FILE,'r'){|file| data = file.gets.strip.split(/\s+/)}
      @notebook[:target_entry].text	= data.shift
      @notebook[:crash_entry].text	= data.shift
      @notebook[:crashn_entry].text	= data.shift
      @notebook[:base_entry].text	= data.shift
      @notebook[:bumpup_entry].text	= data.shift
      @notebook[:bumpupn_entry].text	= data.shift
    end

    def init_weights
      mma = (File.exist?(WEIGHTS_FILE))? Gtk2Diet.get_mma(WEIGHTS_FILE,MMA) : WEIGHT
      units = mma.to_i
      fraction = (0.5 + 10.0*(mma - units)).to_i
      @notebook[:mmaweight_entry].text = mma.to_s
      @notebook[:weight_spinbutton].value = units
      @notebook[:fraction_spinbutton].value = fraction
    end

    def _set_entries(label)
      if values = @foods[label] then
        1.upto(N2){|index| @entries[index].value = values[index-1].to_f}
      end
    end

    def set_entries
      _set_entries( @combo_box_entry.active_text )
    end

    def appender_comboboxentry(row)
      Gtk2AppLib::Configuration::PARAMETERS[:Counter_ComboBoxEntries][0] = @foods.sorted_keys
      @combo_box_entry = Gtk2AppLib::Widgets::ComboBoxEntry.new(:Counter_ComboBoxEntries, row){ set_entries }
    end

    def appender( row=counter_row, entries=@entries )
      Gtk2AppLib::Widgets::Button.new(:Counter_Button, row){ append }
      appender_comboboxentry(row)
      entries.push( @combo_box_entry )
      (N2).times do
        entries.push( Gtk2AppLib::Widgets::SpinButton.new(:Counter_SpinButtons, row) )
      end
    end

    def summary
      row = counter_row
      COUNTER_LABELS.each do |key,label|
        key = (key == :Label_Label)? :Counter_Wide : :Counter_Narrow
        @summary.push( Gtk2AppLib::Widgets::Label.new(key, row) )
      end
    end

    def build_details
      summary
      appender
      append_data_rows
      init_weights
      init_parameters	if File.exist?(PARAMETERS_FILE)
    end

    def _target_calories( mma=@notebook[:mmaweight_entry].text.to_f, target=@notebook[:target_entry].text.to_f )
      diff = mma - target
      calories = nil
      if diff > 0 then
        calories = (BASE_DIET - (BASE_DIET - CRASH_DIET) * diff / CRASH_DIET_N).to_i
        calories = CRASH_DIET if calories < CRASH_DIET
      else
        calories = (BASE_DIET + (BASE_DIET - BUMPUP_DIET) * diff / BUMPUP_DIET_N).to_i
      end
      calories
    end

    def _weight
      @notebook[:weight_spinbutton].value.to_f + (@notebook[:fraction_spinbutton].value.to_f / 10.0)
    end

    def target_calories
      calories = _target_calories( _weight )
      label = "#{calories}.  Stages:"
      calories = _target_calories
      1.upto(STAGES){|i| label += " #{(calories*(i.to_f/STAGES.to_f)).to_i},"}
      @notebook[:targetcalories_label].text = label.chop + '. '
    end

    def weight_button
      weight = _weight
      File.open(WEIGHTS_FILE,'a') do |file|
        file.puts "# #{Time.now}"
        file.puts weight
      end
      mma = @notebook[:mmaweight_entry].text.to_f
      mma = (weight + (MMA-1.0)*mma)/MMA
      mma = (100.0*mma + 0.5).to_i / 100.0
      @notebook[:mmaWeight_entry].text = mma.to_s
      target_calories
    end

    def build_notebook
      @notebook = Notebook.new(@window) do |is,signal,*emits|
        case is
        when @notebook[:weight_button]		then weight_button
        when @notebook[:targetcalories_button]	then target_calories
        end
      end
    end

    def build_app_menu
      @program.append_app_menu(Gtk::SeparatorMenuItem.new)
      @program.append_app_menu(APPEND_APP_MENU){|meth| self.method(meth).call}
    end

    def build
      build_app_menu
      build_notebook
      build_details
      self.signal_connects # defined below
    end

    def signal_connects
      @window.signal_connect('destroy'){ save }
    end

  end
end
