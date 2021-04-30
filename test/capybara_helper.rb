module CapybaraHelper
  ##
  # usage: select_from_chosen('Option', from: 'id_of_field')
  #   example, Get Started form: select_from_chosen('Armenia', from: 'get_started_form_country_id')
  def select_from_chosen(item_text, options)
    field = find_field(options[:from], visible: false)
    find("##{field[:id]}_chosen").click
    find("##{field[:id]}_chosen ul.chosen-results li", text: item_text).click
  end

  def retry_on_pending_connection
    retries = 0

    begin
      yield
    rescue Ferrum::PendingConnectionsError
      retries += 1
      retry unless retries > 3
    end
  end
end
