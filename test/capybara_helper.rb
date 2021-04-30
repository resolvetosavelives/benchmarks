module CapybaraHelper
  ##
  # usage: select_from_chosen('Option', from: 'id_of_field')
  #   example, Get Started form: select_from_chosen('Armenia', from: 'get_started_form_country_id')
  def select_from_chosen(item_text, options)
    field = find_field(options[:from], visible: false)
    find("##{field[:id]}_chosen").click
    find("##{field[:id]}_chosen ul.chosen-results li", text: item_text).click
  end

  # Someday Ferrum will have a better way to handle that pending connection issue.
  # For now, this prevents system tests from flaking on that particular error.
  def retry_on_pending_connection
    retries = 0

    begin
      yield
    rescue Ferrum::PendingConnectionsError
      retries += 1
      unless retries > 3
        puts "Ferrum failed with PendingConnectionsError, retrying. (Retry ##{retries})"
        retry
      end
    end
  end
end
