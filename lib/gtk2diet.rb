
# Adding round_two to Float to ensure 1.8 and 1.9 consistent
class Float
  def round_two
    half_step = (self>0.0)? 0.5: -0.5
    (half_step + 100.0*self).to_i/100.0
  end
end

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

  # load_key_values reads a file
  # interprets the firts word in each line as a key
  # and subsequent words as values.
  #
  # @param [Hash] hash
  # @param [String] filename
  def self.load_key_values(hash, filename)
    File.foreach(filename) do |line|
      data = line.strip.split(/\s+/)
      label = data.shift
      hash[label] = data
    end
  end

  # open is like File.open, except
  # it moves filename to filename.bak if it pre-exists.
  #
  # @param [String] filename
  def self.open(filename,&block)
    File.rename(filename,filename+'.bak') if File.exist?(filename)
    File.open(filename,'w',&block)
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

  # Entries is an Array to hold entries
  class Entries < Array # Entries defined
    def initialize
      super
    end

    def self.values(entries)
      entries.map{|entry| (entry.kind_of?(Gtk::SpinButton))? entry.value.to_s : entry.active_text}
    end

    def values
      Entries.values(self)
    end
  end

  class Summary < Array # Summary defined
    def initialize
      super
    end

    def populate(row)
      COUNTER_LABELS.each do |key,label|
        key = (key == :Label_Label)? :Counter_Wide : :Counter_Narrow
        self.push( Gtk2AppLib::Widgets::Label.new(key, row) )
      end
    end

    def _sum(rows,index)
      self[index].text = rows.inject(0.0){|sum,row| sum + row.children[index].label.to_f }.to_s
    end

    #def update_summary(rows)
    def update(rows)
      2.upto(N1){|index| _sum(rows,index) }
    end
  end

  # TODO about Gtk2Diet::App
  class App # App defined

    def initialize(program)
      @program	= program
      @notebook	= @combo_box_entry = nil # gets set later
      @foods	= Foods.new
      @summary	= Summary.new
      @entries	= Entries.new
      program.window do |window|
        @window	= window
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

    def _delete(row)
      @notebook[:counterbox_component].remove(row)
      row.destroy
    end

    def clear
      rows = data_rows
      rows.each{|row| _delete(row)}
      @summary.update(rows)
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
        @summary.update(data_rows)
      end
    end

    def _update_entries( entries=@entries.values, label=entries.first )
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
      @summary.update(data_rows)
      update_entries
    end

    def append( entries=@entries.values, timestamp=Time.now.strftime('%H:%I:%M'), row=insert_counter_row )
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

    # row_line is a String dump of the labels in row
    #
    # @param [Gtk::HBox] row
    # @return [String]
    def self.row_line(row)
      row.children.map{|label| (label.kind_of?(Gtk::Label))? label.text: label.label}.join("\t")
    end

    def self.save_data_rows(rows)
      file = Gtk2Diet.open(ROWS_FILE)
      rows.each do |row|
        file.puts App.row_line(row)
      end
      file.close
    end

    def save_data_rows
      App.save_data_rows(data_rows.reverse)
    end

    PARAMETERS_ENTRIES = [:target_entry,:crash_entry,:crashn_entry,:base_entry,:bumpup_entry,:bumpupn_entry]
    def self.save_parameters(notebook)
      file = Gtk2Diet.open(PARAMETERS_FILE)
      file.puts PARAMETERS_ENTRIES.map{|key| notebook[key].text}.join(' ')
      file.close
    end

    def save_parameters
      App.save_parameters(@notebook)
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

    def init_parameters
      data = nil
      File.open(PARAMETERS_FILE,'r'){|file| data = file.gets.strip.split(/\s+/)}
      [	:target_entry,
	:crash_entry,
	:crashn_entry,
	:base_entry,
	:bumpup_entry,
	:bumpupn_entry].each{|key| @notebook[key].text = data.shift}
    end

    def self.mma(float,mma=nil,number=MMA)
      (mma.nil?)? float : (float + (number-1)*mma)/number
    end

    # get_mma interpretes each non-comment line from a file as a Float and
    # computes the modified moving average.
    #
    # @param [String] filename
    # @param [Float] number (of days?)
    # @return [Float] mma
    def self.get_mma(filename,number=MMA)
      File.foreach(filename).select{|line| line !~ /^\s*#/ }.inject(nil) do |mma,line|
        float = line.to_f
        App.mma(float,mma,number)
      end
    end

    def self.init_weights
      mma = (File.exist?(WEIGHTS_FILE))? App.get_mma(WEIGHTS_FILE,MMA) : WEIGHT
      return mma, mma.to_i
    end

    def init_weights
      mma,units = App.init_weights
      @notebook[:mmaweight_entry].text = mma.round_two.to_s
      @notebook[:weight_spinbutton].value = units
      @notebook[:fraction_spinbutton].value = (0.5 + 10.0*(mma - units)).to_i
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

    def appender( row=counter_row )
      Gtk2AppLib::Widgets::Button.new(:Counter_Button, row){ append }
      appender_comboboxentry(row)
      @entries.push( @combo_box_entry )
      (N2).times do
        @entries.push( Gtk2AppLib::Widgets::SpinButton.new(:Counter_SpinButtons, row) )
      end
    end

    def build_details
      @summary.populate( counter_row )
      appender
      append_data_rows
      init_weights
      init_parameters	if File.exist?(PARAMETERS_FILE)
    end

    def _weight
      @notebook[:weight_spinbutton].value.to_f + (@notebook[:fraction_spinbutton].value.to_f / 10.0)
    end

    def self.target_calories( diff )
      if diff > 0 then
        calories = (BASE_DIET - (BASE_DIET - CRASH_DIET) * diff / CRASH_DIET_N).to_i
        calories = CRASH_DIET if calories < CRASH_DIET
        return calories
      end
      return (BASE_DIET + (BASE_DIET - BUMPUP_DIET) * diff / BUMPUP_DIET_N).to_i
    end

    def target_calories
      target = @notebook[:target_entry].text.to_f
      label = "#{ App.target_calories( _weight - target ) }.  Stages:"
      calories = App.target_calories( @notebook[:mmaweight_entry].text.to_f - target )
      1.upto(STAGES){|stage| label += " #{(calories*(stage.to_f/STAGES.to_f)).to_i},"}
      @notebook[:targetcalories_label].text = label.chop + '. '
    end

    def self.append_weight(weight)
      File.open(WEIGHTS_FILE,'a') do |file|
        file.puts "# #{Time.now}"
        file.puts weight
      end
    end

    def weight_button
      weight = _weight
      App.append_weight(weight)
      mmaweight_entry = @notebook[:mmaweight_entry]
      mmaweight_entry.text = App.mma( weight, mmaweight_entry.text.to_f, MMA ).round_two.to_s
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
      # APPEND_APP_MENU has :save_data_rows, :restore, :save_n_clear, :edit_help
      @program.append_app_menu(APPEND_APP_MENU){|meth| self.method(meth).call}
    end

    def edit_help
      App.edit_help
    end

    def self.edit_help
      filename = Gtk2AppLib::UserSpace.readme
      text = (File.exist?(filename))? IO.read(filename): ''
      if edited = Gtk2AppLib::DIALOGS.text_view(text, :HELP_TEXT_VIEW) then
        if edited != text then
          Gtk2Diet.open(filename){|file| file.puts edited}
        end
      end
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
