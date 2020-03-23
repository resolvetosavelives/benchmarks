# This is a convenience structure that makes it easier to create a
# SpreadsheetCell in a declarative way.

require "rubyXL/convenience_methods"

class SpreadsheetCell
  def initialize(worksheet, row, col, params)
    text = params[:text]
    formula = params[:formula]
    raise ArgumentError if text && formula

    if text
      @cell = worksheet.add_cell(row, col, text)
      @cell.change_text_wrap true
      @cell.change_vertical_alignment "top"
    elsif formula
      @cell = worksheet.add_cell(row, col, "", formula)
      @cell.change_text_wrap true
      @cell.change_vertical_alignment "top"
    else
      @cell = worksheet[row][col]
      @cell = worksheet.add_cell(row, col) unless @cell
    end
  end

  def text
    @cell.value
  end

  def formula
    @cell.formula
  end

  def address
    [@cell.row, @cell.index_in_collection]
  end

  def with_text(text)
    @cell.raw_value = text
    self
  end

  def with_formula(f)
    @cell.formula = f
    self
  end

  def with_font_color(color)
    @cell.change_font_color color
    self
  end

  def with_font_size(size)
    @cell.change_font_size size
    self
  end

  def with_fill_color(color)
    @cell.change_fill color
    self
  end

  # Valid values:
  # nil -- defaults, usually to the left and to the bottom of the cell
  # center
  def with_alignment(horizontal, vertical)
    @cell.change_horizontal_alignment horizontal
    @cell.change_vertical_alignment vertical
    self
  end

  def with_border(*args)
    if args.include? :all
      borders = %i[top bottom left right]
    else
      borders = args
    end

    %i[top bottom left right].each do |border|
      @cell.change_border(border, "thin") if borders.include? border
    end
    self
  end
end

# This is a list of methods on a cell. It is convenient to have it here so we
# can easily search it when looking to add a new feature.
#
#  => [:row, :style_index, :datatype, :vm, :ph, :value_container, :worksheet,
#  :row=, :worksheet=, :value_container=, :get_cell_xf, :raw_value=,
#  :get_cell_font, :get_cell_border, :number_format, :is_date?, :is,
#  :index_in_collection, :column, :raw_value, :formula, :inspect,
#  :style_index=, :r, :cm, :datatype=, :cm=, :vm=, :column=, :ph=, :value,
#  :formula=, :r=, :is=, :change_font_name, :change_font_size,
#  :change_font_color, :change_font_italics, :change_fill,
#  :change_font_underline, :font_name, :change_font_strikethrough, :font_size,
#  :change_font_bold, :font_switch, :is_underlined, :text_rotation,
#  :change_contents, :get_border, :get_border_color,
#  :change_horizontal_alignment, :change_vertical_alignment, :change_text_wrap,
#  :change_text_rotation, :change_text_indent, :is_italicized, :is_bolded,
#  :is_struckthrough, :fill_color, :horizontal_alignment, :vertical_alignment,
#  :text_wrap, :text_indent, :set_number_format, :change_border, :font_color,
#  :change_border_color, :workbook, :write_xml, :local_namespaces=, :==,
#  :local_namespaces, :before_write_xml, :to_json, :instance_values,
#  :instance_variable_names, :with_options, :as_json, :`, :present?, :presence,
#  :to_yaml, :acts_like?, :blank?, :in?, :to_param, :presence_in, :to_query,
#  :duplicable?, :deep_dup, :html_safe?, :pretty_print_inspect, :pretty_print,
#  :pretty_print_cycle, :pretty_print_instance_variables, :try, :try!,
#  :load_dependency, :unloadable, :require_or_load, :require_dependency,
#  :instance_variable_defined?, :remove_instance_variable, :instance_of?,
#  :kind_of?, :is_a?, :tap, :instance_variable_get, :instance_variable_set,
#  :protected_methods, :instance_variables, :private_methods, :method,
#  :public_method, :public_send, :singleton_method, :class_eval,
#  :define_singleton_method, :extend, :pretty_inspect, :to_enum, :enum_for,
#  :<=>, :===, :=~, :!~, :gem, :eql?, :respond_to?, :byebug, :remote_byebug,
#  :debugger, :freeze, :object_id, :send, :to_s, :display, :class, :nil?,
#  :hash, :dup, :singleton_class, :clone, :then, :itself, :yield_self,
#  :untaint, :taint, :tainted?, :trust, :untrust, :untrusted?,
#  :singleton_methods, :frozen?, :methods, :public_methods, :equal?, :!,
#  :instance_exec, :!=, :instance_eval, :__id__, :__send__]
