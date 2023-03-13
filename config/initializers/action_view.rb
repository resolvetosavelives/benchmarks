# taken from https://stackoverflow.com/a/5268106
# to workaround Rails wrapping validation-error fields with a DIV
# which does not work well with Bootstrap CSS.
# this simply leaves the HTML tag unchanged by Rails.
ActionView::Base.field_error_proc = Proc.new { |html_tag, instance| html_tag }
