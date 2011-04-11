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

  # GUI defined in appconfig
  GUI.each do |klass,sklass,keys|
    # That's class, super class, and keys
    code = Gtk2AppLib::Component.define(klass,sklass,keys)
    eval( code )
  end

  # TODO about WeightRow
  class WeightRow
    def _init
      self.load
    end

    def load
      mma = (File.exist?(WEIGHTS_FILE))? self.get_mma : WEIGHT
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

  # TODO about ParametersRow
  class ParametersRow
    def _init
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

  def self._load_key_values(foods, file=File.open(FOODS_FILE,'r'))
    file.each do |line|
      data = line.strip.split(/\s+/)
      label = data.shift
      foods[label] = data
    end
    file.close
  end

  FOODS = {}

  def self.load_foods
    Gtk2Diet._load_key_values(FOODS) if File.exist?(FOODS_FILE)
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

  def self.row_line(row)
    row.children.map{|label| (label.kind_of?(Gtk::Label))? label.text: label.label}.join("\t")
  end

  # TODO about Gtk2Diet::App
  class App

    def initialize(program)
      @summary = []
      @entries = []
      @program = program
      program.window do |window|
        @window = window
        @combo_box_entry = nil # gets set in build
        self.build
        window.show_all
      end
    end

    def _update_entries( entries=self._entries, label=entries.first )
      if label.strip.length > 0 then
        insert = (FOODS[label])? false: true
        FOODS[label] = entries[1..-1]
        return [Gtk2Diet.foods.find_index(label),label] if insert
      end
      return nil
    end

    def _entries
      @entries.map{|entry| (entry.kind_of?(Gtk::SpinButton))? entry.value.to_s : entry.active_text}
    end

    def _set_entries(label)
      if values = FOODS[label] then
        1.upto(N2){|index| @entries[index].value = values[index-1].to_f}
      end
    end

    def summary_sum(rows,index)
      sum = rows.inject(0.0){|sum,row| sum + row.children[index].label.to_f    }
      @summary[index].text = sum.to_s
    end

    def _weight
      @notebook[:weight_spinbutton].value.to_f + (@notebook[:fraction_spinButton].value.to_f / 10.0)
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

    def _delete(row)
      @notebook[:counterbox_component].remove(row)
      row.destroy
    end

    def rows
      @notebook[:counterbox_component]
    end

    def data_rows
      self.rows.children[3..-1]
    end

    def update_summary
      rows = self.data_rows
      2.upto(N1){|index| self.summary_sum(rows,index) }
    end

    def clear
      self.data_rows.each{|row| self._delete(row)}
      self.update_summary
    end

    def restore
      self.clear
      self.append_data_rows
    end

    def delete(row)
      if Gtk2AppLib::DIALOGS.question?(:DELETE) then
        self._delete(row)
        self.update_summary
      end
    end

    def counter_row
      Gtk2AppLib::Widgets::HBox.new( @notebook[:counterbox_component] )
    end

    def insert_counter_row
      row = self.counter_row
      rows = self.rows
      rows.reorder_child(row,3)
      row
    end

    def update_entries
      index_label = self._update_entries
      @combo_box_entry.insert_text(*index_label) if index_label
    end

    def update
      self.update_summary
      self.update_entries
    end

    def append( entries=self._entries, timestamp=Time.now.strftime('%H:%I:%M'), row=self.insert_counter_row )
      Gtk2AppLib::Widgets::Button.new( timestamp, row, :COUNTER_NARROW, FONT, 'clicked'){ self.delete(row) }
      Gtk2AppLib::Widgets::Label.new( entries.shift, row, :COUNTER_WIDE )
      entries.each{|entry| Gtk2AppLib::Widgets::Label.new( entry, row, :COUNTER_NARROW )}
      self.update
      row.show_all
    end

    def set_entries
      self._set_entries( @combo_box_entry.active_text )
    end

    def appender_comboboxentry(row)
      Gtk2Diet.load_foods
      Gtk2AppLib::Configuration::PARAMETERS[:Counter_ComboBoxEntries][0] = Gtk2Diet.foods
      @combo_box_entry = Gtk2AppLib::Widgets::ComboBoxEntry.new(:Counter_ComboBoxEntries, row){ self.set_entries }
    end

    def appender( row=self.counter_row, entries=@entries )
      Gtk2AppLib::Widgets::Button.new(:Counter_Button, row){ self.append }
      self.appender_comboboxentry(row)
      entries.push( @combo_box_entry )
      (N2).times do
        entries.push( Gtk2AppLib::Widgets::SpinButton.new(:Counter_SpinButtons, row) )
      end
    end

    def save_data_rows
      file = Gtk2Diet._open(ROWS_FILE)
      self.data_rows.reverse.each do |row|
        file.puts Gtk2Diet.row_line(row)
      end
      file.close
    end

    PARAMETERS_ENTRIES = [:target_entry,:crash_entry,:crashn_entry,:base_entry,:bumpup_entry,:bumpupn_entry]
    def save_parameters
      file = File.open(PARAMETERS_FILE,'w')
      file.puts PARAMETERS_ENTRIES.map{|key| @notebook[key].text}.join(' ')
      file.close
    end

    def save
      Gtk2Diet.save_foods
      self.save_data_rows
      self.save_parameters
    end

    def _append_data_rows(file)
      file.each do |line|
        entries = line.strip.split(/\s+/)
        timestamp = entries.shift
        self.append(entries,timestamp)
      end
    end

    def append_data_rows
      File.open(ROWS_FILE,'r'){|file| self._append_data_rows(file) } if File.exist?(ROWS_FILE)
    end

    def summary
      row = self.counter_row
      COUNTER_LABELS.each do |key,label|
        key = (key == :Label_Label)? :Counter_Wide : :Counter_Narrow
        @summary.push( Gtk2AppLib::Widgets::Label.new(key, row) )
      end
    end

    def _build
      self.summary
      self.appender
      self.append_data_rows
    end

    def save_n_clear
      self.save_data_rows
      self.clear
    end

    def edit_help
      filename = Gtk2AppLib::UserSpace.readme
      text0 = (File.exist?(filename))? IO.read(filename): ''
      if text1 = Gtk2AppLib::DIALOGS.text_view(text0, :HELP_TEXT_VIEW) then
        File.open(filename,'w'){|file| file.puts text1}	if text1 != text0
      end
    end

    def _build_app_menu
      @program.append_app_menu(Gtk::SeparatorMenuItem.new)
      @program.append_app_menu(APPEND_APP_MENU){|meth| self.method(meth).call}
    end

    def target_calories
      calories = self._target_calories( self._weight )
      label = "#{calories}.  Stages:"
      calories = self._target_calories
      1.upto(STAGES){|i| label += " #{(calories*(i.to_f/STAGES.to_f)).to_i},"}
      @notebook[:targetcalories_label].text = label.chop + '. '
    end

    def weight_button
      weight = self._weight
      if weight > MAXDIFF then
        File.open(WEIGHTS_FILE,'a') do |file|
          file.puts "# #{Time.now}"
          file.puts weight
        end
        mma = @notebook[:mmaweight_entry].text.to_f
        mma = weight if (weight - mma).abs > MAXDIFF # an obvious skip, re-initialize
        mma = (weight + (MMA-1.0)*mma)/MMA
        mma = (100.0*mma + 0.5).to_i / 100.0
        @notebook[:mmaWeight_entry].text = mma.to_s
        self.target_calories
      end
    end

    def build
      self._build_app_menu
      @window.signal_connect('destroy'){ self.save }
      @notebook = Notebook.new(@window) do |is,signal,*emits|
        case is
        when @notebook[:weight_button]		then self.weight_button
        when @notebook[:targetcalories_button]	then self.target_calories
        end
      end
      self._build
    end

  end
end
